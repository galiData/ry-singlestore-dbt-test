-- Unified lead entity with surrogate key
-- Combines contact records from GoHighLevel and deal/person records from Pipedrive
-- Surrogate key generated from email for cross-system deduplication and joining

with ghl_contacts as (
    select * from {{ ref('stg_gohighlevel__contacts') }}
),

pipedrive_persons as (
    select * from {{ ref('stg_pipedrive__persons') }}
),

ghl_leads as (
    select
        {{ dbt_utils.generate_surrogate_key(['lower(email)']) }} as lead_sk,
        email,
        first_name,
        last_name,
        phone,
        lead_status,
        'gohighlevel'   as source_system,
        created_at
    from ghl_contacts
    where email is not null
),

pipedrive_leads as (
    select
        {{ dbt_utils.generate_surrogate_key(['lower(email)']) }} as lead_sk,
        email,
        first_name,
        last_name,
        phone,
        lead_status,
        'pipedrive'     as source_system,
        created_at
    from pipedrive_persons
    where email is not null
),

final as (
    select * from ghl_leads
    union all
    select * from pipedrive_leads
)

select * from final
