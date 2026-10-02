---
type: how-to
tags: [how-to, data-management, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management" (pp. 613-617, 627-632), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create an archive rule

**Goal:** move old records of a table to its archive table on a schedule, optionally with related records and a destroy rule.
**Prerequisites:** role admin. Check the table's existing archive rules first to avoid overlapping conditions.
**Navigation:** All > System Data Management > Data Management Console (wizard), or Data Management Policies, or System Archiving > Archive Rules (Core UI form)

## Steps (console wizard)

1. In the console, select the table (Overview or Tables tab), then **Create rule**.
2. **Define your rule**: type **Archive**, name and description.
3. **Define conditions**: build the filter. **Calculate archive estimate** to see how many primary records match. Optionally **Auto-rearchive** with an interval.
4. **Destroy archived records** (optional): tick it, set the archive duration (default one year), optionally **Destroy related records**, **Recalculate Destroy Estimate**, **Activate archive destroy rule**.
5. **Manage related records** (optional): **+ Add records**, choose **Action** (Archive, Clear, Cleanup), the **Reference** relationship, and a **Reference table rule** if those records should cascade with their own rule.
6. **Rule summary**: review and tick **Activate the rule upon creation** if wanted.

## Steps (Core UI form)

1. Open the policy for the table and select **New** in **Archive Rules** (or **System Archiving > Archive Rules > New**).
2. Fill **Name**, **Table**, **Conditions**, optionally **Retain references** and **Auto Rearchive**. Submit.
3. Use **Recalculate Archive Estimate**, add **Archive Related Records**, and **Create Destroy Rule** as needed.
4. Tick **Active**. **Run Archive Now** archives at once (only if the policy is active).

## Result / how to check it worked

Matching records move on the next archive run (hourly job). See them under **All > System Archiving > Archive Tables > Archive <table>**, and the rule's backlog and history in the console.

## Example

Rule *Example Old Closed Incidents* on Incident: `[Closed] [relative] [on or before] [150] [Days] [ago]` and `[Active] [is] [false]`. Destroy rule with a duration of two years. Records land in `ar_incident`.

## Tables / fields involved

- `ar_<table>`: the archive table
- `sys_archive_log`: XML copy of each archived record
- `sys_archive_run_chunk`: batches being processed

## Gotchas

- The policy and the rule must both be active.
- An empty or zero destroy duration destroys archived records immediately.
- **Retain references** cannot be unticked after saving.
- Related tables only cascade when their rule is named in **Reference table rule** (since Washington DC).
- Details and limits: [[System Archive and Archive Rules]].
