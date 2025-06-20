with source as (
        select * from {{ source('landing_zone', 'bids_34') }}
  ),
  renamed as (
    select
    supplier,
procurement_number,
    value,
    date_accessed,
    CAST(source[OFFSET(4)] AS STRING) as source
  from source
  )
  select * from renamed
    
    