---
type: how-to
tags: [how-to, cmdb, roles, access-control]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Service instances > Group application services, Control user access to application services (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/control-user-access-to-business-services.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Control Access to Application Services with Service Groups

**Goal:** group service instances and restrict who can see and manage a group by giving it a role.
**Prerequisites:** `app_service_admin` or `service_mapping_admin`; the role to grant exists and is assigned to the right users or groups ([[Users, Groups and Roles Overview]]).
**Navigation:** **All > Configuration > Application Services > Service Groups** and **> Service Group Responsibilities** (also under Service Mapping > Services or Event Management > Services when those are active).

## Steps

1. **Service Groups** > **New** > **Name**, optional **Parent Group** (nesting) > save from the header menu.
2. **Service Group Members** > **New** > the service instance (or an Event Management alert group) > **Submit**. Or from a service instance form: **Service Group Members** > insert a row with the group > **Update**.
3. **Service Group Responsibilities** > **New** > **Application Service Group** and **Role** > **Submit**.

## Result / how to check it worked

Only users with that role see the group's services (plus everything still in **All**). Access to a parent group gives access to all child groups. Test by impersonating a user with and without the role.

## Example

Group *Example Finance Services* holding *Example Payroll - Prod* and *Example Ledger - Prod*. Create role `x_example_finance_svc_admin` containing `app_service_admin`, add it to *Example Finance Admins*, and add a responsibility linking the group and the role. Impersonate *Test User* (not in the group) and confirm the services are hidden.

## Tables / fields involved

- `sa_service_group_member`, `sa_service_group_responsibilities`, `cmdb_ci_service_auto`.

## Gotchas

- New services start in **All**, visible to everyone; never give roles to **All** itself.
- A service can be in many groups; membership is purely logical.
- Event Management can notify on group severity (highest alert severity in the group).
