with successful_transactions as (

    select
        transaction_id,
        account_id,
        transaction_date,
        amount,
        currency,
        transaction_status
    from {{ ref('fct_transaction') }}
    where transaction_status = 'Success'

),

eligible_customer_relationships as (

    select
        customer_account_key,
        customer_id,
        account_id,
        ownership_percentage,
        effective_from,
        effective_to
    from {{ ref('bridge_customer_account') }}

),

allocated_transactions as (

    select
        t.transaction_id,
        t.account_id,
        r.customer_id,
        r.customer_account_key,
        t.transaction_date,
        t.amount as transaction_amount,
        r.ownership_percentage,

        cast(
            t.amount * r.ownership_percentage / 100.0
            as decimal(18, 2)
        ) as allocated_amount,

        t.currency

    from successful_transactions t

    inner join eligible_customer_relationships r
        on t.account_id = r.account_id
        and t.transaction_date >= r.effective_from
        and (
            r.effective_to is null
            or t.transaction_date < r.effective_to
        )

)

select *
from allocated_transactions