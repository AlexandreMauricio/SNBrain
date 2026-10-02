---
type: reference
tags: [reference, cmdb, sla, service-catalog]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Portfolio Management", topics "Service Portfolio Management taxonomy", "Create taxonomy nodes", "Create a service", "Apply scope to a service", "Edit and manage service portfolios", "Service offerings" and subtopics, "Log outages", "View availability results", "Set the time zone for availability results", "Convert services in bulk", "View SLA results", "Installed with Service Portfolio Management" (pp. 3724-3760); "Service Builder" (pp. 3126-3136), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Service offerings, commitments and availability

**What it is:** the form-level detail behind [[Service Portfolio Management]]: taxonomy nodes, service and offering fields, commitments, outages and how availability figures are calculated.

## Taxonomy

- **Standard structure**: portfolio → nodes (any depth, node-to-node) → services (only on the lowest, leaf node) → offerings.
- **Legacy structure**: portfolio → ordered **taxonomy layers** (`spm_taxonomy_layer_definition`, **Order** 100, 200...; locked once a node exists; no gaps allowed) → nodes → services.
- **Taxonomy node** (`spm_taxonomy_node`): **Service portfolio**, **Parent** (reparent at the same level), **Owned by**, **Valid from / to**, CSDM **Lifecycle stage** (Ideation, Operational, End of Life) and **Lifecycle stage status**, **Active** (shown in the DPM workspace or not).
- Moving a branch: change **Service portfolio** on the node; its child nodes, services and offerings move with it. KPI "latest score" data takes a day to follow.

## Service form

Header: **Service portfolio**, **Taxonomy node**, **Phase** (Pipeline, Catalog, Retired), **Status**, **Owned by**, **Delivery manager**, **Business relation manager**. General: **Number** (prefix BSN; empty on records older than the field), **Version**, **Aliases**, **Service classification** (Business Service, Technical Service, Application Service), **Consumer type** (Internal, External, both), **Start date**, **End date**, **Last review date**. Team: **Delegate**, **Business contact**, **Vendor**, **Stakeholders**. Business Need: **Business need**, **Business criticality** (1 most critical to 4 not critical).

Related lists: Offerings, In Scope, Out of Scope (`service_in_scope`, `service_out_scope`; only a parent service has scope; shown on the catalog page), Services I depend On, Services Dependent On Me, Incidents, Problems, Change Requests, Knowledge Articles, Improvement Initiatives.

On new instances the label Business Service was changed to **Service**.

## Service offering form

- Inherited from the parent service on first insert (overwriting what was typed): **Owned by**, **Business criticality**, **Delivery Manager**, **Delegate**.
- Read-only from the parent: **Price model**, **Price unit**. The offering sets **Price** and **Unit Description**.
- Operations: **Contract**, **Maintenance schedule**, **Service level requirement**, **Prerequisites**, **Compatibility dependencies**, **Monitoring requirements**.
- **Total Subscribers** is calculated nightly. **CSAT Survey Frequency** / **Last Sent**.
- **Support group** on the Team tab plus the **Teams** related list (`cmdb_rel_team`): several groups per offering with **Group type** (Support Group, Approver Group, Change Group, Managed By Group) and **Primary**.
- Related lists **All Incidents / All Problems / All Changes** collect tasks where the offering is in the **Service offering** field, in Affected CIs or in Impacted Services. SLA breach reporting for an offering is triggered by any of the three.
- **Items orderable by subscribers**: relate or create catalog items; notifications *Offering retired* and *Catalog Item created from Offering* alert catalog admins.
- Subscriptions (by user, group, department, location, company) decide who may order the related catalog items.
- Reparenting an offering between a business and a technology management service is allowed (not to an application service); blocked if it is the only offering of a service in Catalog phase.
- A draft checked out in Service Builder shows as `[DRAFT]`; the published copy shows a red dot (read-only).

## Commitments

Types and behaviour are in [[Service Portfolio Management]]. Extra fields: **Contract** (the incident's Contract field then needs reference qualifier `contractFilter`), and with vendor ticketing **Breach penalty amount**, **Per**, **Breach penalty time**, **Time amount** (for RTO / RPO).

## Outages

**Service Portfolio Management > Outages** (`cmdb_ci_outage`): **Type** = *Outage* (unplanned; the only type that reduces availability), *Planned Outage*, *Degradation*; **Begin**, **End** or **Duration**. An outage on a service adds all child offerings to its **Affected CIs**; **Refresh affected service offerings** recomputes the list. Outage numbers need plugin `com.snc.outage_numbering`. Unplanned outage time overlapping a planned outage is not counted.

## Availability record (`service_availability`)

| Field | Calculation |
|---|---|
| Committed uptime | period end − period start |
| Acceptable downtime | scheduled period × commitment percentage |
| Total downtime | outage end − outage start (wall clock) |
| Total availability % | (available uptime − total downtime) / available uptime |
| Commitment downtime / outages | downtime and count inside the commitment's schedule |
| Commitment availability % | (committed uptime − commitment downtime) / committed uptime |
| Met commitment | commitment availability % above the commitment |
| MTBF | (committed uptime − commitment downtime) / commitment outages |
| MTRS | commitment downtime / commitment outages |

Periods with calculator v2 (`com.snc.availability.v2`; default on new instances): Daily, Weekly, Monthly, Annually, Last 7 Days, Last 30 Days, Last 12 Months. Records older than three years are archived by the table cleaner. For application services, link a commitment through `service_offering_commitment.cmdb_ci` on `cmdb_ci_service_auto`. Time zone: `spm.availability.global.tz`, or per commitment with `spm.availability.commitment.tz`; **Recalculate results** on the availability list applies a change.

## SLA results

**Service Portfolio Management > Service Level Management > SLA Results**: per offering, commitment and interval: **Required SLA percentage**, **Total tasks**, **Breached**, **Achieved**, **Total achieved %**. Daily job.

## Roles (containment)

`portfolio_admin` ⊃ `portfolio_editor`, `service_admin`, `sla_manager`; `portfolio_editor` ⊃ `service_editor`, `portfolio_viewer`, `sla_manager`; `service_admin` ⊃ `service_author` ⊃ `service_editor` ⊃ `service_viewer` ⊃ `cmdb_read`.

## Service Builder details

Owners need `service_author`, delegates `service_editor`. Wizard tabs for a service: Details (name, consumer type, portfolio, node, lifecycle, description, business criticality, business need), Team (owned by, managed by, delegate, delivery manager, business relationship manager, business contact, vendor, department, company, stakeholders), Additional Details, Service Performance (KPI group), Manage Offerings, Review and Submit. Offering tabs: Details, Team (support group, change group), Operations (subscribers, commitments, contracts, catalog items, offerings and service instances depended on), Financials (price model Fixed or Per unit; cost model and estimated spend with the financial plugins), Offering performance. Drafts are inactive and invisible to search; submitting merges the draft into the published record. Approval subflow: *Service Builder publish*.

## Related

- [[Service Portfolio Management]] · [[Task Outages]] · [[SLA Definitions and Task SLAs]]
