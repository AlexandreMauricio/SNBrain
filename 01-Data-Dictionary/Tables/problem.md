---
type: table
tags: [table, problem, task, schema]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Problem Management", topics "Problem form", "Legacy Problem form", "Map problem states", "Data lookup for prioritizing problems", "Problem management properties" (pp. 3015, 3078-3091), read 2026-10-02. Column names not printed in the guide are marked ?
sn-release: Australia
verified:
updated: 2026-10-02
---

# problem

**Label:** Problem
**Extends:** [[task]]
**Purpose:** one row per problem: the underlying cause of one or more incidents, worked through root cause analysis to a fix or an accepted risk.

## Own columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Origin task | `first_reported_by_task` `?` | reference `task` | the task that first identified the problem |
| Category / Subcategory | `category` / `subcategory` | choice | |
| Problem statement | `short_description` (on task) | string | relabelled; drives related search |
| Resolution code | `resolution_code` `?` | choice | Fix Applied, Risk Accepted, Duplicate, Canceled |
| Duplicate of | `duplicate_of` `?` | reference `problem` | when resolution code is Duplicate |
| Workaround | `workaround` `?` | | Analysis Information; sent with **Communicate Workaround** |
| Cause notes | `cause_notes` `?` | | |
| Fix notes | `fix_notes` `?` | | Resolution Information; sent with **Communicate Fix** |
| Risk accepted reason | `?` | | copied to incidents' work notes |
| Resolved by / Resolved | `resolved_by` `?` / `resolved_at` `?` | | read-only |
| Confirmed by / Confirmed | `?` | | who confirmed at Assess |
| Fix by / Fix | `?` | | who started the fix |
| Primary Known Error article | `?` | reference knowledge | Knowledge Integration plugin |
| Major problem | `major_problem` `?` | boolean | makes work notes mandatory; adds **Major problem review** |
| Problem model | `?` | reference `prb_model` | when models are enabled |
| Known error, Knowledge, Change request | `known_error`, `knowledge`, `rfc` | | legacy form (London and earlier) |

Inherited and used: **Service** (`business_service`), **Service offering**, **Configuration item** (`cmdb_ci`), **Impact**, **Urgency**, **Priority**, **Assignment group**, **Assigned to**, **Work notes**.

Reverse references named in properties: `incident.problem_id`, `problem_task.problem`, `change_request.parent`, `sn_customerservice_case.problem`.

## State values

Best-practice state model (new instances since Madrid). Values confirmed by the migration mapping table are marked ✔; the others are inferred from the sequence.

| Value | Label |
|---|---|
| 101 ✔ | New |
| 102 `?` | Assess |
| 103 `?` | Root Cause Analysis |
| 104 ✔ | Fix in Progress |
| 106 `?` | Resolved |
| 107 ✔ | Closed |

Legacy states: 1 Open, 2 Known Error, 3 Pending Change, 4 Closed/Resolved.

## Priority lookup

Table `dl_problem_priority`. Same matrix as incident except Impact 3 / Urgency 3 = **5 Planning**.

## Related tables

- [[problem_task]] · `prb_model`, `prb_task_model` (models) · `kb_template_known_error_article` (known error articles) · `task_ci`, `task_cmdb_ci_service`, `task_service_offering`

## Used in

- [[Problem Management Overview and Lifecycle]]
