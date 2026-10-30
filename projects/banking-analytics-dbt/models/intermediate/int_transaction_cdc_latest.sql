with ranked_events as (

    select
        event_id,
        transaction_id,
        account_id,
        transaction_date,
        transaction_type,
        channel,
        amount,
        currency,
        transaction_status,
        operation,
        change_timestamp,

        row_number() over (
            partition by transaction_id
            order by
                change_timestamp desc,
                event_id desc
        ) as row_num

    from {{ ref('stg_transaction_cdc') }}

),

latest_events as (

    select
        event_id,
        transaction_id,
        account_id,
        transaction_date,
        transaction_type,
        channel,
        amount,
        currency,
        transaction_status,
        operation,
        change_timestamp

    from ranked_events
    where row_num = 1

)

select *
from latest_events