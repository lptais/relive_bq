with source as (
        select * from {{ source('landing_zone', 'bids_12') }}
  ),
  renamed as (
    select
    supplier,
procurement_number,
    value,
    date_accessed,
    COALESCE(CAST(source[OFFSET(4)] AS STRING), "12") as source
  from source
  )
  select * from renamed
