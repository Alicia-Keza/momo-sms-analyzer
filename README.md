# MoMo SMS Data Analyzer

A pure-Python REST API that parses MTN Mobile Money (MoMo) SMS transaction
records, secures them with Basic Authentication, and exposes them through
five CRUD endpoints. Built for the *Building and Securing a REST API*
assignment.

---

## Team — The GRID

| Name | GitHub |
|---|---|
| Karega Uwase Ines | [@Ines-karega](https://github.com/Ines-karega) |
| Kayumba Isaro Gania | [@Gania-Isaro](https://github.com/Gania-Isaro) |
| Keza Rutayisire Alicia | [@Alicia-Keza](https://github.com/Alicia-Keza) |
| Nshizirungu Wilson | [@nshizirunguwilson](https://github.com/nshizirunguwilson) |
| Teta Aline | [@Tetaaline](https://github.com/Tetaaline) |

---

## The Problem

MTN MoMo users receive hundreds of SMS messages for every transaction —
sending money, receiving payments, paying bills, buying airtime, and more.
These messages are stored as raw XML, making it nearly impossible to
search, filter, or understand your own financial history at a glance.

## Our Solution

This project provides an end-to-end pipeline that:

1. **Parses** the raw `modified_sms_v2.xml` file into structured transactions.
2. **Serves** those transactions over a secure REST API on `http://localhost:8000`.
3. **Benchmarks** two search algorithms (linear scan vs hash-table lookup)
   to demonstrate measurable performance differences on 1,691+ records.

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
