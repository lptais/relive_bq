{% set columns = [
    "id",
    "type",
    "buyer",
    "title",
    "project_id",
    "publish_date",
    "date_accessed",
    "source",
    "procurement_number"
] %}

{% set sources = [
    'base_source_12__procurements_12',
    'base_source_34__procurements_34',
    'base_source_56__procurements_56'
] %}

with all_procurements as (

    {% for src in sources %}
        select
            {{ columns | join(', ') }}
        from {{ ref(src) }}
        {% if not loop.last %}
        union all
        {% endif %}
    {% endfor %}

),

cleaned as (
    select
        id,
        type,
        buyer,
        REGEXP_REPLACE(title, r'^\d+\s*-\s*', '') AS title,
        project_id,
        publish_date,
        date_accessed,
        source,
        cast(procurement_number as string) as procurement_number
    from all_procurements
    where title is not null
      and not regexp_contains(title, r'^\s*\d+\-\d+')
)

select * from cleaned
