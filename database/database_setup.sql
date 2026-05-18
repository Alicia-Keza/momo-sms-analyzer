/* creating the database */
create database momo_db
 character set utf8mb4
 collate utf8mb4_unicode_ci
 comment='momo sms processing system';
use momo_db;

/* Creating tables */

/*users table*/
create table users(
    user_id int not null auto_increment primary key comment 'primary key for each end user',
    full_name varchar(255) not null comment 'full legal name of the user',
    created_at timestamp not null default current_timestamp comment 'time the user opened the account',
)
engine=innodb default charset=utf8mb4
comment 'table storing information about end users';

/*agents table*/
create table agents(
    agent_id int not null auto_increment primary key comment'an identifier for each momo agent, unique for each agent',
    agent_name varchar(255) not null comment'agent business name or trading name',
    agent_code varchar(50) not null comment 'MNO-issued unique identifier code for the agent',
    created_at timestamp not null default current_timestamp comment 'time this agent record was created in the system',

)
engine=innodb default charset=utf8mb4
comment 'momo agents who facilitate cash-in / cash-out operations';

/*merchants table*/
create table merchants(
    merchant_id int not null auto_increment primary key comment'an identifier for each momo merchant, unique for each merchant',
    merchant_name varchar(255) not null comment'merchant business name or trading name',
    shop_code varchar(50) not null comment'MNO-issued unique identifier code for the merchant',
    created_at timestamp not null default current_timestamp comment 'time this merchant record was created in the system', 
)
engine=innodb default charset=utf8mb4
comment 'momo merchants who accept momo payments';

/*service providers table*/
create table service_providers(
    provider_id int not null auto_increment primary key comment'an identifier for each service provider, unique for each provider',
    provider_name varchar(255) not null comment 'name of the third party provider billed with momo',
    service_type enum('utility','telco','insurance') not null comment 'category of services such as utility(water,electricity,internet,tv subscription), telco(mobile data, airtime), insurance()',
    created_at timestamp not null default current_timestamp comment 'time the provider record was inserted into the system',  
)
engine=innodb default charset=utf8mb4
comment 'utility, telco, and insurance providers billed with momo';


/*transaction_categories table*/
create table transaction_categories(
    category_id int not null auto_increment primary key comment'an identifier for each transaction category, unique for each category',
    name varchar(100) not null comment 'machine-readable category slug (e.g. send_money, airtime_purchase)',
    direction ENUM('credit','debit') NOT NULL comment 'money-flow direction relative to the  owning account: credit = inflow, debit = outflow'

)
engine=innodb default charset=utf8mb4
comment ' lookup table classifying each transaction by purpose and direction';

/*sms_messages table*/
create table sms_messages(
    sms_id BIGINT  NOT NULL auto_increment primary key comment'an identifier for each sms message, unique for each message',
    address varchar(50) not null comment'sender address as it appeared on the handset (e.g. M-Money)',
    received_epoch_ms BIGINT  not null comment'unix epoch in milliseconds when the sms was received on the device',
    body text not null comment'full raw sms text body, source of truth for parsing',
    readable_date varchar(50) not null comment'human-readable date string from the android sms provider',
    service_center varchar(50) not null comment'service center number that delivered the SMS',
    backup_set char(8) not null comment'8-character backup set label (constant for each backup file)',
    ingested_at timestamp  not null default current_timestamp comment'time this SMS row was inserted into the system',
    constraint chk_sms_epoch CHECK (received_epoch_ms > 0) comment 'ensure the epoch timestamp is positive',

)
engine=innodb default charset=utf8mb4
comment ' raw SMS messages ingested from SMS backup files';

/*phone_numbers table*/
-- the phone_numbers table links phone numbers to users or agents. this table is polymorphic
-- owner_type = 'user': owner_id -> users.user_id
-- owner_type = 'agent': owner_id -> agents.agent_id
-- owner_id is the foreign key to either users.user_id or agents.agent_id depending on the owner_type

create table phone_numbers(
    phone_id int not null auto_increment primary key comment'an identifier for each phone number, unique for each number',
    owner_type ENUM('user','agent') NOT NULL comment' polymorphic key indicating the  type of the account owner: user or agent from the users and agents table ',
    owner_id int not null comment'polymorphic key linking to users or agents table ',
    msisdn varchar(50) not null comment'mobile number in international format',
    linked_at timestamp not null default current_timestamp comment'time this phone number was added to the system',
    constraint chk_phone_owner_id CHECK (owner_id > 0) comment ' constraint to ensure owner_id is a positive integer',

)engine=innodb default charset=utf8mb4
comment 'table linking phone numbers to users or agents which is also a junction table for users and agents';

