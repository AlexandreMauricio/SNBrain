---
type: concept
tags: [concept, service-catalog, workspace]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Creating a Service Catalog Wizard", "Create declarative actions for Service Catalog Wizards", "Catalog Wizard form", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/catalog-wizard.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Service Catalog wizards

**In one line:** a catalog wizard is a multi-step, guided form (a UI Builder component) on top of a record producer or composite record producer, for long inputs such as a visa application; Catalog Builder itself is built this way.

## Requirements

- A record producer or **composite record producer** whose **Save options** = *Save in destination* and **Allow edit** ticked.
- Role `wizard_admin` or admin.

## Wizard record

**Service Catalog Wizards > Maintain Wizards > New**: **Name**, **Type** (composite record producer or record producer), **Producer**, **Has feedback panel**, **Layout** (Stacked or Tabbed), **Title** (can use `${variable}`), **Enable Save** (auto-save on step change), **Show review step** and **Review step label**, **Show Submit on last step**.

Structure: **Steps** (`Catalog Wizard Step`: name, order, short description, **Hide on template**, **Custom step** with a macroponent, **Feedback** / **Template feedback**), **Sections** inside steps (style, order, width), **Questions** inside sections (a variable or a question set, order).

## Modes

- **Normal**: create or edit records in the producer's table.
- **Template**: admins predefine data and guard rails used later when creating records (optionally mandatory).

## On a page (UI Builder component properties)

**Select Wizard**, **Wizard mode**, **Field space** (Small to Extra Large), **Sys_id of the record** (record, or template in Template mode), **Select template**, **Make template mandatory**, **Home button icon**, **Hide home button**, hide Back / Forward buttons, **Step navigator forward button type** (Primary or Secondary). See [[UI Builder Overview and Concepts]].

## Buttons (declarative actions)

1. Create the action from **Service Catalog Wizards > Catalog Wizard Declarative Actions** (this path presets the model). Model **Catalog Wizard** gives payload and condition fields: Current Step Order, Target Table, Record Producer, Wizard Id, Enable Save, Variables, Is New Record, Template Id, Has Review Step, Is Last Step, Form Dirty, Submitting, Mode, Record Id.
2. **Implemented as** *UXF Client Action* (handled by a page event handler: open a dialog or another wizard; map it with **Configure declarative actions event mappings** in UI Builder) or *Client Script* (works with `g_form` on the producer's linked variables). Button label, tooltip, type, order, grouping (split button), **Scripted client conditions** such as `mode=='template'`.
3. **Catalog Wizard Actions Configurations > New**: link the action, **Applies to** (Normal, Template, All), **Global** (all wizards; Save and Submit are global by default), **Overflow**, **Force Save**, label and type overrides.
4. On the wizard, related list **Wizard Actions Configurations**: map configurations; **Hide action** hides a global one for this wizard.

## Notes

- Catalog client scripts and UI policies work for items inside a wizard.
- Orders placed from a wizard use two-step checkout (`glide.expert.checkout.twostep`).
- Wizard launchers (`sc_cat_item_wizard`) are excluded from cart, Try It and requests by default, and open as a window in Virtual Agent.

## Related

- [[Record Producers]] · [[Catalog Builder]] · [[Service Catalog Overview, Item Types and Roles]]
