---
type: concept
tags: [concept, automation, roles, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Automation Center (Explore, Configure, Use overviews, Reference: components, properties), read at overview depth 2026-10-30. Step pages and form fields (about 100 topics) listed, not read in detail. https://www.servicenow.com/docs/r/integrate-applications/automation-center/automation-center-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Automation Center

**In one line:** one place to take requests for automation, track goals, and watch the health and value of automations from several vendors: flows, RPA Hub, UiPath and others.

From the Brazil docs; not tested. Scoped application `sn_ac` from the Store. Domain separation: Basic. Feeds from [[Task Mining]] and [[Process Mining]].

## Workspace

Dashboards **Overview**, **Executions**, **Value**.

- **Kanban board:** requests and tasks by state.
- **Action Center:** business users run fixes for repeated failures.
- **Connection Manager:** maps third-party data into `sn_ac` tables.
- **Automation Tracker** (**Administration**): track a flow or action as an automation.
- **Migration accelerator:** moves UiPath, Blue Prism and Automation Anywhere automations to RPA Hub.
- **Spotlight** scores requests in New or Deferred; a manual score sets *Score manually altered*.
- **Recommended Actions:** similar requests, with `sn_ac.use_recommended_actions`.

Data arrives from RPA Hub by flow, and from others through the Automation Center API or spokes such as UiPath. Requests: **Automation Center > Build > Submit an Automation Request**; types automation, action, review. A goal maps to many requests.

## Roles and tables

| Role | Can |
|---|---|
| `sn_ac.automation_admin` | everything; contains the next two |
| `sn_ac.automation_technical_user` | requests, sources, tasks, resources, insight rules |
| `sn_ac.automation_business_user` | requests, goals, life-cycle stages |

The components page also writes `sn_ac.automation_techincal_user`: unconfirmed variant.

Tables: `sn_ac_automation_request`, `sn_ac_automation_task`, `sn_ac_automation_execution`, `sn_ac_insight`, `sn_ac_insight_rule`, `sn_ac_automation_source`, `sn_ac_ci_attribute`, `sn_ac_rpa_import`; goal written `sn_sc_automation_goal` (unconfirmed prefix); CIs `cmdb_ci_base_rpa_robot`, `cmdb_ci_base_rpa_process`.

| Property | Default |
|---|---|
| `sn_ac.purge_automation_data_in_days` | 14 |
| `sn_ac.workspace.date.default_num_of_days` | 7 |
| `sn_ac.reporting_currency` | USD |
| `sn_ac.savings_averaging_window` | 4 |
| `sn_ac.use.spotlight.score.for.requests` | true |
| `sn_ac.auto_onboarding_catalog_items` | true |
| `sn_ac_assist.enterprise_dev_hourly_rate` | 50 |

## Example

Goal *Example Reduce Manual Work*, request *Example Invoice Bot*, flow *Example Invoice Flow* added to the Automation Tracker.

## Related

- [[RPA Hub]] · [[Task Mining]] · [[Process Mining]] · [[Workflow Studio Overview]]
