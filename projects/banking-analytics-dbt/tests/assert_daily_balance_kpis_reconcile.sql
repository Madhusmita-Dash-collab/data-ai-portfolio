with source_metrics as (

    select
        date_key,
        balance_date,
        branch_key,
        branch_id,
        product_key,
        product_id,
        count(distinct account_id) as expected_accounts_with_balance,
        sum(closing_balance) as expected_total_closing_balance,
        avg(closing_balance) as expected_average_closing_balance
    from {{ ref('fct_account_balance') }}
    group by
        date_key,
        balance_date,
        branch_key,
        branch_id,
        product_key,
        product_id

),

kpi_metrics as (

    select *
    from {{ ref('mart_daily_balance_kpis') }}

),

comparison as (

    select
        s.date_key as source_date_key,
        k.date_key as kpi_date_key,
        s.balance_date as source_balance_date,
        k.balance_date as kpi_balance_date,
        s.branch_id as source_branch_id,
        k.branch_id as kpi_branch_id,
        s.product_id as source_product_id,
        k.product_id as kpi_product_id,
        s.expected_accounts_with_balance,
        k.accounts_with_balance,
        s.expected_total_closing_balance,
        k.total_closing_balance,
        s.expected_average_closing_balance,
        k.average_closing_balance
    from source_metrics s
    full outer join kpi_metrics k
        on s.date_key = k.date_key
        and s.balance_date = k.balance_date
        and s.branch_key = k.branch_key
        and s.branch_id = k.branch_id
        and s.product_key = k.product_key
        and s.product_id = k.product_id

)

select *
from comparison
where
    source_date_key is null
    or kpi_date_key is null
    or expected_accounts_with_balance != accounts_with_balance
    or abs(
        expected_total_closing_balance - total_closing_balance
    ) > 0.01
    or abs(
        expected_average_closing_balance - average_closing_balance
    ) > 0.01
