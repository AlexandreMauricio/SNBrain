---
type: concept
tags: [concept, change, service-catalog]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topic "Standard change catalog" and subtopics, "Create a standard change request from the catalog" (pp. 589-596, 667), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Standard change catalog

**In one line:** pre-approved, low-risk changes are published as templates in a catalog; requesting one creates a standard change that skips Assess and Authorize.

Plugin `com.snc.change_management.standard_change_catalog`.

## Lifecycle of a template

| Step | Where | Who |
|---|---|---|
| Propose | **Change > Standard Change > Standard Change Catalog > Template Management > Propose a new Standard Change Template**, or context menu **Propose a Standard Change Template** on an existing change (copies its fields and tasks) | itil |
| Add task templates | **Change Task Templates** related list, only while the proposal is New: **Name**, **Order**, **Change Task values** | itil, `sn_change_write` |
| **Request Approval** | proposal New → In Progress; approvals go to the Change Management group (flow *Change - Standard - Proposal*) | |
| Approved | template published in the catalog category; rejected → back to New | `change_manager` |
| **Modify Template** / **Retire Template** (related links on **All Templates**) | creates a proposal; approval gives a new **version**, used by changes created afterwards | |

Proposal fields: **Short description**, **Category**, **Sample Change Requests** (evidence of past success), **Change Request values**. Attachments on the proposal are copied to the template and to every change created from it.

## Properties form

**Change > Administration > Standard Change Properties**

| Field | Effect |
|---|---|
| **Catalog**, **Category** | where templates are published |
| **Two step** | selecting a template opens the change for review; **Submit** inserts it (default on since Jakarta) |
| **Mandatory Change Request values** | fields a proposal must set |
| **Default Change Request values** | |
| **Restricted Change Request values** | fields a proposal may not set (include the sys fields) |
| **Read-only fields** | fields locked on the resulting change |
| **Fields to copy** | copied when proposing from an existing change |
| Same five settings for **Change Task** | |

## Requesting

**Change > Standard Change > Standard Change Catalog**, pick a category (shipped: Network Standard Changes, Server Standard Changes) and a template; complete CI and assignment; save. Category visibility follows user criteria.

## Gotchas

- Not supported on Service Portal.
- A standard change cannot be copied, and cannot use Mass Update CI.
- Predictive Intelligence can suggest candidates (plugin `com.snc.change_management.ml.sctp`, table `std_change_template_candidate`, job *Update Standard Change Cluster Candidates*).

## Related

- [[Change Management Overview and Lifecycle]] · [[Change Models and Change Templates]]
