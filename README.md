# RY SingleStore dbt Project

This repository contains the data transformation layer for Rocket Youth's analytics platform. It uses **dbt (data build tool)** to transform raw operational data stored in **SingleStore** into clean, analytics-ready models.

---

## What is dbt?

dbt (data build tool) is an open-source framework that allows data analysts and engineers to transform raw data in a warehouse using SQL. It brings **software engineering best practices** — version control, testing, documentation, and modular design — to data transformation.

Instead of writing ad-hoc SQL scripts or building complex ETL pipelines, dbt lets you:

- Write **SELECT statements** and dbt handles the materialization (views, tables)
- Define **tests** to validate data quality automatically
- Generate **documentation** from your code and schema definitions
- Track **data lineage** — see exactly how every column in every table was derived

---

## Project Architecture

Data flows through three layers:

```
Raw Sources (SingleStore)
        │
        ▼
┌─────────────────┐
│    Staging      │  stg_*   → views, one model per source table
│                 │            rename columns, cast types, no logic
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Intermediate   │  int_*   → ephemeral, joins and business logic
│                 │            never exposed directly to end users
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     Marts       │  fct_*   → fact tables (events, transactions)
│                 │  dim_*   → dimension tables (customers, locations)
│                 │            materialized as tables, analytics-ready
└─────────────────┘
```

### Naming Conventions

| Prefix | Layer | Example |
|---|---|---|
| `stg_` | Staging | `stg_customers` |
| `int_` | Intermediate | `int_customer_orders` |
| `fct_` | Marts — Facts | `fct_enrollments` |
| `dim_` | Marts — Dimensions | `dim_customers` |

### Source Systems

Each source system has its own subfolder under `models/staging/`:

| Source | Database | Description |
|---|---|---|
| GoHighLevel | `gohighlevel_staging` | CRM, conversations, pipelines |
| Jackrabbit | `jackrabbit_staging` | Class management, enrollments, students |
| Knack | `ryb_knack_staging` | Internal operations |
| QuickBooks | `ryb_quickbooks_staging` | Finance and billing |
| NetSuite | `ryb_netsuite_staging` | Accounting |
| UKG | `ryb_ukg_staging` | HR and workforce management |
| iClassPro | `ryb_iclasspro_*_staging` | Class bookings per location |
| Mindbody | `ryb_mindbody_staging` | Fitness class management |
| LeagueApps | `ryb_leagueapps_staging` | Sports league management |
| Bamboo HR | `ryb_bamboo_staging` | Employee records |
| Google Ads | `ryb_google_ads_staging` | Marketing performance |
| Ramp | `ryb_ramp_staging` | Expense management |
| Pipedrive | `ryb_pipedrive_staging` | Sales pipeline |

---

## Project Structure

```
ry-singlestore-dbt-test/
├── .github/
│   └── workflows/
│       └── dbt.yml               # CI/CD pipeline
├── models/
│   ├── staging/                  # One subfolder per source system
│   │   ├── _sources.yml          # Source table definitions + tests
│   │   ├── _staging.yml          # Staging model docs + tests
│   │   └── stg_*.sql             # Staging models
│   ├── intermediate/             # Business logic and joins
│   └── marts/
│       └── core/                 # Analytics-ready fact and dim tables
│           ├── _core.yml
│           ├── fct_*.sql
│           └── dim_*.sql
├── macros/
│   └── generate_schema_name.sql  # Prevents schema name prefixing
├── tests/                        # Custom singular tests
├── seeds/                        # Static CSV reference data
├── snapshots/                    # SCD Type 2 change tracking
├── analyses/                     # Ad-hoc exploratory SQL
├── dbt_project.yml               # Project configuration
├── profiles.yml                  # Connection configuration (uses env vars)
├── packages.yml                  # dbt packages (dbt_utils)
└── requirements.txt              # Python dependencies
```

---

## dbt Best Practices Applied

### 1. Sources over direct table references
Raw tables are declared as `sources` in `_sources.yml`. Models reference them via `{{ source('system', 'table') }}` — never raw SQL table names. This enables lineage tracking and source freshness checks.

### 2. One model, one file
Each staging model maps to exactly one source table. No joins in staging — that belongs in intermediate.

### 3. Refs over direct model references
Models reference each other with `{{ ref('model_name') }}`. dbt resolves dependencies automatically and builds in the correct order.

### 4. Tests on every model
Every model has at minimum:
- `unique` + `not_null` on primary keys
- `not_null` on required fields

Tests run automatically in CI on every pull request.

### 5. Materialization by layer
- **Staging** → `view` (always fresh, no storage cost)
- **Intermediate** → `ephemeral` (inlined as CTEs, no objects created)
- **Marts** → `table` (pre-computed for fast query performance)

### 6. Documentation in code
Column descriptions live in `_*.yml` files alongside the models. Running `dbt docs generate` produces a full data catalog published automatically to S3.

---

## CI/CD Pipeline

Every code change triggers the GitHub Actions pipeline:

```
Pull Request
  └── dbt compile          (validate SQL syntax)
  └── dbt test             (run data quality tests, --no-fail-fast)

Merge to main
  └── dbt run              (build all models, --no-fail-fast)
  └── dbt test             (validate data quality)
  └── dbt docs generate    (build data catalog)
  └── aws s3 sync          (publish docs to S3)
```

`--no-fail-fast` means a broken model does not block unrelated models from running.

**dbt Docs (auto-updated on every deploy):**
http://ry-dbt.s3-website-us-east-1.amazonaws.com

---

## Local Setup

**Prerequisites:** Python 3.12+, Git

```bash
# 1. Clone the repo
git clone https://github.com/galiData/ry-singlestore-dbt-test.git
cd ry-singlestore-dbt-test

# 2. Create and activate virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
source venv/bin/activate     # Mac/Linux

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure connection
cp .env.example .env         # Fill in your SingleStore credentials

# 5. Load env vars (PowerShell)
Get-Content .env | Where-Object { $_ -match '^\s*[^#]' } | ForEach-Object { $k,$v = $_ -split '=',2; [System.Environment]::SetEnvironmentVariable($k.Trim(), $v.Trim().Trim("'"), 'Process') }

# 6. Verify connection
dbt debug --profiles-dir .

# 7. Install dbt packages
dbt deps

# 8. Run models
dbt run --profiles-dir .

# 9. Run tests
dbt test --profiles-dir .

# 10. Generate and serve docs locally
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

---

## Environment Variables

All connection details are passed via environment variables — never hardcoded.

| Variable | Description |
|---|---|
| `DBT_SINGLESTORE_HOST` | SingleStore cluster hostname |
| `DBT_SINGLESTORE_PORT` | Port (default: `3306`) |
| `DBT_SINGLESTORE_USER` | Database user |
| `DBT_SINGLESTORE_PASSWORD` | Database password |
| `DBT_SINGLESTORE_DATABASE` | Target database |
| `DBT_SINGLESTORE_SCHEMA` | Target schema (same as database in SingleStore) |

In CI/CD these are stored as **GitHub Actions Secrets** and injected at runtime.
