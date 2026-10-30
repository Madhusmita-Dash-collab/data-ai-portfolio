select *
from {{ ref('mart_customer_transaction_history') }}
where
    (
        customer_history_status = 'MATCHED'
        and customer_segment is null
    )
    or
    (
        customer_history_status = 'HISTORY_UNAVAILABLE'
        and customer_segment is not null
    )
    or customer_history_status is null
