with allocation_counts as (

    select count(*) as row_count
    from {{ ref('fct_transaction_customer_allocation') }}

),

history_counts as (

    select count(*) as row_count
    from {{ ref('mart_customer_transaction_history') }}

)

select
    allocation_counts.row_count as allocation_row_count,
    history_counts.row_count as history_row_count
from allocation_counts
cross join history_counts
where allocation_counts.row_count != history_counts.row_count
