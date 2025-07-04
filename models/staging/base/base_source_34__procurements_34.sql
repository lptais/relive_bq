with source as (
        select * from {{ source('landing_zone', 'procurements_34') }}
  ),
  renamed as (
      select
        id,
        type,
        buyer,
        title,
        project_name,
        project_identity as project_id,
        publish_date,
        CAST(date_accessed as DATE) as date_accessed,
        COALESCE(CAST(source[OFFSET(8)] AS STRING), "34") as source,
        procurement_number

      from source
  )
  select * from renamed
