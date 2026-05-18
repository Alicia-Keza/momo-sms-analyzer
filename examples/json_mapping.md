# SQL ↔ JSON Field Mapping

This document explains how each SQL column in `momo_db` is serialized into JSON shapes shown in `json_schemas.json`.

## Global conventions

| SQL data type     | JSON representation                                              |
|-------------------|------------------------------------------------------------------|
| `INT`, `BIGINT`   | JSON number (integer)                                            |
| `DECIMAL(15,2)`   | JSON number with two decimal places (e.g. `5000.00`)             |
| `VARCHAR`, `TEXT`, `CHAR` | JSON string                                              |
| `TIMESTAMP`       | ISO 8601 UTC string with `Z` suffix (e.g. `"2024-01-25T10:00:00Z"`) |
| `ENUM(...)`       | JSON string using the database value verbatim                    |
| `NULL`            | JSON `null`                          

Nested objects are used when a foreign key would otherwise leave the consumer with just an opaque ID. For example, instead of returning `"account_id": 1` in a transaction response, the API embeds the full account object plus its owner, so the consumer needs only one round-trip.

---

## Per-table mapping


### `users` → `user`
| SQL column     | JSON field    | Notes                          |
|----------------|---------------|--------------------------------|
| `user_id`      | `user_id`     | Integer PK                     |
| `full_name`    | `full_name`   | String                         |
| `created_at`   | `created_at`  | TIMESTAMP → ISO 8601 string    |

### `phone_numbers` → `phone_number`

| SQL column   | JSON field   | Notes                                                  |
|--------------|--------------|--------------------------------------------------------|
| `phone_id`   | `phone_id`   | Integer PK                                             |
| `owner_type` | `owner_type` | ENUM(`user`, `agent`) → string                         |
| `owner_id`   | `owner_id`   | Polymorphic FK — see "Polymorphic resolution" below    |
| `msisdn`     | `msisdn`     | 12-digit string in Rwandan international format        |
| `linked_at`  | `linked_at`  | TIMESTAMP → ISO 8601 string                            |

### `accounts` → `account`

| SQL column        | JSON field        | Notes                                                            |
|-------------------|-------------------|------------------------------------------------------------------|
| `account_id`      | `account_id`      | Integer PK                                                       |
| `user_id`         | `user_id`         | FK; in nested contexts replaced by the full `owner` object       |
| `account_number`  | `account_number`  | String, format `ACC-NNNN`                                        |
| `account_type`    | `account_type`    | ENUM(`personal`, `merchant`, `agent`) → string                   |
| `provider_name`   | `provider_name`   | String                                                           |
| `status`          | `status`          | ENUM(`active`, `closed`, `suspended`) → string                   |
| `opened_at`       | `opened_at`       | TIMESTAMP → ISO 8601 string                                      |
| `closed_at`       | `closed_at`       | TIMESTAMP or `null` while the account is open                    |

### `agents` → `agent`

| SQL column   | JSON field   | Notes                                |
|--------------|--------------|--------------------------------------|
| `agent_id`   | `agent_id`   | Integer PK                           |
| `agent_name` | `agent_name` | String                               |
| `agent_code` | `agent_code` | String, unique (`AGT-NNN` format)    |
| `created_at` | `created_at` | TIMESTAMP → ISO 8601 string          |

### `merchants` → `merchant`

| SQL column      | JSON field      | Notes                                |
|-----------------|-----------------|--------------------------------------|
| `merchant_id`   | `merchant_id`   | Integer PK                           |
| `merchant_name` | `merchant_name` | String                               |
| `shop_code`     | `shop_code`     | String, unique (`SHOP-NNNN`)         |
| `created_at`    | `created_at`    | TIMESTAMP → ISO 8601 string          |

### `service_providers` → `service_provider`

| SQL column      | JSON field      | Notes                                                |
|-----------------|-----------------|------------------------------------------------------|
| `provider_id`   | `provider_id`   | Integer PK                                           |
| `provider_name` | `provider_name` | String, unique                                       |
| `service_type`  | `service_type`  | ENUM(`utility`, `telco`, `insurance`) → string       |
| `created_at`    | `created_at`    | TIMESTAMP → ISO 8601 string                          |

### `transaction_categories` → `transaction_category`

| SQL column    | JSON field    | Notes                                  |
|---------------|---------------|----------------------------------------|
| `category_id` | `category_id` | Integer PK                             |
| `name`        | `name`        | String slug (e.g. `send_money`)        |
| `direction`   | `direction`   | ENUM(`credit`, `debit`) → string       |

### `sms_messages` → `sms_message`

| SQL column          | JSON field          | Notes                                                                |
|---------------------|---------------------|----------------------------------------------------------------------|
| `sms_id`            | `sms_id`            | BIGINT PK → integer                                                  |
| `address`           | `address`           | String                                                               |
| `received_epoch_ms` | `received_epoch_ms` | BIGINT → integer (kept as raw milliseconds for client conversion)    |
| `body`              | `body`              | String (raw SMS body, may contain `*` markers)                       |
| `readable_date`     | `readable_date`     | String (device-provided)                                             |
| `service_center`    | `service_center`    | String                                                               |
| `backup_set`        | `backup_set`        | CHAR(8) → 8-character string                                         |
| `ingested_at`       | `ingested_at`       | TIMESTAMP → ISO 8601 string                                          |

