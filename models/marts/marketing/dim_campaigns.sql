-- Campaign dimension table
-- Unified campaign records from Google Ads and GoHighLevel
-- Surrogate key generated from source_system + campaign_id

with google_ads_campaigns as (
    select * from {{ ref('stg_google_ads__campaign') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['\'google_ads\'', 'campaign_id']) }} as campaign_sk,
        campaign_id,
        campaign_name,
        campaign_status,
        'google_ads'    as source_system,
        created_at
    from google_ads_campaigns
)

select * from final
