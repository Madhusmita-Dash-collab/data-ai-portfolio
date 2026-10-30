with source as (

    select *
    from {{ ref('account_balances') }}

),

renamed_and_casted as (

    select
        cast(account_id as varchar) as account_id,
        cast(balance_date as date) as balance_date,
        cast(closing_balance as decimal(18, 2)) as closing_balance,
        cast(currency as varchar) as currency
    from source

)

select *
from renamed_and_casted
