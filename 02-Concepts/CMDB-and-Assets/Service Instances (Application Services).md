---
type: concept
tags: [concept, cmdb, discovery, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Configuration Management > Service instances (Application services) (22 topics, 1,887 cleaned lines, read in full through the docs site API 2026-10-29) - overview, create, the five population methods, dashboard, required attributes, conversions, manually add CIs, update from CMDB, link, group, access, maps, change history, compare, APIs, components installed. https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/application-services.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Instances (Application Services)

**In one line:** a service instance (the CSDM 5 name; the docs still mix it with **application service**) is a CI that stands for one deployed application stack — the hosts, applications and connections that together deliver a service — held in a class under **Service Instance** (`cmdb_ci_service_auto`) and filled with member CIs by one of five methods.

From the Brazil docs; not tested. Place in the data model: [[CSDM Overview and Data Domains]]. Steps: [[Create a Service Instance]], [[Convert Business or Manual Services to Application Services]], [[Edit Manual Application Services - Add CIs, Update from CMDB, Link]], [[Control Access to Application Services with Service Groups]]. Properties and tables: [[Application Services Components and Properties Reference]].

## Entry point

The top CI of a service instance: where clients reach it — a URL, an IP address and port, or a cloud resource (AWS gateway, S3 bucket, Lambda, Azure function). A service instance may be created **empty** (no entry point yet) during planning.

## Types, tables and how they fill

| Type | Table (label) | Filled by | Notes |
|---|---|---|---|
| **Discovered** (top-down) | `cmdb_ci_service_discovered` (Mapped Application Service) | Service Mapping patterns from the entry point, following connections | needs Service Mapping, credentials; VMs must be fully discovered |
| **Tag-based** | `cmdb_ci_service_by_tags` (Tag-based Application Service) | CIs whose discovered tags (key-value, up to **three** pairs, not case-sensitive) match, plus CIs related to them | needs Service Mapping; no credentials; maps containers and partly discovered VMs; does not map connections between members |
| **Dynamic CI Group** | `cmdb_ci_query_based_service` (Dynamic CI Group) | members of one [[CMDB Groups|CMDB group]], kept in sync | **no map**, list only; max **10,000** CIs; one CMDB group per service; service classes filtered out |
| **Created manually** | `cmdb_ci_service_discovered` | an entry point CI, then CIs added by hand | best only for CIs that cannot be discovered; does not follow relationship changes |
| **Dynamic** | `cmdb_ci_service_calculated` (Calculated Application Service(s)) | CIs reachable through `cmdb_rel_ci` relationships, to a set number of **Levels** | updates itself; cannot add or remove CIs directly; starts empty unless converted |

All have **Service classification** = Application Service, except a dynamic CI group created from the legacy Event Management or Service Mapping UI, which is classified **Technical Service**. Services created through the API are the manual type in `cmdb_ci_service_discovered`.

**Combining methods:** only **top-down + manual** may be combined on one service instance. Choosing Dynamic CI Group, Tags or Dynamic Service locks the method list.

Other ways in: APM maps from Dynatrace or AppDynamics (Store integrations; check for duplicate CIs first), service candidates from a **CSV file** (Service Mapping), the `createOrUpdateService` REST API, conversion of legacy services.

**Choosing:** prefer top-down discovery, add tags for cloud and containers, use Dynamic CI Group for things like Active Directory or Exchange where you only have a list, manual only when nothing else works (e.g. intrusion prevention devices).

## Members that are never allowed

NAT (`cmdb_ci_translation_rule`), Endpoint (`cmdb_ci_endpoint`), Qualifier (`cmdb_ci_qualifier`), Application cluster (`cmdb_ci_application_cluster`) are excluded through **Manual CI Inclusions/Exclusions** (`svc_manual_ci_exclusions_inclusions`), which applies to manual adds, conversions, API population and update-from-CMDB, not to traversal rules. A class inherits the setting of its closest ancestor unless it has its own. Replaces the deprecated property `sa.mapping.user.manual.citype.blacklist`.

## Alert impact on a dynamic CI group

Computed on the CMDB group members, their children by **Runs on::Runs**, and CIs related to either by **Virtualized by::Virtualizes**.

## Roles

| Role | Can |
|---|---|
| `app_service_user` | view maps of operational service instances, `getContent` API; contained in `itil` |
| `app_service_admin` | create and modify service instances (Dynamic CI Group, Manual, Dynamic Service methods), service groups, edit maps; contains `itil` |
| `sm_admin` | Top-Down Discovery and Tags methods (as printed; elsewhere the Service Mapping admin role is `service_mapping_admin`: unconfirmed whether these are the same) |
| `service_mapping_admin` / `service_mapping_user` | administer / view in Service Mapping |
| `sm_app_owner` | service owner SME who reviews and approves the mapped service |
| `sn_cmdb_editor`, `itil` | "only can view all service instances" |
| `evt_mgmt_admin`, `evt_mgmt_operator`, `evt_mgmt_user`, `evt_mgmt_integration` | Event Management roles listed alongside |

## Service groups and access

Service groups (**Configuration > Application Services > Service Groups**) group service instances logically (one service can be in many; groups can nest; access to a parent gives access to children). Every new service is in the **All** group, visible to everyone. Giving a role to a group (**Service Group Responsibilities**) restricts that group's services to users with the role. Never assign roles to **All**. Event Management can track health and notify on group severity (the highest alert severity in the group).

## Maps

Opened from the service instance with **View Map**. View mode (`app_service_user`), Edit mode (`app_service_admin`), task indicators need `itil`. Features: Properties pane and **Detailed Properties**, CI grouping (10 or more of a type), spanning tree view, map indicators (alerts, outages, incidents, problems), export to PDF, merged connection lines (manual connections show **Endpoint Type** = Manual Endpoint). Classic Service Mapping adds the **history timeline** (light grey = unapproved change without behaviour impact, dark grey = unapproved with impact, green = approved when change validation is on ([[Proposed Changes to CIs]]), double = several changes), **baselines**, and **Compare** of two points in time, including tracked configuration file versions.

## Dashboard

**All > CSDM > Service instance dashboard**, or CMDB Workspace Insights > Application services, or Service Graph Workspace Insights > Service instances (roles `sn_cmdb_admin`, `itil_admin` or `app_service_admin`; refreshed nightly). Counts `cmdb_ci_service_auto` records with classification Application Service. Overview tab: total, population method defined / not defined, types chart (including Empty and converted), missing data (no service offering, no owner...). Coverage tab: application servers, databases and hardware servers in no service instance, capped by `glide.cmdb.csdm.app_service.max_results` (100,000). Filters by Owned by, Support group, Change group (do not change the "missing" counts). Called the Application Services dashboard before Australia.

## Domain separation

A new service gets the creator's domain; manual adds only offer CIs of the service's domain (same child domain in a hierarchy); `createOrUpdateService` stops if a CI is in another domain; conversion keeps the business service's domain and only takes its CIs.

## Variants and open points (unconfirmed)

- Tag-based table: this chapter consistently writes `cmdb_ci_service_by_tags`; the CSDM chapter also has `cmdb_ci_service_tags`.
- Dynamic service table label: *Calculated Application Service* and *Calculated Application Services*.
- Menu paths: **CSDM > Manage Technology Management Services > Service Instance** and **... > Application Service** both appear; **Configuration > Application Services > Application Services**; **Service Mapping > Services > Service Instances**; **Service Mapping > Application Services**; **Configuration > Service Instances > Service Instances**. Which exist depends on release and plugins.
- Legacy manual services: up to **three** levels added by default when converting to dynamic; for business services the levels are chosen (max **eight**).

## Related

- [[CSDM Overview and Data Domains]] · [[cmdb_ci_service]] · [[CMDB Groups]] · [[CI Relationships]] · [[Unified Map]] · [[Service Offerings, Commitments and Availability]]
