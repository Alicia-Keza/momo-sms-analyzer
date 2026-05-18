--===================================
-- SECTION 2: DML QUERIES 
--===================================
--This section adds sample data to the tables built in section 1
--The values are made up but the SMS bodies follow the real MTN MOMO Rwanda messages
--Format used was taken from the project's XML file
--phone numbers follow the Rwandan format
--All money amounts are in RWF
--Rows are inserted following an order where parent rows are inserted first, then children rows, so no foreign key breaks 
--===================================


-- ======USERS Table (5 rows)======
-- Five end users with MOMO accounts. These are people sending and receiving money
INSERT INTO users (user_id, full_name, created_at) VALUES
(1, 'UWASE Yvette', '2026-05-13 10:00:00'),
(2, 'UWAMAHORO Josiane', '2026-05-14 10:05:00'),
(3, 'MUKASE Claudine', '2026-05-15 10:30:00'),
(4, 'HABIMANA Jean', '2026-05-16 11:45:00'),
(5, 'KAYIRANGA Marie', '2026-05-17 13:50:00');

-- =======AGENTS Table (5 rows)======
-- Five MOMO agents. Users visit them inorder to deposit and withdraw cash
-- Names follow MTN Agents naming style used in the XML file(e.g "Agent Sophia")
INSERT INTO agents (agent_id, agent_name, agent_code, created_at) VALUES
(1, 'Agent Eric' , 'AGT-001', '2026-05-10 08:02:00'),
(2, 'Agent Sarah', 'AGT-002', '2026-05-10 08:50:00'),
(3, 'Agent Davis', 'AGT-003', '2026-05-11 08:30:00'),
(4, 'Agent Katrina', 'AGT-004', '2026-05-11 09:00:00'),
(5, 'Agent Fabiola', 'AGT-005', '2026-05-11 09:35:00');

-- ========MERCHANTS Table (5 rows)======
-- A merchant can be a business,shop,person that receives money though a pay-code
-- Their pay-code is written in a five digits format that also appears in the XML file
INSERT INTO merchants (merchant_id, merchant_name, shop_code, created_at) VALUES
(1, 'SIMBA Supermarket', '10005', '2026-04-12 07:00:00'),
(2, 'INEZA Gisele', '12364', '2026-04-15 08:12:00'),
(3, 'JAVA House', '13472', '2026-04-17 09:10:00'),
(4, 'KIMIRONKO Market', '14573', '2026-04-20 09:32:00'),
(5, 'KEZA Bakery', '15465', '2026-04-21 10:00:00');

-- ==========SERVICE_PROVIDERS Table (5 rows)=======
-- five service-providing companies that get paid through MOMO
-- service_type must be either utility,telco,insurance (already set by DDL Queries)
INSERT INTO service_providers (provider_id, provider_name, service_type, created_at) VALUES
(1, 'REG cash power', 'utility', '2026-04-01 03:02:00'),
(2, 'Airtel Airtime', 'telco', '2026-04-05 07:00:00'),
(3, 'CANAL+ Rwanda', 'telco', '2026-04-09 07:05:00'),
(4, 'Sanlam Insurance', 'insurance', '2026-04-11 09:05:00'),
(5, 'WASAC', 'utility', '2026-04-11 12:00:00');

-- =========TRANSACTION_CATEGORIES Table (8 rows)======
-- A fixed list of all kinds of activities MOMO SMS can describe
-- Each transaction in the transactions table points to these
-- direction: credit means "money comes in", debit means "money leaves the wallet or account"
INSERT INTO transaction_categories (category_id, name, direction) VALUES
(1, 'send_money', 'debit'),
(2, 'receive_money', 'credit'),
(3, 'airtime_purchase', 'debit'),
(4, 'utility_bill', 'debit'),
(5, 'merchant_payment', 'debit'),
(6, 'cash_in', 'credit'),
(7, 'cash_out', 'debit'),
(8, 'insurance_payment', 'debit');

