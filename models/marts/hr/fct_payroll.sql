-- Fact table: payroll earnings per employee per pay period
-- References int_hr__employees for the unified employee dimension

with employees as (
    select * from {{ ref('int_hr__employees') }}
),

ukg_earnings as (
    select * from {{ ref('stg_ukg__earnings_history') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['\'ukg\'', 'earning_id']) }} as payroll_sk,
        e.employee_sk,
        ue.earning_id,
        ue.pay_period_start_date,
        ue.pay_period_end_date,
        ue.gross_pay,
        ue.net_pay,
        ue.earnings_type,
        'ukg'               as source_system
    from ukg_earnings ue
    left join employees e
        on lower(ue.email) = lower(e.email)
)

select * from final
