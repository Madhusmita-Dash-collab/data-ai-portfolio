
with source as (

    select *
    from {{ ref('customers') }}

),

renamed_and_casted as (

    select
        cast(customer_id as varchar) as customer_id,
        cast(first_name as varchar) as first_name,
        cast(last_name as varchar) as last_name,
        cast(date_of_birth as date) as date_of_birth,
        cast(customer_segment as varchar) as customer_segment,
        cast(customer_status as varchar) as customer_status,
        cast(created_at as date) as created_at
    from source

)

select *
from renamed_and_casted
