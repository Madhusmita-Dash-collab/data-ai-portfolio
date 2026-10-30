select
    transaction_id,
    count(*) as row_count
from {{ ref('stg_transactions') }}
where transaction_id is not null
group by transaction_id
having count(*) > 1
