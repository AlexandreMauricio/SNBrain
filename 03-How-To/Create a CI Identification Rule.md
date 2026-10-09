---
type: how-to
tags: [how-to, cmdb, data-integrity, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE) > Configure, topic "Create a CI identification rule" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Create a CI Identification Rule

**Goal:** give a CMDB class its own identification rule so IRE can tell whether an incoming CI already exists.
**Where:** **All > Configuration > CI Class Manager** > **Hierarchy** > the class > **Class Info > Identification Rule**.
**Roles:** `sn_cmdb_admin` or `itil_admin` (read: `sn_cmdb_editor`, `itil`).

Concepts, field meanings and guidelines: [[IRE Identification Rules]]. Look at a shipped rule first (the Hardware class).

## Steps

1. In the **Identification Rule** section choose **Add** (no rule), **Edit** (own rule) or **Replace** (the class is using an inherited rule).
2. Fill **Independent/Dependent**, **Name**, **Description** > **Save**. *Dependent* is available only if the class has dependent relationship rules.
3. **Identifier Entries** > **Add** and choose:
   - **Use attributes from main table**: set **Priority**, **Criterion Attributes**, optionally **Allow null attribute** > **Save**.
   - **Use attributes from another table (Lookup table)**: set **Search On Table** (must reference `cmdb_ci`), criterion attributes, and under **Advanced options** a filter and **Enforce exact count match** > **Save**.
   - **Use attributes from main and another table (Hybrid)**: general settings > main table attributes > lookup table and its attributes > **Save**.
4. Optional, **Related Entries** > **Add**: **Related table**, **Referenced field**, **Priority**, **Criterion attributes** > **Save**.
5. Optional: an inclusion rule under **Identification** > **Inclusion Rule (Advanced)**.
6. Test with [[Simulate an IRE Payload with Identification Simulation]].

## Example

Custom class `u_cmdb_ci_example_thin_client` currently inherits the Hardware rule. **Replace** > Independent, name `Example Thin Client Rule`. One identifier entry on the main table: priority 100, criterion attributes **Serial number**; a second at priority 200 with **Name**. No lookup entries. Simulation with a known serial number then reports an update of that CI.

## Gotchas

- **Replace discards the inherited identifier entries and related entries.** Re-create the ones still needed (for example the related entry for installed software that Hardware provides).
- A rule can be changed only on the class that defines it.
- Keep entries few and avoid lookup entries where an independent attribute set will do.

## Related

- [[Create a CI Class]] · [[CI Class Manager]]
