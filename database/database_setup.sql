/* creating the database */
create database momo_db
 character set utf8mb4
 collate utf8mb4_unicode_ci;
use momo_db;

/* Creating tables */

/*users table*/
create table users(
    user_id int not null auto_increment primary key, 
    full_name varchar(255) not null, 
    created_at timestamp not null default current_timestamp
)
engine=innodb default charset=utf8mb4;

/*agents table*/
create table agents(
    agent_id int not null auto_increment primary key,
    agent_name varchar(255) not null,
    agent_code varchar(50) not null,
    created_at timestamp not null default current_timestamp

)
engine=innodb default charset=utf8mb4;

/*merchants table*/
create table merchants(
    merchant_id int not null auto_increment primary key,
    merchant_name varchar(255) not null,
    shop_code varchar(50) not null,
    created_at timestamp not null default current_timestamp  
)
engine=innodb default charset=utf8mb4;

/*service providers table*/
create table service_providers(
    provider_id int not null auto_increment primary key,
    provider_name varchar(255) not null,
    service_type enum('utility','telco','insurance') not null,
    created_at timestamp not null default current_timestamp   
)
engine=innodb default charset=utf8mb4;

/*transaction_categories table*/
create table transaction_categories(
    category_id int not null auto_increment primary key,
    name varchar(100) not null,
    direction ENUM('credit','debit') NOT NULL

)
engine=innodb default charset=utf8mb4;


/*sms_messages table*/
create table sms_messages(
    sms_id BIGINT  NOT NULL auto_increment primary key,
    address varchar(50) not null,
    received_epoch_ms BIGINT  not null,
    body text not null,
    readable_date varchar(50) not null,
    service_center varchar(50) not null,
    backup_set char(8) not null,
    ingested_at timestamp  not null default current_timestamp,
    constraint chk_sms_epoch CHECK (received_epoch_ms > 0)

)
engine=innodb default charset=utf8mb4;

/*phone_numbers table*/
create table phone_numbers(
    phone_id int not null auto_increment primary key,
    owner_type ENUM('user','agent') NOT NULL,
    owner_id int not null,
    msisdn varchar(50) not null,
    linked_at timestamp not null default current_timestamp,
    constraint chk_phone_owner_id CHECK (owner_id > 0)
)
engine=innodb default charset=utf8mb4;

/* accounts table*/
create table accounts(
    account_id int not null auto_increment primary key,
    user_id int not null,
    account_number varchar(50) not null,
    account_type  ENUM('personal','merchant','agent') not null,
    provider_name varchar(100) not null,
    status ENUM ('active','closed','suspended') default 'active',
    opened_at timestamp not null default current_timestamp,
    closed_at timestamp null default null,  
    constraint fk_accounts_user
     foreign key (user_id) references users(user_id) on delete restrict on update cascade,
    constraint chl_accounts_closed_at check (closed_at is null or closed_at > opened_at)

)
engine=innodb default charset=utf8mb4;


/*transactions table*/
create table transactions(
    transaction_id bigint not null auto_increment primary key ,
    external_tx_id varchar(255) not null,
    source_sms_id BIGINT null default null ,
    account_id int not null ,
    category_id int not null ,
    status ENUM('pending','complete','failed') not null,
    amount decimal(15,2) not null,
    fee_amount decimal(15,2) not null,
    transacted_at timestamp not null default current_timestamp,
    created_at timestamp not null default current_timestamp,
        constraint fk_transactions_sms
        foreign key (source_sms_id) references sms_messages(sms_id) on delete set null on update cascade,
        constraint fk_transactions_account
        foreign key (account_id) references accounts(account_id) on delete restrict on update cascade,
        constraint fk_transactions_category
        foreign key (category_id) references transaction_categories(category_id)  on delete restrict on update cascade,
        constraint chck_transactions_amount check (amount>0),
        constraint chck_transactions_fee check (fee_amount>=0)  
    )
engine=innodb default charset=utf8mb4;

    
/* transaction_participants table*/
create table transaction_participants(
    participant_id int not null auto_increment primary key,
    transaction_id bigint not null ,
    party_type ENUM('user','merchant','agent','provider') not null,
    party_id int not null,
    role ENUM ('sender','receiver','facilitator') not null,
    constraint fk_participants_transaction
    foreign key (transaction_id) references transactions(transaction_id) on delete cascade  on update cascade,
    constraint chk_participants_party_id check (party_id > 0)
)
engine=innodb default charset=utf8mb4;

/*balance_snapshots table*/
create table balance_snapshots(
    snapshot_id bigint not null auto_increment primary key,
    transaction_id bigint not null ,
    account_id int not null ,
    balance_after decimal(15,2) not null,
    snapshot_at timestamp not null default current_timestamp,
    constraint fk_snapshots_accounts
    foreign key (account_id) references accounts(account_id) on delete cascade  on update cascade,
    constraint fk_snapshots_transactions
    foreign key (transaction_id) references transactions(transaction_id) on delete cascade  on update cascade,
    constraint chk_snapshots_balance check (balance_after >= 0)
)
engine=innodb default charset=utf8mb4;

/* system_logs table*/
create table system_logs(
    log_id int not null auto_increment primary key,
    sms_id BIGINT  not null ,
    transaction_id bigint not null,
    event_type ENUM('parse_success','parse_fail','duplicate') not null,
    log_level ENUM('info','warn','error') not null,
    message text not null,
    created_at timestamp  not null default current_timestamp, 
    constraint fk_logs_sms
    foreign key (sms_id) references sms_messages(sms_id) on delete set null on update cascade,
    constraint fk_logs_transactions
    foreign key (transaction_id) references transactions(transaction_id) on delete set null on update cascade 
)

engine=innodb default charset=utf8mb4;
