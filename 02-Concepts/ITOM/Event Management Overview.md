---
type: concept
tags: [concept, cmdb, roles, incident, release-specific]
status: documented
source: ServiceNow Brazil docs, IT Operations Management > ITOM AIOps > Event Management > Explore (overview, process flow), Reference outline, read 2026-10-30. Configure (318 topics), connectors, Use (33) and Express List not read. https://www.servicenow.com/docs/r/it-operations-management/event-management/em-process-flow.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Event Management Overview

**In one line:** turns events from monitoring tools into a smaller set of alerts bound to CIs, so operators can find causes and act.

From the Brazil docs; not tested. Part of ITOM AIOps. Do not confuse these with platform events: `em_event` is not `sysevent`.

## From event to alert

Events arrive by email, script, SNMP trap or web service API, or a MID Server polls the external tool. All are stored in `em_event`, and stay reviewable even when no alert results.

1. **Match event rule:** by source, optional filter and Additional Information filter. A rule with no filter is ignored; **order** decides among several.
2. **Ignore:** if set, no alert.
3. **Transforms** and compose parameters.
4. **Threshold:** if active, events gather until the threshold, then one alert.
5. **Event field mapping:** applied even with no rule. No severity afterwards means no alert.
6. **Alert generation:** search `em_alert` for the **message key**. If found, update; if not, create. Same key means one alert.
7. **Bind** the alert to a CI for root cause analysis.

## Roles

| Role | Can |
|---|---|
| `evt_mgmt_admin` | all configuration. **Treat as sensitive:** can write global scripts (correlation, management and maintenance rules, field mapping, binding) and so reach `admin` |
| `evt_mgmt_operator` | close and acknowledge alerts, oversee the process |
| `evt_team_operator` | read and write alerts for its team; must be on an assignment group, or sees nothing |
| `evt_mgmt_user` | view and acknowledge |

## In the guide

Connectors (Dynatrace, Nagios, Zabbix, SCOM, SolarWinds, push), alert correlation, tag-based alert grouping, alert automation in Service Operations Workspace, Integrations Launchpad, event forwarding. Related products: Health Log Analytics, Metric Intelligence, Service Observability, Service Reliability Management, Synthetic monitoring.

## Example

Source *Example Monitor* sends an event through the web service API. Event rule *Example CPU Rule* maps severity, an alert appears on server *Example Server 01*, and repeat events update the same alert.

## Related

- [[Service Mapping Overview]] · [[Agent Client Collector Overview]] · [[Discovery Overview]]
