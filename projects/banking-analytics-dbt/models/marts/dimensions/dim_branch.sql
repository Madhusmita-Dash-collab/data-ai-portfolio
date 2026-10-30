with branches as (

    select *
    from {{ ref('stg_branches') }}

),

final as (

    select
        md5(branch_id) as branch_key,
        branch_id,
        branch_name,
        city,
        state,
        region
    from branches

)

select *
from final
