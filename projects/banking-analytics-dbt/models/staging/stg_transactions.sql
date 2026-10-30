with source as (

    select *
    from {{ ref('transactions') }}

),

renamed_and_casted as (

    select
        cast(transaction_id as varchar) as transaction_id,
        cast(account_id as varchar) as account_id,
        cast(transaction_date as date) as transaction_date,
        cast(transaction_type as varchar) as transaction_type,
        cast(channel as varchar) as channel,
        cast(amount as decimal(18, 2)) as amount,
        cast(currency as varchar) as currency,
        cast(transaction_status as varchar) as transaction_status,
        cast(ingested_at as timestamp) as ingested_at
    from source

)

select *
from renamed_and_casted
