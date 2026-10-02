---
type: concept
tags: [concept, ai, workspace, incident, problem, knowledge]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Operations Workspace for ITSM", topics "Configuring Recommended Actions for ITSM in Service Operations Workspace", "Recommended Actions for ITSM Workflow", "Access Recommended Actions for ITSM Panel", "Recommendation Framework in Service Operations Workspace" (deprecated), "Recommended Actions for ITSM in Service Operations Workspace" and its reference (pp. 3324-3334, 3630-3644), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Recommended Actions for ITSM

**In one line:** the **Recommendations** side panel of Service Operations Workspace (SOW) offers an agent cards such as "similar open incident: link as parent" or "copy this resolution", and predicts field values on an incident; it is assembled from contexts, rules, recommendations, resource generators and guidances.

It replaces the **Recommendation Framework** (`sn_rf`, with rules such as *Similar open incidents* and field predictions shown as messages), which is deprecated and cannot be newly activated.

## Versions and plugins

| Version | Plugin | Licence | Adds |
|---|---|---|---|
| Standard | part of SOW | ITSM | rule-based ("Non-ML", CI and service matching) and AI Search recommendations |
| Advanced | `sn_sow_itsm_ra_adv` (guide also gives `com.snc.uib.sow_itsm_ra_advanced`), with Task Intelligence Admin Console `com.sn_ti_admin` | ITSM Pro | Task Intelligence recommendations (incident field prediction, similar incidents, similar open changes and problems, similar major incidents, propose major incident) and field recommendations |

Predictive Intelligence solution definitions come from: `com.snc.incident.ml_solution` (assignment group and CI classification; similar open incidents, similar KB articles, similar resolved incidents; Similar Incidents (TI) from SOW 6.0), `com.snc.incident.mim.ml_solution` (propose major incident and similar major incident, trend), `com.snc.incident.ml` (similar open problems), `com.snc.uib.sow_problem` (create problem for major incident). The solutions must be trained. See [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]].

Roles: itil and `sn_incident_write` contain `sn_nb_action.next_best_action_user` (see) and `sn_gd_guidance.guidance_user` (act).

## Building blocks

| Piece | What it is | Shipped |
|---|---|---|
| **Context** | the record type recommendations are computed for | Incident, Incident task, Problem, Problem task, Change request, Change task, Interaction, Request. The interaction context needs the **Context Sys ID** property set on the Recommended Actions component of the record page in UI Builder |
| **Rule** | conditions and roles under which a context shows recommendations | *Active incident*; *Active non-child non-MI Incident*; *AI Search* (all eight record types); *Major Incident with no Problem record*; *High impact Problem with no known error article* |
| **Recommendation** | guidance-based (a card) or field-level (a predicted value) | see below |
| **Resource generator** | fetches the candidate records or values (a trained solution, a query, AI Search) | one per recommendation, for example *Similar open incidents using similarity*, *Resolved Incidents with same CI & Service*, *Incident Fields predictions TI*, *AI Search Resource Generator* |
| **Guidance** | the card layout and the action the agent can take, with inputs and outputs | see below |
| **Search result mapping** | which tables AI Search returns per context | incident: outage, knowledge, change, incident (plus a generative Genius result for Pro Plus), catalog item, problem; other contexts mostly knowledge, incident, problem; interaction and request: knowledge. Search application configuration *[AIS] Recommended Actions for ITSM Search Config* |

Workflow to add one (admin): use or create a context → set a rule → create the recommendation by choosing a resource generator and an action type (inputs, outputs, action).

## Shipped guidance-based recommendations

| Recommendation | Returns | Card action |
|---|---|---|
| AI Search Recommendation | AI Search results for the record | per result type |
| Create Problem Record for a major incident | | **Create Problem** |
| Open incidents (CI & Service) | open incidents with the same CI or service, created in the last 6 months, max 5 | **Make parent** |
| Open PRBs (CI & Service) | problems with the same CI or service from the last 7 days, max 5 | **Link to Problem** |
| Similar resolved incidents (CI & Service) | resolved, same CI or service, last 6 months, max 5 | **Copy resolution** |
| Similar Open Incidents (Similarity) | open incidents by similarity model | **Link as parent** (the current incident becomes the child) |
| Similar Open PRBs (Similarity) | open problems | **Link Problem as Parent** (sets the incident's **Problem**) |
| Similar Resolved Incidents (Similarity) | | **Copy resolution** |
| Similar KB Articles (Similarity) | knowledge articles | **Attach KB** |
| Propose Major Incident (Trend) | | **Propose as Major Incident** |
| Similar Major Incident (Trend) | active major incidents | **Link Major incident as Parent** |
| Similar Incidents (TI) | Task Intelligence similarity | |
| Create known error article for high impact Problem | | **Create article** |

Field-level: *Assignment group / Configuration item / Service (Classification)* (Predictive Intelligence; **inactive by default**, activate in the Recommendations list) and *Incident Fields value prediction (TI)*.

Guidances shipped include *[Incident] Attach KB*, *[Incident] Copy resolution*, *[Incident] Link open incident / problem*, *[Interaction] Review and attach article*, the *[Non-ML]* variants (Copy resolution, Create Problem, Link open incident / problem, Create known error article), *[Task] Link change request / incident / outage / problem*, *[Task] Order item*, and display-only ones (*Show Change request / Problem / genius result [No Action]*).

## What the agent sees

- Incident: **Recommendations** icon > sub-tabs **Recommended actions** (cards: act, or **Dismiss**) and **Search** (manual AI Search).
- Incident task, problem, problem task, change, change task, interaction, request: only the AI Search results.
- Field recommendations (advanced only, incident only): after typing **Short description** and **Description**, before SOW 4.2 press Tab and the fields are filled or suggested; from 4.2 the predictions are listed in each field's drop-down.

## Related

- [[Service Operations Workspace for ITSM]] · [[Working Records in Service Operations Workspace]] · [[AI Search Overview]]
