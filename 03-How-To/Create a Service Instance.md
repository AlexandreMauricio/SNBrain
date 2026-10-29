---
type: how-to
tags: [how-to, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Service instances > Create a Service instance, top-down discovery, Dynamic CI Group, Tags, Manual, Dynamic Service, Modify required attributes and relationships (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/create-it-services.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Create a Service Instance

**Goal:** create a service instance (application service) with the Application Service wizard, relate it to CSDM objects, and choose how it fills with CIs.
**Prerequisites:** `app_service_admin` for Dynamic CI Group, Manual and Dynamic Service; `sm_admin` for Top-Down Discovery and Tags (both need Service Mapping). The entry point CI exists (manual), or the CMDB group exists (dynamic CI group), or tags are discovered (`cmdb_key_value`).
**Navigation:** **All > CSDM > Manage Technology Management Services > Service Instance** > **New**.

Types and tables: [[Service Instances (Application Services)]].

## Steps

1. Optional, once: **All > CSDM > Service Instance Settings** (role `sn_cmdb_admin` or `itil_admin`) to choose **Required attributes** (default Name and Number) and **Required relationships** (none by default; Business Application, Technical Service Offering, Business Service Offering can be added).
2. **Provide Basic Details**: Name (unique across service types), Environment, Version, Model ID, Operational Status, Support Group, Change Group, Managed By Group, Owned By (a user with `sm_app_owner`, or `sm_admin`).
3. **Set Relationships**: tabs Business Application, Technical Service Offering (`service_offering` with classification Technical Service), Business Service Offering (classification Business Service), **Parent Application Service** (builds hierarchies: platform host and apps, micro services, shared technical dependencies). **Next**.
4. **Populate the Application Service** > **Choose a Method** (or **Next** to leave it empty):
   - **Top Down Discovery**: Application Type (CI class of the entry point) and its entry point attributes.
   - **Dynamic CI Group**: **Group Name** = the CMDB group. Service-class CIs are filtered out.
   - **Tags**: **Use a list of tags** (up to three key/value pairs, **Preview Result**) or **Use a candidate from a tag-based service family** (family, then service candidate).
   - **Manual**: **Class** and **CI** of the entry point; add other CIs later from the map.
   - **Dynamic Service**: **Levels** of related CIs to include.
   - **Add Method** to combine Top Down Discovery with Manual (other methods cannot be combined).
5. **Preview the Service**: check relationships and methods (**Edit Relationships**, **Edit Methods**) > **Done**.
6. Afterwards: **View Map** (tags, top-down, manual), or **View CMDB Group CI's** / **View Service CI's** (dynamic CI group; they differ only beyond 10,000 CIs). **Advanced** > Additional Info, Questionnaire, Reject Messages, Worknotes.

## Result / how to check it worked

The service appears in **CSDM > Manage Technology Management Services > Application Service** and **Configuration > Application Services > Application Services** (all `cmdb_ci_service_auto` classes except alert groups); top-down and empty ones also in **Service Mapping > Services > Service Instances**. The [[Service Instances (Application Services)|service instance dashboard]] no longer counts it under *Population method not defined*.

## Example

Service instance *Example Payroll - Prod*, Environment Production, Owned by *Test User*, Support Group *Example App Support*; relationships: business application *Example Payroll*, business service offering *Example Payroll - Standard*. Method Dynamic CI Group with CMDB group *Example Payroll Prod Servers*. Check **View Service CI's** lists the servers.

## Tables / fields involved

- `cmdb_ci_service_auto` and children (`cmdb_ci_service_discovered`, `cmdb_ci_query_based_service`, `cmdb_ci_service_by_tags`, `cmdb_ci_service_calculated`), `service_offering`, `cmdb_ci_business_app`, `cmdb_group`, `cmdb_key_value`.

## Gotchas

- Searching for an entry point CI with a leading wildcard (`*name`) can be slow; be specific.
- A CMDB group can populate only one service instance.
- Docs also show the REST API `createOrUpdateService` as an alternative ([[Application Services Components and Properties Reference]]).
