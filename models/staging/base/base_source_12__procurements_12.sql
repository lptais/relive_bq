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
        publish_date,
        CAST(date_accessed as DATE) as date_accessed,
        COALESCE(CAST(source[OFFSET(7)] AS STRING), "12") as source,
        procurement_number

      from source
  )
  select * from renamed
