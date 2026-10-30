
with source as (

    select *
    from {{ ref('branches') }}

),

renamed_and_casted as (

    select
        cast(branch_id as varchar) as branch_id,
        cast(branch_name as varchar) as branch_name,
        cast(city as varchar) as city,
        cast(state as varchar) as state,
        cast(region as varchar) as region
    from source

)

select *
from renamed_and_casted
