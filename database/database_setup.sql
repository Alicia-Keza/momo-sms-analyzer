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
(1, 'SIMBA Supermarket', '1005', '2026-04-12 7:00:00'),
(2, 'INEZA Gisele', '1236', '2026-04-15 8:12:00'),
(3, 'JAVA House', '1347', '2026-04-17 9:10:00'),
(4, 'KIMIRONKO Market', '1457', '2026-04-20 9:32:00'),
(5, 'KEZA Bakery', '1546', '2026-04-21 10:00:00');

-- ==========SERVICE_PROVIDERS Table (5 rows)=======
-- five service-providing companies that get paid through MOMO
-- service_type must be either utility,telco,insurance (already set by DDL Queries)
INSERT INTO service_providers (provider_id, provider_name, service_type, created_at) VALUES
(1, 'REG cash power', 'utility', '2026-04-01 03:02:00'),
(2, 'Airtel Airtime', 'telco', '2026-04-05 07:00:00'),
(3, 'CANAL+ Rwanda', 'telco', '2026-04-09 07:05:00'),
(4, 'Sanlam Insurance', 'insurance', '2026-04-11 09:05:00'),
(5, 'WASAC', 'utility', '2026-04-11 12:00:00');

-- =========TRANSACTION_CATEGORIES Table (5 rows)======
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

-- ==========SMS_MESSAGES Table (5 rows)=============
-- six raw sms messages, one per transaction below
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
-- Users (owner_type='USER', owner_id matches users.user_id)
(1, 'USER', 1, '250788123456', '2026-05-10 08:03:00')
(2, 'USER', 2, '250788838702', '2026-05-11 08:15:00')
(3, 'USER', 3, '250788456789', '2026-05-12 09:14:00')
(4, 'USER', 4, '250788675845', '2026-05-12 09:20:00')
(5, 'USER', 5, '250788234356', '2026-05-12 09:45:00')
-- Agents (owner_type='AGENT', owner_id matches agents.agent_id)
(6, 'AGENT', 1, '250789987654', '2026-05-13 09:50:00')
(7, 'AGENT', 2, '250789987655', '2026-05-14 10:07:00')
(8, 'AGENT', 3, '250789987656', '2026-05-15 11:00:00')
(9, 'AGENT', 4, '250789987657', '2026-05-16 12:00:00')
(10, 'AGENT', 5, '250789987658', '2026-05-17 12:10:00')

-- ============ACCOUNTS Table (5 rows)===================
-- one MTN MOMO account per user
-- account numbers use short numeric style seen in the XML file(e.g:"36521838")
-- closed_at is NULL because all accounts are still open
INSERT INTO accounts (account_id, user_id, account_type, provider_name, status, opened_at, closed_at) VALUES
(1, 1, 'ACC-001', '36800001', 'personal', 'MTN Mobile Money', 'active', '2026-05-10 08:03:00'),
(2, 2, 'ACC-002', '36800002', 'personal', 'MTN Mobile Money', 'active', '2026-05-11 08:15:00'),
(3, 3, 'ACC-003', '36800003', 'personal', 'MTN Mobile Money', 'active', '2026-05-12 09:14:00'),
(4, 4, 'ACC-004', '36800004', 'personal', 'MTN Mobile Money', 'active', '2026-05-12 09:20:00'),
(5, 5, 'ACC-005', '36800005', 'personal', 'MTN Mobile Money', 'active', '2026-05-12 09:45:00');

--