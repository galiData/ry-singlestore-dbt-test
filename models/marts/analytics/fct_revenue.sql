-- Cross-department revenue fact table — Single Source of Truth for all revenue
-- Combines payment data from accounting with enrollment revenue from growth systems

with accounting_payments as (
    select * from {{ ref('fct_payments') }}
),

growth_enrollments as (
    select * from {{ ref('fct_enrollments') }}
),

accounting_revenue as (
    select
        {{ dbt_utils.generate_surrogate_key(['\'accounting\'', 'payment_sk']) }} as revenue_sk,
        payment_date        as revenue_date,
        amount,
        transaction_type    as revenue_type,
        'accounting'        as department,
        source_system
    from accounting_payments
    where amount > 0
),

growth_revenue as (
    select
        {{ dbt_utils.generate_surrogate_key(['\'growth\'', 'enrollment_sk']) }} as revenue_sk,
        enrollment_date     as revenue_date,
        null                as amount,  -- join to billing records when available
        'enrollment'        as revenue_type,
        'growth'            as department,
        source_system
    from growth_enrollments
),

final as (
    select * from accounting_revenue
    union all
    select * from growth_revenue
)

select * from final
