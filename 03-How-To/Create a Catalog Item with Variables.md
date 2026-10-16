---
type: how-to
tags: [how-to, service-catalog]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Create or edit a catalog item", "Create a service catalog variable", "Define a question choice for a variable", "Define help information for a service catalog variable", "Add a catalog item", "Catalog Item form", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/t_DefineACatalogItem.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Create a catalog item with variables

**Goal:** publish an orderable item with its own questions and a fulfilment flow.
**Prerequisites:** role admin or catalog_admin; a catalog and category; a fulfilment flow (or workflow) for RITMs.
**Navigation:** All > Service Catalog > Catalog Definitions > Maintain Items

## Steps

1. Select **New**. Fill **Name**, **Catalogs**, then **Category** (a category is needed to be found in portal search), **Short Description**, **Description**, **Meta** (search keywords).
2. **Process Engine** tab: choose the **Flow** (or **Workflow** / **Execution plan**; only one).
3. Optional: **Pricing**, **Portal Settings** (Request method, hide cart, quantity, attachments), **Access Type**.
4. **Submit**, then reopen the item.
5. In the **Variables** related list select **New** for each question: **Type**, **Question**, **Name** (keep it, scripts and policies need it), **Order** (100, 200...), **Mandatory**. For choice types add **Question Choices** (**Text**, **Value**, optional **Price**). For a reference set the table under **Type Specifications**. Optional **Annotation** > **Show help** with **Help text** or **Instructions**.
6. Reuse common questions with the **Variable Sets** related list ([[Create a Variable Set]]).
7. Restrict who sees it with **Available For** / **Not Available For** ([[Create and Apply a User Criteria Record]]).
8. Add more catalogs or categories in the **Catalogs** / **Categories** related lists if needed.
9. **Try It** to test the form, then order it once.

## Result / how to check it worked

The item appears in its category (portal and Core UI). Ordering it creates a REQ with one RITM; the RITM's variable editor shows the answers and the flow starts (check the flow execution).

## Example

| Field | Value |
|---|---|
| Name | Example Monitor |
| Catalog / Category | Service Catalog / Example Hardware |
| Flow | Example Hardware Fulfilment |
| Variable 1 | Select Box, question "Screen size", name `screen_size`, choices 24 = 24 inch, 27 = 27 inch (price +50) |
| Variable 2 | Multi-Line Text, question "Business justification", name `business_justification`, mandatory |
| Available For | user criteria *Example Employees* |

## Tables / fields involved

- [[sc_cat_item]]: the item. [[item_option_new]]: its variables. `question_choice`: choices (table name from general knowledge, not this chapter).
- Ordering writes [[task]]-based `sc_request`, `sc_req_item` and the answers in `sc_item_option` ([[Request Management Data Model and Process]]).

## Other ways to do this

[[Create a Catalog Item in Catalog Builder]] (guided, from a template); Fluent API `CatalogItem` in code ([[Fluent API - Service Catalog, SLA, Service Portal and Workspace]]).

## Gotchas

- **Copy** duplicates variables, scripts and approvals; **Insert** copies only the item record. A copy of an active item is active.
- Changing choices also affects existing RITMs.
- Catalog items and variables are captured in update sets; keep variable names unique across the item and its sets.
