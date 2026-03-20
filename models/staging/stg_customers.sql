with source as (

    select * from {{ source('raw', 'raw_customers') }}

),

staged as (

    select
        email,
        first_name,
        last_name,
        phone,
        date_of_birth,
        city,
        coalesce(country, 'US')         as country,
        signup_date,
        case
            when is_active = 1 then true
            else false
        end                             as is_active

    from source

)

select * from staged
