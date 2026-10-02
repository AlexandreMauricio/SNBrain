---
type: how-to
tags: [how-to, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "List administration", topics "Configure the list layout", "Configure list calculations", "Configure list controls" (pp. 998-1003), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Configure a list layout and list control

**Goal:** change the columns of a list for everyone, add totals, and control its buttons and filters.
**Prerequisites:** roles `personalize_list` (layout, calculations) and `personalize_control` (list control).
**Navigation:** right-click a column header in the list, Configure

## Steps

1. Open the list and select the view to change (list controls menu, **View**).
2. **Columns**: right-click a header, **Configure > List Layout**; move and order fields; **Save**.
3. **Calculations**: right-click a numeric column header, **Configure > List Calculations**; tick Total, Minimum, Maximum, Average; **OK**.
4. **Controls**: right-click a header, **Configure > List Control**; set the options (label, omit buttons, roles, list edit type); **Submit** or **Update**.

For a related list, do step 4 from the related list's own header on the parent form.

## Result / how to check it worked

Reload the list. Calculations appear under the last row (and under each group when grouped).

## Example

On the Problem form's Incidents related list: **Label** = *Child Incidents*, **Omit new button** ticked. The list is retitled and **New** is gone.

## Tables / fields involved

- `sys_ui_list` (Lists): list layouts, including personal ones
- the list control record for the table or related list

## Gotchas

- Keep a non-reference field such as Number first: it becomes the link to the record.
- Users with a personal list do not see layout changes until they reset to column defaults.
- For conditional behaviour use the scripted *Omit ... Condition* fields ([[List Configuration and List Controls]]).
- Disabling list editing here is often needed where client scripts guard the form ([[List Editor]]).
