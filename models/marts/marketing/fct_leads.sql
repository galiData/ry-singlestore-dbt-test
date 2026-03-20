-- Fact table: all lead interaction events
-- References int_marketing__leads for unified lead data across GoHighLevel and Pipedrive

with leads as (
    select * from {{ ref('int_marketing__leads') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['source_system', 'lead_sk']) }} as lead_event_sk,
        lead_sk,
        created_at      as event_date,
        lead_status,
        email,
        first_name,
        last_name,
        phone,
        source_system
    from leads
)

select * from final
