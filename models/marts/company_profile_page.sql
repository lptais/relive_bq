{{ config(
    cluster_by = ['supplier']
) }}

select
    supplier,
    procurement_number,
    source,
    title as procurement_title,
    publish_date as published_date,
    buyer,
    value_amount as bid_value,
    currency,
    is_winner
from {{ ref('int_suppliers_bids') }}
