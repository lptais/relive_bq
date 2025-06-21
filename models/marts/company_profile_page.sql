{{ config(
    cluster_by = ['supplier']
) }}

select
    supplier,
    procurement_number,
    source,
    title as procurement_title,
    publish_date,
    buyer,
    value_amount,
    currency,
    is_winner
from {{ ref('int_suppliers_bids') }}