### `transactions` → `transaction`

| SQL column         | JSON field         | Notes                                                                  |
|--------------------|--------------------|------------------------------------------------------------------------|
| `transaction_id`   | `transaction_id`   | BIGINT PK → integer                                                    |
| `external_tx_id`   | `external_tx_id`   | String, unique (`TXN...`)                                              |
| `source_sms_id`    | `source_sms_id`    | FK; in nested contexts replaced by the full `source_sms` object        |
| `account_id`       | `account_id`       | FK; in nested contexts replaced by the full `account` object           |
| `category_id`      | `category_id`      | FK; in nested contexts replaced by the full `category` object          |
| `status`           | `status`           | ENUM(`pending`, `completed`, `failed`) → string                        |
| `amount`           | `amount`           | DECIMAL(15,2) → number                                                 |
| `fee_amount`       | `fee_amount`       | DECIMAL(15,2) → number                                                 |
| `transaction_date` | `transaction_date` | TIMESTAMP → ISO 8601 string                                            |
| `created_at`       | `created_at`       | TIMESTAMP → ISO 8601 string                                            |
| _(computed)_       | `total_debited`    | Server-side `amount + fee_amount`, included in nested view             |

### `transaction_participants` → `transaction_participant`

| SQL column       | JSON field       | Notes                                                                |
|------------------|------------------|----------------------------------------------------------------------|
| `participant_id` | `participant_id` | BIGINT PK → integer                                                  |
| `transaction_id` | `transaction_id` | FK (omitted in nested contexts where the parent is the transaction)  |
| `party_type`     | `party_type`     | ENUM(`user`, `agent`, `merchant`, `provider`) → string               |
| `party_id`       | `party_id`       | Polymorphic FK — see "Polymorphic resolution" below                  |
| `role`           | `role`           | ENUM(`sender`, `receiver`, `facilitator`) → string                   |

### `balance_snapshots` → `balance_snapshot`

| SQL column       | JSON field       | Notes                                                                |
|------------------|------------------|----------------------------------------------------------------------|
| `snapshot_id`    | `snapshot_id`    | BIGINT PK → integer                                                  |
| `account_id`     | `account_id`     | FK (omitted in nested contexts where the parent is the account)      |
| `transaction_id` | `transaction_id` | FK (omitted in nested contexts where the parent is the transaction)  |
| `balance_after`  | `balance_after`  | DECIMAL(15,2) → number                                               |
| `snapshot_at`    | `snapshot_at`    | TIMESTAMP → ISO 8601 string                                          |

### `system_logs` → `system_log`

| SQL column       | JSON field       | Notes                                                                |
|------------------|------------------|----------------------------------------------------------------------|
| `log_id`         | `log_id`         | BIGINT PK → integer                                                  |
| `sms_id`         | `sms_id`         | Nullable FK → integer or `null`                                      |
| `transaction_id` | `transaction_id` | Nullable FK → integer or `null`                                      |
| `event_type`     | `event_type`     | ENUM(`parse_success`, `parse_fail`, `duplicate`) → string            |
| `log_level`      | `log_level`      | ENUM(`INFO`, `WARN`, `ERROR`) → string                               |
| `message`        | `message`        | String                                                               |
| `created_at`     | `created_at`     | TIMESTAMP → ISO 8601 string                                          |

---

## Polymorphic resolution

Two columns in the database are polymorphic FKs that the API must resolve manually:

| Table                       | Discriminator | ID column    | Possible targets                            |
|-----------------------------|---------------|--------------|---------------------------------------------|
| `phone_numbers`             | `owner_type`  | `owner_id`   | `users` or `agents`                         |
| `transaction_participants`  | `party_type`  | `party_id`   | `users`, `agents`, `merchants`, or `service_providers` |

At serialization time the API replaces the bare `owner_id` / `party_id` integer with the full embedded objects from whichever table the discriminator names. For example, when `party_type` is `merchant`, the `party` object contains `merchant_id`,`merchant_name`, and `shop_code`; when it is `user`, it contains `user_id`,`full_name`, and (optionally) the nested `phone`.

See the `complex_transaction` (party_type = user) and 
`complex_transaction_merchant_payment_example` (party_type = merchant) examples in `json_schemas.json` for both shapes side by side.

---

## Nesting rules summary 

1. **Flat entity** representation includes every column from the SQL row, FKs as bare integers.
2. **Nested** representations replace each FK integer with the full embedded objects of the referenced row.
3. When parent embeds a child, the child omits the back-pointing FK (e.g. an account inside a transaction omits `user_id` because the user appears at `account.owner`).
4. Polymorphic FKs always resolve into a typed nested object never left as a bare integer in nested responses. 
5. Computed convenience fields (`total_debited`) appear only in nested responses, never in the flat entity representation. 