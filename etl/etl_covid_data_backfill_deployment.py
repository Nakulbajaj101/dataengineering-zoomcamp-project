from etl_covid_data_backfill import main
from prefect.deployments import Deployment
from prefect_gcp.cloud_run import CloudRunJob
from prefect_gcp.cloud_storage import GcsBucket

cloud_run_job_block = CloudRunJob.load("covid-backfill-run")
gcp_cloud_storage_bucket_block = GcsBucket.load("covid-flows")

deployment = Deployment.build_from_flow(flow=main,
                                        name="covid_data_backfill",
                                        storage=gcp_cloud_storage_bucket_block,
                                        parameters={"start_date":"2020-03-01", "end_date": "2023-01-31"},
                                        infrastructure=cloud_run_job_block,
                                        work_queue_name="ubuntu"
                                        )

if __name__ == "__main__":
    deployment.apply()