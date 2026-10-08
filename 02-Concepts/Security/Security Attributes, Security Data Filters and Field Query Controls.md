---
type: concept
tags: [concept, access-control, security, roles, api, glide-api, schema, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management (read in full 2026-10-08 through the docs site) - Security Attributes (fundamentals, create, base system attributes, compound attributes, local and existing types; 168 lines), Security data filters (overview, create, default enforcement; 144 lines), Field Query Roles and Restrictions (62 lines), Machine identity access controls (53 lines). https://www.servicenow.com/docs/r/platform-security/security-attributes-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Security Attributes, Security Data Filters and Field Query Controls

**In one line:** the access mechanisms that sit beside ACLs: **security attributes** (reusable true/false facts about the user or session), **security data filters** (conditions added to the database query itself so hidden rows never leave the database), dictionary attributes that stop querying on a sensitive column, and **machine identity access controls** that pin an integration user to named APIs and tables.

From the Brazil docs. ACLs: [[Access Control Lists (ACLs)]].

## Security attributes

**System Security > Security Attributes** (`security_admin`). Used as the *Security Attribute Condition* of an ACL and in security data filters.

| Field | Meaning |
|---|---|
| **Label**, **Name**, **Description**, **Application** | |
| **Type** | `string`, `integer`, `boolean`, `list`, or `compound` (a combination of other attributes: a **Condition** plus **New Criteria** for OR sets) |
| **Is dynamic** | re-evaluate on every transaction |
| **Lookup Table**, **Lookup Table Column** | take the value from a table, for example Role (`sys_user_role`), column `name` |
| **Script** | compute the value |

Base system attributes:

| Attribute | True when |
|---|---|
| `Role`, `RoleExplicit` | the user has a given role; has it assigned directly, not inherited |
| `Group`, `GroupExplicit` | the same for group membership |
| `HasAdminRole` | the user is an admin |
| `LoggedIn` | authenticated |
| `Impersonating` | the session is an impersonation |
| `InteractiveSession` | interactive session |
| `NetworkCriteria` | network conditions |
| `SessionIsEmbeddedGuest` | a Web Embeddables guest session |
| `IsIframeEmbeddedSession`, `IsIntegrationAsAServiceSession`, `IsIntegrationAsAUserSession`, *Is Servicenow Web Session*, *Is Mobile App Session* | client-session kinds (plugin `com.glide.client_session_security_attributes`); the first three are meant only for the client type of OAuth and SSO records |

**Local or existing:** a *local* condition lives inside one ACL or filter (the default; quick, but copied logic drifts). An *existing* one references a named attribute record shared by many (one definition, visible in Access Analyzer; changes affect everything using it). Rule of thumb from the docs: if it deserves a name in a design document (for example "user is an AI agent", "user has clearance"), make it a record.

## Security data filters

**System Security > Security Data Filters** (admin).

| Field | Meaning |
|---|---|
| **Table name** | the table filtered |
| **Filter** | the condition added to queries |
| **Security Attributes** | when the filter applies |
| **Mode** | ? (not explained) |
| **Show in UI** | show a notice when the filter affected a query |
| **Active** | keep inactive until tested: a wrong filter locks users out of records |

How they behave:

- Added to the SQL query: all filters on a table are combined with **AND**, together with the user's own query. Query `state != closed` with filters `active=true` and `priority=1` becomes all three.
- Because the rows are never fetched, there is no "rows removed by security" message and nothing leaks through reports or counts. A conditional ACL, by contrast, filters after the query.
- **Read only.** Not consulted by `canRead()`. Not a replacement for ACLs or for visibility rules: pair a filter with a Deny Unless ACL.
- **Child and parent:** a filter on a child table is not applied when the parent table is queried. Add a filter on the parent too (commonly one hiding the child's records there).
- Scope follows the scope of the table.
- Avoid many conditions and conditions on unindexed columns.

Where they are enforced by default: lists and forms (Core UI, workspaces, catalog, portal, mobile), reports and dashboards, exports (XML, CSV, Excel, JSON, PDF), Flow *Look Up Record(s)* steps, AI Search and text search, REST Table and Stats APIs and their GraphQL equivalents, and in script only `GlideRecordSecure`, `GlideRecordSandbox` and `GlideAggregateSandbox`.

**A plain server-side `GlideRecord` ignores them** unless the script calls `enableSecurityFeature` (and `disableSecurityFeature` to turn one off); the docs give no signature (?). Do it for any user-facing query that is not a `GlideRecordSecure`.

## Field query attributes (dictionary)

On a column's dictionary entry, *Attributes* tab (admin):

| Attribute | Value | Effect |
|---|---|---|
| **Field Query Roles** | roles | only those roles may **query** on the column; others are denied the operation |
| **Field Query Restrict Record Access** | true | a query on the column returns, to a user who cannot view the field, only how many rows matched and nothing else |

Related: query ACLs (`query_match`, `query_range`) in [[Access Control Lists (ACLs)]]; attribute names as stored are not given ([[Dictionary Attributes Reference]]).

## Machine identity access controls

**System Security > Machine Identity Access Controls** (admin). For users flagged **Web service access only** ([[Non-Interactive Users]]).

Fields: **Name**, **Active**, **REST API Policy**, **SOAP API Policy**, **Tables**, **Applies to Child Table**, and the list of users.

**Effect is exclusive:** a user under such a control can call only the listed APIs and tables, whatever roles they hold.

## Related

- [[Access Control Lists (ACLs)]] · [[Explicit Roles and Elevated Privilege Roles]] · [[Access Analyzer, Access Findings and Access Observer]] · [[Non-Interactive Users]] · [[Business Rules]]
