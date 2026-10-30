with relationships as (
    select
        account_id,
        customer_id,
        ownership_percentage,
        effective_from,
        effective_to
    from {{ ref('bridge_customer_account') }}
),

account_lifecycle as (
    select
        account_id,
        opened_date,
        closed_date
    from {{ ref('stg_accounts') }}
),

date_boundaries as (
    select account_id, effective_from as boundary_date
    from relationships

    union

    select account_id, effective_to as boundary_date
    from relationships
    where effective_to is not null

    union

    select account_id, opened_date as boundary_date
    from account_lifecycle

    union

    select account_id, closed_date as boundary_date
    from account_lifecycle
    where closed_date is not null
),

ownership_at_each_boundary as (
    select
        d.account_id,
        d.boundary_date,
        a.opened_date,
        a.closed_date,
        coalesce(sum(r.ownership_percentage), 0)
            as total_ownership_percentage
    from date_boundaries d
    inner join account_lifecycle a
        on d.account_id = a.account_id
    left join relationships r
        on d.account_id = r.account_id
        and r.effective_from <= d.boundary_date
        and (
            r.effective_to is null
            or d.boundary_date < r.effective_to
        )
    where d.boundary_date >= a.opened_date
      and (
          a.closed_date is null
          or d.boundary_date < a.closed_date
      )
    group by
        d.account_id,
        d.boundary_date,
        a.opened_date,
        a.closed_date
)

select *
from ownership_at_each_boundary
where abs(total_ownership_percentage - 100.0) > 0.01
