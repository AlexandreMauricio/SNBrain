---
type: concept
tags: [concept, data-management, platform, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management" (pp. 591-609, 625-626, 652), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Data Management overview

**In one line:** Data Management is the set of platform tools for watching how much storage tables use and for archiving or deleting old records through rules grouped in a per-table **data management policy**.

## The pieces

| Piece | What it does | Note |
|---|---|---|
| Data Management Console | storage used, trends, largest and fastest-growing tables, rules and their backlog | below |
| Data management policy | one record per table that groups its archive and cleanup rules and switches them all on or off | below |
| Archive rules | move old records to an `ar_` table | [[System Archive and Archive Rules]] |
| Destroy rules | delete archived records after a retention time | same note |
| Table cleanup rules | delete records automatically by age and condition | [[Table Cleaner]] |
| One-time delete rules, update jobs, delete jobs | previewable bulk changes with rollback | [[Update Jobs, Delete Jobs and One-Time Delete Rules]] |
| Database rotation | split high-volume tables by date | [[Database Rotation - Table Rotation and Table Extension]] |
| Live Archive | archive to object storage (RaptorDB Professional V2) | [[Live Archive with RaptorDB Professional]] |

Active by default. Role: admin. Domain separation: basic support (archived records keep their domain).

**Granular role `data_mgmt_tools_admin`**: lets someone do data management work without full admin, but it is not enough alone. Also assign `delegated_developer` (tables, columns, scopes), `events_admin` (to schedule jobs) and `context_rollback_executor` (to roll back updates and deletes), plus roles that give access to the data itself (e.g. `itil_admin` for incident, problem and change).

## Data management policy

**All > System Data Management > Data Management Policies.**

- Fields: **Name**, **Tablename**, **Description**, **Active**.
- **Both the policy and the rule must be active for a rule to run.** Clearing **Active** on the policy deactivates all its rules.
- Since Xanadu, a policy is created automatically for any table that has an archive or cleanup rule. Check the **Tablename** column before creating one by hand.
- Related lists: **Archive Rules**, **Table Cleanup Rules**.

## Data Management Console

**All > System Data Management > Data Management Console.**

- **Overview tab**: primary storage used and its change over time; trend of the ten largest tables (weekly or monthly); **Tables over 10 GB with the most growth** (growth over 30 days); **Largest tables**; buttons **New cleanup rule**, **New archive rule**, **Manage audit config**.
- **Tables tab**: every table over 100 MB by default, with **Table size (GB)**, **Growth (30 days)**, **Active rules**. Works for physical tables (Task) and logical ones (Incident, Problem, Change Request).
- **Per table**: size and trend, plus **Rule details** (rules, status, type, **Records in backlog**, executions in the last 7 days). Per rule: backlog trend and execution history (time, records impacted, duration).
- Figures refresh **once a day**; reductions can take up to 24 hours to show.

Two terms the console uses:

- **Driver table**: a table that adds volume to another. Incident, Problem and Change Request drive Task.
- **Associated tables**: records with no life of their own, such as Sys Audit (`sys_audit`), Attachment (`sys_attachment`) and Journal Entry (`sys_journal_field`). To shrink them, put rules on the driver table.

Account-wide storage entitlements are tracked in Subscription Management, not here.

## Suggested routine (from the guide)

1. Notice in Subscription Management that an instance uses more storage than expected.
2. In the console, find the tables that consume or grow the most.
3. Check their policies; create one where missing.
4. Archive what must be kept, clean up what is not needed after a date.
5. Keep watching the backlog and the top ten tables.

## Related

- [[Approaches to Deleting Many Records]] · [[Sys ID]]
