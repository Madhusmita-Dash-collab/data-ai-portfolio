with source as (
    select * from {{ref('customer_account_relationships')}}
),
renamed_and_casted as (
    select
        cast(customer_id as varchar) as customer_id,
        cast(account_id as varchar) as account_id,
        cast(relationship_type as varchar) as relationship_type,
        cast(ownership_percentage as integer) as ownership_percentage,
        cast(effective_from as date) as effective_from,
        cast(effective_to as date) as effective_to
    from source 
)
select * from renamed_and_casted