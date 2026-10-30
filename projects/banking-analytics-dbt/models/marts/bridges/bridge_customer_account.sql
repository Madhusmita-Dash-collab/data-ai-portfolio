with relationships as (

    select *
    from {{ ref('stg_customer_account_relationships') }}

),

final as (

    select
        md5(customer_id || '|' || account_id || '|' ||
            cast(effective_from as varchar)) as customer_account_key,

        customer_id,
        account_id,
        relationship_type,
        ownership_percentage,
        effective_from,
        effective_to,

        case
            when effective_to is null then true
            else false
        end as is_current

    from relationships

)

select *
from final
