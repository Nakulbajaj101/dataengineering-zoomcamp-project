

with iso_aggregated as 
(
    select iso3
          , avg(lat) as lat
          , avg(long) as long 
    from {{ source('staging','daily_state_reports_us') }}
    group by 1
) 

select *, {{ dbt_utils.generate_surrogate_key(['iso3']) }} as iso3_id
 FROM iso_aggregated
