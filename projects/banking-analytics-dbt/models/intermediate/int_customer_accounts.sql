with customer_account_relationships as (

    select *
    from {{ ref('stg_customer_account_relationships') }}

),

customers as (

    select *
    from {{ ref('stg_customers') }}

),

accounts as (

    select *
    from {{ ref('stg_accounts') }}

),

products as (

    select *
    from {{ ref('stg_products') }}

),

branches as (

    select *
    from {{ ref('stg_branches') }}

),

joined as (

    select
        rel.customer_id,
        cust.first_name,
        cust.last_name,
        cust.customer_segment,
        cust.customer_status,

        rel.account_id,
        acc.account_type,
        acc.account_status,
        acc.opened_date,
        acc.closed_date,
        acc.currency,

        rel.relationship_type,
        rel.ownership_percentage,
        rel.effective_from,
        rel.effective_to,

        prod.product_id,
        prod.product_name,
        prod.product_category,

        br.branch_id,
        br.branch_name,
        br.city as branch_city,
        br.state as branch_state,
        br.region as branch_region

    from customer_account_relationships as rel

    left join customers as cust
        on rel.customer_id = cust.customer_id

    left join accounts as acc
        on rel.account_id = acc.account_id

    left join products as prod
        on acc.product_id = prod.product_id

    left join branches as br
        on acc.branch_id = br.branch_id

)

select *
from joined
