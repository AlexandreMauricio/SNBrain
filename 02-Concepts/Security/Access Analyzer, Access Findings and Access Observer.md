---
type: concept
tags: [concept, access-control, security, roles, instance-admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security (read in full 2026-10-08 through the docs site) - Access Management > Access Analyzer (27 topics, 1,097 cleaned lines - exploring, evaluate access for a user, role and group, export, compare user records, compare user access, previous searches, permission evaluation, FAQ, debug logs, access simulator, access insights), Access findings (70 lines), Access management console (84 lines); Access observer (98 lines). https://www.servicenow.com/docs/r/platform-security/access-analyzer.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Access Analyzer, Access Findings and Access Observer

**In one line:** three diagnostic tools for access: **Access Analyzer** answers "can this user, role or group do X on this object, and which rule decides" (and simulates role or group changes); **Access findings** are the results of daily automatic checks for risky access configuration; **Access Observer** logs who and what actually reads a given column.

From the Brazil docs. The rules being diagnosed: [[Access Control Lists (ACLs)]], [[Security Attributes, Security Data Filters and Field Query Controls]]. Debugging by impersonation: [[ACL Not Working as Expected]].

## Access Analyzer

A ServiceNow Store application. Role `access_analyzer_admin` (a granular role; changing ACLs or users from it needs the usual roles as well). **Access Analyzer > Analyze Permissions**.

- It impersonates the identity to evaluate; it stores no personal data.
- Session-time policies such as Zero Trust Access are **not** evaluated.
- Unreliable for managed-scope resources and delegated developers.

### Evaluate access

| Input | Choices |
|---|---|
| **Analyze by** | user, role or group |
| **Rule type** | Table (then optional **record** and **field**), UI page (read only), REST Endpoint (full path such as `/api/global/<name>` plus method; execute only), Client callable script include, AI agent, Agentic workflow |

Result, one row per operation: **Overall Access** (*Passed*, *Blocked*, *Skipped* = not evaluated, *Undefined* = no rule found), and columns for ACL, Access Handler, Data filtration, execution time and id. An **alert icon** beside a status means an ACL **script** is involved: read that ACL before trusting the result. **Export** to Excel, CSV, JSON or PDF, by download or email.

What is checked, in this order:

1. **Business rules** (query rules run first).
2. **IAccessHandler**: internal platform checks that can grant or deny without ACLs; not changeable.
3. **Data filters** (read only).
4. **ACLs**: role, then security attribute, then condition, then script.

Access is granted when the handler and the filters pass (or are absent) and an ACL passes. At table level only roles and security attributes are evaluated; conditions and scripts need a record. If the role check blocks, condition and script are skipped. Time-limited role assignments can change the outcome.

Selecting an operation opens the **debug log**: every business rule and ACL considered, with **Applies to** (field, record, table), status, required roles, and the status of role, security attribute, condition and script; whether it is customised; application. Inherited ACLs are evaluated before wildcards; once one ACL passes the rest show *Skipped*; field-level ACLs are listed before table-level ones.

### Compare

| Tab | Shows |
|---|---|
| **Compare user records** (V2) | two users side by side: details, roles, groups; **Show differences only** |
| **Compare user access** (V2) | the same operation on one **table** (optionally record and field) for two users; per ACL the role, attribute, condition and script result; **Show role Hierarchy** draws both users' roles and groups so the missing one is visible. Node menu: view user, role, group, or all resources a role can reach |
| **Access Insights** (V4; **Settings > Access Insights**) | inside the role hierarchy: how many *peers* (same company, department and manager by default; cost centre, country, location and title can be added) and how many in the whole organisation hold the role. Compare like with like |

**Access Analyzer > Access Analyzer Queries** keeps earlier evaluate and compare-access searches (not compare-user-records): **Reanalyze**, **Export**.

### Access Simulator

**Access Analyzer > Access Simulator**: preview, for one user and one table, the effect of *adding a role*, *removing a role*, *adding to a group* or *removing from a group*. Steps: criteria > **Preview changes** (roles and child roles gained in green) > **Simulated results** (present status beside simulated status per operation) > **Take action** (**Add and complete** / **Remove and complete**, or **Skip and Exit**). Applying requires *Take actions* to be enabled under **Settings** (a legal notice must be accepted).

## Access findings and the Access Management Console

- **Access checks** are rules run across the instance every 24 hours (for example: does every client-callable script include have an ACL; do ACLs reference roles that no longer exist; are public pages that should be restricted). Each violation creates an **access finding** with a priority, the check that raised it, the source record and how to resolve it. One check can raise many findings.
- **Access Management > Access Findings** (admin), or the console: **System Security > Security Center > Access management console** (roles `access_analyzer_admin`, `user_admin`).

| Console tab | Use |
|---|---|
| Overview | chart of findings by severity; a quick evaluate-access form; links |
| Access findings | the findings (create a task, mark resolved, or mute; **unmute before resolving**) and the checks (**Run check** to run one now) |
| Access analyzer | the tool and its earlier queries |

## Access Observer

Needs *ServiceNow Otto for Vault* from the Store; role `security_admin`. Purpose: before restricting or encrypting a column, see who and what uses it, so automation is not broken.

**Access Observer > Access Observer Configuration > New**: **Table**, **Column**, **Start job immediately** or **Start date and time**, **End date and time**. The record is active only during the window. Supported column types: string and UTF-8 string, email, URL, phone number (E164), date, date/time, journal and journal input, and the translated types.

**Access Observer > Access Observer Log** (`sys_data_ob_log`), one row per access:

| Field | Meaning |
|---|---|
| **Operation User**, **Operation Role** | who, with which roles |
| **Caller Application** | scope the access came from |
| **Caller Type**, **Caller Source** | kind of element (business rule, scheduled job, record producer ...) and its name |
| **Repeat Count**, **Session ID**, **Java Stack**, **JavaScript Stack**, **Primary Hash**, **Caller Source Document ID** | meaning not explained (?) |

## Related

- [[Access Control Lists (ACLs)]] · [[ACL Not Working as Expected]] · [[Security Attributes, Security Data Filters and Field Query Controls]] · [[Role Management]] · [[Impersonation]]
