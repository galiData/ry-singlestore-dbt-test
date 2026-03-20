-- Fact table: all payment transactions
-- References int_accounting__transactions for unified financial data across QuickBooks and NetSuite

with transactions as (
    select * from {{ ref('int_accounting__transactions') }}
),

payments as (
    select
        {{ dbt_utils.generate_surrogate_key(['source_system', 'transaction_id']) }} as payment_sk,
        transaction_sk,
        transaction_date    as payment_date,
        amount,
        transaction_type,
        customer_id,
        source_system,
        created_at
    from transactions
    where transaction_type in ('payment', 'invoice', 'receipt')
)

select * from payments
