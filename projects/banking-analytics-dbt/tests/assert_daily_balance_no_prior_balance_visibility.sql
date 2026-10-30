select
    account_id,
    balance_date,
    source_balance_date,
    snapshot_type,
    closing_balance
from {{ ref('int_daily_account_balances_synthetic') }}
where
    (
        snapshot_type = 'NO_PRIOR_BALANCE'
        and (
            source_balance_date is not null
            or closing_balance is not null
        )
    )
    or (
        snapshot_type = 'ORIGINAL'
        and (
            source_balance_date is null
            or source_balance_date != balance_date
            or closing_balance is null
        )
    )
    or (
        snapshot_type = 'CARRIED_FORWARD'
        and (
            source_balance_date is null
            or source_balance_date >= balance_date
            or closing_balance is null
        )
    )
    or snapshot_type not in (
        'NO_PRIOR_BALANCE',
        'ORIGINAL',
        'CARRIED_FORWARD'
    )
