select
    account_id,
    balance_date,
    count(*) as row_count
from {{ ref('stg_account_balances') }}
group by
    account_id,
    balance_date
having count(*) > 1
