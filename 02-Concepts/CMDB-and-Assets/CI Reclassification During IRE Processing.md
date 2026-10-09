---
type: concept
tags: [concept, cmdb, data-integrity, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE), topics "Configure CI reclassification during IRE processing", "Create a reclassification restriction rule", "View a reclassification task", and the reclassification notes in "Identification and Reconciliation Engine (IRE)" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CI Reclassification During IRE Processing

**In one line:** when a payload says an existing CI belongs to another class, [[Identification and Reconciliation Engine (IRE) Overview|IRE]] reclassifies it automatically by default (upgrade, downgrade or switch), which for downgrades and switches **loses attribute data**; properties, payload flags and restriction rules control this.

What upgrade, downgrade and switch mean, and what is lost: [[Reclassify a CI]]. Reclassification happens only between classes with **identical identification rules**.

## Three layers of control

### 1. Allow or refuse the reclassification (properties, default true)

`glide.class.upgrade.enabled`, `glide.class.downgrade.enabled`, `glide.class.switch.enabled` (**Configuration > CMDB Properties > Identification/Reconciliation Properties**).

Set to false: IRE **rejects the payload** (or the item, with the enhanced API) and creates a **reclassification task**.

### 2. Update the CI but skip the class change (properties, default false)

`glide.identification_engine.update_without_upgrade_enabled`, `...update_without_downgrade_enabled`, `...update_without_switch_enabled` (add to `sys_properties`).

Set to true: attributes are updated, the class is left alone, **no task is created**. **These win over layer 1.**

| `glide.class.switch.enabled` | `...update_without_switch_enabled` | Linux server arrives as Windows server |
|---|---|---|
| true | false (base system) | attributes updated **and** class switched |
| true | true | attributes updated, class unchanged |
| false | false | payload or item rejected, reclassification task |
| false | true | attributes updated, class unchanged |

### 3. Per payload item (flags)

- `classUpgrade`, `classDowngrade`, `classSwitch` on the item: override the matching layer 1 property.
- `updateWithoutUpgrade`, `updateWithoutDowngrade`, `updateWithoutSwitch` (in the item's `settings`): the class change is skipped if **either** the flag or its property is true. They take precedence over the other settings, and exist to stop several sources flipping one CI's class back and forth.
- For a whole data source: the same options as properties on the **Robust Import Set Transformer** form.

```json
{ "items": [ { "className": "cmdb_ci_server", "classUpgrade": true, "classDowngrade": true, "classSwitch": true,
               "values": { "name": "example-host-01", "serial_number": "EX-0001" } } ] }
```

## Reclassification restriction rules

Block one specific class change while everything else in the update goes through. Table `cmdb_ire_reclassification_restriction` (open with `.list`). Roles: write `sn_cmdb_admin` or `itil_admin`; read `sn_cmdb_editor`, `itil`.

| Field | Notes |
|---|---|
| Name | |
| Source table | the CI's current class |
| Source inheritance | also for child classes of the source |
| Target class | the class it would become |
| Target inheritance | also for child classes of the target |
| Type | **Downgrade** or **Switch** |
| Active | toggle in the list |

- **One direction only.** Linux to Windows and Windows to Linux need two rules.
- On by default as a mechanism: `glide.identification_engine.reclassification_restriction_rules_enabled` = true. A payload can bypass the rules with `"settings": { "skipReclassificationRestrictionRules": "true" }`.
- Typical use: a Service Graph Connector that reports servers with a less specific class and would downgrade them. Example: source `cmdb_ci_linux_server`, target `cmdb_ci_server`, type Downgrade.
- The IRE output says when a restriction rule was applied.

## Reclassification tasks

Table `reclassification_task`. **Configuration > Identification/Reconciliation > Reclassification Tasks** (role `sn_cmdb_admin`, `sn_cmdb_editor`, `admin` or `itil`). Fields: **Configuration item**, **Short description**, **Description** (current class and the class it should become), **Internal payload**.

- Created only by the layer 1 properties, **not** by the layer 2 ones.
- Nothing is done automatically: review, then reclassify by hand if right.
- The error logged is `RECLASSIFICATION_NOT_ALLOWED` ([[IRE Error Messages]]).

## Related

- [[IRE Properties and Tables Reference]] · [[IRE Identification Rules]]
