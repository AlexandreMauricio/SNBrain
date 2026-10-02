---
type: concept
tags: [concept, instance-admin, api, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Platform performance", topics "Transaction quotas", "Application quotas", "Operational toggles", "Transaction cancellation", "Platform performance reference" (pp. 2796-2830), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Transaction quotas, application quotas and operational toggles

**In one line:** quota rules cancel transactions that run too long or do too much, so one bad query, script or integration call cannot starve the instance.

## Transaction quotas

- The **Quota Manager** is a background thread. Every heartbeat (`glide.quota.manager.heartbeat`, 1 s) it lists active transactions, matches each against the quota rules whose conditions fit, and cancels the first one that exceeds a limit. The user sees a cancellation page (UI page `transaction_canceled_quota`).
- Rules: **System Definition > Quota Rules** (the guide also names it Transaction Quota Rules). Limits available: **Maximum Duration** (s), Maximum Business Rules, Maximum Database Time, Maximum SQL Statement Time, Maximum SQL Queries, Maximum Outbound Requests, Maximum Outbound Request Duration, Maximum Events, Maximum Jobs. **Order**: lower checked first, but all are checked.
- Conditions: **URL**, **Thread Name**, **Foreground**, **Type** (List, Form, XMLHttp, Report, SOAP, Export, Scheduler, Text Search, Other), **User**, **Homepage**, **Homepage Widget**, **Attributes**.

### Base rules worth knowing

| Rule | Effect |
|---|---|
| UI Transactions | cancels UI transactions just before the 5-minute load-balancer cut-off, showing a cancel page instead of HTTP 500. Background scripts excepted |
| REST Table API request timeout | inbound Table API calls limited to **60 s** |
| REST Import Set API / Aggregate API / Attachment API request timeout | 60 s each |
| Homepage Widgets | 30 s per widget ("Widget cancelled - maximum execution time exceeded") |
| Reference Completer | reference auto-complete stopped after 5 s |
| Fix Script Processor | fix scripts may run 4 hours |
| Scan timeout | Instance Scan, 3 hours |

### Finding cancellations

- **System Logs > System Log > Transaction Cancellations** (`syslog_cancellation`; property `glide.quota.manager.log.cancellation`).
- System log warnings: filter **Message** starts with `Cancel`. Reasons in the text:
  - `maximum execution time exceeded`: the Quota Manager did it;
  - `canceled by other transaction`: the session cancelled its own earlier request;
  - `canceled by user request`: the user pressed cancel.
- In the transaction log, cancelled transactions have `CANCELLED` appended to the URL.
- Debug: property `glide.quota.manager.debug` = true, then **System Diagnostics > Session Debug > Debug Quotas**.

Warning from the guide: quotas set too low break normal work; study **User Administration > Active Transactions** first and test outside production. `glide.quota.manager.minimum_transaction_time` (1 s) should match the most restrictive quota.

## User-side cancel

Long transactions show a timer and a **Cancel** button after `glide.ui.transaction.long_response.time` seconds (`com.glide.request_manager.active`). Imports cannot be cancelled this way. Admins can **Kill** background transactions from **User Administration > Active Transactions** or **System Diagnostics > Active Transactions (All Nodes)** (intended for jobs, not user requests; never kill the row that lists the transactions).

## Application quotas

**System Definition > Application Quota Rules**: one rule per scoped application (never global), limiting **Maximum Events** and **Maximum Jobs** in an update period (`glide.quota.manager.cluster.update.seconds`, 300). On violation **all** transactions of that scope are cancelled and new ones blocked until the next period. **Log only** just records. Evaluated independently of transaction quotas.

## Operational toggles

**System Run Level** menu: an **operational toggle** names a throttleable behaviour (for example how often type-ahead search polls); **toggle levels** give it values; **run level toggle mappings** pick the level for each system run level, with exception roles. Used to reduce load under stress.

## Related

- [[Monitoring and Troubleshooting Instance Performance]] · [[Export Limits and Properties]] · [[Instance Scan]]
