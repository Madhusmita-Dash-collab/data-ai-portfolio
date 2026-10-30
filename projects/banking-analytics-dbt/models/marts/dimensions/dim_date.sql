with date_spine as (

    select
        unnest(
            generate_series(
                date '2024-01-01',
                date '2025-12-31',
                interval '1 day'
            )
        )::date as calendar_date

),

final as (

    select
        cast(strftime(calendar_date, '%Y%m%d') as integer) as date_key,
        calendar_date,
        extract(year from calendar_date)::integer as year,
        extract(quarter from calendar_date)::integer as quarter,
        extract(month from calendar_date)::integer as month,
        strftime(calendar_date, '%B') as month_name,
        extract(day from calendar_date)::integer as day_of_month,
        extract(isodow from calendar_date)::integer as day_of_week,
        strftime(calendar_date, '%A') as day_name,
        case
            when extract(isodow from calendar_date) in (6, 7)
                then true
            else false
        end as is_weekend,
        date_trunc('month', calendar_date)::date as month_start_date
    from date_spine

)

select *
from final
