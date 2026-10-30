# ADR-004: Financial Balance Reconciliation

**Status:** Accepted for portfolio implementation  
**Scope:** Synthetic banking analytics platform

## Context

The account balance source contains account ID, balance date, closing balance, and currency. The transaction source contains transaction ID, account ID, transaction date, transaction type, channel, amount, currency, and transaction status.

The balance snapshots are defined as end-of-day (EOD) closing balances. Same-day posted transactions are assumed to be included in the corresponding EOD balance.

The source does not provide transaction posting dates, debit/credit indicators, transfer references, opening balances, or adjustment/reversal records.

## Decision

1. Compare each balance snapshot with the previous snapshot for the same account.
2. Include transactions dated after the previous snapshot date and up to and including the current snapshot date.
3. Include successful deposits and withdrawals as known movements, using positive and negative signs respectively.
4. Flag successful transfers and other unsupported transaction types as `REVIEW_REQUIRED`.
5. Classify supported intervals as `RECONCILED` or `UNRECONCILED`, using a tolerance of 0.01 in the account's currency.
6. Preserve source values and report discrepancies; never invent adjustments to force reconciliation.
7. Treat the first available balance snapshot as outside the interval-based reconciliation until an opening balance or an approved baseline is available.

## Consequences and limitations

The reconciliation output is a diagnostic control, not proof of complete financial reconciliation. Differences may reflect missing transactions, unsupported movement types, adjustments, reversals, timing differences, or inconsistencies in the synthetic source.

Production implementation requires agreed posting-date semantics, transfer direction and counterparties, adjustment/reversal handling, opening balances, currency rules, and exception ownership.

## Validation

A dbt singular test validates that reconciliation statuses follow the defined classification rules. Passing this test confirms classification consistency; it does not establish that the source balances are financially correct.