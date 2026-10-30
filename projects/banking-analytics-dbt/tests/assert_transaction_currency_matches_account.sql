select
    t.transaction_id,
    t.account_id,
    t.currency as transaction_currency,
    a.currency as account_currency
from {{ ref('stg_transactions') }} t
inner join {{ ref('stg_accounts') }} a
    on t.account_id = a.account_id
where upper(trim(t.currency))
    != upper(trim(a.currency))
