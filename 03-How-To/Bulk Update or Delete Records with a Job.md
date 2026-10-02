---
type: how-to
tags: [how-to, data-management, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management", topics "Updating records safely in Core UI" and "Deleting records safely in Core UI" (pp. 637-642), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Bulk update or delete records with a job

**Goal:** change a field on many records, or delete many records, without a script and with the option to roll back.
**Prerequisites:** role admin.
**Navigation:** All > System Data Management > Update Jobs / Delete Jobs

## Steps: update job

1. Open **System Data Management > Update Jobs** (specific records), or in any list right-click a column header and choose **Data Management > Update All with preview** (everything in the list).
2. Select the table and add conditions.
3. **Preview** and open the count link to see the matching records.
4. Under **Fields & values**, choose each field and its new value.
5. **Continue** to save the job.
6. **Execute Now** then **Proceed**, or set **Run at** and select **Update** to schedule.

## Steps: delete job

1. Open **System Data Management > Delete Jobs**, or list header **Data Management > Delete All with preview**.
2. Select the table and add conditions. **Preview** the records. **Continue**.
3. Select the related link **Preview Cascade** and review the counts per table.
4. Execute now or schedule with **Run at**.

## Result / how to check it worked

The job's progress page and execution results. To undo, open the executed job and select the related link **Rollback**.

## Example

On a test instance, an update job on Incident with condition **Category is Software** sets **Assigned to** to *Test User*. After checking the result, **Rollback** restores the previous assignees.

## Tables / fields involved

- the target table and, for deletes, the tables that extend or reference it

## Other ways to do this

[[Approaches to Deleting Many Records]]

## Gotchas

- Deletes cascade up to three levels; attachments are deleted even if not shown in the preview.
- Run large jobs outside business hours. Do not use a delete job to empty a whole table.
- Scheduling for later can affect a different number of records than the preview showed.
- Background: [[Update Jobs, Delete Jobs and One-Time Delete Rules]].
