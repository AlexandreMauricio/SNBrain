---
type: concept
tags: [concept, knowledge, reporting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > Knowledge Management > Analytics and Reporting Solutions for Knowledge Management (Knowledge Management Platform Analytics Solutions, Knowledge Management dashboard, Knowledge Management Overview dashboard, Update the navigation path for the Knowledge Management Overview dashboard, Pareto chart for Knowledge Demand Insights, Demand Insights for Cases / Incidents / HR Cases dashboards), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/analytics-and-reporting-solutions.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Management Dashboards

**In one line:** three families of shipped knowledge dashboards: the **Knowledge Management** dashboard (Performance Analytics solution, indicators over time), the **Knowledge Management Overview** dashboard (plain reports, plugin `com.sn_knowledge_overview`), and the **Demand Insights** dashboards (knowledge gaps from Predictive Intelligence).

From the Brazil docs; not tested. Knowledge Center has its own health and insight views: [[Knowledge Center]].

## Knowledge Management dashboard (Platform Analytics solution)

- Solution `com.snc.pa.knowledge_v2` (replaced the first version in London; the old one keeps working after upgrade; activating v2 needs a historical data collection job to fill new indicators). Enable through **Performance Analytics > Guided Setup** > Get Started, then the Knowledge Management section. Open from **Self-Service > Dashboard(s)** and search for it.
- **Run As user** of the data collection jobs: System Administrator in some solutions, blank in others; check that the user exists and has enough access (matters only with domain separation).
- Tabs: **Content Usage**, **Content Governance**, **Content Quality**.
- Audiences: `knowledge_manager` (publication velocity, what customers search for), `knowledge_admin` (plan content creation), content creators with `pa_viewer`.
- Indicators (all as described on the page): % of articles published (published / active, daily); monthly average article rating (sum of ratings / articles rated); average select rank (sum of search ranks / searches with rank); select through rate (searches with rank / searches); average time to publish (days, daily, goal minimise); monthly counts of active users who searched, active users who viewed, searches, searches with rank (Highest select Rank > 0), articles rated (knowledge feedback with a rating); daily counts of articles published and active; helper sums of ratings and of search ranks; the same rank / select through / search / view measures for **unauthenticated users** (lower average select rank is better, higher select through rate is better).
- Breakdowns: Time to Publish Groups, Knowledge Base, Knowledge Category.
- Extra visualisations: Articles with Inactive Authors (active, author inactive), Invalid Articles (active, workflow Draft / Review / Published / Pending retirement, Valid to before today, latest = true), Articles Created Over 1 Year, Articles not Published (Draft or Review).
- **Self-Service Analytics** widgets: activate `com.snc.pa.self_service_analytics`, find the indicators in the PA Admin Console, build widgets, and activate the **[SSA] Self-Service Analytics** data collection job ([[Self-Service Analytics and Case Deflection]]).

## Knowledge Management Overview dashboard (reports)

- Plugin **Knowledge Overview** (`com.sn_knowledge_overview`); on upgrade it must be activated by hand. Responsive layout: `glide.cms.enable.responsive_grid_layout` = true. Open from **Self-Service > Dashboards**. Roles `knowledge_manager`, `knowledge_admin`.
- Sections and reports: **Article life cycle** (created last 30 days, number in review, by workflow state, in review over 30 days, created / updated last 30 days by base and workflow, expiring next 90 days, in Draft); **Article Feedback** (flagged, marked not helpful, comments, ratings in last 30 days, average rating); **Article Usage** (knowledge use = articles attached to tasks, views by base, both trended by month); **Author Metrics** (monthly use, views and articles created per author).
- **Upgraded instances, menu path** (`admin`): **System Definition > Modules**, find Title *overview* in Application menu *knowledge*, open **Overview**, set **Link type** = *URL (from Arguments)* and **Arguments** = `now/platform-analytics-workspace/dashboards/params/edit/false/sys-id/<dashboard sys_id>` (the page gives a fixed sys_id), Update. The dashboard then opens from **Knowledge > Administration > Overview**. The module lives in **Modules** (`sys_app_module`, see [[Application Menus and Modules]]).

## Demand Insights dashboards

Part of `com.snc.knowledge_ml`; setup in [[Knowledge Demand Insights and Predictive Intelligence]].

| Dashboard | Roles | Data |
|---|---|---|
| Demand Insights for Cases | `sn_km_ml.knowledge_curation_user` + `sn_customerservice_manager` | Pareto *Candidate Knowledge Gaps for Case*: **Knowledge Curation Task** (`kb_curation_task_cluster`) where Curation configuration = `sn_customerservice_case` and Solution.Active = true |
| Demand Insights for Incidents | `sn_km_ml.knowledge_curation_user` + `incident_manager` | same table, curation configuration incident |
| Demand Insights for HR Cases | `sn_km_ml.knowledge_curation_user` + `sn_hr_core.admin` | needs also `com.sn_hr_core` |

**Pareto chart**: left axis = number of uncovered tasks per collection, right axis = cumulative percentage; bars largest first; a blue line at 80% shows the fewest collections to resolve to cover 80% of the tasks.

## Related

- [[Knowledge Management Overview]] · [[ITSM Platform Analytics Dashboards and KPIs]] · [[Knowledge Logs, Numbering and Extension Points]]
