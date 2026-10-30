with transactions as (

    select *
    from {{ ref('fct_transaction') }}

),

daily_metrics as (

    select
        date_key,
        transaction_date,
        branch_key,
        branch_id,
        product_key,
        product_id,

        count(*) as total_transactions,

        sum(
            case
                when lower(transaction_status) = 'success' then 1
                else 0
            end
        ) as successful_transactions,

        sum(
            case
                when lower(transaction_status) = 'failed' then 1
                else 0
            end
        ) as failed_transactions,

        sum(
            case
                when lower(transaction_status) = 'success'
                    then amount
                else 0
            end
        ) as successful_transaction_amount,

        round(
            100.0 * sum(
                case
                    when lower(transaction_status) = 'success' then 1
                    else 0
                end
            ) / nullif(count(*), 0),
            2
        ) as success_rate_pct

    from transactions

    group by
        date_key,
        transaction_date,
        branch_key,
        branch_id,
        product_key,
        product_id

)

select *
from daily_metrics
