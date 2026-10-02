---
type: how-to
tags: [how-to, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topic "Configuring the form layout" (pp. 741-750), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Configure a form layout

**Goal:** change, for all users of a view, which fields, sections, annotations, lists and charts a form shows.
**Prerequisites:** role `personalize_form` (`form_admin` to create sections, admin to move splits).
**Navigation:** open a record, form context menu, Configure > Form Layout (or Related Lists)

## Steps

1. Open a record of the table, in the view you want to change.
2. Form context menu, **Configure > Form Layout**.
3. **Fields**: move them between **Available** and **Selected**, and order them with the arrows.
4. **New section**: under **Form view and section**, choose **New...** in **Section**, enter the caption, **OK**. Order sections with the arrows, then add fields to the section.
5. **Annotation**: move `* Annotation` to Selected, place it above the field it explains, choose the type and Plain Text or HTML, and type the text.
6. **Embedded list**: move one of the lists (red, at the bottom of Available) to Selected and position it.
7. **Chart**: move `* Chart` to Selected, give it a label, save, then **Configure chart** on the form and select the report.
8. **Splits**: move the `|- begin_split -|`, `|- split -|` and `|- end_split -|` markers.
9. **Save**.
10. For related lists: **Configure > Related Lists**, move lists from Available to Selected, **Save**.

## Result / how to check it worked

Reload the form in that view: the changes show for every user of the view.

## Example

On the Incident form default view, add a section *Example Vendor Details* with two fields, and put a Text annotation in HTML above the first one: `<span style="color:red">Select the primary location:</span>`.

## Tables / fields involved

- the form's table; a new field added here creates a column ([[sys_dictionary]])

## Gotchas

- Do not add an editable field to more than one section.
- An empty section stays on the form as an empty section.
- Sections are deleted from **System UI > Form Sections**, not from the layout screen.
- The guide recommends Form Builder over this screen. Background: [[Form Layout, Sections and Views]].
