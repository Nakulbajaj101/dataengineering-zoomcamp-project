
from prefect_github.repository import GitHubRepository
from prefect_dbt import DbtCoreOperation
from prefect import task, flow

@task(retries=2, timeout_seconds=60, log_prints=True)
def load_dbt_dir(github_block: str="", dbt_dir_path: str=""):
    """Function to load github directory"""
    
    github_repository_block = GitHubRepository.load(f"{github_block}")
    github_repository_block.get_directory(from_path=f"{dbt_dir_path}")

@task(retries=2, timeout_seconds=60, log_prints=True)
def run_dbt_operation(dbt_core_operation_block: str=""):
    """Function to run dbt operation"""
    
    dbt_op = DbtCoreOperation.load(f"{dbt_core_operation_block}")
    dbt_op.run()

@flow(name="run_dbt_from_github", timeout_seconds=200, log_prints=True)
def run_dbt_from_github(github_block: str="", dbt_dir_path: str="", dbt_core_operation_block: str=""):
    """Flow to run dbt operations from github"""

    load_dbt_dir(github_block=github_block, dbt_dir_path=dbt_dir_path)
    run_dbt_operation(dbt_core_operation_block=dbt_core_operation_block)

if __name__ == "__main__":
    run_dbt_from_github(github_block="covid-data-dbt-clone",
                        dbt_dir_path="dbtcode/covid_19_data",
                        dbt_core_operation_block="covid-dbt-prod-build-operation")
