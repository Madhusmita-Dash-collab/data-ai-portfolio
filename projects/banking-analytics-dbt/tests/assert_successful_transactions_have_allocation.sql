select
    t.transaction_id,
    t.account_id,
    t.transaction_date
from {{ ref('fct_transaction') }} t
left join (
    select distinct transaction_id
    from {{ ref('fct_transaction_customer_allocation') }}
) a
    on t.transaction_id = a.transaction_id
where t.transaction_status = 'Success'
  and a.transaction_id is null
