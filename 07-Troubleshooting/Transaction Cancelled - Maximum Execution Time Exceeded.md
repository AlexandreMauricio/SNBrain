---
type: troubleshooting
tags: [troubleshooting, instance-admin, api]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Platform performance", topics "Transaction quotas", "Default quota rules", "Transaction cancellation" (pp. 2797-2823), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Transaction cancelled: maximum execution time exceeded

## Symptom

A page shows a transaction cancelled message, a dashboard widget shows "Widget cancelled - maximum execution time exceeded", or a REST call to the Table API fails after about 60 seconds.

## Cause

A **transaction quota rule** matched the transaction and its limit was exceeded. Usual base rules: UI Transactions (about 5 minutes), REST Table API request timeout (60 s), Homepage Widgets (30 s), Reference Completer (5 s).

## Check

1. **System Logs > System Log > Transaction Cancellations**, or system log warnings where **Message** starts with `Cancel`.
2. Read the reason: `maximum execution time exceeded` (quota), `canceled by other transaction` (the user's session re-issued the request), `canceled by user request` (cancel button).
3. Find which rule: **System Definition > Quota Rules**, compare conditions (type, URL) with the transaction.
4. Find why it is slow: **System Diagnostics > Stats > Slow Queries / Slow Scripts**.

## Fix

- Prefer fixing the slowness: smaller query, pagination (`sysparm_limit` on REST), an index, a lighter report.
- Only then consider raising the rule's **Maximum Duration**, and test outside production.

## Related

- [[Transaction Quotas, Application Quotas and Operational Toggles]] · [[Monitoring and Troubleshooting Instance Performance]]
