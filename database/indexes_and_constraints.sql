-- momo database indexes and constraints


USE momo_db;

-- this is index for transaction dates sorting them by the date reported
CREATE INDEX idx_transactions_date
    ON transactions (transaction_date);

-- this is for index for filtering transaction by status
CREATE INDEX idx_transactions_status
    ON transactions (status); 

-- to help when filtering by both transaction date and status and for failed transactions in last 7 days 
CREATE INDEX idx_transactions_date_status
    ON transactions (status, transaction_date);

-- helps in finding participants faster and alsoo easier
CREATE INDEX idx_participants_party
    ON transaction_participants (party_type, party_id);

