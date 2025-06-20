with source as (
        select * from {{ source('landing_zone', 'procurements_12') }}
  ),
  renamed as (
      select
        id,
        type,
        buyer,
        title,
        project_id,
        FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%m/%d/%Y', publish_date)) as publish_date,
        CAST(date_accessed as DATE) as date_accessed,
        CAST(source[OFFSET(7)] AS STRING) as source,
        procurement_number

      from source
  )
  select * from renamed
    