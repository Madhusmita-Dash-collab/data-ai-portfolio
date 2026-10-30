with source as (

    select *
    from {{ ref('transaction_cdc') }}

),

renamed_casted as (

    select
        cast(event_id as varchar) as event_id,
        cast(transaction_id as varchar) as transaction_id,
        cast(account_id as varchar) as account_id,
        cast(transaction_date as date) as transaction_date,
        cast(transaction_type as varchar) as transaction_type,
        cast(channel as varchar) as channel,
        cast(amount as decimal(18,2)) as amount,
        cast(currency as varchar) as currency,
        cast(transaction_status as varchar) as transaction_status,
        upper(trim(cast(operation as varchar))) as operation,
        cast(change_timestamp as timestamp) as change_timestamp

    from source

)

select *
from renamed_casted
