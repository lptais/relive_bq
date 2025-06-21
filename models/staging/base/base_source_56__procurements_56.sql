with source as (
        select * from {{ source('landing_zone', 'procurements_56') }}
  ),
  renamed as (
      select
        id,
        type,
        buyer,
        title,
        content,
        project_id,
        publish_date,
        CAST(date_accessed as DATE) as date_accessed,
        COALESCE(CAST(source[OFFSET(8)] AS STRING),"56") as source,
        procurement_number

      from source
  )
  select * from renamed
