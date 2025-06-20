with union_procurements as (
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
from {{ ref('stg_source_56__procurements_56') }}
),

union_bids as (
  select * from {{ ref('stg_source_12__bids_12') }}
  union all
  select * from {{ ref('stg_source_34__bids_34') }}
  union all
  select * from {{ ref('stg_source_56__bids_56') }}
),

clean_procurement_titles as (
  select
    *,
    regexp_replace(title, r'^\d{1,2}[-–]\d{3}\s*[-:–]?\s*', '') as cleaned_title
  from union_procurements
  where title is not null
),

split_bid_values as (
  select
    *,
    REGEXP_EXTRACT(value, r'^[^\d]+') as currency,
    SAFE_CAST(REGEXP_EXTRACT(value, r'[\d,.]+') AS FLOAT64) as numeric_value
  from union_bids
  where supplier is not null
),

rank_bids as (
  select *,
    row_number() over (partition by procurement_number order by numeric_value asc) as bid_rank
  from split_bid_values
)

select
  p.id,
  p.procurement_number,
  p.cleaned_title as title,
  p.publish_date,
  p.buyer,
  p.date_accessed,
  p.source,
  count(b.procurement_number) as number_of_bids,
  max(if(b.bid_rank = 1, b.supplier, null)) as winner_supplier,
  max(if(b.bid_rank = 1, b.numeric_value, null)) as winner_bid_value,
  max(if(b.bid_rank = 1, b.currency, null)) as winner_bid_currency
from clean_procurement_titles p
left join rank_bids b on b.procurement_number = p.procurement_number
group by
  all
