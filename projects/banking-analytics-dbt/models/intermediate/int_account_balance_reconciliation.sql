
with balances_with_previous as (

    select
        account_id,
        balance_date,
        closing_balance as actual_closing_balance,
        currency,

        lag(balance_date) over (
            partition by account_id
            order by balance_date
        ) as previous_balance_date,

        lag(closing_balance) over (
            partition by account_id
            order by balance_date
        ) as previous_closing_balance

    from {{ ref('stg_account_balances') }}

),

transaction_movements as (

    select
        account_id,
        transaction_date,
        transaction_type,
        amount,

        case
            when lower(transaction_type) = 'deposit'
                then amount
            when lower(transaction_type) = 'withdrawal'
                then -amount
            else 0
        end as signed_amount,

        case
            when lower(transaction_type) in ('deposit', 'withdrawal')
                then 0
            else 1
        end as unsupported_movement

    from {{ ref('stg_transactions') }}
    where lower(transaction_status) = 'success'

),

reconciliation as (

    select
        b.account_id,
        b.previous_balance_date,
        b.balance_date,
        b.previous_closing_balance,

        coalesce(sum(t.signed_amount), 0)
            as known_net_transaction_movement,

        coalesce(sum(t.unsupported_movement), 0)
            as unsupported_transaction_count,

        coalesce(
            sum(
                case
                    when t.unsupported_movement = 1
                        then t.amount
                    else 0
                end
            ),
            0
        ) as unsupported_transaction_amount,

        b.actual_closing_balance,
        b.currency

    from balances_with_previous b

    left join transaction_movements t
        on b.account_id = t.account_id
        and t.transaction_date > b.previous_balance_date
        and t.transaction_date <= b.balance_date

    where b.previous_balance_date is not null

    group by
        b.account_id,
        b.previous_balance_date,
        b.balance_date,
        b.previous_closing_balance,
        b.actual_closing_balance,
        b.currency

),

calculated as (

    select
        *,
        previous_closing_balance
            + known_net_transaction_movement
            as expected_closing_balance,

        actual_closing_balance
            - (
                previous_closing_balance
                + known_net_transaction_movement
            ) as reconciliation_difference

    from reconciliation

)

select
    *,

    case
        when unsupported_transaction_count > 0
            then 'REVIEW_REQUIRED'
        when abs(reconciliation_difference) <= 0.01
            then 'RECONCILED'
        else 'UNRECONCILED'
    end as reconciliation_status

from calculated
