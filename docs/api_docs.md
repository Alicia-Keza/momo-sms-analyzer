# MoMo REST API — Endpoint Reference

**Base URL:** `http://localhost:8000`
**Authentication:** HTTP Basic on **every** endpoint
(`API_USERNAME` / `API_PASSWORD` loaded from environment variables)

Every request must include an `Authorization` header:

```
Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM=
```

(that header is the base64 encoding of `admin:password123`).

A missing or invalid header always returns:

```
401 Unauthorized
{"error": "Unauthorized"}
```

with a `WWW-Authenticate: Basic realm="MoMo API"` response header so
that browsers and tools like Postman prompt for credentials automatically.

---

## Endpoint Summary

| # | Method | Path | Purpose |
|---|---|---|---|
| 1 | GET | `/transactions` | List every transaction |
| 2 | GET | `/transactions/{id}` | Fetch one transaction by id |
| 3 | POST | `/transactions` | Add a new transaction |
| 4 | PUT | `/transactions/{id}` | Update an existing transaction |
| 5 | DELETE | `/transactions/{id}` | Remove a transaction |

---

## 1. GET `/transactions`

List every transaction parsed from `modified_sms_v2.xml`.

### Request

```bash
curl -u admin:password123 http://localhost:8000/transactions
```

### Response — `200 OK`

```json
[
  {
    "id": 1,
    "transaction_type": "receive_money",
    "amount": 2000.0,
    "sender": "Jane Smith",
    "receiver": "You",
    "timestamp": "2024-05-10T14:30:58Z",
    "external_tx_id": "76662021700",
    "raw_body": "*165*S* You have received 2,000 RWF from Jane Smith ..."
  },
  {
    "id": 2,
    "transaction_type": "payment",
    "amount": 1000.0,
    "sender": "You",
    "receiver": "Jane Smith",
    "timestamp": "2024-05-10T15:02:11Z",
    "external_tx_id": "76662021701",
    "raw_body": "*165*S* Your payment of 1,000 RWF to Jane Smith ..."
  }
]
```

### Error Codes

| Code | Meaning |
|---|---|
| 401 | Missing or invalid credentials |

---

## 2. GET `/transactions/{id}`

Fetch a single transaction by its numeric id.

### Request

```bash
curl -u admin:password123 http://localhost:8000/transactions/5
```

### Response — `200 OK`

```json
{
  "id": 5,
  "transaction_type": "payment",
  "amount": 2000.0,
  "sender": "You",
  "receiver": "Samuel Carter",
  "timestamp": "2024-05-11T16:48:49Z",
  "external_tx_id": "17818959211",
  "raw_body": "TxId: 17818959211. Your payment of 2,000 RWF to Samuel Carter ..."
}
```

### Error Codes

| Code | Meaning |
|---|---|
| 401 | Missing or invalid credentials |
| 404 | No transaction with that id |

---

## 3. POST `/transactions`

Create a new transaction. The server assigns the next available `id`
automatically; any `id` field in the request body is ignored.

### Request

```bash
curl -u admin:password123 \
     -X POST \
     -H "Content-Type: application/json" \
     -d '{
       "transaction_type": "send_money",
       "amount": 5000,
       "sender": "Wilson",
       "receiver": "Tester",
       "timestamp": "2026-05-28T12:00:00Z",
       "external_tx_id": "TEST001",
       "raw_body": "manual postman test"
     }' \
     http://localhost:8000/transactions
```

### Response — `201 Created`

```json
{
  "transaction_type": "send_money",
  "amount": 5000,
  "sender": "Wilson",
  "receiver": "Tester",
  "timestamp": "2026-05-28T12:00:00Z",
  "external_tx_id": "TEST001",
  "raw_body": "manual postman test",
  "id": 1692
}
```

### Error Codes

| Code | Meaning |
|---|---|
| 400 | Request body is missing or not valid JSON |
| 401 | Missing or invalid credentials |

---

## 4. PUT `/transactions/{id}`

Update one or more fields on an existing transaction. The `id` is
preserved — any `id` field in the body is overwritten with the URL id.
Fields you don't include are left untouched (merge semantics).

### Request

```bash
curl -u admin:password123 \
     -X PUT \
     -H "Content-Type: application/json" \
     -d '{"amount": 9999}' \
     http://localhost:8000/transactions/1692
```

### Response — `200 OK`

```json
{
  "transaction_type": "send_money",
  "amount": 9999,
  "sender": "Wilson",
  "receiver": "Tester",
  "timestamp": "2026-05-28T12:00:00Z",
  "external_tx_id": "TEST001",
  "raw_body": "manual postman test",
  "id": 1692
}
```

### Error Codes

| Code | Meaning |
|---|---|
| 400 | Request body is missing or not valid JSON |
| 401 | Missing or invalid credentials |
| 404 | No transaction with that id |

---

## 5. DELETE `/transactions/{id}`

Remove the transaction with the given id from memory and from
`transactions.json`.

### Request

```bash
curl -u admin:password123 \
     -X DELETE \
     http://localhost:8000/transactions/1692
```

### Response — `200 OK`

```json
{"deleted": 1692}
```

A subsequent `GET /transactions/1692` returns `404`.

### Error Codes

| Code | Meaning |
|---|---|
| 401 | Missing or invalid credentials |
| 404 | No transaction with that id |

---

## Status Code Reference

| Code | When you'll see it |
|---|---|
| **200 OK** | Successful GET / PUT / DELETE |
| **201 Created** | Successful POST — the body contains the new record with its server-assigned `id` |
| **400 Bad Request** | POST or PUT body is missing or not valid JSON |
| **401 Unauthorized** | Missing or wrong credentials on any endpoint |
| **404 Not Found** | Either the path is unknown or the requested transaction id does not exist |

---

## Authentication Helper

To generate a Basic Auth header manually:

```bash
echo -n "admin:password123" | base64
# YWRtaW46cGFzc3dvcmQxMjM=
```

Then in any tool:

```
Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM=
```

Postman and curl handle this for you (`-u user:pass`).
