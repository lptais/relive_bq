with bids as (
    select *
    from {{ ref('int_suppliers_bids') }}
),

aggregated as (
    select
        procurement_number,
        title as procurement_title,
        publish_date as published_date,
        buyer,
        count(*) as number_of_bids,
        max(if(is_winner, supplier, null)) as winner_supplier_name,
        max(if(is_winner, value_amount, null)) as winner_bid_value
    from bids
    group by
        procurement_number, 
        title, 
        publish_date, 
        buyer
)

select * from aggregated
