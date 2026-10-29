---
type: concept
tags: [concept, cmdb, assets, data-integrity, ai]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB success advisor (35 topics, 1,387 cleaned lines, read in full through the docs site API 2026-10-29) - Explore, outcomes, Configure (install, roles, upgrade marking), Access, workspace card states, landing page, Data Foundations advisor (principal classes, recommendations and criteria property, auto and manual setup, scope, sync, dashboard, remediation, data integrations, settings, indicators), Reference. The HAM and SAM advisor pages are linked but are not in this guide (?). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-sa-explore.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB Success Advisor

**In one line:** a scoped store app (`sn_cmdb_advisor`, Next Experience) that narrows CMDB data quality work to a *scope* — principal classes for **Data Foundations**, hardware model categories for **HAM**, software products for **SAM** — and gives each a dashboard, an AI summary of top issues, remediation suggestions, an integrations tab and a settings check.

From the Brazil docs. Needs CMDB Workspace (`sn_cmdb_ws`) and SGC Central (`sn_sgc_central`). Install from **System Applications > All Available Applications > All** (role `admin`, entitlements). The three outcomes can run together.

## Opening it

- [[CMDB Workspace]]: Home > **Product highlights** card > **Remediate** (opens the dashboard if the scope is set, otherwise starts setup), or Management > Optimize > *CMDB success advisor*.
- Service Graph Workspace: **Governance** (product highlights or Management tools > Optimize), or **Insights** card (read-only users land here).
- Software Asset Workspace (`com.sn_sam_workspace`): *Review CMDB data quality* notification, straight to the SAM dashboard.

Landing page cards: *Set principal classes* / *Select model categories* / *Select software products* (not yet set up), **View insights** (ready), *Needs installation* (DF, SAM) or *Pending install* (HAM), *Needs entitlement*. The CMDB Workspace card shows an AI caption with a timestamp when a summary exists (DF and HAM only; SAM never), and an **Auto-setup** tag when set up automatically.

## Roles

| Role | Access |
|---|---|
| `sn_cmdb_admin` | everything: landing page, setup, Dashboard, **Settings** and **Integrations** tabs |
| `sn_cmdb_user`, `sn_cmdb_editor` | Dashboard tab only, read-only, from Service Graph Workspace Insights |
| `sn_cmdb_advisor.scope_user` | read pages and data incl. AI summary (plus `sn_cmdb_user`) |
| `sn_cmdb_advisor.scope_editor` | edit SAM scope and content template (DF and HAM scope still need `sn_cmdb_admin`) |
| `sam_user` / `sam_admin` | view SAM dashboard / pick SAM software products |
| `cmdb_inst_admin` | create or change Service Graph Connector connections from the advisor |
| `pd_user` / `pd_admin` | view / modify Discovery patterns from the advisor |
| `pa_viewer` | use dashboard filters |

## Data Foundations: principal classes

The scope is a set of **principal classes** (up to 200; limit in `sn_cmdb_advisor_content_template`). Saving the scope **marks them principal** in `cmdb_class_info`, which **filters the Configuration item picker on incidents, problems and changes** to those classes ([[CI Classes, Dependency and Principal Class]]). If users then miss CIs, remove the task table from `com.snc.task.principal_class_filter`; do not clear the Principal Class flag, the advisor needs it.

**Recommendations** (monthly job): weighted score of incident/problem/change activity over the suggestion period, CI count and class category (servers and cloud highest, services/offerings and enterprise architecture lowest). Fewer than six qualifying classes are padded with Computer, Server, Database, Cloud Database, Virtual Machine Instance. Groups in the *Set principal classes* dialog: Recommended additions (top 20), **Recommended removals** (selected classes on the exclusion list: endpoint `cmdb_ci_endpoint_*`, `*_template`, classes outside the native `cmdb_ci` family, and listed names), then technology groups (AI systems, Cloud, Databases, End user computing, Enterprise architecture, Integrations, IPAM, IT networking, Kubernetes, Mainframe, Middleware, Others, SaaS, Servers, Service instances, Services and offerings, Storage, Virtualization). Search finds any non-excluded class.

| Property | Default | Meaning |
|---|---|---|
| `sn_cmdb_advisor.principal_class_suggestion_period` | 180 | days of task history scanned |
| `sn_cmdb_advisor.suggested_principal_classes_limit` | 20 | size of Recommended |
| `sn_cmdb_advisor.principal_class_others` | | extra custom classes for the Others group |
| `sn_cmdb_advisor.principal_class_recommendation_criteria` | (create it; `PREDEFINED`) | on instances with no task history, recommend the five standard classes. Create in the CMDB success advisor scope, type string, role `admin` |

