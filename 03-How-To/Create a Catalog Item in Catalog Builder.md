---
type: how-to
tags: [how-to, service-catalog]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Catalog Builder, topics "Creating or editing catalog item template", "Create a catalog item using a template", "Create a question for a catalog item in Catalog Builder", "Edit a catalog item in Catalog Builder", "Transfer catalog items using update sets", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/create-item-cat-builder.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Create a catalog item in Catalog Builder

**Goal:** let a business owner build a catalog item through the guided builder, within limits set by a catalog admin's template.
**Prerequisites:** a catalog item template the user is allowed to use (**Template Available for**); role catalog_builder_editor (or catalog_admin / admin).
**Navigation:** All > Service Catalog > Catalog Builder

## Steps

1. (Catalog admin, once) **Dashboard > Create a catalog item template** > *Standard*: set allowed catalogs and categories, required question sets, allowed question types, portal settings, access, fulfilment flow, and **Overrides** (what may be edited, what must be filled, restricted choices). Submit.
2. (Builder) **Dashboard > Create a new catalog item** > **Continue** > pick the template > **Use this item template**.
3. Choose **Build on your own** (or **Build with ServiceNow Otto**, see [[AI Authoring for Catalog Builder]]) > **Build**.
4. **Details**: name, short description, description.
5. **Location**: catalogs, categories (Service Portal) and topics (Employee Center), within what the template allows.
6. **Questions**: **Insert new question**: type, subtype, **Question label**, **Name** (no spaces), mandatory / hidden / read-only; tabs Annotation, Additional details (source table, filter), Choices, Default value, Auto-populate. Question sets from the template stay.
7. **UI Policy** (and **Client Script** if you are a catalog builder developer).
8. **Settings**, **Access**, **Fulfilment** (pick a flow; add service fulfillment steps if the flow supports them).
9. **Preview** in portal, Now Mobile or Virtual Agent.
10. **Review and submit** > **Submit**.

## Result / how to check it worked

The item moves from Draft to Published and appears in the catalog. A local update set named like `CB_<template>_<item>_<timestamp>` holds it for transfer.

## Example

| Part | Value |
|---|---|
| Template | *Example HR Templates* (catalogs: HR; question set *Example Employee Details* required; allowed types: text, choice, date) |
| Item | *Example Parking Permit*: questions "Car registration" (single-line, mandatory), "Start date" (date); fulfilment: *Step-based request fulfillment* with one Task step for *Example Facilities* |

## Tables / fields involved

- [[sc_cat_item]] (field **Template**, published / draft copies with **Checked out**), [[item_option_new]].

## Other ways to do this

[[Create a Catalog Item with Variables]] (classic form, all options).

## Gotchas

- Editing a published item creates a draft copy; the live item stays unchanged until submit, and cannot be edited in the classic form while checked out.
- Not editable in the builder: price, execution plans, meta tags, attributes, advanced reference qualifiers, permissions, data lookups ([[Catalog Builder]]); use **Edit in advanced view**.
- With a pre-publish review subflow the item waits **In review**; cancel the review to edit again.
- Template changes do not update existing items.
