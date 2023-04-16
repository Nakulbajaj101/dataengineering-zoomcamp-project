{{
    config(
        partition_by={
            "field": "DT",
            "data_type": "DATE",
            "granularity": "month"
            },
        cluster_by=["iso3","state"]
    )
}}

with states_covid_deaths_recovered as 
(
SELECT
DATASET_DATE
,DEATHS
,CONFIRMED
,states.state
,iso3.iso3
,country.country
,LEAD(DEATHS,1) over (PARTITION BY fact.STATE_ID order by DATASET_DATE desc) as lagged_deaths
,LEAD(CONFIRMED,1) over (PARTITION BY fact.STATE_ID order by DATASET_DATE desc) as lagged_confirmed

 FROM {{ ref("covid_cases_fact") }} fact
 inner join {{ ref("states_dim") }} states
 on fact.STATE_ID = states.state_id

 inner join {{ ref("iso3_dim") }} iso3
 on fact.iso3_id = iso3.iso3_id

 inner join {{ ref("country_dim") }} country
 on fact.COUNTRY_ID = country.COUNTRY_ID

)

,agg
as
(
select DATE_TRUNC(DATASET_DATE, month) as DT, 
state,
iso3,
country,
SUM(DEATHS - coalesce(lagged_deaths,1)) as DEATHS,
SUM(CONFIRMED - coalesce(lagged_CONFIRMED,1)) as CONFIRMED
FROM states_covid_deaths_recovered
group by 1,2,3,4
)

select *, SAFE_DIVIDE(DEATHS ,CONFIRMED) as FATALITY_PERC
from agg
