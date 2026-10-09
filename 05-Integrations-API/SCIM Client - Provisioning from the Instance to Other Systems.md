---
type: concept
tags: [concept, integrations, api, users, scripting, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Identity (chapter read in full 2026-10-08) - SCIM Client, Exploring SCIM Client, Activate the SCIM Client plugin, SCIM Client properties, tables, scriptable APIs, and logs, Create a REST message, Create a SCIM Provider, Create a SCIM Provider Resource Mapping, Create a SCIM attribute mapping, Attribute Mapping references, SCIM Client troubleshooting. The SCIM2Client API reference is in the API documentation and was not read. https://www.servicenow.com/docs/r/platform-security/identity/scim-client-app.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# SCIM Client - Provisioning from the Instance to Other Systems

**In one line:** as a SCIM *client* the instance calls another system's SCIM endpoints to create, update and delete users and groups there, so that an onboarding flow in ServiceNow can provision accounts in other applications or in another ServiceNow instance.

From the Brazil docs. The opposite direction: [[SCIM Provider - Provisioning Users and Groups into the Instance]]. Naming trap: inside the client, a **SCIM Provider** record is the *remote* system being called.

Plugin **SCIM v2 - ServiceNow Cross-domain Identity Management Client** (`com.snc.integration.scim2.client`). Configuration role `scim_client_config_admin`.

## Four records

| # | Record | Where | Content |
|---|---|---|---|
| 1 | **REST message** | **System Web Services > Outbound > REST Message** | **Endpoint** = the remote SCIM base URL; authentication; header `Content-type: application/scim+json`; **all five** HTTP methods, with `${resourceName}` and `${resourceId}` variables in the URLs. A sample ships with the base system |
| 2 | **SCIM Provider** (`sys_scim_provider`) | **SCIM Client > SCIM Provider** | **Name**, **Outbound REST Message**, **HTTP Method for Update** (PATCH or PUT). **Resource Definition** and **Schema Field Definition** are fetched from the remote `/ResourceTypes` and `/Schemas`; **Refresh** then **Update** after the remote schema changes |
| 3 | **Resource mapping** (`sys_scim_provider_resource_mapping`) | **SCIM Client > SCIM Provider Resource Mapping** | **Provider**, **Resource Name** (User, Group), **Primary Table** (the table holding the record's sys_id). User and Group samples ship |
| 4 | **Attribute mappings** (`sys_scim_attribute_mapping`) | related list on the resource mapping | one per SCIM attribute, below |

### Attribute mapping

| Field | Notes |
|---|---|
| **Schema Name**, **Attribute**, **Sub-Attribute** | for `name.familyName`: attribute `name`, sub-attribute `familyName` |
| **Field Type**, **Multi-Value**, **Filter Condition** | from the remote schema; a filter picks one of a multi-valued attribute, for example `type eq "work"` |
| **Unique** | the attribute that identifies the same resource on both sides (for users typically `userName`); not for multi-valued attributes |
| **Database Table Name**, **Database Field Name** | *direct* mapping; dot-walking allowed (the user's department name) |
| **Default Value** | sent when the direct mapping is empty, or as a *constant* (then table and field are None) |
| **Run Script**, **Script** | *script* mapping; required for multi-valued attributes without a filter (a group's `members`). **Must return a string**, or JSON converted to a string, in the shape the remote system expects |

The `password` attribute is not supported.

## Triggering provisioning

The scriptable **SCIM2Client** API (server side) performs the calls. It is meant to run in the **system context** or as an administrator: background scripts, scheduled jobs, flow script steps running as system, business rules and script includes. Triggered by an ordinary user it works only if that user may obtain the REST message's token and read the mapped tables. Method signatures are not in this guide (?).

## Logs and properties

**SCIM > SCIM Client Logs** (`sys_scim_client_logs`): **Request ID**, **SCIM Provider**, **Resource**, **Resource ID**, **Action**, **Status**, **Message**.

| Property (**SCIM > SCIM Client Properties**) | Default | Meaning |
|---|---|---|
| `com.snc.integration.scim2.client.log.request.status` | ALL | ALL or FAILURE |
| `com.snc.integration.scim2.client.log.cleanup.duration` | 180 | days logs are kept |

## Troubleshooting

| Message | Cause and fix |
|---|---|
| "Unable to access the table ... Please cross check the Access control rules" | the API ran as a user without access to a mapped table: run it in the system context |
| "User Not Authenticated" | token not generated through the provider's REST message, or invalid; or not in the system context |
| "Cannot cast java.lang.Integer to java.lang.String" | a mapping script returned a number: always return a string |
| 400 `invalidValue`, "Manager id ... doesn't exist" | attributes expecting an id need the id **in the remote system**, not the local sys_id |
| request body cut off in the outbound log | raise `glide.outbound_http.content.max_limit`; see outbound web services logging |

## Related

- [[SCIM Provider - Provisioning Users and Groups into the Instance]] · [[Connections, Credentials and Aliases]] · [[OAuth 2.0 Outbound - The Instance as OAuth Client]]
