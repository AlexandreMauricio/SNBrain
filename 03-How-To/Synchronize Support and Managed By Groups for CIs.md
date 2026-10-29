---
type: how-to
tags: [how-to, cmdb, users, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CSDM > Implement > Dynamic CI group and service type, Synchronizing group assignment attributes, Set the group for a CI or an entire class of CIs, Synchronize user groups for a technology management offering (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/common-service-data-model-csdm/csdm-enable-tso.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Synchronize Support and Managed By Groups for CIs

**Goal:** fill **Support group**, **Change group** and **Managed by group** on many CIs at once instead of by hand, either per CI class or through a technology management offering.
**Prerequisites:** roles `itil` and `itil_admin` (as printed in the docs); the groups exist in `sys_user_group`.
**Navigation:** **All > Configuration > CI Class Manager** (method A); **All > Configuration > CMDB Groups**, **Dynamic CI Groups**, **All > CSDM > Technical Service Offering** (method B).

Column names are not printed in this chapter; the labels are. *Change group* was previously labelled *Assignment group*. **Managed by group** means the group responsible for the CI data being complete and correct, not necessarily the group that repairs it.

## Steps

**Method A: one class, through CI Class Manager**

1. **CI Class Manager** > **Hierarchy** > pick the class > **Basic Info**.
2. Set **Managed by Group** > **Save**.
3. **CI List** to check. Applies only to CIs of that class (**not subclasses**) that are **not** under a technology management offering.

**Method B: everything an offering covers**

1. Create a [[CMDB Groups|CMDB group]] whose queries select the CIs.
2. **Dynamic CI Groups** > create a dynamic CI group pointing at that CMDB group.
3. **CSDM > Technical Service Offering** > create the technology management offering.
4. **CI Relationships** > **New**: Parent = the offering, Child = the dynamic CI group > **Submit**.
5. Open the offering, fill **Support group**, **Change group**, **Managed by group**, and **Save** from the header context menu. A message confirms synchronisation is enabled.
6. Values flow offering → dynamic CI group → every member CI.

## Result / how to check it worked

Member CIs show the offering's groups. New CIs are picked up by the scheduled job **CSDM Data Synchronization**; to run it now, **Scheduled Jobs > CSDM Data Sync > Execute** (two names for the job in the docs, unconfirmed which is the record name).

## Example

Group *Example Linux Servers* (CMDB group: class Linux Server, location *Example City*), dynamic CI group *DCG Example Linux*, offering *Example Hosting - Production*, related as parent/child. Set Support group *Example Server Support*, Change group *Example CAB Group*, Managed by group *Example CMDB Stewards*, save, then open a member CI to check the three fields.

## Tables / fields involved

- `cmdb_ci_query_based_service` (dynamic CI group), `cmdb_group` (CMDB group), `service_offering`, [[cmdb_rel_ci]], [[cmdb_ci]].

## Precedence

Offering wins over CI Class Manager: for CIs under an offering, Managed by group is synced from the dynamic CI group and **overwrites** the class value. A CI should be under only one technology management service or offering.

## Gotchas

- Filling Managed by group helps CMDB Data Manager approvals: without it, policy approvals go to the administrator ([[CMDB Data Manager]]).
- A dynamic CI group under a technology management service can hold up to 10,000 CIs ([[CMDB Groups]] limit `glide.cmdb.group.max_ci_limit`).
- The docs' Linux example sets the field to "sys_user_group", meaning a group record; pick a real group.
