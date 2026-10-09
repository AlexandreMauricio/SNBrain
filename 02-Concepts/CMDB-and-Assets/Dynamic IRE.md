---
type: concept
tags: [concept, cmdb, data-integrity, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE) > Explore, topic "Dynamic IRE", and Configure, topic "Exclude classes from Dynamic IRE" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Dynamic IRE

**In one line:** an alternative identification engine that needs no hand-written identification rules: it scores candidate matches on many attribute combinations in parallel and adjusts itself as payloads arrive. The classic, rule-driven engine is then called **Static IRE**. Background: [[Identification and Reconciliation Engine (IRE) Overview]].

- Applies **only to Hardware** ([[cmdb_ci_hardware]]) **and its descendants**.
- Its algorithms cannot be changed.
- Claimed benefits: fewer duplicates (more attribute combinations tried), no rule maintenance.

## Availability

- **On by default on new (zBooted) instances from Zurich Patch 11**: property `glide.identification_engine.dynamic_ire_enabled` = true ("committed mode").
- Upgraded instances stay on Static IRE until switched.

## Modes

| Mode | What runs | Use |
|---|---|---|
| **Simulation** | Static and Dynamic side by side; differences stored in **CMDB IRE Output Comparison Items** (`cmdb_ire_output_comparison_item`) | compare on a non-production instance first |
| **Committed** | Dynamic only | production. Can be switched back to Static with no after-effects |

## Simulate, commit, go back

Role `sn_cmdb_user`.

1. **CI Class Manager** > **Hierarchy** > **Hardware** > **Identification Rule** > section **Dynamic IRE** > **Simulate Dynamic IRE**.
2. In the dialog, start the simulation without ticking the "I have simulated and assessed..." statement.
3. Study the comparison: a **parity score** (share of identical results) and bar charts of inserts, updates and incomplete CIs per engine. A bar opens the comparison records (JSON); **Summarize** on a record gives a readable version through an Otto for CMDB skill.
4. On production: tick the statement > **Commit to Dynamic IRE**.
5. Back: same page > **Change to Static IRE**.

Or set `glide.identification_engine.dynamic_ire_enabled` directly. Comparison runs when `glide.identification_engine.dynamic_ire.auto_compare` (default true) and `...auto_compare.sampling.enabled` are both true.

A mature Static setup should show a high parity score: Dynamic reaches the same answers without the rules.

## Exclude classes

For a hardware child class identified by custom attributes with its own rules, Dynamic IRE may not help. Add the class to **Dynamic IRE skipped classes** (`cmdb_dynamic_ire_skip_class.list` > **New** > **Class to be skipped for Dynamic IRE**). The class **and its descendants** keep using Static IRE.

Roles: write `itil_admin` or `sn_cmdb_admin`; read `itil`, `itil_admin`, `sn_cmdb_editor`.

## Related

- [[IRE Identification Rules]] · [[Duplicate CI Detection in IRE]]
