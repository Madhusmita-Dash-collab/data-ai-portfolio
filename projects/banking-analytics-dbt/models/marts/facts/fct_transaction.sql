
{{
    config(
        materialized='incremental',
        unique_key='transaction_id',
        incremental_strategy='delete+insert'
    )
}}

{% if is_incremental() %}

with watermark as (
    select
        coalesce(
            max(ingested_at),
            timestamp '1900-01-01 00:00:00'
        ) as max_ingested_at
    from {{ this }}
),

transactions as (
    select *
    from (
        select
            src.*,
            row_number() over (
                partition by src.transaction_id
                order by src.ingested_at desc
            ) as row_num
        from {{ ref('int_transaction_enriched') }} as src
        cross join watermark as w
        where src.ingested_at >=
            w.max_ingested_at - interval '3 days'
    ) deduplicated
    where row_num = 1
),

{% else %}

with transactions as (
    select *
    from {{ ref('int_transaction_enriched') }}
),

{% endif %}

final as (

    select
        t.transaction_id,

        -- Dimension keys
        a.account_key,
        p.product_key,
        b.branch_key,
        d.date_key,

        -- Source identifiers for traceability
        t.account_id,
        t.product_id,
        t.branch_id,

        -- Transaction attributes
        t.transaction_date,
        t.transaction_type,
        t.channel,
        t.amount,
        t.currency,
        t.transaction_status,
        t.ingested_at,
        -- Reporting measure
        case
            when lower(t.transaction_status) = 'success'
                then 1
            else 0
        end as successful_transaction_count

    from transactions t

    left join {{ ref('dim_account') }} a
        on t.account_id = a.account_id

    left join {{ ref('dim_product') }} p
        on t.product_id = p.product_id

    left join {{ ref('dim_branch') }} b
        on t.branch_id = b.branch_id

    left join {{ ref('dim_date') }} d
        on cast(t.transaction_date as date) = d.calendar_date

)

select *
from final