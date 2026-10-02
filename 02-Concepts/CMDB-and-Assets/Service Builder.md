---
type: concept
tags: [concept, cmdb, service-catalog, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Builder" (pp. 3126-3137), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Service Builder

**In one line:** Service Builder (`sn_service_builder`) is a guided editor for defining business and technology management services and their service offerings, with draft / approval / publish versioning on top of the Service Portfolio Management data.

Menu **Service Portfolio Management > Service Builder**. Home tabs: **Dashboard** (create a business or technical service; recently touched services) and **Services** (all, with state, classification, phase, status, owner). The data model is in [[Service Portfolio Management]] and [[Service Offerings, Commitments and Availability]].

## Roles

| Role | Can |
|---|---|
| `service_admin` | create services; edit any service |
| `service_author` | create services; edit own. Required for whoever is **Owned by** |
| `service_editor` | edit services they own or are **Delegate** of; cannot create |
| `portfolio_admin`, `portfolio_editor` | also create services |

Whoever can edit a service can edit its child offerings.

## Versioning and approval

| State | Meaning |
|---|---|
| Draft | new and not yet submitted, or the working copy of a checked-out published item. Always inactive, hidden from search; the only editable state. Shown with *[DRAFT]* before the name |
| Awaiting approval | submitted; process and portfolio owners review naming, descriptions, commitments, KPIs and duplicates |
| Published | the version in use |

- Editing a published item checks it out: a draft copy of it and its related records (offerings, subscribers) is created; the published one stays live with **Checked out** = true and is read-only. On submit and approval the draft is merged into the published record and deleted.
- An offering is published through its parent service: checking out an offering checks out the parent too, the sibling offerings stay Published.
- By default the subflow *Service Builder publish* (Workflow Studio) **approves automatically**; add an *Ask for Approval* action there to require a real approval (available from Utah).

## Steps for a service

1. **Details**: **Service name** (technology-agnostic), **Consumer type**, **Portfolio** and **Node** (only the lowest taxonomy level takes services), lifecycle (CSDM stage and status fields if `com.snc.cmdb.csdm.activation` is installed, otherwise the legacy phase and status), **Description**, **Business criticality** (1 most critical to 4 not critical), **Business need**.
2. **Team**: **Owned by**, **Managed by**, **Delegate**, **Delivery manager**, **Business relationship manager**, **Business contact**, **Vendor**, **Department**, **Company**, **Stakeholders**.
3. **Additional Details**, then **Service Performance**: a KPI group.
4. **Manage Offerings**: at least one offering is required to publish.
5. **Review and Submit**.

## Steps for a service offering

1. **Details**: **Offering name**, **Consumer type** (Internal, External, Internal and External), **Business criticality**, lifecycle, **Description**, **Prerequisites**.
2. **Team**: owner, delegate, delivery manager, **Support group** (usually level 2), **Change group**, vendor, company, stakeholders. These two groups drive default assignment on tasks (see [[Working Records in Service Operations Workspace]]).
3. **Operations**: subscribers (**Selected groups**, **departments**, **locations**, **users**, **companies**), **Selected commitments**, **Service level requirements**, **Active contract**, **Additional contracts**, **Selected catalog items**, **Offerings I depend on**, **Service instance I depend on** (business services).
4. **Financials**: **Price model** (Per Unit → **Price unit**, **Unit description**; Fixed → **Price**). With the financial plugins (`com.snc.financial_management_for_spm`, `com.snc.spm.spend`; ITSM Pro): **Cost model** (Fixed → **Offering cost** per **Time period**; Per unit → **Cost Unit** × **Units per period**), giving **Estimated spend**.
5. **Offering Performance**: a KPI group.

Services and offerings can be duplicated as a starting point.

## A general rule stated just before this chapter

Script includes whose names end in `SNC` are read-only base versions: never edit them, and do not override methods that start with an underscore (private). Customise by overriding functions in the non-SNC script include that extends it, for example `ChangeProcess` extending `ChangeProcessSNC` (server-side script includes). That keeps upgrades delivering fixes to the SNC version.

## Related

- [[Service Portfolio Management]] · [[Service Offerings, Commitments and Availability]]
