-- Vendor dimension table
-- Deduplicated vendor records from QuickBooks and NetSuite
-- Surrogate key generated from source_system + vendor_id

with quickbooks_vendors as (
    select * from {{ ref('stg_quickbooks__customers') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['\'quickbooks\'', 'customer_id']) }} as vendor_sk,
        customer_id     as vendor_id,
        customer_name   as vendor_name,
        email,
        phone,
        'quickbooks'    as source_system,
        created_at,
        updated_at
    from quickbooks_vendors
)

select * from final
