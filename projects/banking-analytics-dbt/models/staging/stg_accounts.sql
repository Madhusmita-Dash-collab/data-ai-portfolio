with source as (

    select *
    from {{ ref('accounts') }}

),

renamed_and_casted as (

    select
        cast(account_id as varchar) as account_id,
        cast(product_id as varchar) as product_id,
        cast(branch_id as varchar) as branch_id,
        cast(account_type as varchar) as account_type,
        cast(account_status as varchar) as account_status,
        cast(opened_date as date) as opened_date,
        cast(closed_date as date) as closed_date,
        cast(currency as varchar) as currency
    from source

)

select *
from renamed_and_casted
