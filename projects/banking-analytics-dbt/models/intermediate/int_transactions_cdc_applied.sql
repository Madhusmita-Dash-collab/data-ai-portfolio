with existing_transactions as (

    select
        transaction_id,
        account_id,
        transaction_date,
        transaction_type,
        channel,
        amount,
        currency,
        transaction_status,
        false as is_deleted,
        cast(null as timestamp) as deleted_at

    from {{ ref('stg_transactions') }}

),

cdc_events as (

    select *
    from {{ ref('int_transaction_cdc_latest') }}

),

active_cdc_records as (

    select
        transaction_id,
        account_id,
        transaction_date,
        transaction_type,
        channel,
        amount,
        currency,
        transaction_status,
        false as is_deleted,
        cast(null as timestamp) as deleted_at

    from cdc_events
    where operation in ('INSERT', 'UPDATE')

),

deleted_cdc_records as (

    select
        transaction_id,
        account_id,
        transaction_date,
        transaction_type,
        channel,
        amount,
        currency,
        transaction_status,
        true as is_deleted,
        change_timestamp as deleted_at

    from cdc_events
    where operation = 'DELETE'

),

all_cdc_records as (

    select * from active_cdc_records

    union all

    select * from deleted_cdc_records

),

existing_not_in_cdc as (

    select e.*
    from existing_transactions e
    left join cdc_events c
        on e.transaction_id = c.transaction_id
    where c.transaction_id is null

)

select * from existing_not_in_cdc

union all

select * from all_cdc_records