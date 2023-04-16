{{
    config(
        materialized='incremental',
        unique_key = 'record_id',
        partition_by={
            "field": "DATASET_DATE",
            "data_type": "DATE",
            "granularity": "day"
            },
        incremental_strategy = 'insert_overwrite'
    )
}}

with covid_cases as 

(

select CONFIRMED, 
      DEATHS, 
      RECOVERED, 
      ACTIVE, 
      FIPS, 
      INCIDENT_RATE, 
      TOTAL_TEST_RESULTS, 
      CASE_FATALITY_RATIO, 
      TESTING_RATE, 
      HOSPITALIZATION_RATE,
      DATASET_DATE,
      STATES.STATE_ID,
      ISO3.ISO3_ID,
      COUNTRY.COUNTRY_ID,
      LAST_UPDATE_TIMESTAMP,
      ROW_NUMBER() OVER (PARTITION BY STATES.STATE_ID, COUNTRY.COUNTRY_ID, ISO3.ISO3_ID, DATASET_DATE ORDER BY LAST_UPDATE_TIMESTAMP DESC) AS RECORD_RANK
FROM {{ source('staging','daily_state_reports_us') }} RAW
INNER JOIN {{ ref("country_dim") }} COUNTRY 
ON RAW.COUNTRY_REGION = COUNTRY.COUNTRY

INNER JOIN {{ ref("states_dim") }} STATES 
ON RAW.PROVINCE_STATE = STATES.STATE

INNER JOIN {{ ref("iso3_dim") }} ISO3
ON RAW.ISO3 = ISO3.ISO3
)

,clean_covid_records as 
(
SELECT * EXCEPT (RECORD_RANK)
FROM covid_cases
WHERE RECORD_RANK = 1
)

SELECT *, {{ dbt_utils.generate_surrogate_key(['STATE_ID', 'COUNTRY_ID', 'ISO3_ID', 'DATASET_DATE'])}} AS RECORD_ID
FROM clean_covid_records

{% if is_incremental() %}
WHERE DATASET_DATE NOT IN (
    SELECT DISTINCT DATASET_DATE FROM {{ this }}
)
{% endif %}