-- ==========SMS_MESSAGES Table (7 rows)=============
-- seven raw sms messages, one per transaction below
-- Each body follows the real MTN MOMO sms format taken from the XML file
-- service_center values are all in the "+25078811038X" MTN gateway range
-- Row 6 is a failed transaction kept to test the failed status path
INSERT INTO sms_messages (sms_id, address, received_epoch_ms, body, readable_date, service_center, backup_set, ingested_at) VALUES
(1, 'M-Money', 1779088500000, '*165*S*5000 RWF transferred to UWAMAHORO Josiane (250788234567) from 36800001 at 2026-05-12 09:13:00. Fee was:50 RWF. New balance:45000 RWF.', '12 May 2026 09:13:00 AM', '+250788110383', '20260512', '2026-05-12 09:14:00'),
(2, 'M-Money', 1779613680000, '*162*TxId:50019384572*S*Your payment of 15000 RWF to REG Cash Power with token 84516-29304-77182-46093 has been completed at 2026-05-14 11:08:00. Fee was 100 RWF. Your new balance: 60000 RWF', '14 May 2026 11:08:00 AM', '+250788110381', '20260514', '2026-05-14 11:09:00'),
(3, 'M-Money', 1779468120000, '*162*TxId:50018273461*S*Your payment of 2000 RWF to Airtime with token  has been completed at 2026-05-11 18:42:00. Fee was 0 RWF. Your new balance: 18000 RWF .', '11 May 2026 6:42:00 PM', '+250788110381', '20260511', '2026-05-11 18:43:00' ),
(4, 'M-Money', 1779796500000, 'TxId: 50020495683. Your payment of 3,500 RWF to SIMBA Supermarket 1005 has been completed at 2026-05-16 13:55:00. Your new balance: 24,000 RWF. Fee was 0 RWF.', '16 May 2026 1:55:00 PM', '+250788110382', '20260516', '2026-05-16 13:56:00'),
(5, 'M-Money', 1779978000000, '*164*S*Y''ello,A transaction of 8000 RWF by Sanlam Insurance on your MOMO account was successfully completed at 2026-05-10 16:20:00. Message from debit receiver. Your new balance:16000 RWF. Fee was 0 RWF. Financial Transaction Id: 50021506794.*EN#', '10 May 2026 4:20:00 PM', '+250788110383', '20260510', '2026-05-10 16:21:00'),
(6, 'M-Money', 1780165800000, '*143*R*Y''ello, the transaction with amount 7500 RWF for MUKASE Claudine with message: 1763055172864732058079215 failed at 2026-05-09 20:30:00 .Please Contact MobileMoney HelpLine for Assistance.Thank you for using MTN MobileMoney.*EN#','09 May 2026 8:30:00 PM', '+250788110384', '20260509', '2026-05-09 20:31:00'),
(7, 'M-Money', 1780403100000, ' You KAYIRANGA Marie (*********012) have via agent: Agent Sarah (250790222222), withdrawn 20000 RWF from your mobile money account: 36800005 at 2026-04-02 14:25:00 and you can now collect your money in cash. Your new balance: 4000 RWF. Fee paid: 350 RWF. Message from agent:1. Financial Transaction Id: 50023728916.','2 April 2026 2:25:00 PM', '+250788110383', '20260402', '2026-04-02 14:26:00');

