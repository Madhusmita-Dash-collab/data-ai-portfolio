with fact_metrics as (
    select
        date_key,
        branch_key,
        product_key,
        count(distinct account_id) as accounts_with_balance,
        sum(closing_balance) as total_closing_balance
    from {{ ref('fct_account_balance') }}
    group by date_key, branch_key, product_key
),

mart_metrics as (
    select
        date_key,
        branch_key,
        product_key,
        accounts_with_balance,
        total_closing_balance
    from {{ ref('mart_daily_balance_kpis') }}
)

select
    coalesce(f.date_key, m.date_key) as date_key,
    coalesce(f.branch_key, m.branch_key) as branch_key,
    coalesce(f.product_key, m.product_key) as product_key
from fact_metrics f
full outer join mart_metrics m
    on f.date_key = m.date_key
    and f.branch_key = m.branch_key
    and f.product_key = m.product_key
where
       f.date_key is null
    or m.date_key is null
    or f.accounts_with_balance != m.accounts_with_balance
    or f.total_closing_balance != m.total_closing_balance
