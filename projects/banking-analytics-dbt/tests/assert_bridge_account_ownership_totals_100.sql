select
    account_id,
    effective_from,
    effective_to,
    sum(ownership_percentage) as total_ownership_percentage
from {{ ref('bridge_customer_account') }}
group by
    account_id,
    effective_from,
    effective_to
having sum(ownership_percentage) != 100
