-- Fact table: all student enrollment events
-- References int_growth__students for the unified student dimension
-- Covers enrollments across Jackrabbit, iClassPro, LeagueApps, Mindbody, EZFacility, SportsEngine, TeamSnap

with students as (
    select * from {{ ref('int_growth__students') }}
),

-- NOTE: Expand with additional enrollment source models as staging models are built out
-- e.g. stg_jackrabbit__enrollments, stg_iclasspro__enrollments, etc.
jackrabbit_enrollments as (
    select * from {{ ref('stg_jackrabbit__enrollments') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['\'jackrabbit\'', 'enrollment_id']) }} as enrollment_sk,
        s.student_sk,
        e.enrollment_id,
        e.enrollment_date,
        e.class_name        as program_name,
        e.status            as enrollment_status,
        'jackrabbit'        as source_system
    from jackrabbit_enrollments e
    left join students s
        on lower(e.email) = lower(s.email)
)

select * from final
