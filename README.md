# Project Name:  Monthly COVID-19 Reporting

[![CD_DEPLOY](https://github.com/Nakulbajaj101/dataengineering-zoomcamp-project/actions/workflows/cd-deploy.yml/badge.svg?branch=main)](https://github.com/Nakulbajaj101/dataengineering-zoomcamp-project/actions/workflows/cd-deploy.yml)

[![CI_TESTS](https://github.com/Nakulbajaj101/dataengineering-zoomcamp-project/actions/workflows/ci-tests.yml/badge.svg)](https://github.com/Nakulbajaj101/dataengineering-zoomcamp-project/actions/workflows/ci-tests.yml)

[![DBT_BIGQUERY](https://github.com/Nakulbajaj101/dataengineering-zoomcamp-project/actions/workflows/dbt-workflow.yml/badge.svg)](https://github.com/Nakulbajaj101/dataengineering-zoomcamp-project/actions/workflows/dbt-workflow.yml)

## Project Description
This data engineering project aims to develop a system for collecting and reporting monthly COVID-19 data for the US government. The project will involve the following steps:

* Data Collection and Ingestion: Collecting COVID-19 data from reliable sources such as the CDC, WHO, and state health departments.
* Data Processing: Cleaning and formatting the data to ensure consistency and accuracy.
* Data Storage: Storing the processed data in a database or data warehouse.
* Reporting: Generating monthly reports that summarize the COVID-19 data for the US government.

The project will require expertise in data engineering, database management, and report generation. The goal is to develop a system that is reliable, efficient, and easy to use for the US government officials.



### Problem statement and project description
The US government requires accurate and up-to-date information on the number of COVID-19 cases and deaths each month. This information is critical for informing public health policy and tracking the progress of the pandemic. The government needs a reliable and automated system for collecting, processing, and reporting COVID-19 data on a monthly basis.

#### Expected Deliverables
Automated system for collecting, processing, and reporting monthly COVID-19 data.
Clean and formatted data stored in a database or data warehouse.
Monthly reports that summarize the COVID-19 data for the US government.

#### Benefits
Provides the US government with accurate and up-to-date information on COVID-19 cases and deaths.
Helps inform public health policy and track the progress of the pandemic.
Allows for timely decision making and response to the COVID-19 crisis.


## Data

USA daily state covid reports (csse_covid_19_daily_reports_us)
[Data Source](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports_us)

This table contains an aggregation of each USA State level data.

File naming convention
MM-DD-YYYY.csv in UTC.


Update frequency
Once per day between 04:45 and 05:15 UTC.

### Field description
* Province_State - The name of the State within the USA.
* Country_Region - The name of the Country (US).
* Last_Update - The most recent date the file was pushed.
* Lat - Latitude.
* Long_ - Longitude.
* Confirmed - Aggregated case count for the state.
* Deaths - Aggregated death toll for the state.
* Recovered - Aggregated Recovered case count for the state.
* Active - Aggregated confirmed cases that have not been resolved (Active cases = total cases - total recovered - total deaths).
* FIPS - Federal Information Processing Standards code that uniquely identifies counties within the USA.
* Incident_Rate - cases per 100,000 persons.
* Total_Test_Results - Total number of people who have been tested.
* People_Hospitalized - Total number of people hospitalized. (Nullified on Aug 31, see Issue #3083)
* Case_Fatality_Ratio - Number recorded deaths * 100/ Number confirmed cases.
* UID - Unique Identifier for each row entry.
* ISO3 - Officially assigned country code identifiers.
* Testing_Rate - Total test results per 100,000 persons. The "total test results" are equal to "Total test results (Positive + Negative)" from COVID Tracking Project.
* Hospitalization_Rate - US Hospitalization Rate (%): = Total number hospitalized / Number cases. The "Total number hospitalized" is the "Hospitalized – Cumulative" count from COVID Tracking Project. The "hospitalization rate" and "Total number hospitalized" is only presented for those states which provide cumulative hospital data. (Nullified on Aug 31, see Issue #3083)

## Getting started
* Sign up to google account(GCP) and create a project `dataengineeringzoomcamp-2023`
* Sign up to prefect cloud and create a workspace `data-engineering`
* Sign up to AWS account and create an AWS IAM role with permissions to create buckets, ec2
    * Add programmatic access to the role and store access key and secret access key securely
* Have anaconda and python 3.9+
* Have docker downloaded
* Have git for cloning the repo
* Create three service accounts for GCP  with the native GCP roles
    - Editor: Bigquery, Storage Admin, Compute Admin
    - Prefect: BigQuery Job User, Cloud Run developer, Storage Object Creator, Storage Object Viewer
    - Dbt: BigQuery Data Editor, BigQuery Job User
    - Authorise editor service account to create resources
    - Create the key and download the json file
    - Download and install gcloud cli `https://cloud.google.com/sdk/docs/install`
    - Run the below code 
        ```bash 
        gcloud init 
        gcloud auth activate-service-account <editor>.iam.gserviceaccount.com --key-file=</path/editor.json>
        ```

### Setting up local environment

Run the below script

```bash
conda create --name de-zoomcamp-project python=3.9
conda activate de-zoomcamp-project
pip install -r requirements.txt
```

## Build With
The section covers tools used to run the project. We can call this multi cloud strategy. The core infrastructure is on GCP in terms of data lifecycle management and ETL pipeline and DBT transformation processing. Prefect cloud is utilised for deploying flows and deployments, and observability. Utilised AWS for running prefect agent.

- Prefect cloud for end to end orchestration
- Python for ETL
- Bigquery for data warehousing
- DBT for transforming models in the warehouse, and making these ready for consumption in looker.
- Google Cloud Storage for data lake
- Looker for data visualisation and reporting
- Terraform for provisioning infrastructure such as bigquery datasets, gcs buckets for prefect flows, and prefect agent on AWS
- Github actions for continuous integration and deployment workflows


## Project Folders
- .github - Contains logic and files for github actions
- deploy - Contains logic and files for infrastructure as code
- etl - Contains prefect flows and logic for deployments to prefect
- dbtcode - Contains logic for data transformtaion in the bigquery warehouse
- dashboard - Contains html and screenshot of the dashboard

### Setting up prefect
This section assumes local environment setup was done and all dependencies were installed

- Sign up with prefect cloud and create a workspace called `data-engineering`
- Create an api key and save it temporarily, somewhere safe on your machine
- Run `prefect cloud login` and follow the instructions. Once authenticated please remove the key locally


#### Configuring prefect blocks
Overall we need 9 blocks to run this project
These blocks are mentioned below with type of blocks seprated by / 
and then name of the blocks. In order to run the code we need all these blocks defined.

* dbt CLI BigQuery Target Configs / covid-dbt-prod-target-config
* dbt CLI Profile / covid-dbt-prod-profile
* dbt Core Operation / covid-dbt-prod-build-operation
* GCP Cloud Run Job / covid-backfill-run
* GCP Credentials / covid-data-prefect-flows-secret
* GCP Credentials / covid-dbt-credentials
* GCS Bucket / covid-flows
* GCS Bucket / covid-us-daily-data
* GitHub Credentials / dataengineering-dbt-project-credentials
* GitHub Repository / covid-data-dbt-clone

## Setting up dbt
The dbt code is defined in the dbtcode folder
We need to navigate to covid_19_data folder and have the profile defined locally

```yml 
covid_19_data:
  outputs:
    prod:
      keyfile: "{{ env_var('DBT_GOOGLE_KEYFILE') }}"
      method: service-account
      project: dataengineeringzoomcamp-2023
      schema: covid_19_cases
      threads: 10
      type: bigquery
  target: prod
```

We need to ensure an environment variable `DBT_GOOGLE_KEYFILE` which stores absolute path to google editor service account json file. 
To learn more about running DBT navigate to the folder at [DBT folder README](https://github.com/Nakulbajaj101/dataengineering-zoomcamp-project/blob/main/dbtcode/covid_19_data/README.MD)

The source table in bigquery have the time partitioning and all the tables in core dbt directory have partitiong and clustering


## Configure cloud run
To configure cloud run with prefect and run it we need two things:

1. We need to bind the service account to make it assume as default compute service account. When we find the default compute service account, we can use the below command to bind it:
```bash 
gcloud iam service-accounts add-iam-policy-binding <your-compute-account>-compute@developer.gserviceaccount.com --member="serviceAccount:<your-prefect-service-account>@<project_id>.iam.gserviceaccount.com"  --role roles/iam.serviceAccountUser
```

2. We need to create the docker image and push it to ECR:

- Enable container regitsry api for google
- Follow the page to congigure docker with gcloud auth[auth](https://cloud.google.com/container-registry/docs/advanced-authentication)
- From the etl directory run the command
```bash 
bash deploy_docker_image_gcr.sh
```
- Create a prefect block for cloud run [Cloud run on prefect](https://medium.com/the-prefect-blog/serverless-prefect-flows-with-google-cloud-run-jobs-23edbf371175)

## Running and deploying the infra

Run `make apply_local` from the root directory to provision infra
Run `make deploy_prefect_flows` to deploy prefect flows
From prefect UI run a flow to test it

## Dashboard
Prepared the dashboard using Looker(Data Studio) from Google
![alt text](https://github.com/Nakulbajaj101/dataengineering-zoomcamp-project/blob/main/dashboard/Covid_Monthly_Analytical_Insights.png)

If you wish to access to the dashboard please request access via link: [Dashboard share link](https://lookerstudio.google.com/reporting/4cc8cc5e-0e83-4889-84a3-9236225b791a)


## How to deploy and destroy infrastructure as code
Terraform Plan
For prod: In the root directory of the repo run `make plan_prod`

To provision and apply

For prod: In the root directory of the repo run `make apply_prod`

To destroy
For prod: In the root directory of the repo run `make destroy_prod`


## CICD
The github workflows are configured to run at each pull request. This will run terraform plan and once succeeded a reviewer can merge the request. If anycode in dbt repo will be changed, even dbt code will run. Once everything passes a reviewer can merge the request. 
For CD, post merging of pull request, terraform plan and apply will run, and if code has changed for prefect flows, then a new image will be pushed to ECR and new code will be published to prefect cloud.


Contact for questions or support
Nakul Bajaj @Nakulbajaj101

