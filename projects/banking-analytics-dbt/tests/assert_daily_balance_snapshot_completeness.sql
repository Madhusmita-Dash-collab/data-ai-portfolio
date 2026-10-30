with expected_account_dates as (

    select
        d.calendar_date as balance_date,
        a.account_id
    from {{ ref('dim_date') }} d
    inner join {{ ref('dim_account') }} a
        on a.opened_date <= d.calendar_date
        and (
            a.closed_date is null
            or a.closed_date > d.calendar_date
        )

),

actual_snapshots as (

    select
        account_id,
        balance_date,
        count(*) as snapshot_count
    from {{ ref('int_daily_account_balances_synthetic') }}
    group by
        account_id,
        balance_date

),

completeness_check as (

    select
        e.account_id,
        e.balance_date,
        coalesce(s.snapshot_count, 0) as snapshot_count
    from expected_account_dates e
    left join actual_snapshots s
        on e.account_id = s.account_id
        and e.balance_date = s.balance_date

)

select *
from completeness_check
where snapshot_count != 1
