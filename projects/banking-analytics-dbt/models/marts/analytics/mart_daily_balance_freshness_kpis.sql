with daily_metrics as (
    select
        balance_date,
        count(*) as expected_account_snapshots,

        sum(
            case when snapshot_type = 'ORIGINAL'
                then 1 else 0 end
        ) as original_snapshots,

        sum(
            case when snapshot_type = 'CARRIED_FORWARD'
                then 1 else 0 end
        ) as carried_forward_snapshots,

        sum(
            case when snapshot_type = 'NO_PRIOR_BALANCE'
                then 1 else 0 end
        ) as unavailable_snapshots,

        sum(
            case when balance_age_days > 30
                then 1 else 0 end
        ) as stale_snapshots,

        max(balance_age_days) as maximum_balance_age_days

    from {{ ref('int_daily_balance_freshness') }}
    group by balance_date
)

select
    balance_date,
    expected_account_snapshots,
    original_snapshots,
    carried_forward_snapshots,
    unavailable_snapshots,
    stale_snapshots,
    maximum_balance_age_days,

    round(
        100.0 * stale_snapshots
        / nullif(expected_account_snapshots, 0),
        2
    ) as stale_snapshot_pct,

    round(
        100.0 * unavailable_snapshots
        / nullif(expected_account_snapshots, 0),
        2
    ) as unavailable_snapshot_pct

from daily_metrics