-- ==========PHONE_NUMBERS Table (10 rows)================
-- One phone number per user and per agent
-- owner_type tells which table owner_id points to (either users or agents since they are the only ones to have phone numbers in this project)
-- This is the polymorphic link, MYSQL can't enforce this with a foreign key because FK can only point to one table
INSERT INTO phone_numbers (phone_id, owner_type, owner_id, msisdn, linked_at) VALUES
-- Users (owner_type='user', owner_id matches users.user_id)
(1, 'user', 1, '250788123456', '2026-05-10 08:03:00'),
(2, 'user', 2, '250788838702', '2026-05-11 08:15:00'),
(3, 'user', 3, '250788456789', '2026-05-12 09:14:00'),
(4, 'user', 4, '250788675845', '2026-05-12 09:20:00'),
(5, 'user', 5, '250788234356', '2026-05-12 09:45:00'),
-- Agents (owner_type='agent', owner_id matches agents.agent_id)
(6, 'agent', 1, '250789987654', '2026-05-13 09:50:00'),
(7, 'agent', 2, '250789987655', '2026-05-14 10:07:00'),
(8, 'agent', 3, '250789987656', '2026-05-15 11:00:00'),
(9, 'agent', 4, '250789987657', '2026-05-16 12:00:00'),
(10, 'agent', 5, '250789987658', '2026-05-17 12:10:00');

-- ============ACCOUNTS Table (5 rows)===================
-- one MTN MOMO account per user
-- account numbers use short numeric style seen in the XML file(e.g:"36521838")
-- closed_at is NULL because all accounts are still open
INSERT INTO accounts (account_id, user_id, account_number, account_type, provider_name, status, opened_at, closed_at) VALUES
(1, 1, '36800001', 'personal', 'MTN Mobile Money', 'active', '2026-05-10 08:03:00', NULL),
(2, 2, '36800002', 'personal', 'MTN Mobile Money', 'active', '2026-05-11 08:15:00', NULL),
(3, 3, '36800003', 'personal', 'MTN Mobile Money', 'active', '2026-05-12 09:14:00', NULL),
(4, 4, '36800004', 'personal', 'MTN Mobile Money', 'active', '2026-05-12 09:20:00', NULL),
(5, 5, '36800005', 'personal', 'MTN Mobile Money', 'active', '2026-05-12 09:45:00', NULL);

-- =============TRANSACTIONS Table (7rows)===================
-- Seven transactions covering the main MOMO activities seen in the XML data structure file
-- external_tx_id uses 11-digit numeric IDs like the real financial Transaction ID in the XML
-- Each row links to its source SMS(source_sms_id) and the account it touched
INSERT INTO transactions (transaction_id, external_tx_id, source_sms_id, account_id, category_id, status, amount, fee_amount, transaction_date, created_at) VALUES
(101, '76662021701', 1, 1, 1, 'completed', 5000.00, 50.00, '2026-05-12 09:13:00', '2026-05-12 09:14:00'),
(102, '50019384572', 2, 3, 4, 'completed', 15000.00, 100.00, '2026-05-14 11:08:00', '2026-05-14 11:09:00'),
(103, '50018273461', 3, 4, 3, 'completed', 2000.00, 0.00, '2026-05-11 18:42:00', '2026-05-11 18:43:00'),
(104, '50020495683', 4, 5, 5, 'completed', 3500.00, 0.00, '2026-05-16 13:55:00', '2026-05-16 13:56:00'),
(105, '50021506794', 5, 1, 8, 'completed', 8000.00, 0.00, '2026-05-10 16:20:00', '2026-05-10 16:21:00'),
-- failed transfer:same SMS as row 6 in sms_messages
(106, '50022617805', 6, 2, 1, 'failed', 7500.00, 0.00, '2026-05-09 20:30:00', '2026-05-09 20:31:00'),
-- cash withdrawal through an agent: same SMS as row 7 in sms_messages
(107, '50023728916', 7, 5, 7, 'completed', 20000.00, 350.00, '2026-04-02 14:25:00', '2026-04-02 14:26:00');


