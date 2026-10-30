select
    balance_date,
    expected_account_snapshots,
    original_snapshots,
    carried_forward_snapshots,
    unavailable_snapshots,
    stale_snapshots,
    stale_snapshot_pct,
    unavailable_snapshot_pct
from {{ ref('mart_daily_balance_freshness_kpis') }}
where
    expected_account_snapshots
        != original_snapshots
        + carried_forward_snapshots
        + unavailable_snapshots

    or stale_snapshots > expected_account_snapshots

    or stale_snapshots < 0

    or unavailable_snapshots < 0

    or abs(
        stale_snapshot_pct
        - round(
            100.0 * stale_snapshots
            / nullif(expected_account_snapshots, 0),
            2
        )
    ) > 0.01

    or abs(
        unavailable_snapshot_pct
        - round(
            100.0 * unavailable_snapshots
            / nullif(expected_account_snapshots, 0),
            2
        )
    ) > 0.01
