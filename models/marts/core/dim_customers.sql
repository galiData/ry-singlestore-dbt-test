with customers as (

    select * from {{ ref('stg_customers') }}

)

select
    email,
    first_name,
    last_name,
    concat(first_name, ' ', last_name)                      as full_name,
    phone,
    date_of_birth,
    timestampdiff(year, date_of_birth, curdate())           as age,
    city,
    country,
    signup_date,
    is_active

from customers
