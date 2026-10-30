insert into transactions (
    transaction_id,
    account_id,
    transaction_date,
    transaction_type,
    channel,
    amount,
    currency,
    transaction_status
)
values (
    'T_LATE_TEST',
    'A001',
    date '2024-06-20',
    'Deposit',
    'Online',
    100,
    'INR',
    'Success'
);