--=============TRANSACTION_PARTICIPANTS Table(14 rows)===============
-- Junction table for the many-to-many links between transactions and the four party tables(users,agents,merchants,service_providers)
-- party_type tells which table party_id points to
-- every transaction has at least one party either(sender, receiver, facilitator)
INSERT INTO transaction_participants (participant_id, transaction_id, party_type, party_id, role) VALUES
-- tx 101: UWASE Yvette sends money to UWAMAHORO Josiane(user to user)
(1, 101, 'user', 1, 'sender'),
(2, 101, 'user', 2, 'receiver'),
-- tx 102: MUKASE Claudine buys airtime from Airtel airtime(user to provider)
(3, 102, 'user', 3, 'sender'),
(4, 102, 'provider', 2, 'receiver'),
-- tx 103: HABIMANA Jean pays his power bill to REG cash power(user to provider)
(5, 103, 'user', 4, 'sender'),
(6, 103, 'provider', 1, 'receiver'),
-- tx 104:KAYIRANGA Marie pays to SIMBA Supermaket(user to merchant)
(7, 104, 'user', 5, 'sender'),
(8, 104, 'merchant', 1, 'receiver'),
--tx 105: UWASE Yvette pays her insurance to sanlam insurance(user to provider)
(9, 105, 'user', 1, 'sender'),
(10, 105, 'provider', 5, 'receiver'),
-- tx 106: failed transfer from UWAMAHORO Josiane to MUKASE Claudine
(11, 106, 'user', 2, 'sender'),
(12, 106, 'user', 3, 'receiver'),
-- tx 107: KAYIRANGA Marie withdraws cash through Agent Sarah(user with agent as a facilitator)
(13, 107, 'user', 5, 'sender'),
(14, 107, 'agent', 2, 'facilitator');

--=================BALANCE_SNAPSHOTS Table(6 rows)==========================
-- A snapshot of MOMO account balance right after a transaction
-- failed transactions don't change the balance , so they get no snapshot
INSERT INTO balance_snapshots (snapshot_id, account_id, transaction_id, balance_after, snapshot_at) VALUES
(1, 1, 101, 45000.00, '2026-05-12 09:14:00'),
(2, 3, 102, 60000.00, '2026-05-14 11:09:00'),
(3, 4, 103, 18000.00, '2026-05-11 18:43:00'),
(4, 5, 104, 24000.00, '2026-05-16 13:56:00'),
(5, 1, 105, 16000.00, '2026-05-10 16:21:00'),
(6, 5, 107, 4000.00, '2026-04-02 14:26:00');

--==================SYSTEM_LOGS Table(8 rows)==============================
-- one log line for each SMS the parser handled
-- row 6 is a WARN because the transaction failed 
-- row 8 catches the same SMS being read twice
INSERT INTO system_logs (log_id, sms_id, transaction_id, event_type, log_level, message, created_at) VALUES
(1, 1, 101, 'parse_success', 'INFO', 'Send-money SMS parsed and transaction created successfully', '2026-05-12 09:14:00'),
(2, 2, 102, 'parse_success', 'INFO', 'Airtime purchase SMS parsed successfully', '2026-05-14 11:09:00'),
(3, 3, 103, 'parse_success', 'INFO', 'REG cash power SMS parsed successfully', '2026-05-11 18:43:00'),
(4, 4, 104, 'parse_success', 'INFO', 'merchant payment SMS parsed successfully', '2026-05-16 13:56:00'),
(5, 5, 105, 'parse_success', 'INFO', 'Insurance payment SMS parsed successfully', '2026-05-10 16:21:00'),
--WARN: SMS parsed fine but the transaction it describes is a failure
(6, 6, 106, 'parse_fail', 'WARN', 'SMS parsed but transaction status is failed', '2026-05-09 20:31:00'),
(7, 7, 107, 'parse_success', 'INFO', 'Cash-out via agent SMS parsed successfully', '2026-04-02 14:26:00'),
--WARN: duplicate SMS detected (sms_id 2 was seen twice)
(8, 2, NULL, 'duplicate', 'WARN', 'Duplicate SMS detected , already processed', '2026-05-14 11:09:00');



--==========================END OF SECTION 2================================================