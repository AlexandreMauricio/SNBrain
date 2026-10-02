---
type: concept
tags: [concept, instance-admin, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "ServiceNow plugins" and "Find components installed with an application" (pp. 15-20), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Plugins

**In one line:** a plugin is a ServiceNow-provided package that adds features to the platform or to an application; you activate it once and **cannot deactivate it**.

## Plugin or application

- **Plugin**: extends the platform or installed applications. All come from ServiceNow. Identified by an id such as `com.glide.email_client`.
- **Application**: a standalone set of features, from the Store or built by you.

## Activating

- Some are active by default. Others: **Admin > Application Manager** (or **System Applications > All Available Applications > All**), find it, install. Role admin.
- Dependencies are shown first and activated with it.
- The button is greyed out when: a **subscription** is required and not bought; it needs **ServiceNow personnel** to activate (use **Request Plugin**, which opens the Activate Plugin form on Now Support; activations run in two daily batches, US Pacific business days); or it is already active.
- Paid plugins can be tried on a **non-production** instance without buying; production needs the request.
- On a **personal developer instance** most plugins can be activated freely (from the instance or from the developer site's *Manage my instance*).

## After activation

- **No deactivation.** If it is unwanted, hide it with roles and ACLs. Some plugins support a rollback context ([[Rollback and Delete Recovery]]).
- So: activate in sub-production first and test.
- A warning during activation about a failed create/alter table needs support.

## What did a plugin install?

1. `sys_metadata.list` in the navigator (Application Files).
2. Add the **Package** column, filter **Package** is `<plugin name>`.
3. Group by **Class** to see tables, roles, business rules, scheduled jobs and so on.

## Example

Before using inbound email redaction, check **Package** is *Email Inbound Redaction* in `sys_metadata` on a sub-production instance to see what it added.

## Related

- [[Admin Center, Store and Application Manager]] · [[System Properties]]
