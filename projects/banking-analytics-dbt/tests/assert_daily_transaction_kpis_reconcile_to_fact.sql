with fact_metrics as (
    select
        date_key,
        branch_key,
        product_key,
        count(*) as total_transactions,
        sum(
            case when lower(transaction_status) = 'success'
                then 1 else 0 end
        ) as successful_transactions,
        sum(
            case when lower(transaction_status) = 'failed'
                then 1 else 0 end
        ) as failed_transactions,
        sum(
            case when lower(transaction_status) = 'success'
                then amount else 0 end
        ) as successful_transaction_amount
    from {{ ref('fct_transaction') }}
    group by date_key, branch_key, product_key
),

mart_metrics as (
    select
        date_key,
        branch_key,
        product_key,
        total_transactions,
        successful_transactions,
        failed_transactions,
        successful_transaction_amount
    from {{ ref('mart_daily_transaction_kpis') }}
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
    or f.total_transactions != m.total_transactions
    or f.successful_transactions != m.successful_transactions
    or f.failed_transactions != m.failed_transactions
    or f.successful_transaction_amount != m.successful_transaction_amount
