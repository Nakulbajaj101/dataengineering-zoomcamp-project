{{
    config(
        partition_by={
            "field": "DT",
            "data_type": "DATE",
            "granularity": "month"
            }
    )
}}

with country_covid_deaths_recovered as 
(
SELECT
DATASET_DATE
,DEATHS
,CONFIRMED
,country.country
,LEAD(DEATHS,1) over (PARTITION BY fact.STATE_ID order by DATASET_DATE desc) as lagged_deaths
,LEAD(CONFIRMED,1) over (PARTITION BY fact.STATE_ID order by DATASET_DATE desc) as lagged_confirmed

FROM {{ ref("covid_cases_fact") }} fact
inner join {{ ref("country_dim") }} country
on fact.COUNTRY_ID = country.COUNTRY_ID
)

,agg as 

(

select DATE_TRUNC(DATASET_DATE, month) as DT, 
country,
SUM(DEATHS - coalesce(lagged_deaths,1)) as DEATHS,
SUM(CONFIRMED - coalesce(lagged_CONFIRMED,1)) as CONFIRMED
FROM country_covid_deaths_recovered
group by 1,2
)

select *, SAFE_DIVIDE(DEATHS ,CONFIRMED) as FATALITY_PERC
from agg
