with customer_history as (

    select *
    from {{ ref('snap_customers') }}

),

historical_dimension as (

    select
        md5(
            customer_id || '|' ||
            cast(dbt_valid_from as varchar)
        ) as customer_key,

        customer_id,
        first_name,
        last_name,
        date_of_birth,
        customer_segment,
        customer_status,
        created_at,

        dbt_valid_from as valid_from,
        dbt_valid_to as valid_to,

        case
            when dbt_valid_to is null then true
            else false
        end as is_current

    from customer_history

)

select *
from historical_dimension
