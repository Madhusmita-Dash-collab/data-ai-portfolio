with allocated_transactions as (

    select *
    from {{ ref('fct_transaction_customer_allocation') }}

),

customer_history as (

    select
        customer_key,
        customer_id,
        customer_segment,
        customer_status,
        valid_from,
        valid_to
    from {{ ref('dim_customer_history') }}

),

historical_customer_match as (

    select
        t.transaction_id,
        t.account_id,
        t.customer_id,
        t.transaction_date,
        t.transaction_amount,
        t.ownership_percentage,
        t.allocated_amount,
        t.currency,

        c.customer_key,
        c.customer_segment,
        c.customer_status,

        case
            when c.customer_key is not null
                then 'MATCHED'
            else 'HISTORY_UNAVAILABLE'
        end as customer_history_status

    from allocated_transactions t

    left join customer_history c
        on t.customer_id = c.customer_id
        and t.transaction_date >= cast(c.valid_from as date)
        and (
            c.valid_to is null
            or t.transaction_date < cast(c.valid_to as date)
        )

)

select *
from historical_customer_match
