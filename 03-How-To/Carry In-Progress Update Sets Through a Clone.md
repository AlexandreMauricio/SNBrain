---
type: how-to
tags: [how-to, instance-admin, update-sets]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Managing Instance Clone", topic "Handling a large amount of in-progress update sets" (pp. 720-721), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Carry in-progress update sets through a clone

**Goal:** keep many work-in-progress update sets on a target instance that is about to be cloned over.
**Prerequisites:** role `clone_admin`, and admin rights on update sets on both instances.
**Navigation:** update set lists on the target and source; Clone Admin Console

## Steps

1. On the **target**, filter the update sets list to all work-in-progress ones.
2. Create one new update set to act as a batch parent.
3. Select the whole **Parent** column for the filtered rows (Shift plus selecting the column), double-click a cell and set the parent to the new update set, updating all rows at once.
4. Set the parent update set to **Completed** and name it recognisably (e.g. `CLNREQ_<date>`).
5. Export the parent update set.
6. On the **source**, retrieve it. **Do not commit.**
7. Wait 24 hours so the daily backup includes it, or use an on-demand backup.
8. Run the clone.
9. On the target after the clone, set the parent back to work in progress and remove the parent link from the children.
10. On the source, delete the retrieved update set.

## Result / how to check it worked

After the clone, the target has the parent update set and the in-flight development with it.

## Example

Twelve in-progress update sets on *dev* are parented under `CLNREQ_2026_10_01`, retrieved (not committed) on *prod*, and come back to *dev* inside the clone.

## Tables / fields involved

- update sets (parent field)

## Other ways to do this

- The clone option **No. of days of In-progress Global Update Sets to be preserved** keeps global in-progress update sets from the last 90 days, but **not scoped ones** ([[Clone Options and States]]).
- Export each update set to XML before the clone and import it afterwards.

## Gotchas

- Committing the retrieved set on the source would apply unfinished work to production.
- Applications that exist only on the target must be reinstalled after the clone.
