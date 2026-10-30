select
    a.customer_id,
    a.account_id,
    a.customer_account_key as relationship_key_1,
    b.customer_account_key as relationship_key_2,
    a.effective_from as start_1,
    a.effective_to as end_1,
    b.effective_from as start_2,
    b.effective_to as end_2
from {{ ref('bridge_customer_account') }} a
inner join {{ ref('bridge_customer_account') }} b
    on a.customer_id = b.customer_id
    and a.account_id = b.account_id
    and a.customer_account_key < b.customer_account_key
    and a.effective_from < coalesce(
        b.effective_to,
        cast('9999-12-31' as date)
    )
    and b.effective_from < coalesce(
        a.effective_to,
        cast('9999-12-31' as date)
    )
