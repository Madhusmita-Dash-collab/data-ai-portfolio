with balances as (

    select *
    from {{ ref('fct_account_balance') }}

),

daily_metrics as (

    select
        date_key,
        balance_date,
        branch_key,
        branch_id,
        product_key,
        product_id,

        count(distinct account_id) as accounts_with_balance,

        sum(closing_balance) as total_closing_balance,

        avg(closing_balance) as average_closing_balance

    from balances

    group by
        date_key,
        balance_date,
        branch_key,
        branch_id,
        product_key,
        product_id

)

select *
from daily_metrics
