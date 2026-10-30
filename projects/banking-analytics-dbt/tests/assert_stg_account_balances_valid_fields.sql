select
    account_id,
    balance_date,
    closing_balance,
    currency
from {{ ref('stg_account_balances') }}
where
    account_id is null
    or trim(account_id) = ''
    or balance_date is null
    or closing_balance is null
    or closing_balance < 0
    or currency is null
    or trim(currency) = ''
