select
    transaction_id,
    customer_id,
    count(*) as row_count
from {{ ref('mart_customer_transaction_history') }}
group by transaction_id, customer_id
having count(*) > 1
