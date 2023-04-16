

with country_aggregated as 
(
    select country_region as country
          , avg(lat) as lat
          , avg(long) as long 
    from {{ source('staging','daily_state_reports_us') }}
    group by 1
) 

select *, {{ dbt_utils.generate_surrogate_key(['country']) }} as country_id
 FROM country_aggregated
