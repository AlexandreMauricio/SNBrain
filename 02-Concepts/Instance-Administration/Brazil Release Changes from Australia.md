---
type: reference
tags: [reference, release-specific, sn-release, security, roles, instance-admin]
status: documented
source: ServiceNow Brazil Release Notes (map 97F4kxpjkdv178Iq1OQ9sQ, 292 topics), read 2026-10-30. Read - release landing, ServiceNow AI Platform administration, capabilities, security (to Encryption), IT Service Management, Upgrade information, Deprecation summary (filtered), Browser summary start. Not read - other product sections, plugin lists, fixed issue lists, Zurich and Yokohama cross-family pages, remaining security sections, Prepare your upgrade detail. https://www.servicenow.com/docs/r/release-notes/rn-learn-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Brazil Release Changes from Australia

**In one line:** what the Brazil release notes say changed for platform, security and ITSM work: check here before trusting an Australia-era note or planning an upgrade.

From the release notes; not tested. Dates on the page: early availability September 24, 2026, general availability Q4 2026. Many changes apply to **new (zBoot) instances only**, so an upgraded instance can behave differently from a new one. **Never assume a change is in your instance** without checking its version and how it was built.

## Check before upgrading

| Change | Effect | Applies to |
|---|---|---|
| ITSM Enhanced Security Features (`com.snc.itsm.enhanced_security`) now activates automatically | new ACLs; to revert, ask Support for the ACL list | upgrades |
| Catalog roles removed from request management ACLs | a user with only a catalog role may lose `sc_request`, `sc_req_item` access through these ACLs | all, per the notes |
| Enhanced read-only field protection: `read_only_option`, values `strict_read_only`, `client_script_modifiable` | see KB2718122 for affected fields | all, per the notes |
| `glide.security.acl_with_invalid_roles_strict_deny` | an ACL whose roles **all** do not exist now denies; find them in **All > Access Management > Access Findings** | on by default if new; turn on if upgraded |
| Edge Encryption needs Java 21; scheduled upgrade needs Zurich Patch 13 or Australia Patch 6 or later | | Edge Encryption users |
| `sn_change_write` replaced by `sn_change_read` for `insights_admin`, `insights_owner` | | Cloud Cost Management section |
| Customised or deleted ACL roles should be reviewed | stated for Hardware Asset Management and Cloud Cost Management | upgrades |
| After upgrade, update Workflow Studio from the Store | stated for Playbooks | upgrades |

Upgrade and update also complete much faster: the notes warn not to read that as failure. See [[Upgrades - Process, Upgrade Center and Upgrade Console]].

## Deprecations

**Being prepared for future deprecation** (still supported):

- **Basic authentication for inbound integrations.** Move REST and SOAP to OAuth 2.0, mTLS or federated tokens. See [[Inbound API Authentication and API Access Policies]].
- Virtual Agent for NLU, Virtual Agent Lite, ITSM Virtual Agent pre-built topics, and some channel integrations.
- CMDB Baseline, User Registration Request (`com.snc.user_registration`), Operational Technology Discovery.

**Deprecated or removed:**

- **KPI Composer:** removal expected in the D release, no replacement. See [[Performance Analytics Concepts and Roles]].
- **Service Graph Workspace:** merged into CMDB Workspace.
- Clone requests through lists and forms (legacy) redirect to the new page.
- `findOrCreateRelationshipType` no longer creates CI relationship types.
- App Engine Studio PDF Extractor; Planning console; Communities; Migration Utility for Service Operations Workspace (`sn_sow_migration`).
- Live Connect Basic authentication "will be gradually phased out"; OAuth recommended.
- ServiceNow Studio: Experience switcher, Tools tab, top Create menu, Resources section removed.

**Planned, no replacement:** Workforce Optimization for ITSM (`com.snc.wfo_itsm`), Agent Client Collector for Investigation (`com.snc.acc_adapter`), Microsoft Endpoint Configuration Manager for Investigation (`com.snc.mecm_adapter`).

## Naming

- **Now Assist** is becoming **ServiceNow Otto**. Older names remain in many places, so the vault keeps both.
- **SQL API** is now **Live Connect**.
- AI licensing tiers: Foundation, Advanced, Prime.

## Platform

