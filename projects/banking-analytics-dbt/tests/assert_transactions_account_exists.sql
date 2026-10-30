select
    t.transaction_id,
    t.account_id
from {{ ref('stg_transactions') }} t
left join {{ ref('stg_accounts') }} a
    on t.account_id = a.account_id
where a.account_id is null
