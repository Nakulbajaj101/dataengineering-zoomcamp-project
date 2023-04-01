# dataengineering-zoomcamp-project

### Problem statement and project description

# Getting started

## Create three service accounts
- Editor: Bigquery, Storage Admin, Compute Admin
- Prefect: Bigquery Jobs, Storage Objects Creator
- Dbt: Bigquery Jobs

### Authorise service account to create resources
```bash 
gcloud init 
gcloud auth activate-service-account <youreditor>.iam.gserviceaccount.com --key-file=</path/editor.json>
```

### Setting up prefect
#### Configuring block for storage
#### Configuring block for running bigquery jobs

### Setting up dbt
#### Dbt profiles
#### Running dbt
### Setting up local environment

```bash
conda create --name de-zoomcamp-project python=3.9
conda activate de-zoomcamp-project
pip install -r requirements.txt
```

### Setup dbt

* dataset_name: "covid_19_cases"
