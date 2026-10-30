with expected_account_dates as (

    select
        d.calendar_date as balance_date,
        a.account_id,
        a.opened_date,
        a.closed_date
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
    from {{ ref('fct_account_balance') }}
    group by
        account_id,
        balance_date

)

select
    e.account_id,
    e.balance_date,
    e.opened_date,
    e.closed_date,
    coalesce(s.snapshot_count, 0) as snapshot_count,
    case
        when s.account_id is null then 'MISSING_SNAPSHOT'
        when s.snapshot_count > 1 then 'DUPLICATE_SNAPSHOT'
    end as issue_type
from expected_account_dates e
left join actual_snapshots s
    on e.account_id = s.account_id
    and e.balance_date = s.balance_date
where coalesce(s.snapshot_count, 0) != 1
