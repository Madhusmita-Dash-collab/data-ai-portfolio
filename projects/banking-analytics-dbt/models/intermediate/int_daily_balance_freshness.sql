select
    account_id,
    balance_date,
    source_balance_date,
    snapshot_type,
    closing_balance,
    date_diff(
        'day',
        source_balance_date,
        balance_date
    ) as balance_age_days
from {{ ref('int_daily_account_balances_synthetic') }}
