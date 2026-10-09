---
type: how-to
tags: [how-to, cmdb, workspace, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Workspace, topics "Create a CI manually in CMDB Workspace", "Request attributes for new CIs", "Limit class list selection for new CIs" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-workspace.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Create a CI Manually in CMDB Workspace

**Goal:** create one CI by hand and have identification (IRE) check it, so it is unique and meets the rules of its class.
**Where:** **Workspaces > CMDB Workspace** > Home > quick link **Create CI**; or CI overview > **CI Summary** > a group bar > a class > **Create CI**.
**Role:** `cmdb_manual_ci_ire_access` (inside `sn_cmdb_editor` by default).

Not for application services and similar special CIs: those have their own wizards.

## Steps

1. **Select class.** Classes without a valid identification rule are greyed out. **Continue**.
2. **Required attributes.**
   - Dependent class: under **Dependent-upon CI** choose the **Dependent-upon class** and pick the CI it depends on.
   - **Identifier entries:** choose one or more sets of **Criterion attributes** and fill their values.
   - Mandatory attributes of the class.
   - **Continue.** If an existing CI matches, *CI already exists* appears: **Review existing CI** and change one or the other.
3. **Additional attributes:** whatever the administrator asks for on top (for example Operational status). **Continue**.
4. **Relationship definition:** optional. **Add** > **Relationship type** (the Parent / Child note is the new CI's role) > select the other CIs > **Add** > **Continue**. A dependent CI already got its dependent relationship in step 2.
5. **Review** > **Create**. Then **Done**, **Review new CI** or **Create another CI**.

## Result

- **Discovery source** = *Manual via IRE*.
- **Operational status** = *Design*; change it when the CI is ready.

## Example

Class **Linux Server**, criterion attribute set *Serial number*, serial `EX-0001`, name `Example Server 02`, additional attribute Operational status left as Design, no extra relationship. **Create**. A second attempt with serial `EX-0001` stops at step 2 with *CI already exists*.

## Administrator options

Both use the configuration identifiers framework ([[CMDB Workspace]]), role `sn_cmdb_ws.config_editor`:

- **Ask for extra attributes:** `sn_cmdb_ws_ci_additional_attributes.list` > **New**: Config identifier (Default = fallback for every workspace), CI class, Additional attributes, Apply to hierarchy, Active.
- **Limit the classes offered:** `sn_cmdb_ws_ci_class_config.list` > **New**: Config identifier, CI class, Operation (include or exclude), Apply to hierarchy, Active.
- **Do something after the CI is created** (for example create a record that references it): implement the extension point `ManualCreateCIExtPoint` (server-side script include). `getAppId()` returns the sys_id of the workspace's application from **UX Application** (`sys_ux_page_registry`); `postInsertCI()` holds the extra actions. One implementation per application.

## Gotchas

- From a class that is excluded from this flow, the list shows **New** instead of **Create CI**: that creates the CI in the classic form **without IRE**.
- Relationships to users and groups can be added but are not processed by IRE.
- The criterion attribute list leaves out entries based on the Product instance identifier.

## Related

- [[CI Form in CMDB Workspace]] · [[CI Classes, Dependency and Principal Class]] · [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]]
