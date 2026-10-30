with customers as (

    select *
    from {{ ref('stg_customers') }}

),

final as (

    select
        md5(customer_id) as customer_key,
        customer_id,
        first_name,
        last_name,
        date_of_birth,
        customer_segment,
        customer_status,
        created_at
    from customers

)

select *
from final
