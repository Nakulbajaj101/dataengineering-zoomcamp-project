# dataengineering-zoomcamp-project

### Problem statement and project description

### Data

File naming convention
MM-DD-YYYY.csv in UTC.

#### Field description
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

Update frequency
Once per day between 04:45 and 05:15 UTC.

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
