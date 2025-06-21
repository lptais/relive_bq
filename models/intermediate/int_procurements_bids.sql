/* 
Model joining procurements and bids with ARRAY_AGG logic.
This model is not part of the solution. Used for validation purposes.
*/
with procurements as (
  select * from {{ ref('stg_procurements') }}
),

bids as (
  select * from {{ ref('stg_bids') }}
),

aggregated as (
  select
    p.*,
    count(b.procurement_number) as number_of_bids,
    array_agg(struct(b.supplier, b.value_amount) order by b.value_amount desc) as all_bids
  from procurements p
  left join bids b
    on p.procurement_number = b.procurement_number
    and p.source = b.source
  group by all
)

select * from aggregated
