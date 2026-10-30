with source_metrics as (

    select
        date_key,
        transaction_date,
        branch_key,
        branch_id,
        product_key,
        product_id,
        count(*) as expected_total_transactions,
        sum(case when lower(transaction_status) = 'success' then 1 else 0 end)
            as expected_successful_transactions,
        sum(case when lower(transaction_status) = 'failed' then 1 else 0 end)
            as expected_failed_transactions,
        sum(case when lower(transaction_status) = 'success' then amount else 0 end)
            as expected_successful_transaction_amount,
        round(
            100.0 * sum(case when lower(transaction_status) = 'success' then 1 else 0 end)
            / nullif(count(*), 0),
            2
        ) as expected_success_rate_pct
    from {{ ref('fct_transaction') }}
    group by
        date_key,
        transaction_date,
        branch_key,
        branch_id,
        product_key,
        product_id

),

kpi_metrics as (

    select *
    from {{ ref('mart_daily_transaction_kpis') }}

),

comparison as (

    select
        s.date_key,
        s.transaction_date,
        s.branch_id,
        s.product_id,
        s.expected_total_transactions,
        k.total_transactions,
        s.expected_successful_transactions,
        k.successful_transactions,
        s.expected_failed_transactions,
        k.failed_transactions,
        s.expected_successful_transaction_amount,
        k.successful_transaction_amount,
        s.expected_success_rate_pct,
        k.success_rate_pct
    from source_metrics s
    full outer join kpi_metrics k
        on s.date_key = k.date_key
        and s.transaction_date = k.transaction_date
        and s.branch_key = k.branch_key
        and s.branch_id = k.branch_id
        and s.product_key = k.product_key
        and s.product_id = k.product_id

)

select *
from comparison
where
    expected_total_transactions is null
    or total_transactions is null
    or total_transactions != expected_total_transactions
    or successful_transactions != expected_successful_transactions
    or failed_transactions != expected_failed_transactions
    or abs(
        successful_transaction_amount - expected_successful_transaction_amount
    ) > 0.01
    or abs(success_rate_pct - expected_success_rate_pct) > 0.01
    or successful_transactions + failed_transactions > total_transactions
