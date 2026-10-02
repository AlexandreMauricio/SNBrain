---
type: concept
tags: [concept, ai, incident]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Machine learning solutions for IT Service Management" (pp. 2883-2888) and "Task Intelligence for ITSM" (pp. 3761-3787), read in full 2026-10-02. The Virtual Agent, AI specialist and MCP server parts that used to be summarised here now have their own notes
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM Predictive Intelligence and Task Intelligence

**In one line:** two machine-learning layers trained on the instance's own incident history: **Predictive Intelligence** solution definitions (classification and similarity, called from business rules, flows or recommendations) and **Task Intelligence for ITSM**, a no-code console that trains, deploys and monitors field-prediction and similar-record models for incidents.

(The file name still mentions Virtual Agent for link stability; see [[ITSM Virtual Agent Topics and Setup]], [[L1 IT Service Desk AI Specialist]], [[ITSM MCP Server]].)

## Predictive Intelligence for Incident Management

Separate subscription; plugins requested through Now Support (**Request plugin** on the application list).

| Plugin | Gives |
|---|---|
| `com.snc.incident.ml_solution` (with `com.glide.platform_ml`) | classification: *Incident Assignment*, *Incident Categorization*, *Incident Service*, *Incident Configuration Item*, each predicted from **Short description** |
| `com.snc.incident.ml` (activates `com.snc.contextual_search_ml`) | similarity: *Similar Open Incidents*, *Similar Resolved Incidents*, *Similar Closed Incidents*, *Similar Incidents*, *Similar Knowledge Articles* (short description and description) |
| `com.snc.incident.mim.ml_solution` (installs `com.snc.incident.mim` and the first plugin) | *Major Incident Detection* / *Major Incident Recommendation* (similar active major incidents to link to; similar incidents to propose a major incident), *Similar Incidents (Major Incident Workbench)* (similar incidents not yet children) |

The shipped definitions are templates: copy them to customise.

- Business rule *Update Prediction Results* on `incident` (runs when an incident is closed; server-side) updates the precision and coverage statistics of the assignment and categorization solutions.
- The prediction business rule template: in the global domain list the solutions explicitly in the `solutionNames` array; for domain separation follow the commented code; it calls `applyPredictionForSolution()` so a prediction is made even when the field holds its default value.
- Models drift: retrain or redefine them as the business changes.

How the predictions reach agents: [[Recommended Actions for ITSM]].

## Task Intelligence for ITSM

Application `com.snc.itsm_ml_task` (ITSM Pro; Utah patch 5 or later) with the Task Intelligence Admin Console (`com.sn_ti_admin`). Menu **Task Intelligence for ITSM > Setup** and **> Monitoring**.

| Role | Can | Contains |
|---|---|---|
| `sn_itsm_ml_task.ti_admin` | create, edit, deploy, monitor | `sn_incident_read`, `sn_ti_admin.tia_admin` |
| `sn_itsm_ml_task.ti_analyst` | monitoring dashboard | `sn_incident_read`, `sn_ti_admin.tia_analyst` |
| `sn_itsm_ml_task.ti_user` | view-only dashboard | `sn_incident_read`, `sn_ti_admin.tia_user` |

### Models

| Model | Predicts |
|---|---|
| Incident Categorization (card *Predict incident field choices to reduce handle time*) | chosen **Output fields** of the incident from chosen **Input fields** |
| Similar Incidents | incidents similar to the current one |
| Similar open Change Requests for Incident, Similar open Problems for Incident | changes / problems similar to the incident |
| Major Incident Recommendation | major incidents to link to; incidents to propose as major |

The four similarity models are shipped: on a production instance they are **trained on your data and deployed automatically** at install, predicting in the background only (results stored in prediction tables, nothing shown on the form) and already linked to a recommended-action rule. The admin gets an email with the analytics link within about four weeks.

### Wizard

1. **Set up model** from the card.
2. (Similarity) **Define the purpose**: prediction table, and training table Incident, Problem or Change request.
3. **Train**: name; output / prediction table and fields; input / training table and fields; **Conditions** selecting the training records; (similarity) language and update or training frequency. At least **10,000 records** are needed; widen the conditions if the count is lower. **Launch training** (an email can announce the end).
4. **Assess**: estimated number of auto-filled fields, **View sample results**, **Comparison**; then a **Prediction preference** per field:

| Preference | Effect |
|---|---|
| Autofill (categorization only) | writes the best value into the field |
| Recommendations | shows the top values or records; the agent accepts or rejects; the number shown is set in Advanced Recommended Actions |
| Monitor only | runs in the background and stores predictions without touching records: the way to validate against live data |
| Turn off predictions | |

5. **Deploy**, then **Configure Recommended Actions**: map the model into the resource generator's **Model** field and make sure the rule is active.

**Edit Model** (menu on the model): view current results, or retrain with new data or fields, **Compare models results**, **Redeploy** (nothing is saved until redeploy; the new model replaces the old). **Export model** downloads XML to carry to another instance in an update set.

### Monitoring

Per model: number of predictions over time, incident MTTR, predictions agents accepted, replaced, and skipped by the model, a performance table per model and output field, and usage of each field prediction per day (count or percentage, with the training baseline). Falling acceptance or rising replacement means retrain.

Tables are named `sn_ti_admin_*`: template, solution, model (snapshot of production and staging configuration), model_prediction, feature, statistic, statistic_card, help, page, tag, implementation_detail, context, application_page.

## Related

- [[Recommended Actions for ITSM]] · [[Otto for ITSM Skills and Agentic Workflows]] · [[Change Risk Calculation and Assessment]] · [[Incident Management Overview and Lifecycle]]
