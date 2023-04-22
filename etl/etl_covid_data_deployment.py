from etl_covid_data import daily
from prefect.deployments import Deployment
from prefect.orion.schemas.schedules import RRuleSchedule
from prefect_gcp.cloud_run import CloudRunJob
from prefect_gcp.cloud_storage import GcsBucket

cloud_run_job_block = CloudRunJob.load("covid-backfill-run")
gcp_cloud_storage_bucket_block = GcsBucket.load("covid-flows")

deployment = Deployment.build_from_flow(flow=daily,
                                        name="covid_daily",
                                        storage=gcp_cloud_storage_bucket_block,
                                        schedule=(RRuleSchedule(rrule="FREQ=DAILY", timezone="Australia/Sydney")),
                                        infrastructure=cloud_run_job_block
                                        )

if __name__ == "__main__":
    deployment.apply()