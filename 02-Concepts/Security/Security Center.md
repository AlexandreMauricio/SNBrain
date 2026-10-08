---
type: concept
tags: [concept, security, instance-admin, admin, roles, notifications, reporting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Security Center (whole chapter, 64 topics, 2,243 cleaned lines, read in full 2026-10-08 through the docs site) - landing page, Identity and Access Management, Security configuration console (hardening, all settings, score trend and comparison, scanner, findings, comparison, checks, suites, results, Customer Actions), Security monitoring console (event notifications, policies, custom email, metrics and every metric category), Security posture console (best practices, posture dashboards), Security Tasks, Security learning, banner announcements, granular roles. The lists of scan checks and best practices are in a separate note. https://www.servicenow.com/docs/r/platform-security/security-center/sec-center-v2.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Security Center

**In one line:** a free application, installed by default since Vancouver, that tells an administrator how securely the instance is configured (a **hardening compliance score**), scans for risky configuration, lists security changes ServiceNow wants customers to make, watches security metrics and events, and turns all of it into assignable **Security Tasks**.

From the Brazil docs. Check and best-practice lists: [[Security Center Scan Checks and Best Practices]]. Steps to improve the score: [[Raise the Hardening Compliance Score]]. Tools it links to: [[Access Analyzer, Access Findings and Access Observer]], [[Scripting Governance Tool]].

- **All > System Security > Security Center** (also **All > Security Center**). Scope prefix `sn_vsc`. Updated through the Store each quarter between family releases.
- Replaces Instance Security Center, which ended sales in September 2024 and is unsupported.

## Layout

| Area | Contains |
|---|---|
| Landing page | *My Security Tasks*, instance summary cards, Access management, Machine identity, the three consoles, tools, learning links |
| **Security configuration console** | Security hardening, Security scanner, Customer Actions |
| **Security monitoring console** | Security Event Notifications, Security metrics |
| **Security posture console** | Best Practices, Security posture dashboards |
| Identity and Access Management | Machine Identity Console, Access Analyzer, Scripting Governance (the Conditional Script Writer group and role `snc_required_script_writer_permission`) |
| Security Tasks, Learning | |

## Hardening compliance score

Hardening settings are recommended values for security-related properties and plugins (the long reference list is the *Hardening settings* chapter of the same guide).

- Each setting has a **risk score from 0 to 10**. **Score = sum of the risk scores of compliant settings ÷ sum of all risk scores × 100**, rounded up. Docs example: 25.4 ÷ 34.9 = 72.7, shown as 73.
- Recalculated on the first of each month and after installing Security Center; **Update score** recalculates on demand.
- The best practices suggest staying as near 100% as functionality allows, with 83% as a minimum, and trying changes on a non-production instance first.

**All settings** list: **Name**, **Compliance Status**, **Score Impact** (percentage; all add to 100), **Priority** (Critical, High, Moderate, Low; 1 to 4), **Security category**, **Resolution Details**. A setting's page adds **Functional impact** (what changing it can break), description, documentation link, activity, and **Setting configuration** (what is wrong and how to fix it; one setting may involve several properties and plugins). Filters can be saved and shared with everyone or a group.

- **Hardening compliance score trend**: chart with Performance Analytics options (targets, thresholds, forecast, trend, comments, statistics) and a table of dates, scores and counts of non-compliant settings.
- **Hardening score comparison**: between an older and a recent date, which settings changed status, by priority and by security area.

## Security scanner

Its suites are also reachable under **All > Instance Scan > Suites**. **Checks** are rules that look for risky configuration; **suites** group checks and can be scheduled; a **finding** is a record that broke a check.

| Check class | Use |
|---|---|
| Table check | conditions against records of a known table |
| Column type check | a rule run over every field of a given type |
| Script-only check | metadata and complex logic in a script |
| Linter check | analyses script code through its syntax tree |

- Shipped suite **Auditor** (the *Access Controls Auditor* suite; read-only). To change the set, create a suite and add checks (for example filter *Category is Security* and *Application is Global*), or build child and parent suites (running a parent runs its children).
- A suite has tabs *Details*, *Checks*, *Child Suites*, *Parent Suites*, *Schedule* (name, **Run** frequency, **Active**, optional scripted **Condition**, **Run as tz**). Roles for suites: `admin` or `sn_vsc.security_center_viewer`.
- **Findings** list: check, category, **Count** (how many times the record broke it), priority 1 to 4, source table and record, resolution details, linked task, domain. **Mute / Unmute** with a reason (muted findings of the last six months have their own card).
- Finding types on the shipped checks: *Resolution Recommended*, *Review and Decide*, *Inform*.
- **Scan results**: per run, tabs for details (status, type, seconds), findings, suites, checks, failures (checks that errored), log, statistics, targets.
- **Security scan comparison**: needs at least two runs of the same suite; changed findings by criticality and security area.

## Customer Actions

Guided, manual security changes that an upgrade cannot make for you because they could disturb your configuration (examples given: retiring weak certificates, enforcing MFA, disabling insecure protocols, the end of support of the GlideEncrypter API).

- Tabs **Available**, **Overdue**, **Due soon**, **In progress**, **Complete**; a timeline by due date; an overdue count.
- Open one: overview (why) > **Go to next step** > follow each instruction group and **Mark complete** > **Complete**. All activity is recorded and can be commented.

## Security Event Notifications

Policies that send email when something security-relevant happens (for example *Send notification when high privileged role is granted*, impersonation, exports).

- List columns: name, status, last triggered, count last week, percentage change against the usual weekly rate.
- Shipped policies: recipients and values can be changed, but **not the trigger or the conditions: duplicate first** (arrow beside **Update** > **Duplicate**).
- **New custom policy**: choose one of three event types, then *Policy settings*: **Trigger**; **Conditions** (all or any); **Notifications** (template, groups, users). **Activate** / **Deactivate**.
- Custom email: a notification on table Security policy notification (`sn_vsc_security_policy`) (written so in the docs; the name suggests the policy table (?)), **Send when** = Triggered, recipients from the *Users/Groups in fields* lists, body using `${event_id.<field>}` and `${execution.policy.name}`; then select it in the policy.
- History: charts and a table of all notifications sent.

## Security metrics

More than 50 trend metrics, each with Performance Analytics features (thresholds, targets, forecasts), plus a customizable *My metrics* dashboard (edit while in the Security Center application scope; shareable).

| Category | Metrics |
|---|---|
| Users | total, active, inactive, inactive but not locked out, locked out, new, successful and failed logins, external logins, local logins not protected by MFA, never logged in, not logged in for a month / 6 months / a year, need to reset password, password reset failures |
| Privileged users | the same set for users holding elevated roles |
| Privileged identity | admin logins, impersonations, elevations to `security_admin`, logins by ServiceNow employees, admin users added |
| Authentication | users enrolled for MFA, using MFA, bypassing MFA, high-privileged users without MFA, locked-out MFA users, web-service-only accounts, X.509 certificates expiring within 30 days, biometric or hardware key users, REST APIs without an access policy, integration accounts without *Web service access only* |
| Adaptive authentication (needs the plugin and policies on) | policy result rates, success and failure by event type, denied IP addresses, logins and users by event type, API logins |
| Active sessions, Session management | user sessions, privileged user sessions |
| Integration accounts | total, active, inactive (accounts with **Internal integration user** ticked on the user record) |
| Export | total exports by user; exports of classified data by class |
| Data classification | classifiable and classified tables and columns |
| Antivirus | quarantined, downloaded, restored, deleted files |
| Email | spam received per day |

Email on a threshold: open the metric > *Thresholds* icon > **+**: visibility (everyone or me), type (for example *All time high*; a value only for *Less than* / *More than*) > save; the email itself is the event-based notification **PA Thresholds Notification** (recipients and content edited there).

## Security posture console

- **Best Practices**: a list of recommended configuration tasks with a **maturity level** (*Build a foundation*, *Enhance the experience*, *Optimize the functionality*, *Add advanced features*: crawl, walk, run, fly), **Status** (Open, In progress, Completed), **Priority** you set (Immediate, Later, Not applicable), **Goals** (initial security configuration, secure emails, monitoring logs, manage access controls, protect with encryption, keep instances up to date) and the Security Center version that introduced, changed or removed it. Each has *Overview*, *Task Steps* (instructions; **Mark step complete**, skip, **Restart step**) and *Activity*. **Complete Best Practice** works even with steps skipped: leave a comment for auditors. The list itself: [[Security Center Scan Checks and Best Practices]].
- **Security posture dashboards**: sections *At a glance* (compliance score, metric threshold alerts for me and unassigned (table `sn_vsc_metric_threshold_event`; the docs print `n_vsc_...`), Customer Actions due soon, quarantined files, release version), *Users* (total, active, active integration accounts, active privileged accounts, never logged in = created in the last 60 days with no last login), *Login protection* (failed logins, failed privileged logins, privileged accounts without MFA, REST APIs without an API access policy), *Instance hardening*, *Instance trends* (auditor suite results), *Data protection* (classified data, classified exports, total and encrypted PII columns).
- Tab **All instances**: the same figures for the production instance and its non-production instances, through the trust configuration between instances ([[Otto for Setup and Multi-Instance Trust]]).
- The shipped dashboard cannot be edited: **More Actions > Duplicate** and edit the copy.

## Security Tasks

**Security Center > Security Tasks**: one list for all security work, with cards for upcoming, overdue and open.

- Created with **+Create task** (on hardening settings, findings, checks, suites, metrics, best practices, Customer Actions) or **automatically**, one open task per source:

| Type | Generated when |
|---|---|
| Metrics threshold breached | a metric's threshold is breached (a new task only after the previous one is closed) |
| Event notification | a notification policy triggers |
| Hardening score deviation | the score falls by at least the configured amount since the previous daily score (default 3 points) |
| New Customer Action | a Customer Action is installed |
| New banner announcement | a banner arrives |

- Settings: **Security Center > Security Center Properties**: enable or disable automated tasks; hardening score degradation threshold.
- Fields: **Number**, **Type**, **Short description**, **Assignment group**, **Assigned to** (must be in the group and hold `admin` or the task manager role), **State** (Pending, Open, In Progress, Closed, Canceled), **Priority** (1 Critical to 4 Low), **Due date**, **Due status**, **Details**, work notes (also private).
- Bulk: tick rows > **Edit** (assign to yourself), **Delete**, **Export** (Excel, CSV, JSON, PDF; download or email).

## Roles

| Role | Can |
|---|---|
| `admin` | everything |
| `sn_vsc.security_center_admin` (since Security Center 3.2) | administer Security Center without `admin`. Contains `mi_admin`, `access_analyzer_admin`, `pa_admin`, `scan_user`, `data_classification_auditor`, `sn_ace.ace_user`, `antivirus_viewer`, `sn_vsc.task_manager`, `sn_mif.mif_read`, `sn_cicd.sys_ci_automation` |
| `sn_vsc.security_center_viewer` | read only (the pages also list creating and rescheduling scan suites) |
| `sn_vsc.task_manager` | work on, create and manage Security Tasks; sees others' tasks without editing them; no access to the rest of Security Center |
| `itil` | only the Security Tasks assigned to them |

## Banner announcements

ServiceNow can push a banner to administrators about a newly found security risk, with a link to the fix. Dismissing it lasts for the session only; it returns until its end date (**Start** / **End** on the Banner Announcement record, `sys_ux_banner_announcement`). On by default; switch under **Security Center > Notifications > Manage announcement settings** or property `sn_vsc.configure_customer_push_action` = false.

## Discrepancies in the docs

- Role names appear with a dot (`sn_vsc.security_center_viewer`, `sn_vsc.task_manager`) and with an underscore (`sn_vsc_security_center_viewer`, `sn_vsc_task_manager`).
- The Auditor suite is said to hold 8 checks on one page, while the *Auditor checks* page lists about twenty.
- "Active privileged accounts" is defined on the dashboard page only by a garbled condition (active, not an internal integration user); elsewhere privileged users are "users given additional roles by admins".
- Active integration accounts are identified by **Internal integration user** on one page and by **Web service access only** on another.

## Related

- [[Security Center Scan Checks and Best Practices]] · [[Raise the Hardening Compliance Score]] · [[Access Analyzer, Access Findings and Access Observer]] · [[Scripting Governance Tool]] · [[Multi-Factor Authentication]] · [[Adaptive Authentication]] · [[ServiceNow Vault and Otto for Vault]] · [[Otto for Setup and Multi-Instance Trust]] · [[System Properties Reference]]
