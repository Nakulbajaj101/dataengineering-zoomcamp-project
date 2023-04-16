

with states_aggregated as 
(
    select province_state as state
          ,uid
          , max(lat) as lat
          , max(long) as long 
    from {{ source('staging','daily_state_reports_us') }}
    group by 1,2
) 

select *, {{ dbt_utils.generate_surrogate_key(['state', 'uid']) }} as state_id
 FROM states_aggregated
