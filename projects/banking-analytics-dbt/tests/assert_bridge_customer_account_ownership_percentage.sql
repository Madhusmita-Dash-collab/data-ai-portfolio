select
    customer_account_key,
    customer_id,
    account_id,
    ownership_percentage
from {{ ref('bridge_customer_account') }}
where ownership_percentage < 1
   or ownership_percentage > 100
