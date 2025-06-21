with bids as (
    select *
        from {{ ref('stg_bids') }}
),

procurements as (
    select *
        from {{ ref('stg_procurements') }}
),

bids_with_procurements as (
    select
        b.supplier,
        b.procurement_number,
        b.value_amount,
        b.currency,
        b.date_accessed,
        b.source,
        p.title,
        p.publish_date,
        p.buyer,
    -- Window function to define winning bid, assumed to be the lowest one
        row_number() over (
            partition by b.procurement_number, b.source
            order by b.value_amount asc
        ) as bid_rank
    from bids b
    -- INNER JOIN to ensure that only procurements with a title are returned
    inner join procurements p
      on b.procurement_number = p.procurement_number
     and b.source = p.source
    -- Excludes bids with null values
    where b.value_amount is not null
)

select
-- Generate PK based on combination of supplier, procurment_number and source
    {{ dbt_utils.generate_surrogate_key(['supplier','procurement_number', 'source']) }} as generated_pk,
    supplier,
    procurement_number,
    value_amount,
    currency,
    date_accessed,
    source,
    title,
    publish_date,
    buyer,
    bid_rank = 1 as is_winner
from bids_with_procurements
