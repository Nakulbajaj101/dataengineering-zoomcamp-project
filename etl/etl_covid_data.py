import os
from pathlib import Path

import pandas as pd
from gcp.utils import Bigquery
from google.cloud import bigquery
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from schemas import covid_19_daily_data_schema

RAW_DATA_DIR = "/data/raw"
TRANSFORM_DATA_DIR = "/data/transform"

@task(retries=2, log_prints=True)
def get_file_urlpath(url: str, year: int, month: int, day: int) -> str:
    """Create file name"""

    file_url = f"{url}/{day:02}-{month:02}-{year}.csv"
    return file_url

@task(retries=2, log_prints=True)
def fetch_data_csv(url: str, iterator=True, sep=",", chunksize=100000) -> Path:
    """Function to fetch data"""

    try:
        if iterator:
            df_iter = pd.read_csv(filepath_or_buffer=url, iterator=iterator, sep=sep, chunksize=chunksize)
            df = next(df_iter)
        else:
            df = pd.read_csv(filepath_or_buffer=url)

        for dir_path in [RAW_DATA_DIR, TRANSFORM_DATA_DIR]:
            if not os.path.exists(f".{dir_path}"):
                os.makedirs(f".{dir_path}")

        filename = url.split("/")[-1].replace(".csv",".parquet")
        raw_data_path = Path(f".{RAW_DATA_DIR}/{filename}")
        df.to_parquet(raw_data_path, compression="gzip")
        return raw_data_path
    except Exception as e:
        print(e)
    

@task(retries=2, log_prints=True)
def transform_data(raw_file_path: Path, remove_raw_on_completion: bool=True) -> Path:
    """Function to transform the data"""

    df = pd.read_parquet(path=raw_file_path)
    df.columns = [cols.upper() for cols in df]
    df.drop(labels=["PEOPLE_TESTED","MORTALITY_RATE"], axis=1, inplace=True)
    df = df.rename(columns={"LONG_":"LONG", "DATE":"DATASET_DATE", "LAST_UPDATE": "LAST_UPDATE_TIMESTAMP"})

    # Convert string dates to actual datetime objects
    df["LAST_UPDATE_TIMESTAMP"] = pd.to_datetime(df["LAST_UPDATE_TIMESTAMP"])
    df["DATASET_DATE"] = pd.to_datetime(df["DATASET_DATE"]).dt.date
    
    # Convert integer types to float
    integer_cols = [cols for cols in df.select_dtypes(include="int")]
    for col in integer_cols:
        df[col] = df[col].astype(float)

    filename = str(raw_file_path).split("/")[-1]

    transform_data_path = Path(f".{TRANSFORM_DATA_DIR}/{filename}")
    df.to_parquet(transform_data_path, compression="gzip")

    if remove_raw_on_completion:
        os.remove(path=raw_file_path)

    return transform_data_path


@task(retries=2, log_prints=True)
def load_data_gcs(file_path, bucket_block, bucket_path, remove_source_file_on_completion: bool=True) -> None:
    """Function to load the data"""

    gcp_cloud_storage_bucket_block = GcsBucket.load(f"{bucket_block}")
    gcp_cloud_storage_bucket_block.upload_from_path(
        from_path=f"{file_path}",
        to_path=f"{bucket_path}"
    )

    if remove_source_file_on_completion:
        os.remove(file_path)


@task(retries=2, log_prints=True)
def upload_data_bq(secret_name: str="", table: str="", dataset: str="", schema: list[bigquery.SchemaField]=[],gcs_uri: str="", time_partitioning: bool=False, partition_by: str=""):
    """Function to upload data from gcs to bigquery"""
    
    bq = Bigquery(secret_name=f"{secret_name}")
    bq.gcs_to_bq(dataset=dataset,
                 table=table,
                 gcs_uri=gcs_uri,
                 autodetect=False,
                 schema=schema,
                 time_partitioning=time_partitioning,
                 partition_by=partition_by)


@flow(name="covid_cases_child_flow")
def daily(year: int, month: int, day: int):
    url_prefix = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us"
    year = year
    month = month
    day = day
    dataset = "covid_19_cases"
    table = "daily_state_reports_us"
    gcs_uri = f"gs://covid_19_bucket_dataengineeringzoomcamp-2023{TRANSFORM_DATA_DIR}/*.parquet"

    file_url = get_file_urlpath(url=url_prefix,
                            year=year,
                            month=month,
                            day=day)
  
    raw_file_path = fetch_data_csv(url=file_url, iterator=True, sep=",", chunksize=100000)
    if raw_file_path:
        transform_file_path = transform_data(raw_file_path=raw_file_path, remove_raw_on_completion=True)
        load_data_gcs(file_path=transform_file_path, bucket_block="covid-us-daily-data", bucket_path=transform_file_path, remove_source_file_on_completion=True)
        upload_data_bq(secret_name="covid-data-prefect-flows", 
                    table=table,
                    schema=covid_19_daily_data_schema,
                    dataset=dataset,
                    gcs_uri=gcs_uri,
                    time_partitioning=True,
                    partition_by="DATASET_DATE"
                    )
    else:
        print("Data cannot be found")

    
@flow(name="covid_cases_parent_flow")
def main(years: list=[], months: list=[], days: list=[]):

    for year in years:
        for month in months:
            for day in days:
                daily(year=year, month=month, day=day)

if __name__ == "__main__":
    main(years=[2020, 2021], months=[1,2], days=[1,2,3,4])
