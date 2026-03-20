with source as (
    select * from {{ source('jackrabbit', 'BIDStudents') }}
),

staged as (
    select
        -- ids
        studentId               as student_id,
        orgId                   as org_id,

        -- personal info
        email,
        firstName               as first_name,
        lastName                as last_name,
        phone,
        dateOfBirth             as date_of_birth,
        city,
        state,
        country,

        -- status
        isActive                as is_active,

        -- timestamps
        createdAt               as created_at,
        updatedAt               as updated_at

    from source
)

select * from staged
