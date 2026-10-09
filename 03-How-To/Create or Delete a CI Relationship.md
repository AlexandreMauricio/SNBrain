---
type: how-to
tags: [how-to, cmdb, forms-lists]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CI relationships in the CMDB > CI relationship editor, topics "Create or edit a CI relationship", "Delete a CI relationship", "Legacy CI relationship builder" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CIRelationships.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Create or Delete a CI Relationship

**Goal:** add or remove a relationship between a CI and another CI, user or group with the relationship editor.
**Where:** a CI form > **Related Items** > **+** (Add CI relationship).
**Roles:** `sn_cmdb_editor`, `asset` or `itil` (plus `snc_platform_rest_api_access` to view relationships if the Table API ACL is active).

> From Brazil the relationship editor is being prepared for deprecation: hidden on new instances, still supported. Unified Map in CMDB Workspace is the current way. Background in [[CI Relationships]].

The CI the editor was opened from is the **base CI**. The relationship type chosen decides whether it becomes parent or child.

## Create, with suggested relationships

1. Tick **Use suggested relationship**.
2. Pick a type in **Suggested relationship type**. Types end in (Parent) or (Child); suggested ones are highlighted and marked. Narrow the list with **Hide CI relationship**, **Hide user relationship**, **Hide group relationship** (remembered in the user preferences `ci_manage_relationships_filter_hint.cmdb_ci`, `.sys_user`, `.sys_user_group`).
3. In **Configuration Items**, select one or more CIs (filter conditions > **Run filter**).
4. **+** in **Relationships** (or drag the CIs there).
5. **Save** or **Save and Exit**.

## Create, without suggested relationships

1. Clear **Use suggested relationship**.
2. Select the other CIs in **Configuration Items**.
3. **+** in **Downstream Relationships** (base CI is the parent) or **Upstream Relationships** (base CI is the child).
4. For each new row, **Please select a relationship** and choose the type.
5. **Save** or **Save and Exit**.

## Delete

1. Open the editor from the CI.
2. In **Relationships**, select the rows > **Delete selected relationships**.
3. **Save** or **Save and Exit**.

## Example

On the CI `Example App Server`, open the editor, tick **Use suggested relationship**, choose **Runs on (Parent)**, select `Example Linux Host` in the CI list, press **+**, **Save and Exit**. Related Items now shows *Example App Server Runs on Example Linux Host*.

## Gotchas

- **Deleting a relationship to a dependent CI can break its identification**: the dependent CI no longer points to what it depends on.
- The three Service Mapping endpoint types (Implement End Point, Use End Point, Applicative Flow) cannot be used between ordinary CIs.
- Save buttons light up only when a relationship is completely defined.
- The legacy builder (older browsers) works as a list collector: choose a type, move CIs between the available and linked boxes, **Save**. There, **Show all relationships** (role `sn_cmdb_admin` or `itil_admin`) offers every type, suggested or not.
