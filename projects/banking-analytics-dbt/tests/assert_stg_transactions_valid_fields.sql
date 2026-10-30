select
    transaction_id,
    account_id,
    transaction_date,
    transaction_type,
    amount,
    currency,
    transaction_status
from {{ ref('stg_transactions') }}
where
    transaction_id is null
    or trim(transaction_id) = ''
    or account_id is null
    or trim(account_id) = ''
    or transaction_date is null
    or transaction_type is null
    or trim(transaction_type) = ''
    or amount is null
    or amount <= 0
    or currency is null
    or trim(currency) = ''
    or transaction_status is null
    or lower(trim(transaction_status)) not in ('success', 'failed')
