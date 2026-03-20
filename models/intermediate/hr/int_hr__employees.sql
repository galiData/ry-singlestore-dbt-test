-- Unified employee entity with surrogate key
-- Combines employee records from UKG and BambooHR
-- Surrogate key generated from email for cross-system deduplication and joining

with ukg_employees as (
    select * from {{ ref('stg_ukg__employees') }}
),

bamboo_employees as (
    select * from {{ ref('stg_bamboo__employees') }}
),

ukg_unioned as (
    select
        {{ dbt_utils.generate_surrogate_key(['lower(email)']) }} as employee_sk,
        email,
        first_name,
        last_name,
        employee_id,
        department,
        employment_status,
        hire_date,
        'ukg'           as source_system,
        created_at
    from ukg_employees
    where email is not null
),

bamboo_unioned as (
    select
        {{ dbt_utils.generate_surrogate_key(['lower(email)']) }} as employee_sk,
        email,
        first_name,
        last_name,
        employee_id,
        department,
        employment_status,
        hire_date,
        'bamboo'        as source_system,
        created_at
    from bamboo_employees
    where email is not null
),

final as (
    select * from ukg_unioned
    union all
    select * from bamboo_unioned
)

select * from final