**Setup:**
- *Automatic*: on install or upgrade the job *CMDB Advisor - Auto Setup* configures DF if: no DF dashboard yet, fewer than 5 million CIs, at most 200 principal classes, and `com.snc.task.principal_class_filter` empty or some principal class already exists. Scope = existing principal classes, or the top five recommendations if none. Data collection runs monthly until the dashboard is first opened, then daily; *CMDB Advisor - Check Job Completion and Notify* tells `sn_cmdb_admin` users when it is ready.
- *Manual*: landing page > **Set principal classes** > pick groups or classes > **Done**. *CMDB Advisor - DF Daily Data Collection* fills the dashboard and then runs daily. When `com.snc.task.principal_class_filter` is set, a confirmation check box (classes added/removed, effect on task CI pickers) must be ticked before **Done**.
- On upgrade, classes of existing HAM model categories are marked principal once and seed the DF scope; HAM-used classes cannot be edited in DF until removed from HAM.

**Sync:** the advisor keeps its own scope. Classes made principal elsewhere (CI Class Manager, the Otto principal class agent) are not added; classes un-marked elsewhere stay in scope. Opening the dashboard compares them and shows an out-of-sync banner; fix via **Manage principal classes** (the inline alert's *Show more* lists the differences).

## Data Foundations dashboard

Filters: principal classes, CI class categories (needs `sn_data_model_nav`), date range, **Stale CI** days (7, 14, 30, 60, 90). Charts show the top 10 values plus *Others*; selecting a segment opens **KPI Details** (trend, and a **Remediation actions** panel when actions exist).

| Card | Measures |
|---|---|
| AI summary | top 5 issues with remediation, ranked by % affected within categories Data integrity > CI attributes > Reconciliation and governance > Data Manager policies (gaps over 15 points in a category or 40 across can reorder). Needs the Otto *summarize CMDB readiness* skill; **View reasoning** |
| CIs by principal class / by data integration source | distribution of operational CIs |
| CIs missing name, managed by group, location | completeness |
| Stale CIs, Duplicate CIs | with **Ask Otto** starting the CMDB Staleness Agent (`sn_cmdb_editor`) or Duplicate CIs Agent (`cmdb_dedup_admin`, feature preview), both need `now_assist_panel_user` |

Indicators are named *DF CIs by principal class*, *DF CIs by discovery source*, *DF CIs missing name/location/managed by group*, *DF Duplicate CIs*, *DF CIs not updated in last 7/14/30/60/90 days*. A banner appears if the PA collector hit its row limit. Remediation tips from the docs: stale often means a failing or out-of-scope Discovery schedule; duplicates often mean IRE rules need work ([[IRE Identification Rules]]); missing location or owner can be derived by enrichment rules.

**Data integrations tab**: Discovery patterns (**Status**, **Attribute coverage**, **View pattern**) and Service Graph Connectors (**Installed**, attribute coverage, active and inactive connections), plus **Suggested integrations** not yet installed. *Attribute coverage* shows suggested vs installed version, supported principal classes and attributes; *View available version* opens Application Manager.

**Settings tab** (Ideal / Requires attention): CI creation from assets using IRE (and its business rule), reconciliation rules per principal class ([[IRE Reconciliation, Data Refresh and Data Source Rules]]), principal classes without a **Managed by group** field, *Sync managed by group* business rule active, fewer than 10 custom attributes per class, Data Manager policies (archive, attestation, certification, delete, retire; [[CMDB Data Manager]]). Actions open Data Manager, New policy, attributes, the property, or CI Class Manager. Business rules need the application picker set to Global.

## Components

Jobs: *CMDB Advisor - Auto Setup*, *- Check Job Completion and Notify*, *- DF / HAM / SAM Daily Data Collection* (each invoking a *CMDB success advisor data collection for ...* PA job).

Tables: `sn_cmdb_advisor_ci_attribute_coverage`, `sn_cmdb_advisor_content_template` (scope and the 200 limit; raising it can hurt performance), `sn_cmdb_advisor_settings`, `sn_cmdb_advisor_suggested_attribute`, `sn_cmdb_advisor_suggested_ingestion_source`, `sn_cmdb_advisor_targeted_product`, `sn_cmdb_advisor_aggregate_data` (draft, ready, retired), `sn_cmdb_advisor_notification`, `sn_cmdb_advisor_selected_context` (manual or automatic selections).

## Related

- [[CI Classes, Dependency and Principal Class]] · [[CMDB Workspace Insights and SGC Central]] · [[CMDB and CSDM Data Foundations Dashboards]] · [[CMDB Health]] · [[CMDB Data Manager]]
