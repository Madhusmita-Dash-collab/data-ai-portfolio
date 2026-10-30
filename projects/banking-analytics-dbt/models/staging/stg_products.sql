with source as (

    select *
    from {{ ref('products') }}

),

renamed_and_casted as (

    select
        cast(product_id as varchar) as product_id,
        cast(product_name as varchar) as product_name,
        cast(product_category as varchar) as product_category
    from source

)

select *
from renamed_and_casted
