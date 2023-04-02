from google.cloud import bigquery

covid_19_daily_data_schema = [
    bigquery.SchemaField("PROVINCE_STATE", "STRING"),
    bigquery.SchemaField("COUNTRY_REGION", "STRING"),
    bigquery.SchemaField("LAST_UPDATE_TIMESTAMP", "TIMESTAMP"),
    bigquery.SchemaField("LAT", "FLOAT64"),
    bigquery.SchemaField("LONG", "FLOAT64"),
    bigquery.SchemaField("CONFIRMED", "FLOAT64"),
    bigquery.SchemaField("DEATHS", "FLOAT64"),
    bigquery.SchemaField("RECOVERED", "FLOAT64"),
    bigquery.SchemaField("ACTIVE", "FLOAT64"),
    bigquery.SchemaField("FIPS", "FLOAT64"),
    bigquery.SchemaField("INCIDENT_RATE", "FLOAT64"),
    bigquery.SchemaField("TOTAL_TEST_RESULTS", "FLOAT64"),
    bigquery.SchemaField("CASE_FATALITY_RATIO", "FLOAT64"),
    bigquery.SchemaField("UID", "FLOAT64"),
    bigquery.SchemaField("ISO3", "STRING"),
    bigquery.SchemaField("TESTING_RATE", "FLOAT64"),
    bigquery.SchemaField("HOSPITALIZATION_RATE", "FLOAT64"),
    bigquery.SchemaField("DATASET_DATE", "DATE")
    ]