with all_bids as (
  select
  * from {{ ref('base_source_12__bids_12') }}
  union all
  select
  * from {{ ref('base_source_34__bids_34') }}
  union all
  select
  * from {{ ref('base_source_56__bids_56') }}
),

cleaned as (
  select
    supplier,
    cast(procurement_number as string) as procurement_number,
    regexp_extract(value, r'([^\d.]+)') as currency,
    cast(regexp_extract(value, r'([\d.]+)') as float64) as value_amount,
    date_accessed,
    source
  from all_bids
  where supplier is not null
)

select * from cleaned
