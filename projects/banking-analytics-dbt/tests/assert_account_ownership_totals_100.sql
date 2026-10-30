select
    account_id,
    sum(ownership_percentage) as total_ownership_percentage
from {{ ref('bridge_customer_account') }}
group by account_id
having abs(sum(ownership_percentage) - 100.0) > 0.01