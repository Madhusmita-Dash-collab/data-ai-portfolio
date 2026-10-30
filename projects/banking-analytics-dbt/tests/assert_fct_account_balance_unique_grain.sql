select
    account_id,
    balance_date,
    count(*) as row_count
from {{ ref('fct_account_balance') }}
group by
    account_id,
    balance_date
having count(*) > 1
