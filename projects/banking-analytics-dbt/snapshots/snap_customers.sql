{% snapshot snap_customers %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_segment', 'customer_status']
    )
}}

select
    customer_id,
    first_name,
    last_name,
    date_of_birth,
    customer_segment,
    customer_status,
    created_at
from {{ ref('stg_customers') }}

{% endsnapshot %}
