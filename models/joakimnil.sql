with

source as (

  select * from {{ source('PS', 'F_SN') }}

)

-- C_IMPORT contains less useful data that we need. However, we use it here because
-- F_SN contains invalid transactions, which are excluded from C_IMPORT,
-- which allows us to filter out the invalid transactions by session_id.
, cdr_import as (

  select * from {{ source('PS', 'C_IMPORT') }}

)

, selection as (
  select
    {{ source_and_id_based_key('PS', 'session_id') }} as cdr_pk
    , session_id as cdr_id
    , chargepoint_id as charger_id
    , {{ source_and_id_based_key('PS', 'connector_id') }} as connector_fk
    , connector_id
    , {{ source_and_id_based_key('PS', 'location_id') }} as location_fk
    , location_id , duration_seconds as session_duration_sec
    , {{ convert_seconds_to_time_type('duration_seconds') }} as session_duration_time
    , energy_value / 1000 as power_consumption_kwh
    , final_price_currency as currency_fk
    , final_price_incl_vat - final_price_vat_amount as net_revenue
    , final_price_vat_amount as tax
    , started_at as session_start_dt
    , to_char(session_start_dt, 'yyyymmdd') as start_dt_fk
    , stop_request_at as stop_received_dt
    , stopped_at as session_stop_dt
    , to_char(session_stop_dt, 'yyyymmdd') as stop_dt_fk
 , 'PS' as source_system
  from source
  where session_id in (select session_id from cdr_import)

)

select * from selection