- HTML editor: TinyMCE 6.8.2 to 8.3.0. Text patterns: `glide.ui.html.editor.textpatterns`.
- `glide.ui.choice.display_none`: empty choice shows None or --None--.
- `glide.export.xls.max.rows.per.sheet`, `glide.export.xlsx.max.rows.per.sheet`: Excel row limit. See [[Exporting Data]].
- `glide.sys.fencing.restricted_caller_access.invalidation_mode`: how update set commits invalidate Restricted Caller Access records.
- Rows changed by an AI agent show an AI indicator in Core UI lists, until an inline edit clears it.
- ES12 mode gains scripting features; engine updated from Rhino.
- Daily slow-pattern snapshots, kept up to 33 days.
- **Multi-Instance Setup** (`sn-app-amf`, Store): discovers related non-production instances, needs AMF Core.
- Date and time format moved from the user profile to **Language & Region** in Preferences.
- New language pack: Latin American Spanish (`com.snc.i18n.latam_spanish`).
- Zing: column-level `query_range` read ACLs on indexed columns; **Text Search Query Range ACL Checker** tool. v3 indexes need access to all indexed columns, v4 matches only accessible ones.
- Notifications: inbound email channel for redaction, source mailbox in headers, original bounced email viewable.
- Subscription storage now pooled at account level.

## Clone

**Clone Admin Console**, role `clone_admin`: OAuth 2.0 for targets (`oauth_admin` on the target at setup, both instances Australia Patch 5 or later), Multi-Instance View, Instance Overview, **Clone Activity** (was Clone Home), new request allowed if over five days from others, JWT certificate authentication.

Unconfirmed variant: Multi-Instance View needs Australia Patch 5 in one place and Patch 2 in another. See [[Instance Clone Overview]].

## Security

- **Basic Auth Restriction** page: track first, then enforce an allowlist; `snc_basic_auth_api_access` is one way onto it.
- **Policy-based login** (identifier-first) in the Authentication Console.
- SAML certificate expiry banners; RS256 ID tokens; outbound certificate policies per host.
- Workload Identity Federation outbound for Azure and Google Cloud.
- External authorization servers for MCP clients.
- **Access Analysis Agent:** ask whether a user, group or role can reach something; result Passed, Blocked or Undefined.
- Data Privacy: dry run, reversible tokenization, OCR discovery on images, your own PII detection.

## ITSM

- **Incident, new instances only:** `incident_manager` loses `itil`, gains `incident_write`; `major_incident_manager` and `sn_comm_management.comm_plan_mgr` lose `itil`, gain `sn_incident_write`, `sn_problem_write`, `sn_change_write`, `sn_request_write` (`com.snc.itsm.roles`). Upgraded instances keep `itil`.
- **Auto resolve On-hold** with reason Awaiting Caller Information: default 3 attempts, 1 business day apart, then resolved as *Resolved - No response from caller*; 0 disables. New instances only.
- **`glide.ui.autoclose.time` now counts business days**, not calendar days.
- **Change:** compliance dynamic schema, change lockdown, scaled change, ITIL process on models, state field policies. See [[Change Lockdown]], [[Dynamic Schema]].
- **Otto:** autonomous change agents for creation, CI suggestion, plans and templates; ITSM MCP Server needs `sn_mcp_server.viewer`.
- **Service Catalog:** `glide.sc.catalog_item.subscription_enforcement` (`allow_bypass` default, `require_criteria`). Angular portal through `com.glideapp.servicecatalog.ui16_portal`: default on new instances, install on upgrades.
- **CMDB:** Dynamic IRE default on new instances, optional on upgrades; `app_service_owner` contains `app_service_user`; `itil` removed from `app_service_admin`. Certification tasks can be reset.
- **Hermes:** configurable topic retention, which may change the 36 hours in [[Hermes Messaging Service]].
- **Knowledge:** Duplicate score in article health; stale and expiring article scan.

## Example

Before upgrading *Example Test Instance* from Australia: list users with only catalog roles, list ACLs under **Access Findings**, list inbound integrations on Basic authentication, and test role behaviour with *Test User*.

## Related

- [[Upgrades - Process, Upgrade Center and Upgrade Console]] · [[Plugins]] · [[ITSM Granular Roles]] · [[Hardening Settings - Access Control]] · [[Skipped Records in Upgrades]]
