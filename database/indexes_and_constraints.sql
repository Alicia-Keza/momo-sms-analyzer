-- momo database indexes and constraints


USE momo_db;

-- this is index for transaction dates sorting them by the date reported
CREATE INDEX idx_transactions_date
    ON transactions (transaction_date);

-- this is for index for filtering transaction by status
CREATE INDEX idx_transactions_status
    ON transactions (status); 