---
type: how-to
tags: [how-to, instance-admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Instance Clone", topics "Request a clone", "Cancel a clone", "Roll back a clone", "Schedule recurring clones" (pp. 718-722), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Request, schedule, cancel or roll back a clone

**Goal:** refresh a sub-production instance from another instance, once or on a schedule, and know how to stop or undo it.
**Prerequisites:** role `clone_admin` on the source. Target registered ([[Register a Clone Target Instance]]). A clone profile is recommended.
**Navigation:** All > Clone Admin Console > Request Clone

## Steps: request

1. Open **All > Clone Admin Console > Request Clone**.
2. Choose **Source instance** and **Target instance** (a target can be added from here).
3. Choose a **Clone Profile**. Left empty, all available exclusions, preservers and cleanup scripts are used. A profile marked default loads automatically.
4. Optionally tick **Lock settings at the time of clone request**.
5. Set **Clone Scheduled Start time** on the calendar (it shows maintenance and other conflicts).
6. Add email addresses for updates (external ones allowed).
7. Review the exclusions, preservers and scripts by selecting the numbers shown, and set the options ([[Clone Options and States]]).
8. **Continue**, review the summary, **Confirm and Submit Clone Request**.

## Steps: recurring

On the same form, pick the time slot, select **Schedule**, choose the **clone frequency** and the total number of clones.

## Steps: cancel

**Clone Home**, select the clone's tile, **Cancel**, give a reason, **OK**. Possible until the **Node Repoint** stage; the target stays as it was.

## Steps: roll back

**Clone Home**, select the clone's tile, **Rollback**. Only the last clone, within **seven days** (two days if the instance is sharded).

## Result / how to check it worked

The **Clone Activity** tab shows the request with its state, start, completion and duration. Preparation, including choosing the backup, only begins at the scheduled time.

## Example

Clone *prod* to *dev* next Saturday night with the profile *Example Dev Refresh*, on-demand backup off, updates emailed to the platform team; repeat every 4 weeks for 6 occurrences.

## Tables / fields involved

- `clone_instance`: legacy clone history

## Gotchas

- **Everything on the target that is not preserved is overwritten**, including in-progress update sets and unpublished applications ([[Carry In-Progress Update Sets Through a Clone]]).
- The backup can be up to 36 hours old; very recent source changes may be missing unless an on-demand backup is used.
- Two clones to the same target within five days are rejected.
- To clone several targets from one source, raise one request per target.
