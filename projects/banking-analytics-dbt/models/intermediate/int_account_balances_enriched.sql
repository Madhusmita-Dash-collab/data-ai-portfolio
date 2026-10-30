with account_balances as (

    select *
    from {{ ref('stg_account_balances') }}

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

enriched as (

    select
        bal.account_id,
        bal.balance_date,
        bal.closing_balance,
        bal.currency,

        acc.account_type,
        acc.account_status,
        acc.opened_date,
        acc.closed_date,

        prod.product_id,
        prod.product_name,
        prod.product_category,

        br.branch_id,
        br.branch_name,
        br.city as branch_city,
        br.state as branch_state,
        br.region as branch_region

    from account_balances as bal

    left join accounts as acc
        on bal.account_id = acc.account_id

    left join products as prod
        on acc.product_id = prod.product_id

    left join branches as br
        on acc.branch_id = br.branch_id

)

select *
from enriched
