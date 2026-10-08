---
type: concept
tags: [concept, instance-admin, security, admin, roles, email, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Logs (whole chapter, 20 topics, 799 cleaned lines, read in full 2026-10-08 through the docs site) - System logs, System log, Disable stack trace formatting, Transaction logs, Client transaction timings, Push logs, System email log, Event logs, Import logs, System Diagnostics module, Customer Updates table, Log history, Use the log file browser, Enhanced logging security, Avoid log tampering (protected tables, configuration, property), Logging auditing and errors, Disabling SQL error messages, Granular admin roles for Logging tables. https://www.servicenow.com/docs/r/platform-security/system-logs.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# System Logs, Log Files and Protected Tables

**In one line:** the instance keeps several logs as ordinary tables under **System Logs** (system log, transactions, emails, events, imports, outbound web services), plus text log files per application node; tables rotate after weeks, files after 21 days, and the Protected Tables feature stops even administrators from altering them.

From the Brazil docs. Sending logs elsewhere for longer retention: [[Log Export Service (LES)]]. Field-level history of records is auditing, a different mechanism (Auditing chapter of the same guide). Performance use of these logs: [[Monitoring and Troubleshooting Instance Performance]].

## The logs

| Module (System Logs >) | Table | Content |
|---|---|---|
| System Log | Log (`syslog`) | messages from the platform, applications and scripts |
| Transactions | Transaction Log (`syslog_transaction`) | one row per request |
| Emails | Email (`sys_email`) | every email created or received ([[sys_email]]) |
| Push Notifications | not named on the page (`sys_push_notification` appears in the protected tables list (?)) | push messages queued and sent |
| Events | Event (`sysevent`) | every event fired ([[Events and the Event Queue]]) |
| Imports | table not named (?) | messages from imports and transforms; detail under **Import Sets > Transform History** |
| Outbound web services logging (module label not given (?)) | `sys_outbound_http_log` | outbound REST and SOAP calls |
| Utilities > Node Log File Browser / Download | files | the node's own log files |

Elsewhere: **System Diagnostics** (Upgrade History, Slow Queries) and the Customer Updates table.

### System log (`syslog`)

Fields: **Created**, **Level** (Debug, Information, Warning, Error), **Message** (long messages and stack traces are collapsed; client script `FormatStackForSyslog` does this and can be deactivated), **Source** (area, for example EMAIL), **Source Package** (application).

- A *Warning* is an unexpected condition that was handled; an *Error* is an operation that failed. Instances produce many platform errors that need no action: judge by the source.
- The list shows the current day; use the file browser for older entries.

### Transaction log (`syslog_transaction`)

Fields: **Created**, **Type**, **Created by**, **Origin application** (scope), **Response time**, **Network time**, **Output length**, **SQL count**, **Business rule count**, **Business rule time**, **URL**, **System ID** (node), **IP address**, **GZipped**, **Protocol**, **HTTP Response Code**.

- Background and scheduler transactions are logged only when longer than 1,000 ms (KB0778299).
- UI action **Show Syslog Records** on a transaction opens the `syslog` rows written during it.
- Plugin *Client Transaction Timings* (needs the response time indicator) adds **System Logs > Client Transactions**: per form or list load, server response time, business rule time, SQL time, client response time, network time, browser time, client script time, UI policy time, with a per-step breakdown for forms.

### Email log

`sys_email` fields used here: **Mailbox**, **State** (Error, Ignored, Processed, Ready), **Receive type** (None, Forward, New, Reply), **Type** (received; received - ignored; send - ready; send - failed; send - ignored; send - translation - ready; sent), **Target**, **User**, **Notification Type** (None, SMS, SMTP), **Weight**, **Importance**, **Error String** (why sending failed), **Recipients**, **Body**, **Headers**, and the embedded list of originating event and notification. Not rotated: the Email retention feature archives after one year and destroys a year later.

### Push log

**Claim**, **Payload**, **Queue count** (attempts; 0 for long means no job is picking it up; at 10 the system gives up), **Request ID**, **Type** (pending, success = sent but not necessarily received, failure). Roles `push_admin` or `admin`.

### Event log

**Created**, **Name**, **URI**, **Parm1**, **Parm2**, **Table**, **Processed**, **Processing time** (ms), **Queue**. The hardening guidance: review events such as logins and failed logins on a schedule.

### Customer Updates (`sys_update_xml`)

One row per configuration change: **Name**, **Type**, **Target Name**, **View**, **Payload** (the record's XML after the change), **Local Update Set**, **Remote Update Set**, who and when ([[Update Sets]]). Not recorded there: metadata types with update synchronisation off, cascading renames, sys_id changes when files are coalesced, some generated flow documentation, licensing configuration rows, background jobs, and manual edits of the table itself.

## Retention

| Table | Kept by rotation |
|---|---|
| `syslog`, `syslog_transaction` | 8 weekly rotations |
| `sysevent`, `ecc_queue`, `ecc_event` | 7 daily rotations |

Node log files: compressed every 2 days, **purged after 21 days**, and immediately when a node is retired. The file browser and download work **only for the node you are logged in to** (see **System Diagnostics > Stats**). Browser filters: start and end time, level, message, session id, thread name, maximum rows.

Node log lines carry an **attribution** (the script or component that wrote the line, or the Java class) and each transaction start line carries the transaction id and type (List, Form, XMLHttp, Report, SOAP, Export, Scheduler, TextSearch, REST, JSON, AMB, Archive, Batch REST, Instance Scan, Other). Properties `glide.log.append.attribution` and `glide.db.log.append.classname.attribution`, both on by default. UI macros and portal widgets are not attributed.

## Protected tables (log tampering)

Plugin **Protected Tables** (`com.glide.protected_tables`), installed but disabled since Utah. **Protected Tables > Log Protection** (role `security_admin`, elevated).

- Covers `syslog`, `syslog_transaction`, `sys_outbound_http_log`, `sysevent`, `sys_audit`, `sys_push_notification`, `syslog_app_scope`, and its own configuration table.
- Per table and per operation (insert, update, delete) one of four levels: *Block and log the attempt*, *Only block*, *Only log*, *Don't block and don't log*. Attempts are written to `protected_table_log`.
- Fixed: `syslog` and `syslog_app_scope` for update and delete; the configuration table for all three; `sysevent` inserts can never be blocked.
- Switch on with the **Enable Log Protection** toggle; switch off only through property `com.glide.security.protected_table.enabled` = false.
- A hardening setting ([[Hardening Settings - Validation, Files, Logging and Other]]): anything that writes to or deletes from these tables will start failing.

Related hardening: `glide.db.loguser` = false keeps SQL error details out of the browser.

## Roles for log tables

Since the granular admin roles, `admin` is no longer bound to these ACLs:

| Role | Access |
|---|---|
| `syslog_viewer` | read `syslog` |
| `syslog_admin` | create and write `syslog` |
| `txn_part_metrics_viewer` | read and report on `syslog_transaction_part_metrics` |
| `txn_part_metrics_admin` | create, write, delete on that table |

## Related

- [[Log Export Service (LES)]] · [[Monitoring and Troubleshooting Instance Performance]] · [[Events and the Event Queue]] · [[sys_email]] · [[Update Sets]] · [[Security Center]] · [[Impersonation]]
