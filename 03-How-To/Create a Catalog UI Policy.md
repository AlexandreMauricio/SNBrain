---
type: how-to
tags: [how-to, service-catalog, ui-policy]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Debugging Service Catalog, topics "Service catalog UI policy", "Create a UI policy for catalog items", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/t_CreatUIPolicyForSvcCalgIt.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Create a catalog UI policy

**Goal:** make catalog variables mandatory, visible, read-only, set or cleared depending on other answers, without code.
**Prerequisites:** role admin; named variables on the item or variable set.
**Navigation:** All > Service Catalog > Catalog Administration > Catalog UI Policies

## Steps

1. **New**. **Applies to**: *A Catalog Item* (or *A Variable Set*), then pick it.
2. **Short description**, **Active**, **Order**.
3. **Catalog Conditions** on the item's variables (set variables show as `set » variable`).
4. Choose where it runs: **Applies on a Catalog Item view** (order form), **Applies on Requested Items**, **Applies on Catalog Tasks**, **Applies on the Target Record** (records from record producers).
5. **On load** and **Reverse if false** as needed.
6. Save, then **Catalog UI Policy Actions** > **New** per variable (or whole set): **Mandatory**, **Visible**, **Read Only** (Leave alone / True / False), **Value action** (Set value with **Value**, or Clear value), optional **Field message type** and **Field message**.
7. Only if needed: **Run scripts** with Execute if true / false (for things the actions cannot do, such as role checks).
8. **Try It** on the item.

## Result / how to check it worked

Changing the condition variable shows the effect at once; with Reverse if false it undoes itself. Use the Variable Action Logger if not ([[Debugging Service Catalog Items]]).

## Example

| Part | Value |
|---|---|
| Item | Example Office Move |
| Condition | `move_reason` is *Other* |
| Action | `other_reason`: Visible true, Mandatory true |
| Applies on | catalog item view and requested items |

## Tables / fields involved

- Catalog UI policy and action tables (names not given by the docs); variables in [[item_option_new]].

## Other ways to do this

A catalog client script for logic the condition builder cannot express: [[UI Policy or Client Script]], [[Catalog Client Scripts, UI Policies and Variable Editors]]. In Catalog Builder: the item's **UI Policy** step.

## Gotchas

- Mandatory beats hidden and read-only: an empty mandatory variable stays visible.
- Set value does not work on Attachment and Masked variables; Clear value does not work on sets and containers; on an MRVS only whole-set actions.
- Item policies run before set policies unless `glide.sc.ui_policy.variable_set_run_first` is true.
- Policies with scripts or several actions do not show as question behaviours in Catalog Builder.
