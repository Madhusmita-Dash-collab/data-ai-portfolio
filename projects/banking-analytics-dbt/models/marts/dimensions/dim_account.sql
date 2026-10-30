with accounts as (

    select *
    from {{ ref('stg_accounts') }}

),

final as (

    select
        md5(account_id) as account_key,
        account_id,
        product_id,
        branch_id,
        account_type,
        account_status,
        opened_date,
        closed_date,
        currency
    from accounts

)

select *
from final
