-- Cross-department customer dimension — Single Source of Truth for all customer entities
-- Merges student, lead, and client records from all source systems using email as unified identity key

with students as (
    select * from {{ ref('dim_students') }}
),

leads as (
    select * from {{ ref('int_marketing__leads') }}
),

student_customers as (
    select
        student_sk          as customer_sk,
        email,
        first_name,
        last_name,
        true                as is_student,
        false               as is_lead,
        source_system       as primary_source_system,
        created_at
    from students
),

lead_customers as (
    select
        lead_sk             as customer_sk,
        email,
        first_name,
        last_name,
        false               as is_student,
        true                as is_lead,
        source_system       as primary_source_system,
        created_at
    from leads
),

-- Union all customer sources and deduplicate by email
all_customers as (
    select * from student_customers
    union all
    select * from lead_customers
),

deduped as (
    select *,
        row_number() over (
            partition by lower(email)
            order by
                case primary_source_system when 'jackrabbit' then 1 else 2 end,
                created_at asc
        ) as row_num
    from all_customers
),

final as (
    select
        customer_sk,
        email,
        first_name,
        last_name,
        is_student,
        is_lead,
        primary_source_system,
        created_at
    from deduped
    where row_num = 1
)

select * from final
