with balances as (

    select *
    from {{ ref('int_account_balances_enriched') }}

),

final as (

    select
        -- Dimension keys
        a.account_key,
        p.product_key,
        b.branch_key,
        d.date_key,

        -- Business identifiers
        balances.account_id,
        balances.product_id,
        balances.branch_id,
        cast(balances.balance_date as date) as balance_date,

        -- Financial measures
        balances.closing_balance,
        balances.currency

    from balances

    left join {{ ref('dim_account') }} a
        on balances.account_id = a.account_id

    left join {{ ref('dim_product') }} p
        on balances.product_id = p.product_id

    left join {{ ref('dim_branch') }} b
        on balances.branch_id = b.branch_id

    left join {{ ref('dim_date') }} d
        on cast(balances.balance_date as date) = d.calendar_date

)

select *
from final
