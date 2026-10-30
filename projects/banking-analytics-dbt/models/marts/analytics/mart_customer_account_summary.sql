with customer_accounts as (

    select
        customer_id,
        count(distinct account_id) as linked_account_count,
        count(distinct case
            when is_current then account_id
        end) as current_linked_account_count
    from {{ ref('bridge_customer_account') }}
    group by customer_id

),

customer_details as (

    select
        customer_key,
        customer_id,
        first_name,
        last_name,
        customer_segment,
        customer_status,
        created_at
    from {{ ref('dim_customer') }}

),

final as (

    select
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        c.customer_segment,
        c.customer_status,
        c.created_at,
        coalesce(a.linked_account_count, 0) as linked_account_count,
        coalesce(a.current_linked_account_count, 0)
            as current_linked_account_count
    from customer_details c
    left join customer_accounts a
        on c.customer_id = a.customer_id

)

select *
from final
