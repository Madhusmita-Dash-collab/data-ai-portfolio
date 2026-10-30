select
    customer_account_key,
    customer_id,
    account_id,
    effective_from,
    effective_to
from {{ ref('bridge_customer_account') }}
where effective_from is null
   or (
       effective_to is not null
       and effective_to <= effective_from
   )