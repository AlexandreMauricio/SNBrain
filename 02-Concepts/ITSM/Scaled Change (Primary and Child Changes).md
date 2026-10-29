---
type: concept
tags: [concept, change, automation, schema]
status: documented
source: ServiceNow Brazil ITSM docs, Change Management > Scaled change (overview, Configure a Primary change model, Configure a Child change model, Create a scaled change flow, Components installed with Scaled Change), read 2026-10-29. https://www.servicenow.com/docs/r/it-service-management/change-management/scaled-change-overview.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Scaled Change (Primary and Child Changes)

**In one line:** with the **Major Change** plugin (`com.sn_major_change`), one **Primary change** listing many affected CIs generates one **Child change** per CI when it reaches a chosen state, so each CI's implementation is tracked separately (20 affected CIs = 20 child changes).

From the Brazil docs; not in the Australia PDF; not tested. Built on change models ([[Change Models and Change Templates]]) and a Workflow Studio flow.

## Set up (`sn_change_write` or `itil`)

1. **Primary change model**: **Change > Administration > Change Models** > the model > open the trigger state (e.g. Assess) > **Attributes** tab > add **Allow Child Change Creation** (Active). Without it nothing is generated.
2. **Child change model**: an ordinary model with the states child changes need.
3. **Flow** (Workflow Studio): trigger on Change Request (`change_request`) updated, condition *Model is <your primary model> and State is Assess*, run *Only if not currently running*; action **Child change requests creation** with the child model as input; end the flow if the action says the request was not processed; **Wait For Condition** until *Child changes creation status* is Completed or Completed with errors; then **Evaluate Change Model** to move the primary on.

Each child copies from the primary: category, description, justification, implementation plan, risk and impact analysis, backout plan, test plan, software model; its own CI is the affected CI. On children, **Configuration item** and **Model** are read only.

## Fields and records

| Field / record | Meaning |
|---|---|
| `child_changes_creation_status` (on the primary) | `in_progress`, `completed`, `completed_with_errors`; always empty on children |
| `primary_change` (on the child) | reference to the primary; not on the form (view the XML); add the related list driven by it to the primary's form to see the children |
| Change Management Worker (`chg_mgt_worker`, type *Child change requests creation*) | one per batch of CIs; children are created asynchronously in batches |

## Properties (`sys_properties.list`, filter `sn_major_change`)

| Property | Meaning |
|---|---|
| `sn_major_change.affected_ci_threshold` | maximum affected CIs on a primary before enforcement applies |
| `sn_major_change.threshold_enforcement_mode` | `warning` (log and continue) or `blocking` (log and stop); missing or other values fall back to warning |
| `sn_major_change.child_change_generation_batch_size` | CIs per generation batch |

Defaults were not shown on the page. A data archive rule archives a child change six months after its primary becomes inactive.

## Example

Primary model *Example Patch Wave* with **Allow Child Change Creation** on Assess, child model *Example Patch Item*, flow *Example Generate Patch Children*; a change for 12 servers yields 12 child changes when it reaches Assess.

## Related

- [[Change Management Overview and Lifecycle]] · [[change_request]] · [[Change Conflict Detection and Maintenance Schedules]]
