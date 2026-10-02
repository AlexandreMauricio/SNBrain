---
type: reference
tags: [reference, instance-admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Instance Clone reference" (pp. 726-731), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Clone options and states

Navigation: **All > Clone Admin Console > Request Clone**. Concepts: [[Instance Clone Overview]]. Grouped and paraphrased.

## Options on a clone request

| Option | Default | Notes |
|---|---|---|
| **Lock settings for this clone request** | off | freezes the profile's settings as they are now, whatever changes later |
| **Amount of data copied from the Task table** | Full | or **Last 90 days** for task and its children. Counter-intuitively, 90 days can take **longer**, because older records are removed after the restore |
| **Clone frequency** | None | Weekly, Every 2 weeks, Every 4 weeks, with a number of occurrences |
| **Backup options** | Most recent | or **On-demand backup**, taken at the start time; the clone waits for it |
| **Exclude tables specified in Exclusion List** | on | off copies the data of those tables too. Default exclusions (audit, licence usage, logs, notifications) stay excluded regardless |
| **Exclude audit and log data** | on | audit and log tables arrive empty; activity streams on the target then lack history |
| **Exclude attachment data** | on | skips large files in `sys_attachment` (video, images, binaries). System attachments are kept (table names starting `ZZ_`, `sys_certificate`, `sc_cat_item`, `sys_upgrade_manifest`, `ecc_agent_jar`, `ecc_agent_mib`, `sys_store_app`). Can add to clone duration |
| **Preserve theme** | on | target keeps its theme and CSS |
| **No. of days of In-progress Global Update Sets to be preserved** | off | keeps in-progress **global** update sets created in the last 90 days. Scoped update sets are not kept |

## Guidelines for a faster clone

- Leave the task data option on **Full**.
- Excluding attachments adds time.
- Preserve little, and put conditions on preservers.
- Exclude large tables entirely where the data is not needed.
- Use clone chaining for many targets.

## Scheduling limits

- Two clones to the same target must be at least **five days apart**.
- Maximum scheduled occurrences: 25 weekly, 13 every two weeks, 7 every four weeks.
- A scheduled clone cannot be modified: cancel and resubmit.

## Clone states

| State | Meaning |
|---|---|
| Draft | being created (never shown in history) |
| Requested | awaiting approval |
| Scheduled | will start at the set time |
| Active | running |
| Completed | finished successfully |
| Canceled | cancelled |
| Hold | rejected by the server: not ready by the scheduled time, or other requests were submitted before it completed |
| Error | failed while running; contact Support |
| Rollback requested / Rolling back / Rolled back / Rollback failure | rollback progress |

## Cleanup script execution states

Ready to schedule, Scheduled, Executing, then Completed, Error (message in **Error message**) or Not executed (skipped by its own logic). A retry returns to Executing and increments **Runs**.

## Related

- [[Request, Schedule, Cancel or Roll Back a Clone]]
