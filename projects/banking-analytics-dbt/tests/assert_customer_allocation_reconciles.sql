select
    transaction_id,
    max(transaction_amount) as original_amount,
    sum(allocated_amount) as total_allocated_amount
from {{ ref('fct_transaction_customer_allocation') }}
group by transaction_id
having abs(
    max(transaction_amount) - sum(allocated_amount)
) > 0.01
