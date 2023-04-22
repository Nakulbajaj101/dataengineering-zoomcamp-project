from google.cloud import bigquery
from google.cloud.exceptions import NotFound
from prefect_gcp import GcpCredentials


class Bigquery():

    def __init__(self, secret_name: str):
        """Class constructor"""

        self.secret_name = secret_name
        self.client = self.authenticate_bq()

    def authenticate_bq(self) -> bigquery.Client:
        """Function to create and authenticate bigquery client"""

        # "covid-data-prefect-flows"
        gcp_credentials = GcpCredentials.load(f"{self.secret_name}")
        google_auth_credentials = gcp_credentials.get_credentials_from_service_account()
        client = bigquery.Client(credentials=google_auth_credentials)
        return client

    def check_table(self, dataset: str, table: str):
        """Check if table exists"""
        
        dataset_ref = bigquery.DatasetReference(self.client.project, dataset)
        table_ref = bigquery.TableReference(dataset_ref, table)
        try:
            self.client.get_table(table_ref)
            return True
        
        except NotFound:
            print(f"Table not found")
            return False
    
    def create_table(self, dataset: str="", table: str="", schema: list[bigquery.SchemaField]=None, time_partitioning: bool=False, partition_by: str=""):
        """Create bigquery table"""

        # Construct a BigQuery client object.
        dataset_ref = bigquery.DatasetReference(self.client.project, dataset)

        table_ref = dataset_ref.table(table)

        table = bigquery.Table(table_ref, schema=schema)

        if time_partitioning:
            table.time_partitioning = bigquery.TimePartitioning(
            type_ = bigquery.TimePartitioningType.DAY,
            field=f"{partition_by}")  # name of column to use for partitioning

        table = self.client.create_table(table)  # Make an API request.
        print(
            "Created table {}.{}.{}".format(table.project, table.dataset_id, table.table_id)
        )

    def gcs_to_bq(self, dataset: str, table: str, gcs_uri: str,
                  schema: list[bigquery.SchemaField]=None, 
                  source_format: bigquery.SourceFormat=bigquery.SourceFormat.PARQUET, 
                  load_strategy: str="append", autodetect: bool=True,
                  time_partitioning: bool=False, partition_by: str=""):
        
        """Function to upload data from gcs to bigquery"""

        table_id = f"{self.client.project}.{dataset}.{table}"
        uri = f"{gcs_uri}"
        
        if load_strategy == "append":
            job_config = bigquery.LoadJobConfig(
            source_format = source_format)
        else:
            job_config = bigquery.LoadJobConfig(
            source_format = source_format,
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
            )

        if not self.check_table(dataset=dataset, table=table):
            print("Creating table")
            self.create_table(dataset=dataset,
                              table=table,
                              schema=schema,
                              time_partitioning=time_partitioning,
                              partition_by=partition_by)

        if not autodetect:
            job_config.schema = schema
            job_config.autodetect = autodetect
        
        load_job = self.client.load_table_from_uri(
            uri, table_id, job_config=job_config
        )  # Make an API request.

        previous_rows = self.client.get_table(table_id).num_rows
        load_job.result()  # Waits for the job to complete.

        destination_table = self.client.get_table(table_id)
        updated_rows = destination_table.num_rows

        total_rows_loaded = updated_rows - previous_rows
        print("Loaded {} rows.".format(total_rows_loaded))