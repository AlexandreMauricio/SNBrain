---
type: how-to
tags: [how-to, instance-admin, update-sets]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Upgrade Center", topics "Process the skipped records list", "Resolve conflicts for an individual record", "Review skipped records using related lists" (pp. 2866-2885), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Process the skipped records list after an upgrade

**Goal:** decide, for each customised record the upgrade skipped, whether to keep, merge or revert, and capture the decisions for the next instances.
**Prerequisites:** role admin. The first sub-production instance has been upgraded. An update set is selected to capture changes.
**Navigation:** All > Upgrade Center > Upgrade History

## Steps

1. Open **Upgrade History** and select the upgrade (or use **Review changes** on the Upgrade Summary Report).
2. Open the related list **Skipped Changes to Review**. Sort by **Priority**.
3. Open a record. Read the differences (click a text field to open the diff/merge view).
4. Choose:
   - keep yours: set **Resolution** to *Reviewed and Retained*;
   - merge: **Resolve Conflicts**, move what you want from left (base) to right (yours), **Save Merge**;
   - take the base version: **Revert to Base System**.
5. Write the reason in **Comment** and update.
6. Repeat; then complete the update set and move it to the next instance after that instance is upgraded.

## Result / how to check it worked

**Skipped Changes to Review** is empty (or holds only deliberately deferred records). The **Skipped Record VTB** related link shows the same as a board. Test the affected features.

## Example

A business rule *Example incident autoclose tweak* was skipped at priority 2. The new base version fixes a bug in a function you did not touch: use **Resolve Conflicts**, bring that block across, keep your own change, save. Status becomes *Reviewed and Merged*.

## Tables / fields involved

- `sys_upgrade_history`, `sys_upgrade_history_log` (upgrade details), `sys_update_xml` (customer updates)

## Gotchas

- Filter **Changed** is true to hide customised records the vendor did not touch.
- Be in the right application scope for scoped records.
- Background: [[Skipped Records in Upgrades]].
