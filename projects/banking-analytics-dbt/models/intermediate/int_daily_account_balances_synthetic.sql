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

source_balances as (

    select
        account_id,
        balance_date as source_balance_date,
        closing_balance,
        currency
    from {{ ref('stg_account_balances') }}

),

balances_as_of_date as (

    select
        e.account_id,
        e.balance_date,
        e.opened_date,
        e.closed_date,
        s.source_balance_date,
        s.closing_balance,
        s.currency,
        row_number() over (
            partition by e.account_id, e.balance_date
            order by s.source_balance_date desc nulls last
        ) as balance_rank
    from expected_account_dates e
    left join source_balances s
        on e.account_id = s.account_id
        and s.source_balance_date <= e.balance_date

),

latest_balance as (

    select
        account_id,
        balance_date,
        opened_date,
        closed_date,
        source_balance_date,
        closing_balance,
        currency
    from balances_as_of_date
    where balance_rank = 1

)

select
    account_id,
    balance_date,
    opened_date,
    closed_date,
    source_balance_date,
    closing_balance,
    currency,
    case
        when source_balance_date = balance_date then true
        else false
    end as is_original_snapshot,
    case
        when source_balance_date is null then 'NO_PRIOR_BALANCE'
        when source_balance_date = balance_date then 'ORIGINAL'
        else 'CARRIED_FORWARD'
    end as snapshot_type
from latest_balance
