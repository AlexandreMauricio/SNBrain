---
type: concept
tags: [concept, cmdb, workspace, reporting, roles]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital Portfolio Management" (pp. 2145-2153, 2212-2241 and 2259-2261: overview, users, homepage, life-cycle management, getting started, personalising the home page, custom record views, personal and enterprise portfolios, portfolio templates, Needs attention panels, relationship map, creating demands and improvement initiatives, list modules, persona and views), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Digital Portfolio Management

**In one line:** Digital Portfolio Management (DPM, scope `sn_dpm`) is a configurable workspace that shows *solutions* (services, service offerings, business applications, service instances) through a plan / build / run life cycle, pulling data from other applications into one place.

**Where:** **Workspaces > Digital Portfolio Management**. Roles: DPM manager (`sn_dpm.dpm_manager`) uses it; DPM admin (`sn_dpm.dpm_admin`) configures it ([[DPM Administration, KPI Groups and Reference]]). What each solution page shows: [[DPM Solution Pages and Needs Attention]].

DPM only *surfaces* data. What a user sees depends on the plugins installed and the licence level of the source application (standard or pro); editing a solution needs that solution's own ACLs (for example a service editor role and ownership). DPM itself only lets a manager create demands and improvement initiatives and manage personal portfolios. Service data comes from [[Service Portfolio Management]] and the CSDM tables.

In Australia the labels of `cmdb_ci_service_technical` and its offerings are **Technology Management Service** and **Technology Management Service Offering** (CSDM 5 wording).

## Life cycle

| Phase | Shows |
|---|---|
| Plan | roadmap and backlog (opens Strategic Planning or Portfolio Planning), ideas, demands, projects starting soon, improvement initiatives |
| Build | projects (status, overdue, missed milestones, critical issues), changes, improvement initiatives; for business applications epics, stories, sprints, releases or DevOps flow and accelerate metrics |
| Run | KPI groups from Performance Analytics (availability, incidents, requests, CSAT), commitments, breakdowns, deployments, risk |

With a standard Performance Analytics licence only the last 6 months show and indicators cannot be edited (KB1637474 on KPI results).

## Home page

Welcome message, **Current status** solution cards, recently visited personal and enterprise portfolios, recently viewed items. A card shows the solution name and type, an actions menu (details, relationship map, remove) and its *Needs attention* attributes with counts; colour and icon give the status.

| Status | Default threshold |
|---|---|
| Good (green) | nothing |
| Moderate (orange) | Alerts 3, Risks 1 |
| Severe (red) | Critical incidents 1, Outages 1, Alerts 10, Risks 3 |

Changes and Audits have no default threshold. Data is current as of page load.

**Default cards** on first login are solutions where the user is in one of these fields:

| Solution | Table | Fields |
|---|---|---|
| Service | `cmdb_ci_service`, `cmdb_ci_service_business`, `cmdb_ci_service_technical` | Owned by, Delivery manager, Delegate, Business relationship manager, Business contact, Managed by |
| Service offering | `service_offering` | Owned by, Delivery manager, Delegate, Business contact, Managed by |
| Business application | `cmdb_ci_business_app` | IT application owner, Business owner, Portfolio manager |
| Service instance | `cmdb_ci_service_auto` (including dynamic CI groups) | Owned by, Managed by |

Limits: properties `dpm.homepage.cmdb_ci_service_limit` (750) and `dpm.homepage.cmdb_ci_business_app_limit` (250), so 1,000 cards in total; raising them can hurt performance.

**Personalize** (role `sn_dpm.dpm_manager`): **Edit status conditions** (own thresholds per attribute), **Add items**, **Remove items** (retired items are not offered). Once personalised, the defaults are no longer generated; the choice is stored in `dpm_home_page_item` (user preference `dpm_home_page_item_list`). **Search** matches solution names only, not owners. **Filter** by status or by type.

## Personal portfolios

An unstructured collection of any solutions, owned or not, with KPIs, needs-attention items and a relationship map.

Personal portfolios icon > **Create personal portfolio**: **Name**, **Owned by**, **Description**, **Add collaborators** (Editors and Viewers: users or groups) > **Next** > pick items on the tabs Business applications, Services/Offerings, Service instances (search by title or owner) > **Add selected items** > **Review portfolio** > **Create**. Later **Edit** or **Share**.

