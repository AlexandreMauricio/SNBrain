---
type: concept
tags: [concept, portal, incident, ai, release-specific]
status: documented
source: ServiceNow Brazil ITSM docs, Employee Slate for ITSM (landing, Explore, Configure, Use), read 2026-10-29. https://www.servicenow.com/docs/r/it-service-management/employee-works-itsm.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Employee Slate for ITSM

**In one line:** an ITSM add-on for the **Employee Slate** home page that shows a **Service Health Broadcast** of outages and degradations (with an *Ask Otto* summary) and a **Tech lounge** for walk-up check-in or appointment booking, also reachable conversationally through Otto.

From the Brazil docs; not in the Australia PDF; not tested. Employee Slate itself (the AI-first employee home, built for Moveworks or for Now Assist) is described in [[Simplified IT Service Management]]; the walk-up back end is the Walk-up Experience application.

## Set up

Install the *Employee Slate for ITSM* plugin, then integrate with one of: **Employee Slate for Moveworks** (Moveworks chatbot and plugins from the Moveworks Marketplace) or **Employee Slate (built for Now Assist)**. Walk-up locations, queues and appointments come from Walk-up Experience configuration. *Ask Otto* on outages needs the **Outage lookup** plugin. The Tech lounge quick link is added through the EmployeeWorks web app configuration; the name *Tech lounge* can be changed.

## What employees see

- **Service Health Broadcast** banner: active outages, maintenance and degradations of the highest business-criticality tier (service tiers are configured), for all users. Statuses: outage (unavailable), degradation (below normal), maintenance (scheduled or in progress), operational. **All services** page and a service detail page; users can subscribe to status updates.
- **Ask Otto**: chat that summarises the active outages.
- **Tech lounge**: location (remembered), hours, live walk-in queue. Check in with a reason and a description (Otto suggests articles and a generated answer while typing); then position and estimated wait update live, with email updates (technician assigned, spot status, queue position). Or **Book appointment** (in person or remote, date and slot from location hours and load, add to calendar). The same check-in, queue view and cancellation work in conversation with Otto.

Otto's summaries and answers are AI-generated and may be wrong.

## Example

Location *Example HQ Tech Lounge* renamed *Example IT Bar*; an employee checks in with reason *Laptop* and description *screen flickers*, sees position 3, and later cancels from the Otto chat.

## Related

- [[Service Operations Workspace for ITSM]] · [[Otto for ITSM Skills and Agentic Workflows]]
