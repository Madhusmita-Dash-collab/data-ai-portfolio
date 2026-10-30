with products as (

    select *
    from {{ ref('stg_products') }}

),

final as (

    select
        md5(product_id) as product_key,
        product_id,
        product_name,
        product_category
    from products

)

select *
from final