/* accounts table*/
create table accounts(
    account_id int not null auto_increment primary key comment'an identifier for each account, unique for each account',
    user_id int not null comment'user id from the users table  as a foreign key ',
    account_number varchar(50) not null comment'account number',
    account_type  ENUM('personal','merchant','agent') not null comment' type of account is either personal, merchant or agent ',
    provider_name varchar(100) not null comment 'MNO operating this account text label (e.g., "MTN Mobile money")',
    status ENUM ('active','closed','suspended') default 'active' comment 'account status either active, closed or suspended',
    opened_at timestamp not null default current_timestamp comment'time this account was opened',
    closed_at timestamp null default null comment'time this account was closed',  
    constraint fk_accounts_user 
     foreign key (user_id) references users(user_id) on delete restrict on update cascade comment'foreign key to the users table,  restricts deletion or update of users if there are accounts associated with them',
    constraint chl_accounts_closed_at check (closed_at is null or closed_at > opened_at) comment 'constraint to ensure that closed_at is either null or greater than opened_at'


)engine=innodb default charset=utf8mb4
comment 'table linking accounts to users and  other information about accounts';


/*transactions table*/
create table transactions(
    transaction_id bigint not null auto_increment primary key  comment'an identifier for each transaction, unique for each transaction',
    external_tx_id varchar(255) not null comment'external transaction identifier',
    source_sms_id BIGINT null default null comment'foreign key to the sms_messages table',
    account_id int not null comment'foreign key to the accounts table',
    category_id int not null comment'foreign key to the transaction_categories table',
    status ENUM('pending','completed','failed') not null comment'status of the transaction',
    amount decimal(15,2) not null comment'amount of money transacted',
    fee_amount decimal(15,2) not null comment'fee amount of money transacted',
    transaction_date timestamp not null comment'time this transaction was transacted',
    created_at timestamp not null default current_timestamp comment'time this transaction was created',
        constraint fk_transactions_sms
        foreign key (source_sms_id) references sms_messages(sms_id) on delete set null on update cascade comment'foreign key to the sms_messages table',
        constraint fk_transactions_account
        foreign key (account_id) references accounts(account_id) on delete restrict on update cascade comment'foreign key to the accounts table',
        constraint fk_transactions_category
        foreign key (category_id) references transaction_categories(category_id)  on delete restrict on update cascade comment'foreign key to the transaction_categories table',
        constraint chck_transactions_amount check (amount>0) comment 'constraint to ensure that amount is a positive number',
        constraint chck_transactions_fee check (fee_amount>=0) comment'constraint to ensure that fee amount is a non-negative number'
    
)engine=innodb default charset=utf8mb4
comment 'table linking transactions to sms messages and accounts';

/* transaction_participants table*/
--junction table resolving m:n relationship between transactions and participants
--transactions that are made with users, merchants, agents or providers 
--party_id is a polymorphic foreign key to the users, merchants, agents or providers table 
--role can be sender, receiver or facilitator
create table transaction_participants(
    participant_id int not null auto_increment primary key comment'an identifier for each participant, unique for each participant',
    transaction_id bigint not null comment'foreign key to the transactions table',
    party_type ENUM('user','merchant','agent','provider') not null comment'type of participant is either user, merchant, agent or provider',
    party_id int not null comment'foreign key to the users, merchants, agents or providers table',
    role ENUM ('sender','receiver','facilitator') not null comment'role of the participant is either sender, receiver or facilitator',
    constraint fk_participants_transaction
    foreign key (transaction_id) references transactions(transaction_id) on delete cascade  on update cascade comment'foreign key to the transactions table',
    constraint chk_participants_party_id check (party_id > 0) comment'constraint to ensure that party_id is a positive number'

)engine=innodb default charset=utf8mb4
comment 'table linking participants to transactions';

/*balance_snapshots table*/
create table balance_snapshots(
    snapshot_id bigint not null auto_increment primary key comment'an identifier for each snapshot, unique for each snapshot',
    transaction_id bigint not null comment'foreign key to the transactions table',
    account_id int not null comment'foreign key to the accounts table',
    balance_after decimal(15,2) not null comment'balance after transaction',
    snapshot_at timestamp not null default current_timestamp comment'time this snapshot was taken',
    constraint fk_snapshots_accounts
    foreign key (account_id) references accounts(account_id) on delete cascade  on update cascade comment'foreign key to the accounts table',
    constraint fk_snapshots_transactions
    foreign key (transaction_id) references transactions(transaction_id) on delete cascade  on update cascade comment'foreign key to the transactions table',
    constraint chk_snapshots_balance check (balance_after >= 0)

)engine=innodb default charset=utf8mb4
comment 'table linking balance snapshots to transactions and accounts';  

/* system_logs table*/
create table system_logs(
    log_id int not null auto_increment primary key comment'an identifier for each log, unique for each log',
    sms_id BIGINT  null default null comment'foreign key to the sms_messages table',
    transaction_id bigint  null default null comment'foreign key to the transactions table',
    event_type ENUM('parse_success','parse_fail','duplicate') not null comment'type of event is either parse_success, parse_fail or duplicate',
    log_level ENUM('info','warn','error') not null comment'level of log is either info, warn or error',
    message text not null comment'message of the log in human readable format',
    created_at timestamp  not null default current_timestamp comment'time this log was created', 
    constraint fk_logs_sms
    foreign key (sms_id) references sms_messages(sms_id) on delete set null on update cascade comment'foreign key to the sms_messages table ',
    constraint fk_logs_transactions
    foreign key (transaction_id) references transactions(transaction_id) on delete set null on update cascade comment'foreign key to the transactions table'

)engine=innodb default charset=utf8mb4
comment 'table linking system logs to sms messages and transactions';

