---
type: how-to
tags: [how-to, service-catalog, request]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Create an order guide", "Create an order guide rule to add a catalog item", "Create an order guide variable", "Cascade an order guide variable", "Create an item variable assignment", "Order guide form", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/t_CreateAnOrderGuide.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Create an order guide

**Goal:** one form that orders several catalog items together, choosing them from the requester's answers.
**Prerequisites:** role catalog_admin or admin; the catalog items to include already exist.
**Navigation:** All > Service Catalog > Catalog Definition > Order Guides

## Steps

1. **New**: **Name**, **Category**, **Short description**, **Description**. Tick **Cascade variables** if answers should flow to the items. Leave **Two step** off for the normal three-step guide.
2. Save (form header context menu > **Save**).
3. **Variables** related list: create the Describe Needs questions, or attach a variable set that the items also use (best for cascading: same names on guide and items).
4. **Rule base** related list > **New** per item: **If this condition is true** (on guide variables, Requested For...), **Include this item**, optional **Show quantity** / **Quantity**, **Ignore Mandatory Evaluation**.
5. Optional, on a rule: **Item Variable Assignments** > **New** to force an item variable to a **Value** or to an **Order Guide Variable**.
6. Optional: **Generate sequence** to order fulfilment through Playbooks (plugin `com.glideapp.servicecatalog.order_guide_sequencing`).
7. Test with **Try It** or from the portal.

## Result / how to check it worked

Describe Needs shows the guide's questions; Choose Options lists only the items whose rules matched, pre-filled with cascaded values; checkout makes one REQ with one RITM per item, each showing the guide in **Order Guide**.

## Example

| Part | Value |
|---|---|
| Guide | Example New Starter |
| Variables (variable set *Example Starter Details*) | `department` (reference to Department), `job_role` (select box: staff, manager) |
| Rule 1 | always: include *Example Laptop* |
| Rule 2 | `job_role` is manager: include *Example Mobile Phone* |
| Item variable assignment | on rule 1, laptop `ram` = 16 when the rule fires |

## Tables / fields involved

- `sc_cat_item_guide` (guide), rule base records (table not named in the docs), [[item_option_new]] (variables), `sc_req_item` **Order Guide** field.

## Other ways to do this

Run the guide from a script or workflow with `SNC.ScriptableOrderGuide` ([[Order Guides]]).

## Gotchas

- Order guide variables carry no price.
- Mandatory fields block tab switching unless `glide.sc.guide.tab.validate` is false.
- Requested For cascades always and becomes read-only on the items.
- Inactive items are silently left out; record producers can be included too.
