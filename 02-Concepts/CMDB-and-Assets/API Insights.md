---
type: concept
tags: [concept, cmdb, workspace, api, integrations, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "API Insights" (https://www.servicenow.com/docs/r/servicenow-platform/api-insights/api-insights.html and the pages under it), read through the docs site API 2026-10-09. Read in full: Explore, Configure, Administer and monitor, access requests, clustering, remediation, Reference. Only skimmed: the step lists for viewing, searching and comparing APIs, the API details page, application service relationships and the connection create / install screens
sn-release: Brazil
verified:
updated: 2026-10-09
---

# API Insights

**In one line:** a workspace (**Workspaces > API Insights**, app `sn_api_insights_ws`) that treats the organisation's APIs as CIs in the CMDB: an inventory fed by Service Graph Connectors and by the instance's own APIs, with ownership, business context, access requests and data-quality follow-up.

**Domain separation: not supported.**

## Who uses it

| User | Role | Does |
|---|---|---|
| Enterprise architect | `sn_api_insights_ws.api_mgmt_architect` (contains `task_editor`, `sn_incident_read`, `sn_vul.vulnerability_read`, `sn_cmdb_editor`, `sn_msi.msi_incident_read`) | search and compare APIs, follow the team's APIs, request and grant access, fix missing data |
| Enterprise architect administrator | `sn_api_insights_ws.api_mgmt_architect_admin` (contains the architect role) | settings: creation tool, relationship model, ownership group, workflows |
| CMDB administrator | `sn_cmdb_admin` | connectors and imports, clustering recommendations. Also needs `cmdb_inst_admin` (connections) and `ml_report_user` + `platform_ml_read` (clustering); security widgets need `sn_si.basic` or `evt_mgmt_user`, `sn_vul.vulnerability_read`, `sn_msi.msi_incident_read`, `sn_si.read` |

Install (role `admin`): **System Applications > All Available Applications > All** > API Insights. It brings MetricBase (`com.snc.clotho`) and the Store apps [[CMDB CI Class Models App|CMDB CI Class Models]] (`sn_cmdb_ci_class`), [[CMDB Workspace]] (`sn_cmdb_ws`), SGC Central (`sn_sgc_central`), Node map component, Timeline component, UX Commons, list selector. Set the application scope to API Insights before assigning its roles.

## Where the API data comes from

- **Service Graph Connectors** for API platforms: connection status, processing status and ongoing executions on the Overview tab, same cards as SGC Central ([[CMDB Workspace Insights and SGC Central]]). **Create connection** and **Explore connectors** from there.
- **The instance's own APIs** (Settings > **Import instance APIs** > **Configure API import**): scripted and outbound REST, scripted and outbound SOAP. Options: **All custom APIs**, **ServiceNow APIs** (pick from a list), **Active in last** N days (scripted only). The scheduled job **Import ServiceNow API to API Insights** does the import.
- **API specifications**, validated by rules (below).

## Settings

Settings tab. CMDB admins turn on **All settings** to see the architect settings too.

| Setting | Options |
|---|---|
| Data model recommendations (`sn_cmdb_admin`) | **Proposed API clustering** on or off; **Cluster quality** 0 to 100 |
| API creation tool | None; Digital Integration Management (creates a digital interface record); External tool with a URL |
| API-to-business application relationship model | **CSDM** (API > application service > business application) or **Digital Integration Management** (API > digital interface > business context) |
| Ownership group | which CI group field counts as owner: **Managed by Group**, Change Group, Approval Group or Support Group. Job *SyncOwnershipGroupsOfAPIVersions* copies it to the next API version |
| Configure workflows | the flow run for an API action such as an access request |

## Overview tab

- CMDB admin: connection status, clustering recommendations, APIs by discovery source, life cycle (Operational, Deploy, End of Life), type (REST, GraphQL, SOAP), environment, ownership group, business application, and **APIs missing data**. Bar colours: red when more than 50% of APIs lack the attribute, yellow 10 to 50%, green under 10%.
- Architect: search, access requests received and sent, missing-data counts, the team's APIs by stage.

## Missing data and how it is fixed

| Missing | Fix | Stored as |
|---|---|---|
| Business context | **Create relationships** to an application service or business application | a relationship record in the CMDB |
| Ownership group | **Create reference** | a reference on the API CI |
| Product model | **Create reference** | reference |
| Design (shown only with Digital Integration Management, `sn_apm_di`) | **Create reference** to the digital interface | reference |

Overview > select the category (number for architects, bar for CMDB admins) > tick the APIs > the action > **Create**.

### Tag-based relationship mapping

For many APIs, rules create the relationships from tags. Table **Tag Based Relationship Mapping** (`sn_api_insights_ws_tag_relationship_mapping`, open with `.list`; role `sn_cmdb_admin` or the architect role).

| Field | Notes |
|---|---|
| Source Class | API, API Component, API Frontend, API Backend or Managed API |
| Target Class | Application Service or Business Application |
| Relationship Type | |
| Tag Key | key in Key Value (`cmdb_key_value`) |
| Target Match Field | field on the target CI that must equal the tag value |
| Parent Class Role | whether source or target is the parent |
| Active | |

The scheduled job **Tag based relationship mapping** applies active rules and skips relationships that already exist. **Inactive by default**: an admin must activate and schedule it.

## API clustering recommendations

Machine learning groups API components that are not linked to any API. Overview > the count under **API clustering recommendations** > **Proposed API clustering** (cluster concept, size, quality 0 to 100, updated). Open a concept > tick components > **Accept** > link to an **Existing API record** or **Create API record** (name, version, base URL; created through IRE) > **Submit**.

## Access requests

- Request (architect role): search > **APIs** tab > tick **one** API > **Request access**: **Access type** (API Key, Application, Basic Auth, Developer, OAuth 2.0, Other), **Access duration in days**, justification. Needs an ownership group and a workflow configured first.
- Owner side: Overview > **Access requests received** > **Grant access** or **Reject request**. Sender side: **Send reminder** or **Withdraw request**.
- The *View requests* link in the reminder email works only for a holder of an architect role who is in the group that received the email.
- Flows shipped (Workflow Studio subflows): **API Request Reminder** and **API Grant/Reject Access Template**. A custom flow must take the inputs `request` (reference to **API Requests Access Task**, `sn_api_insights_ws_request_access_task`; required), `grant` (string; required) and `description` (string; optional). See [[Flows, Subflows and Actions Overview and Architecture]].

## API specification validation

- **API Specification** (`sn_api_insights_ws_api_specification`): Name, Version, Type (for example `openapi3.0.0`), Specification (the document), **State** (Unprocessed, Valid, Invalid), Message.
- **Specification Validation Rule** (`sn_api_insights_ws_spec_validation_rule`; edit with `sn_cmdb_editor`, read with `cmdb_read`): Specification, Version (comma-separated; empty = all), **Type** (*Path* = keys must be present; *Expected value* = one key must hold one of the values), Key, Value, **Severity** (warning keeps the specification valid; error makes it invalid), Message, Active.
- Scheduled job **API Specification Validation** runs the active rules over unprocessed specifications.
- Shipped OpenAPI rules: tags must have a `name` (warning); `info`, `paths` and `components` must exist (error); a `servers` section must exist (error).

## Scheduled jobs and tables

Jobs: Gather APIs without Business App relationship; Import ServiceNow API to API Insights; Import ServiceNow API usage to MetricBase; SyncOwnershipGroupsOfAPIVersions; API Specification Validation; Tag based relationship mapping.

Other tables: `sn_api_insights_ws_apis_missing_relationships`, `sn_api_insights_ws_importable_servicenow_api`, `sn_api_insights_ws_openapi_specifications`, `sn_api_insights_ws_push_api_spec`, `sn_api_insights_ws_api_metric_config` (maps each discovery source to MetricBase metrics: usage, error rate, latency, cache hit).

## Properties

| Property | Default | Effect |
|---|---|---|
| `sn_api_insights_ws.import_scripted_rest_api` | `{"custom_api":false,"servicenow_api":true,"active_in_last":false,"active_in_last_number_of_days":90}` | import of scripted REST APIs |
| `sn_api_insights_ws.import_scripted_soap_api` | all false, 90 days | scripted SOAP |
| `sn_api_insights_ws.import_outbound_rest_api`, `...import_outbound_soap_api` | `{"custom_api":false,"servicenow_api":false}` | outbound REST and SOAP |
| `sn_api_insights_ws.ml_min_cluster_quality` | 80 | minimum cluster quality shown |
| `sn_api_insights_ws.show_ml_clustering_recs` | true | clustering recommendations on |
| `sn_api_insights_ws.search_api_limit` | 1000 | search result limit |
| `sn_api_insights_ws.settings_api_to_business_app_service` | CSDM | relationship model |
| `sn_api_insights_ws.settings_grant_access_workflow` | API Grant/Reject Access Template | flow run on an access request (sys_id) |
| `sn_api_insights_ws.settings_preferred_tool`, `...settings_preferred_tool_url` | Authoring tool, `http://www.postman.com` | creation tool |
| `sn_api_insights_ws.settings_support_group_column` | `managed_by_group` | the `cmdb_ci` column used as owner group |
| `sn_api_insights_ws.show_overview_metrics_widgets` | false | MetricBase widgets on API overview pages |

## Related

- [[CI Relationships]] · [[Integration Options and Interfaces Overview]]
