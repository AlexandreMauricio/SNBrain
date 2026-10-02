---
type: how-to
tags: [how-to, fields, forms-lists, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Define field styles" (pp. 812-813), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Define a field style

**Goal:** colour or format a field in lists or forms when it has a given value or meets a scripted condition.
**Prerequisites:** role `personalize_styles` or admin.
**Navigation:** right-click the field label, Configure Styles; or All > System UI > Field Styles

## Steps

1. Right-click the field label and select **Configure Styles** (admins can also use **System UI > Field Styles**).
2. Select **New**.
3. Set **Table** and **Field name**.
4. In **Value**, enter the exact value that triggers the style, or `javascript:` plus a condition using `current`. **Leave it empty to style the field on forms; give a value to style it in lists.**
5. In **Style**, enter the CSS.
6. Submit.

## Result / how to check it worked

Open the list (or form): matching cells show the style.

## Example

Overdue items in red in a list, on a custom date field:

- Value: `javascript:gs.dateDiff(gs.now(), current.u_example_date.getDisplayValue(), true) < 0`
- Style: `background-color:red; color:white;`

## Tables / fields involved

- the styled table and field

## Gotchas

- Only **one** `javascript:` entry per Value. Combine conditions with `&&` in a single statement.
- **Not supported in workspaces** (use highlighted values there: [[Field Administration]]).
- Not applied to comments and work notes in the activity formatter (use the `glide.ui.activity_stream.style.*` properties).
- Styles on a table do not apply to database views that include it; define them on the view.
- Add alternative text (configure the form to show the field) for icon-like styles so screen readers can announce them.
