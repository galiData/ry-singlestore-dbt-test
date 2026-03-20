-- Student dimension table
-- Deduplicated student records across all program management systems
-- Built from int_growth__students — picks the most complete record per email

with students as (
    select * from {{ ref('int_growth__students') }}
),

-- Deduplicate by student_sk, preferring jackrabbit as primary source
deduped as (
    select *,
        row_number() over (
            partition by student_sk
            order by
                case source_system when 'jackrabbit' then 1 else 2 end,
                created_at asc
        ) as row_num
    from students
),

final as (
    select
        student_sk,
        email,
        first_name,
        last_name,
        phone,
        date_of_birth,
        city,
        source_system,
        created_at
    from deduped
    where row_num = 1
)

select * from final
