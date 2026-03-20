{% docs __overview__ %}

# Rocket Youth Analytics — dbt Project

Welcome to the Rocket Youth data catalog. This project transforms raw operational data from all business systems into clean, tested, analytics-ready models in **SingleStore**.

---

## Owners

**Rocket Youth Analytics Team**

| Name | Email |
|---|---|
| Gal Vekselman | gal@rocketyouthbrands.com |
| Matheus Esteves | mesteves@rocketyouthbrands.com |

---

## Data Architecture

Data flows through three transformation layers:

```
Raw Sources  →  Staging (stg_)  →  Intermediate (int_)  →  Marts (fct_ / dim_)
```

| Layer | Prefix | Materialization | Purpose |
|---|---|---|---|
| Staging | `stg_` | View | Rename columns, cast types — one model per source table, no business logic |
| Intermediate | `int_` | Ephemeral | Joins and business logic, never queried directly |
| Marts | `fct_` `dim_` | Table | Final analytics-ready tables, fast to query |

---

## Source Systems

| Source | Database | Domain |
|---|---|---|
| **GoHighLevel** | `gohighlevel_staging` | CRM — contacts, conversations, pipelines, opportunities |
| **Jackrabbit** | `jackrabbit_staging` | Class management — students, enrollments, attendance, payments |
| **Knack** | `ryb_knack_staging` | Internal operations and service management |
| **QuickBooks** | `ryb_quickbooks_staging` | Finance — invoices, payments, bills, vendors |
| **NetSuite** | `ryb_netsuite_staging` | Accounting — transactions, budgets, subsidiaries |
| **UKG** | `ryb_ukg_staging` | HR and workforce — employees, schedules, timecards |
| **iClassPro** | `ryb_iclasspro_*_staging` | Class bookings across multiple locations |
| **Mindbody** | `ryb_mindbody_staging` | Fitness class management |
| **LeagueApps** | `ryb_leagueapps_staging` | Sports league registrations and transactions |
| **Bamboo HR** | `ryb_bamboo_staging` | Employee records and compensation |
| **Google Ads** | `ryb_google_ads_staging` | Marketing performance and ad spend |
| **Ramp** | `ryb_ramp_staging` | Expense management |
| **Pipedrive** | `ryb_pipedrive_staging` | Sales pipeline |
| **EZFacility** | `ryb_ezfacility_staging` | Facility and membership management |
| **RingCentral** | `ryb_ringcentral_staging` | Call logs and recording insights |
| **SportsEngine** | `ryb_sportsengine_staging` | Sports program registrations |
| **TeamSnap** | `ryb_teamsnap_staging` | Team and league management |
| **BracketTeam** | `ryb_bracketteam_staging` | Tournament scheduling |
| **Campsite** | `ryb_campsite_staging` | Camp enrollments |

---

## Naming Conventions

| Pattern | Meaning | Example |
|---|---|---|
| `stg_<source>__<entity>` | Staged source table | `stg_jackrabbit__students` |
| `int_<description>` | Intermediate logic | `int_student_enrollments` |
| `fct_<event>` | Fact table (events/transactions) | `fct_enrollments` |
| `dim_<entity>` | Dimension table (entities) | `dim_customers` |

---

## Data Quality

Every model has tests enforced automatically in CI on every pull request:

- **Primary keys** — `unique` + `not_null` on all key columns
- **Required fields** — `not_null` on business-critical columns
- **Referential integrity** — foreign key relationships validated across models

---

## CI/CD

All changes go through GitHub Actions:

- **Pull Request** → compile + test modified models only
- **Merge to main** → run + test modified models + publish updated docs here

Docs are rebuilt and published automatically after every successful deploy.

{% enddocs %}
