with daily_counts as (
    select
        balance_date,
        snapshot_type,
        count(*) as account_snapshot_count
    from {{ ref('int_daily_account_balances_synthetic') }}
    group by
        balance_date,
        snapshot_type
),

daily_summary as (
    select
        balance_date,
        sum(account_snapshot_count) as expected_account_snapshots,
        sum(
            case
                when snapshot_type = 'ORIGINAL'
                then account_snapshot_count else 0
            end
        ) as original_snapshots,
        sum(
            case
                when snapshot_type = 'CARRIED_FORWARD'
                then account_snapshot_count else 0
            end
        ) as carried_forward_snapshots,
        sum(
            case
                when snapshot_type = 'NO_PRIOR_BALANCE'
                then account_snapshot_count else 0
            end
        ) as unavailable_snapshots
    from daily_counts
    group by balance_date
)

select
    balance_date,
    expected_account_snapshots,
    original_snapshots,
    carried_forward_snapshots,
    unavailable_snapshots,
    round(
        100.0 * original_snapshots
        / nullif(expected_account_snapshots, 0),
        2
    ) as original_snapshot_pct,
    round(
        100.0 * carried_forward_snapshots
        / nullif(expected_account_snapshots, 0),
        2
    ) as carried_forward_pct,
    round(
        100.0 * unavailable_snapshots
        / nullif(expected_account_snapshots, 0),
        2
    ) as unavailable_balance_pct
from daily_summary
