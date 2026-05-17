-- MoMo SMS Database — CRUD Operations and Sample Queries


use momo_db;


-- section a: read queries

-- q1 — all transactions for a single user, joined through their account.

SELECT t.transaction_id, t.external_tx_id, u.full_name AS account_owner, a.account_number, tc.name AS category, t.amount, t.fee_amount, t.status, t.transaction_date FROM transactions t JOIN accounts a on t.account_id = a.account_id JOIN users u ON a.user_id = u.user_id JOIN transaction_categories tc ON t.category_id = tc.category_id WHERE u.user_id = 1 ORDER BY t.transaction_date;

-- q2 — count of transactions per category (with totals).

SELECT tc.name AS category, tc.direction, COUNT(t.transaction_id) AS tx_count, COALESCE(SUM(t.amount), 0) AS total_amount_rwf, COALESCE(SUM(t.fee_amount), 0) AS total_fees_rwf FROM transaction_categories tc LEFT JOIN transactions t ON tc.category_id = t.category_id GROUP BY tc.category_id, tc.name, tc.direction ORDER BY tx_count DESC, total_amount_rwf DESC;