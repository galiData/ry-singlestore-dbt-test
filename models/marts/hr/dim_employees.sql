-- Employee dimension table
-- Deduplicated employee records from UKG and BambooHR
-- Built from int_hr__employees — picks the most complete record per email

with employees as (
    select * from {{ ref('int_hr__employees') }}
),

-- Deduplicate by employee_sk, preferring UKG as primary source (payroll system of record)
deduped as (
    select *,
        row_number() over (
            partition by employee_sk
            order by
                case source_system when 'ukg' then 1 else 2 end,
                created_at asc
        ) as row_num
    from employees
),

final as (
    select
        employee_sk,
        email,
        first_name,
        last_name,
        employee_id,
        department,
        employment_status,
        hire_date,
        source_system,
        created_at
    from deduped
    where row_num = 1
)

select * from final
