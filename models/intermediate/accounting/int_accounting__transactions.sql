-- Unified financial transaction entity with surrogate key
-- Combines transaction records from QuickBooks and NetSuite
-- Surrogate key generated from source_system + source_transaction_id for cross-system deduplication

with quickbooks_transactions as (
    select * from {{ ref('stg_quickbooks__invoices') }}
),

netsuite_transactions as (
    select * from {{ ref('stg_netsuite__transactions') }}
),

quickbooks_unioned as (
    select
        {{ dbt_utils.generate_surrogate_key(['\'quickbooks\'', 'invoice_id']) }} as transaction_sk,
        'quickbooks'        as source_system,
        cast(invoice_id as varchar) as transaction_id,
        invoice_date        as transaction_date,
        total_amount        as amount,
        'invoice'           as transaction_type,
        customer_id,
        created_at
    from quickbooks_transactions
),

netsuite_unioned as (
    select
        {{ dbt_utils.generate_surrogate_key(['\'netsuite\'', 'transaction_id']) }} as transaction_sk,
        'netsuite'          as source_system,
        cast(transaction_id as varchar) as transaction_id,
        transaction_date,
        amount,
        transaction_type,
        null                as customer_id,
        created_at
    from netsuite_transactions
),

final as (
    select * from quickbooks_unioned
    union all
    select * from netsuite_unioned
)

select * from final
