-- MoMo SMS Database — CRUD Operations and Sample Queries


use momo_db;


-- section a: read queries

-- q1 — all transactions for a single user, joined through their account.

SELECT t.transaction_id, t.external_tx_id, u.full_name AS account_owner, a.account_number, tc.name AS category, t.amount, t.fee_amount, t.status, t.transaction_date FROM transactions t JOIN accounts a on t.account_id = a.account_id JOIN users u ON a.user_id = u.user_id JOIN transaction_categories tc ON t.category_id = tc.category_id WHERE u.user_id = 1 ORDER BY t.transaction_date;

-- q2 — count of transactions per category (with totals).

SELECT tc.name AS category, tc.direction, COUNT(t.transaction_id) AS tx_count, COALESCE(SUM(t.amount), 0) AS total_amount_rwf, COALESCE(SUM(t.fee_amount), 0) AS total_fees_rwf FROM transaction_categories tc LEFT JOIN transactions t ON tc.category_id = t.category_id GROUP BY tc.category_id, tc.name, tc.direction ORDER BY tx_count DESC, total_amount_rwf DESC;

-- q3 - all failed transactions with full owner and category context.

SELECT t.transaction_id, t.external_tx_id, u.full_name AS account_owner, tc.name AS category, t.amount, t.transaction_date, s.body AS source_sms FROM transactions t JOIN accounts a ON t.account_id = a.account_id JOIN users u ON a.user_id = u.user_id JOIN transaction_categories tc ON t.category_id = tc.category_id LEFT JOIN sms_messages s ON t.source_sms_id = s.sms_id WHERE t.status = 'failed' ORDER BY t.transaction_date DESC;

-- q4 - top 5 users by total transaction volume(completed transactions only).

SELECT u.user_id, u.full_name, COUNT(t.transaction_id) AS completed_tx_count, SUM(t.amount) AS total_volume_rwf, SUM(t.fee_amount) AS total_fees_paid_rwf FROM users u JOIN accounts a ON u.user_id = a.user_id JOIN transactions t ON a.account_id = t.account_id WHERE t.status = 'completed' GROUP BY u.user_id, u.full_name ORDER BY total_volume_rwf DESC LIMIT 5;
