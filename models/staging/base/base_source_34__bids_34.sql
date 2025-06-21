with source as (
        select * from {{ source('landing_zone', 'bids_34') }}
  ),
  renamed as (
    select
    supplier,
procurement_number,
    value,
    date_accessed,
    COALESCE(CAST(source[OFFSET(4)] AS STRING), "34") as source
  from source
  )
  select * from renamed
