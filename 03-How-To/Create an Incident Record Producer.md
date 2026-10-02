---
type: how-to
tags: [how-to, incident, service-catalog]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topics "Incident templates and record producers", "Create incident template", "Create a module that uses incident template", "Create a record producer to log incidents", "Create a record producer using a template" (pp. 2439-2443), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Create an incident record producer

**Goal:** give end users a catalog form that creates a pre-classified incident.
**Prerequisites:** role `catalog_admin` or admin. Optional: an incident template.
**Navigation:** All > Service Catalog > Catalog Definitions > Record Producers

## Steps

1. Select **New**. **Name**, **Table name** = Incident (`incident`), **Short description**, **Description**.
2. On **Accessibility**: **Catalogs** and **Category** (for example *Can We Help You?*).
3. Save (context menu). Related lists **Variables** and **Variable Sets** appear.
4. **Variables > New** for each question: **Type**, **Question**, **Name**; for a reference, the table under **Type Specifications**.
5. Optional: under **Generated Record Data** choose a **template** to set hidden fields (category, assignment group, impact...).
6. **Try It** to test.

## Result / how to check it worked

The item appears in the catalog. Submitting creates an incident with the caller set to the user, variables mapped to fields with the same name, and the template's values applied.

## Example

| Field | Value |
|---|---|
| Name | Example router reset |
| Table name | Incident |
| Variable | Reference, question "Which router?", name `cmdb_ci`, reference table `cmdb_ci_ip_router` |
| Template | *Example network incident*: Category = Network, Impact = 2, Urgency = 3, Assignment group = Example Network Team |

A module can open a blank incident with a template directly: module **Link type** *URL (from Arguments)*, **Arguments** `incident.do?sys_id=-1&sysparm_template=<template name>`.

## Tables / fields involved

- `sc_cat_item_producer` (record producers), `item_option_new` (variables), `sys_template` (templates), [[incident]]

## Gotchas

- Template values are **static**: no reference to other fields; use a script for that.
- Template visibility: **Global**, or the named **User** / **Group**; with none of them only the creator sees it.
- To link a request created from an incident back to it, the producer script needs `new LinkRecordProducerToIncident().linkRecordProducerToParentIncident(RP.getParameterValue('sysparm_req_parent'), current);` (server-side record producer script).
- Background: [[Incident Management Overview and Lifecycle]] · [[Form Templates]].
