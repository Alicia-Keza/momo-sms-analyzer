-- MoMo SMS Database — CRUD Operations and Sample Queries


use momo_db;


-- section a: read queries(select with joins)

-- q1 — all transactions for a single user, joined through their account.

SELECT t.transaction_id, t.external_tx_id, u.full_name AS account_owner, a.account_number, tc.name AS category, t.amount, t.fee_amount, t.status, t.transaction_date FROM transactions t JOIN accounts a on t.account_id = a.account_id JOIN users u ON a.user_id = u.user_id JOIN transaction_categories tc ON t.category_id = tc.category_id WHERE u.user_id = 1 ORDER BY t.transaction_date;

-- q2 — count of transactions per category (with totals).

SELECT tc.name AS category, tc.direction, COUNT(t.transaction_id) AS tx_count, COALESCE(SUM(t.amount), 0) AS total_amount_rwf, COALESCE(SUM(t.fee_amount), 0) AS total_fees_rwf FROM transaction_categories tc LEFT JOIN transactions t ON tc.category_id = t.category_id GROUP BY tc.category_id, tc.name, tc.direction ORDER BY tx_count DESC, total_amount_rwf DESC;

-- q3 - all failed transactions with full owner and category context.

SELECT t.transaction_id, t.external_tx_id, u.full_name AS account_owner, tc.name AS category, t.amount, t.transaction_date, s.body AS source_sms FROM transactions t JOIN accounts a ON t.account_id = a.account_id JOIN users u ON a.user_id = u.user_id JOIN transaction_categories tc ON t.category_id = tc.category_id LEFT JOIN sms_messages s ON t.source_sms_id = s.sms_id WHERE t.status = 'failed' ORDER BY t.transaction_date DESC;

-- q4 - top 5 users by total transaction volume(completed transactions only).

SELECT u.user_id, u.full_name, COUNT(t.transaction_id) AS completed_tx_count, SUM(t.amount) AS total_volume_rwf, SUM(t.fee_amount) AS total_fees_paid_rwf FROM users u JOIN accounts a ON u.user_id = a.user_id JOIN transactions t ON a.account_id = t.account_id WHERE t.status = 'completed' GROUP BY u.user_id, u.full_name ORDER BY total_volume_rwf DESC LIMIT 5;

-- q5 - every party involved in a specific transaction.

SELECT tp.participant_id, tp.role, tp.party_type, tp.party_id, CASE tp.party_type WHEN 'user' THEN (SELECT full_name FROM users WHERE user_id = tp.party_id) WHEN 'agent' THEN (SELECT agent_name FROM agents WHERE agent_id = tp.party_id) WHEN 'merchant' THEN (SELECT merchant_name FROM merchants WHERE merchant_id = tp.party_id) WHEN 'provider' THEN (SELECT provider_name FROM service_providers WHERE provider_id = tp.party_id) END AS party_name FROM transaction_participants tp WHERE tp.transaction_id = 1006 ORDER BY tp.role;

-- section b: create queries (insert)

-- q6 - insert a new pending transaction for something to update later.

INSERT INTO transactions (external_tx_id, source_sms_id, account_id, category_id, status, amount, fee_amount, transaction_date) VALUES ('TXN20240126001', NULL, 2, 1, 'pending', 6000.00, 60.00, '2024-01-26 09:00:00');

-- display the inserted transaction to confirm it worked.

SELECT * FROM transactions WHERE external_tx_id = 'TXN20240126001';

-- section c: update queries(update)

-- q7 - update the pending transaction to completed

UPDATE transactions SET status = 'completed' WHERE external_tx_id = 'TXN20240126001' and status = 'pending';

-- verify the update worked
SELECT * FROM transactions WHERE external_tx_id = 'TXN20240126001';

-- q8 - bulk update: close an account by setting status to 'closed'

UPDATE accounts SET status = 'closed', closed_at = NOW() WHERE account_id = 10;

-- verify the update worked
SELECT * FROM accounts WHERE account_id = 10;