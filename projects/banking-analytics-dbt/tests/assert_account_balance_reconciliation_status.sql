select
    account_id,
    previous_balance_date,
    balance_date,
    unsupported_transaction_count,
    reconciliation_difference,
    reconciliation_status
from {{ ref('int_account_balance_reconciliation') }}
where
    unsupported_transaction_count < 0
    or (
        unsupported_transaction_count > 0
        and reconciliation_status != 'REVIEW_REQUIRED'
    )
    or (
        unsupported_transaction_count = 0
        and abs(reconciliation_difference) <= 0.01
        and reconciliation_status != 'RECONCILED'
    )
    or (
        unsupported_transaction_count = 0
        and abs(reconciliation_difference) > 0.01
        and reconciliation_status != 'UNRECONCILED'
    )
    or reconciliation_status is null