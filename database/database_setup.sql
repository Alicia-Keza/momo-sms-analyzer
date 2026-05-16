/* Creating tables */
create table users(
    user_id int not null auto_increment ,
    full_name varchar(255) not null,
    created_at timestamp default current_timestamp,
);

/*agents table*/
create table agents(
    agent_id int not null auto_increment ,
    agent_name varchar(255) not null,
    agent_code varchar(50) not null,
    created_at timestamp default current_timestamp,

/*merchants table*/
create table merchants(
    merchant_id int not null auto_increment,
    merchant_name varchar(255) not null,
    shop_code varchar(50) not null,
    created_at timestamp default current_timestamp,    
);
/*service providers table*/
create table service_providers(
    provider_id int not null auto_increment ,
    provider_name varchar(255) not null,
    service_type enum('utility','telco','insurance') not null,
    created_at timestamp default current_timestamp,    
);
/*transaction_categories table*/
create table transaction_categories(
    category_id int not null auto_increment ,
    name varchar(100) not null,
    direction ENUM('credit','debit') NOT NULL, 

);

/*sms_messages table*/
create table sms_messages(
    sms_id BIGINT UNSIGNED  NOT NULL auto_increment ,
    address varchar(50) not null,
    received_epoch_ms BIGINT  not null,
    body text not null,
    readable_date
    service_center varchar(50) not null,
    backup_set char(8)
    ingested_at timestamp default current_timestamp;

);

/*phone_numbers table*/
create table phone_numbers(
    phone_id int not null auto_increment ,
    owner_type ENUM('user','agent') NOT NULL,
    owner_id int not null,
    msisdn varchar(50) not null,
    linked_at timestamp default not null current_timestamp,
    constraint chk_phone_owner Check (owner_id > 0) 
);

/* accounts table*/
create table accounts(
    account_id int not null auto_increment ,
    user_id int not null ,
    account_number varchar(50) not null,
    account_type  ENUM(varchar(50)) not null,
    provider_name varchar(100) not null,
    status ENUM ('active','closed','suspended') default 'active',
    opened_at timestamp default current_timestamp,
    closed_at timestamp default null on update current_timestamp,  
);

/*transactions table*/
create table transactions(
    transaction_id bigint not null auto_increment ,
    external_tx_id varchar(255) not null,
    source_sms_id BIGINT UNSIGNED NOT NULL ,
    account_id int not null ,
    category_id int not null ,
    status ENUM('pending','success','failed') not null,
    amount decimal(15,2) not null,
    fee_amount decimal(15,2) not null,
    transacted_at timestamp default not null current_timestamp,
    created_at timestamp default current_timestamp,
);
    
/* transaction_participants table*/
create table transaction_participants(
    participant_id int not null auto_increment ,
    transaction_id bigint not null ,
    party_type ENUM('sender','recipient') not null,
    party_id varchar(255) not null,
    role ENUM ('sender','recipient','facilitator') not null,
    
    
);
/*balance_snapshots table*/
create table balance_snapshots(
    snapshot_id bigint not null auto_increment,
    account_id int not null ,
    balance_after decimal(15,2) not null,
    snapshot_at timestamp default current_timestamp,

);
/* system_logs table*/
create table transaction_flags(
    log_id int not null auto_increment ,
    sms_id BIGINT UNSIGNED NOT NULL ,
    transaction_id bigint not null ,
    event_type ENUM('parse_success','parse_fail') not null,
    log_level ENUM('info','warn','error') not null,
    message text not null,
    created_at timestamp default current_timestamp,    
);
