-- momo database indexes and constraints


USE momo_db;

-- this is index for transaction dates sorting them by the date reported
CREATE INDEX idx_transactions_date
    ON transactions (transaction_date);

-- this is for index for filtering transaction by status
CREATE INDEX idx_transactions_status
    ON transactions (status); 

-- to help when filtering by both transaction date and status and for failed transactions in last 7 days 
CREATE INDEX idx_transactions_status_date
    ON transactions (status, transaction_date);

-- helps in finding participants faster and alsoo easier
CREATE INDEX idx_participants_party
    ON transaction_participants (party_type, party_id);

-- this is for finding phone owners
CREATE INDEX idx_phones_owner
    ON phone_numbers (owner_type, owner_id);

-- here is looking up raw sms ordered by received time
CREATE INDEX idx_sms_received
    ON sms_messages (received_epoch_ms);

-- Filtering sms by sender
CREATE INDEX idx_sms_address
    ON sms_messages (address);

-- checking logs  by created time
CREATE INDEX idx_logs_created
    ON system_logs (created_at);

-- Filtering logss  according to event type
CREATE INDEX idx_logs_event
    ON system_logs (event_type);

-- Balnceing hisory  lookups
CREATE INDEX idx_snapshots_at
    ON balance_snapshots (snapshot_at);

-- Account number should be unique
ALTER TABLE accounts
    ADD CONSTRAINT uq_account_number UNIQUE (account_number);

-- Every agent code  should only exist  only once
ALTER TABLE agents
    ADD CONSTRAINT uq_agent_code UNIQUE (agent_code);
     
-- merchant shop code should be unique
ALTER TABLE merchants
    ADD CONSTRAINT uq_shop_code UNIQUE (shop_code);

-- provider_name  must be unique to avoid ambiguos joins from  the text fields
ALTER TABLE service_providers
    ADD CONSTRAINT uq_provider_name UNIQUE (provider_name);

-- transaction category names should be unique  like "send_money" row
ALTER TABLE transaction_categories
    ADD CONSTRAINT uq_category_name UNIQUE (name);

-- external transaction id must stay unique which  will  prevent repeating
ALTER TABLE transactions
    ADD CONSTRAINT uq_external_tx_id UNIQUE (external_tx_id);

-- same phone number should notexist  more than once
ALTER TABLE phone_numbers
    ADD CONSTRAINT uq_msisdn UNIQUE (msisdn);

-- Security and also format check  rules

ALTER TABLE phone_numbers
    ADD CONSTRAINT chk_msisdn_format
    CHECK (msisdn REGEXP '^250[0-9]{9}$');

ALTER TABLE accounts
    ADD CONSTRAINT chk_account_number_format
    CHECK (account_number REGEXP '^[0-9]{8}$');

ALTER TABLE transactions 
    ADD CONSTRAINT chk_external_tx_id_format
    CHECK (external_tx_id REGEXP '^TXN[0-9]+$');

ALTER TABLE transactions
    ADD CONSTRAINT chk_transactions_amount_max
    CHECK (amount <= 10000000.00);
