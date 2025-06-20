with all_procurements as (
  select 
  id,
        type,
        buyer,
        title,
        project_id,
        publish_date,
        date_accessed,
       source,
        procurement_number
        from {{ ref('stg_source_12__procurements_12') }}
  union all
  select 
  id,
        type,
        buyer,
        title,
        project_id,
        publish_date,
        date_accessed,
       source,
        procurement_number
         from {{ ref('stg_source_34__procurements_34') }}
  union all
  select id,
        type,
        buyer,
        title,
        project_id,
        publish_date,
        date_accessed,
       source,
        procurement_number
         from {{ ref('stg_source_56__procurements_56') }}
),

all_bids as (
  select * from {{ ref('stg_source_12__bids_12') }}
  union all
  select * from {{ ref('stg_source_34__bids_34') }}
  union all
  select * from {{ ref('stg_source_56__bids_56') }}
),

split_bid_value as (
  select
    *,
    REGEXP_EXTRACT(value, r'^[^\d]+') as currency,
    SAFE_CAST(REGEXP_EXTRACT(value, r'[\d,.]+') AS FLOAT64) as numeric_value
  from all_bids
  where supplier is not null
),

winner_bids as (
  select
    procurement_number,
    min(numeric_value) as winning_value
  from split_bid_value
  group by procurement_number
)

select
  {{ dbt_utils.generate_surrogate_key(['b.supplier', 'p.id']) }} as generated_pk,
  b.supplier,
  p.id as procurement_id,
  p.procurement_number,
  p.title,
  p.publish_date,
  p.buyer,
  b.numeric_value,
  b.currency,
  case when b.numeric_value = w.winning_value then true else false end as is_winner
from split_bid_value b
left join all_procurements p on b.procurement_number = p.procurement_number
left join winner_bids w on b.procurement_number = w.procurement_number
