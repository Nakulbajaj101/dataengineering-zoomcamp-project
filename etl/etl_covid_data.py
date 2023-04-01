from pathlib import Path
import os
import pandas as pd


DATA_DIR = "./data"

def get_file_urlpath(url: str, year: int, month: int, day: int) -> str:
    """Create file name"""

    file_url = f"{url}/{day:02}-{month:02}-{year}.csv"
    return file_url


def fetch_data_csv(url: str, iterator=True, sep=",", chunksize=100000) -> Path:
    """Function to fetch data"""

    if iterator:
        df_iter = pd.read_csv(filepath_or_buffer=url, iterator=iterator, sep=sep, chunksize=chunksize)
        df = next(df_iter)
    else:
        df = pd.read_csv(filepath_or_buffer=url)
    
    if not os.path.exists(f"{DATA_DIR}"):
        os.makedirs(f"{DATA_DIR}")
    
    filename = url.split("/")[-1]
    path = Path(f"{DATA_DIR}/{filename}")
    df.to_csv(path, index=False)

    return path

def transform_data(path: Path) -> pd.DataFrame:

    pass

def load_data(data: pd.DataFrame) -> None:

    pass


if __name__ == "__main__":

    url_prefix = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us"
    year = 2021
    month = 1
    day = 1

    file_url = get_file_urlpath(url=url_prefix,
                            year=year,
                            month=month,
                            day=day)
    
    path = fetch_data_csv(url=file_url, iterator=True, sep=",", chunksize=100000)
    print(path)
    

