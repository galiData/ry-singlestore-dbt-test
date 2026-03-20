-- Unified student entity with surrogate key
-- Combines student records from Jackrabbit and iClassPro
-- Surrogate key generated from email for cross-system joining

with jackrabbit_students as (
    select * from {{ ref('stg_jackrabbit__students') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['lower(email)']) }} as student_sk,
        email,
        first_name,
        last_name,
        phone,
        date_of_birth,
        city,
        'jackrabbit'    as source_system,
        created_at
    from jackrabbit_students
    where email is not null
)

select * from final
