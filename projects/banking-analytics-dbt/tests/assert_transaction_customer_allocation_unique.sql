select
    transaction_id,
    customer_id,
    count(*) as row_count
from {{ ref('fct_transaction_customer_allocation') }}
group by transaction_id, customer_id
having count(*) > 1