- A group can be an editor or viewer only if it has the DPM manager role. An admin sets this from `dpm_personal_portfolio.list` > portfolio > **Edit user groups** / **View user groups**.
- **All items** filters the cards by solution type.
- Solutions found elsewhere in the workspace can be added to a personal portfolio from their More menu.

## Enterprise portfolios

Structured as a tree: portfolio > enterprise taxonomy nodes (nestable) > solutions. KPIs roll up through each level. Anyone with the manager role can view them; admins create them.

| Type | Built from | Node shows |
|---|---|---|
| Service portfolio | created directly in the workspace since May 2025 (before: Service Portfolio Management tables) | performance snapshot (availability, open incidents, incidents not updated for 5 days, new requests); needs attention: critical incidents, outages, changes |
| Business application portfolio | enterprise portfolio tables | portfolio success metrics (availability, incidents with breached SLA, incidents caused by changes, successful changes); needs attention adds alerts, risks, audits |
| Service instance portfolio | enterprise portfolio tables | as business applications, with mean time to resolve |

Navigate: enterprise portfolios icon > **Portfolio** field (grouped by type) > node > **View Details** (tabs Overview, Taxonomy nodes, the solutions tab, Info; Needs attention panel) > expand to child nodes and solutions, each with its own **View details**. To switch to another portfolio type, clear the **Portfolio** field first. Filter by life-cycle stage: Pre-operational, Operational, Retired (service instance portfolios: Operational, Retired). From a service the More menu also offers adding it to the home page or editing it in [[Service Builder]].

**Create** (role admin):

- In the workspace: **Create enterprise portfolio** > type > **Create portfolio** (form: **Name**, **Short description**, **Description**, **Portfolio type**, **Portfolio owner**, **Portfolio manager**, **Portfolio Stakeholders**) or, for service portfolios only, **Choose template** (apply everything, or exclude the services) > **Save** > add KPI groups > **Add taxonomy node** (existing or new; parent, child, sibling or duplicate).
- Classic UI: **Digital Portfolio Management > DPM Enterprise Portfolios > Create new** (same fields plus **Active**; managers only see active portfolios). Needs the enterprise portfolio plugin.

Service portfolio templates:

| Template | Content |
|---|---|
| Sample Organizational Structure | nodes per director under a CIO (security, development, architecture, governance, innovation, operations, PMO, vendor management) with placeholder descriptions |
| IT Service Portfolio | nodes such as Application Development & Deployment, Cybersecurity & Compliance, Data & Analytics, End User & IT Support, Enterprise Operations, Infrastructure & Cloud, IT Governance & Strategy, with child nodes and example services |
| EDUCAUSE Higher Education IT Service Portfolio | nodes such as Administrative and Business, Communication and Collaboration, Information Security, Infrastructure, Research, Teaching and Learning, with services for a university |

## Lists

List icon: tab **Lists** (Services, Offerings, Business applications, Service instances, Demands, Projects, Contracts; each *Owned by me* or *All*) and tab **My Lists** (**Add new List**: *Start from existing* or *Create your own* with a source table, columns and filters). Share a list by copying its URL.

## Actions from the workspace

- **Create > Demand** on a service or offering in a personal portfolio (needs the Demand Management plugins): dates, details, business case, financials, assessment data, owner. It then shows on the Plan tab.
- **Create > Improvement initiative** (needs [[Continual Improvement Management]]): the standard initiative form (goals, details, schedule, notes).
- **View relationships**: the Unified Map with the solution at the top; side panels for summary, contacts, current issues and related service instances.

## Custom record view

To choose which form view the workspace uses for a table: **Now Experience Framework > Configuration Settings > UX Form View Rules > New** (**Name**, **Table**, **View**, **Application**, **Execution Order**); clear the cache afterwards.

## Related

- [[DPM Solution Pages and Needs Attention]] · [[DPM Administration, KPI Groups and Reference]] · [[Configure a Service Availability KPI in Digital Portfolio Management]] · [[Service Portfolio Management]] · [[Service Offerings, Commitments and Availability]] · [[ITSM Application Suite Overview]]
