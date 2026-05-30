#  MoMo SMS Data Analyzer

A web application that parses, processes, and visualizes MTN Mobile Money (MoMo) SMS transaction data — turning raw XML messages into a clean, queryable, and well-structured financial database.

---

## Team — The GRID

| Name | GitHub |
|---|---|
| Karega Uwase Ines | [@Ines-karega](https://github.com/Ines-karega) |
| Kayumba Isaro Gania | [@Gania-Isaro](https://github.com/Gania-Isaro)|
| Keza Rutayisire Alicia | [@Alicia-Keza](https://github.com/Alicia-Keza) |
| Nshizirungu Wilson | [@nshizirunguwilson](https://github.com/nshizirunguwilson)|
| Teta Aline | [@Tetaaline](https://github.com/Tetaaline)|

---

## The Problem

MTN MoMo users receive hundreds of SMS messages for every transaction — sending money, receiving payments, paying bills, buying airtime, and more. These messages are stored as raw XML, making it nearly impossible to search, filter, or understand your own financial history at a glance.

## Our Solution

This application provides an end-to-end pipeline that:

- **Parses** raw MoMo XML SMS exports from Android devices
- **Cleans and transforms** each message into structured transaction records
- **Categorizes** transactions (sent money, received money, merchant payments, airtime, bill payments, etc.)
- **Stores** everything in a normalized MySQL relational database (`momo_db`)
- **Exposes** data via a REST API with well-defined JSON response shapes
- **Displays** results on an interactive dashboard with charts and filterable tables

---

## System Architecture

```
Raw XML SMS Backup
        │
        ▼
  [ETL Pipeline]       ── Parses, cleans, and categorizes SMS messages
        │
        ▼
   [momo_db]           ── MySQL relational database (12 tables)
        │
        ▼
  [REST API Layer]     ── Serves structured JSON responses
        │
        ▼
 [Web Dashboard]       ── Charts, tables, and transaction explorer
```

>  [View full architecture diagram](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&dark=auto#Uhttps%3A%2F%2Fdrive.google.com%2Fuc%3Fid%3D1pJqEcyqJ5frSs4OMQe_iEsQh8y3e-S65%26export%3Ddownload)

---

## AI Usage Log Document

A detailed, honest record of every AI tool interaction during this project — limited to permitted uses (grammar/syntax checking, code syntax verification, and cited MySQL best-practice research), with inline attribution in the affected code.

> 📄 [`docs/AI_USAGE_LOG.md`](docs/AI_USAGE_LOG.md)

---

## Database Design Document

The full design document (PDF): ERD with documentation, design rationale, data dictionary, sample queries with screenshots, and the security/accuracy rules added to the database.

> 📄 [`docs/Database Design Document - The GRID.pdf`](docs/Database%20Design%20Document%20-%20The%20GRID.pdf)

---

## Database Output Screenshots

Screenshots of executed SQL — CRUD query results (`Q001`–`Q011`) and security/constraint enforcement (`SEC001`–`SEC008`) — used as evidence in the design document.

> 📁 [`docs/screenshots/`](docs/screenshots/)

---

## Database Design (`momo_db`)

The database is built in **MySQL** with `utf8mb4` encoding and InnoDB engine throughout. It consists of **12 tables** organized into three layers.

### Entity Tables

| Table | Description |
|---|---|
| `users` | End users who own MoMo accounts |
| `agents` | MoMo agents facilitating cash-in / cash-out |
| `merchants` | Businesses accepting MoMo payments |
| `service_providers` | Utility, telco, and insurance providers billed via MoMo |
| `phone_numbers` | Polymorphic — links numbers to users or agents |
| `accounts` | MoMo accounts (personal, merchant, or agent) linked to users |

### Transaction Tables

| Table | Description |
|---|---|
| `sms_messages` | Raw ingested SMS messages — source of truth for all parsing |
| `transaction_categories` | Lookup table: category slug + credit/debit direction |
| `transactions` | Core transaction records linked to accounts and categories |
| `transaction_participants` | Polymorphic junction table — senders, receivers, facilitators |
| `balance_snapshots` | Account balance recorded after each transaction |

### System Table

| Table | Description |
|---|---|
| `system_logs` | Parse success, failure, and duplicate events for observability |

### Transaction Categories

| Category slug | Direction | Meaning |
|---|---|---|
| `send_money` | debit | Transfer to another user |
| `merchant_payment` | debit | Payment to a shop / merchant |
| `airtime_purchase` | debit | Airtime top-up |
| `bill_payment` | debit | Utility / insurance / telco bill |
| `receive_money` | credit | Inbound transfer |
| `cash_in` | credit | Deposit via agent |
| `cash_out` | debit | Withdrawal via agent |

### Key Design Decisions

- **Polymorphic FKs** — `phone_numbers.owner_id` and `transaction_participants.party_id` resolve to different entity tables depending on their `owner_type` / `party_type` discriminator columns.
- **Balance snapshots** — every completed transaction stores the resulting account balance for auditing and charting.
- **System logs** — every SMS parse attempt (success, failure, or duplicate) is recorded for debugging and monitoring.
- **Source traceability** — every transaction links back to the raw SMS it was parsed from via `source_sms_id`.

---

### Relationships & Cardinality

| Relationship | Cardinality | Foreign Key | On Delete | On Update |
|---|---|---|---|---|
| `users` → `accounts` | 1 : M | `accounts.user_id` | RESTRICT | CASCADE |
| `accounts` → `transactions` | 1 : M | `transactions.account_id` | RESTRICT | CASCADE |
| `transaction_categories` → `transactions` | 1 : M | `transactions.category_id` | RESTRICT | CASCADE |
| `sms_messages` → `transactions` | 1 : 0..1 | `transactions.source_sms_id` | SET NULL | CASCADE |
| `transactions` → `transaction_participants` | 1 : M | `transaction_participants.transaction_id` | CASCADE | CASCADE |
| `transactions` → `balance_snapshots` | 1 : 1 | `balance_snapshots.transaction_id` | CASCADE | CASCADE |
| `accounts` → `balance_snapshots` | 1 : M | `balance_snapshots.account_id` | CASCADE | CASCADE |
| `sms_messages` → `system_logs` | 1 : M (nullable) | `system_logs.sms_id` | SET NULL | CASCADE |
| `transactions` → `system_logs` | 1 : M (nullable) | `system_logs.transaction_id` | SET NULL | CASCADE |
| `users` / `agents` → `phone_numbers` | 1 : M (polymorphic) | `phone_numbers.owner_id` + `owner_type` | — | — |
| `users` / `agents` / `merchants` / `service_providers` → `transaction_participants` | M : N (polymorphic) | `transaction_participants.party_id` + `party_type` | — | — |

**Notes:**

- `users → accounts` is **1:M** — one user can hold multiple accounts (personal, merchant, agent), but every account belongs to exactly one user.
- `accounts → transactions` is **1:M** — one account has many transactions; every transaction is tied to exactly one account.
- `sms_messages → transactions` is **1:0..1** — one SMS produces at most one transaction. The FK is nullable (`source_sms_id` can be `NULL`) to allow manually inserted transactions with no source SMS.
- `transactions → transaction_participants` is **1:M** — one transaction has multiple participants (e.g. a sender and a receiver). The junction table resolves the M:N relationship between transactions and any entity type (user, agent, merchant, provider).
- `transactions → balance_snapshots` is effectively **1:1** — one snapshot is recorded per transaction per account, capturing the balance immediately after.
- `system_logs` FKs to both `sms_messages` and `transactions` are **nullable** — a log entry may relate to a failed SMS parse (no transaction yet) or to a transaction with no linked SMS.
- **Polymorphic relationships** (`phone_numbers`, `transaction_participants`) use a discriminator column (`owner_type`, `party_type`) to identify which table `owner_id` / `party_id` points to. MySQL cannot enforce these with standard FKs; resolution is handled at the application layer.
- All standard FKs use `ON UPDATE CASCADE` so that primary key changes propagate automatically, and either `ON DELETE RESTRICT` (to protect financial records) or `ON DELETE CASCADE` / `SET NULL` where child rows are safe to remove or orphan.

---

## Indexes & Constraints

### Indexes

| Index | Table | Columns | Purpose |
|---|---|---|---|
| `idx_transactions_date` | `transactions` | `transaction_date` | Date-range queries and sorting |
| `idx_transactions_status` | `transactions` | `status` | Filter by pending / completed / failed |
| `idx_transactions_status_date` | `transactions` | `status, transaction_date` | Combined status + date filters (e.g. failed in last 7 days) |
| `idx_participants_party` | `transaction_participants` | `party_type, party_id` | Fast participant lookups |
| `idx_phones_owner` | `phone_numbers` | `owner_type, owner_id` | Phone-to-owner resolution |
| `idx_sms_received` | `sms_messages` | `received_epoch_ms` | Chronological SMS ordering |
| `idx_sms_address` | `sms_messages` | `address` | Filter by SMS sender |
| `idx_logs_created` | `system_logs` | `created_at` | Log timeline queries |
| `idx_logs_event` | `system_logs` | `event_type` | Filter by event type |
| `idx_snapshots_at` | `balance_snapshots` | `snapshot_at` | Balance history lookups |

### Uniqueness Constraints

| Constraint | Table | Column | Rule |
|---|---|---|---|
| `uq_account_number` | `accounts` | `account_number` | No duplicate account numbers |
| `uq_agent_code` | `agents` | `agent_code` | Each agent code is unique |
| `uq_shop_code` | `merchants` | `shop_code` | Each merchant shop code is unique |
| `uq_provider_name` | `service_providers` | `provider_name` | Prevents ambiguous joins on provider name |
| `uq_category_name` | `transaction_categories` | `name` | One row per category slug |
| `uq_external_tx_id` | `transactions` | `external_tx_id` | Prevents duplicate transaction ingestion |
| `uq_msisdn` | `phone_numbers` | `msisdn` | Each phone number registered once |

### Format & Business Rule Checks

| Constraint | Rule |
|---|---|
| `chk_msisdn_format` | Phone numbers must match `^250[0-9]{9}$` (Rwandan format) |
| `chk_account_number_format` | Account numbers must be exactly 8 digits |
| `chk_external_tx_id_format` | Must match `TXNxxxxxxx` or numeric format |
| `chk_transactions_amount` | Transaction amount must be `> 0` |
| `chk_transactions_amount_max` | Transaction amount must be `<= 10,000,000 RWF` |
| `chk_transactions_fee` | Fee must be `>= 0` |
| `chk_snapshots_balance` | Balance after transaction must be `>= 0` |
| `chk_accounts_closed_at` | `closed_at` must be after `opened_at` |

---

## CRUD Queries & Views

Implemented in `database/queries.sql` with result screenshots in `docs/screenshots/`.

### Read Queries

| Query | Description |
|---|---|
| Q001 | All transactions for a single user, joined through their account |
| Q002 | Count and total value of transactions per category |
| Q003 | All failed transactions with full owner and SMS context |
| Q004 | Top 5 users by total completed transaction volume |
| Q005 | Every party (sender, receiver, facilitator) in a specific transaction |

### Write Queries

| Query | Description |
|---|---|
| Q006 | Insert a new pending transaction |
| Q007 | Update a pending transaction to completed |
| Q008 | Bulk-close an account (set status + `closed_at`) |
| Q009 | Delete a system log row |

### View: `full_transaction_details`

A convenience view joining `transactions`, `accounts`, `users`, `transaction_categories`, and `sms_messages` into a single flat result set. Includes a computed `total_debited_rwf = amount + fee_amount` column.

| Field | Source |
|---|---|
| `transaction_id`, `external_tx_id` | `transactions` |
| `account_owner` | `users.full_name` |
| `account_number`, `wallet_provider` | `accounts` |
| `category`, `money_direction` | `transaction_categories` |
| `amount`, `fee_amount`, `total_debited_rwf` | `transactions` (last computed) |
| `status`, `transaction_date` | `transactions` |
| `sms_sender`, `source_sms_body` | `sms_messages` |

---

## JSON API Schemas

Defined in `examples/json_schemas.json` with a full mapping guide in `examples/json_mapping.md`.

### Global Conventions

| SQL Type | JSON Representation |
|---|---|
| `INT`, `BIGINT` | JSON number (integer) |
| `DECIMAL(15,2)` | JSON number with 2 decimal places (e.g. `5000.00`) |
| `VARCHAR`, `TEXT`, `CHAR` | JSON string |
| `TIMESTAMP` | ISO 8601 UTC string with `Z` suffix (e.g. `"2024-01-25T10:00:00Z"`) |
| `ENUM` | JSON string using the database value verbatim |
| `NULL` | JSON `null` |

### Flat vs. Nested Responses

- **Flat** — one row per entity, foreign keys as bare integers.
- **Nested** — foreign keys replaced with fully embedded objects, requiring only one API round-trip. Polymorphic FKs (`owner_id`, `party_id`) always resolve to a typed nested object.
- **Computed fields** — `total_debited` (`amount + fee_amount`) appears only in nested responses.

### Complex Transaction Object

For full transaction details the API returns a deeply nested object embedding:

- `source_sms` — the raw SMS that was parsed
- `account` + `account.owner` — the account and its user
- `category` — transaction category and direction
- `participants[]` — each party with their full entity (user, merchant, agent, or provider) and phone number
- `balance_snapshot` — balance recorded after the transaction
- `system_logs[]` — all parse events linked to this transaction

### Example Transactions

**Send Money**
```
Alice Uwimana (250788123456)
  → sends 5,000 RWF + 50 RWF fee
  → to Jean Pierre Habimana (250788234567)
  → new balance: 45,000 RWF  |  TXN20240125001
```

**Merchant Payment**
```
Diane Iribagiza (250722789012)
  → pays 3,500 RWF (no fee)
  → to Simba Supermarket (SHOP-1001)
  → new balance: 24,000 RWF  |  TXN20240125005
```

---

## Project Structure

```
momo-sms-analyzer/
├── api/                             # REST API layer (in progress)
├── data/                            # SMS XML backup files
├── database/
│   ├── database_setup.sql           # CREATE DATABASE + all 12 tables, indexes, unique/format constraints, sample data
│   └── queries.sql                  # CRUD queries + full_transaction_details view
├── docs/
│   ├── images/
│   │   └── architecture.png         # System architecture diagram
│   └── screenshots/                 # Query result screenshots (Q001–Q011, SEC001–SEC008)
├── etl/                             # ETL pipeline (in progress)
├── examples/
│   ├── json_schemas.json            # API response shapes for all entities
│   └── json_mapping.md              # SQL ↔ JSON field mapping documentation
├── scripts/                         # Utility scripts (in progress)
├── tests/                           # Test suite (in progress)
├── web/                             # Frontend dashboard (in progress)
├── index.html                       # Web UI entry point
├── .env.example                     # Environment variable template
└── requirements.txt                 # Python dependencies
```

---

## Branch Structure

| Branch | Contents |
|---|---|
| `main` | Stable base — project structure and documentation |
| `feature/ddl-schema` | `database/database_setup.sql` — full 12-table MySQL schema, indexes, unique/format constraints |
| `feature/json-schemas` | `examples/json_schemas.json` + `examples/json_mapping.md` — API contract |
| `feature/queries-crud` | `database/queries.sql` — read/write queries and `full_transaction_details` view |
| `feature/sample-data` | Seed data for testing (in progress) |

---

## Scrum Board

Track our progress on the [GitHub Project Board](https://github.com/users/Alicia-Keza/projects/1).

---

## Project Layout

```
.
├── api/                      # REST API (server, CRUD, auth)
│   ├── __init__.py
│   ├── auth.py               # Basic Auth, loads creds from env vars
│   ├── crud.py               # In-memory data layer
│   └── server.py             # HTTP routing for the 5 endpoints
├── dsa/                      # XML parser + search benchmark
│   ├── __init__.py
│   ├── parse_xml.py          # XML -> list of transaction dicts
│   └── search_compare.py     # Linear vs dict-lookup timing
├── tests/                    # Automated end-to-end tests
│   ├── __init__.py
│   └── test_api.py           # 18 assertions covering all endpoints
├── docs/                     # Documentation + PDF report
│   ├── api_docs.md           # Endpoint reference
│   ├── AI_USAGE_LOG.md       # Per-person AI usage log
│   └── report.pdf            # The submitted PDF report
├── screenshots/              # 5 Postman test screenshots
│   ├── get_success.png
│   ├── unauthorized.png
│   ├── post_success.png
│   ├── put_success.png
│   └── delete_success.png
├── .env.example              # Template for environment variables
├── .gitignore
├── modified_sms_v2.xml       # Source SMS data
├── requirements.txt          # Empty - stdlib only
└── README.md
```

---

## Setup

### 1. Configure credentials

```bash
cp .env.example .env
set -a; source .env; set +a
```

On Windows PowerShell:
```powershell
Get-Content .env | ForEach-Object { $k,$v = $_.split('='); Set-Item env:$k $v }
```

If you forget to export the env vars, the server refuses to start with a
clear error message — credentials are never hard-coded in source.

### 2. Start the API server

```bash
python -m api.server
```

The server listens on `http://localhost:8000`. The startup banner shows
how many transactions were loaded and which user is configured:

```
MoMo API listening on http://localhost:8000
Records loaded: 1691
Auth user     : admin
Press Ctrl+C to stop.
```

### 3. Hit the API with curl

```bash
# List all transactions
curl -u admin:password123 http://localhost:8000/transactions

# Get a single transaction
curl -u admin:password123 http://localhost:8000/transactions/1

# Wrong password -> 401
curl -i -u admin:wrong http://localhost:8000/transactions

# Create a new transaction
curl -u admin:password123 \
     -X POST -H "Content-Type: application/json" \
     -d '{"transaction_type":"send_money","amount":5000,"sender":"A","receiver":"B"}' \
     http://localhost:8000/transactions

# Update one
curl -u admin:password123 \
     -X PUT -H "Content-Type: application/json" \
     -d '{"amount":7500}' http://localhost:8000/transactions/1692

# Delete one
curl -u admin:password123 -X DELETE http://localhost:8000/transactions/1692
```

The full endpoint reference, with request and response examples, is at
[`docs/api_docs.md`](docs/api_docs.md).

### 4. Run the automated test suite

In a second terminal (keep the server running):

```bash
set -a; source .env; set +a
python tests/test_api.py
```

Expected output:

```
Results: 18 passed, 0 failed.
```

### 5. Run the DSA benchmark
```bash
python dsa/search_compare.py
```

Prints a side-by-side comparison of linear search vs dictionary lookup
over 1,691 transactions, plus a Big-O reflection.

---

## Security Notes

- Credentials are **loaded from environment variables**
  (`API_USERNAME` / `API_PASSWORD`), never hard-coded.
- The server **refuses to start** without those env vars set.
- **`.env` is git-ignored** — only `.env.example` is committed.
- **All 5 endpoints** require Basic Authentication. Missing or wrong
  credentials return `401 Unauthorized` with a `WWW-Authenticate` header.
- See Section 5 of [`docs/report.pdf`](docs/report.pdf) for why Basic
  Auth is weak in production and what to use instead
  (JWT, OAuth 2.0).

---

## Testing Checklist

The five Postman screenshots required by the rubric live in
[`screenshots/`](screenshots/):

1. `get_success.png` — `GET /transactions` with valid auth → **200**
2. `unauthorized.png` — `GET /transactions` with wrong auth → **401**
3. `post_success.png` — `POST /transactions` → **201**
4. `put_success.png` — `PUT /transactions/{id}` → **200**
5. `delete_success.png` — `DELETE /transactions/{id}` → **200**

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `ERROR: API_USERNAME and API_PASSWORD ...` | env vars not exported | `set -a; source .env; set +a` |
| `Address already in use` on startup | something else on port 8000 | `API_PORT=8765 python -m api.server` |
| Tests hang or print `URLError` | server not running | start the server first in a separate terminal |
| Tests print 401 everywhere | env vars not exported in the *tests* terminal | re-run `set -a; source .env; set +a` |
| Parser returns 0 records | `modified_sms_v2.xml` missing or moved | put the file at the project root |

---

## Tech Stack

| Layer | Tool |
|---|---|
| HTTP server | `http.server` (stdlib) |
| XML parsing | `xml.etree.ElementTree` (stdlib) |
| Auth | HTTP Basic via `base64` (stdlib) |
| Testing | `urllib.request` (stdlib) |
| Benchmark | `time.perf_counter` (stdlib) |

**Zero third-party dependencies.** Runs on any Python 3.10+.
