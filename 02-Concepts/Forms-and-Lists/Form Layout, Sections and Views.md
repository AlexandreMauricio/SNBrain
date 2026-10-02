---
type: concept
tags: [concept, forms-lists, admin, roles, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration" (pp. 734-753), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Form layout, sections and views

**In one line:** a form is defined per **table and view**; configuring it decides which fields, sections, annotations, formatters, embedded lists and related lists appear, for everyone, while personalizing changes it for one user only.

## Three tools for the same job

| Tool | Where | Status |
|---|---|---|
| **Form Builder** | the guide's recommended tool; has everything the other two do | recommended |
| **Form Designer** | form menu, **Configure > Form Design**; drag and drop, **Fields** and **Field Types** tabs | being prepared for deprecation from Australia. Plugin `com.glide.ui.ng.fd` on upgraded instances |
| **Form Layout** | form menu, **Configure > Form Layout**; slushbucket of Available and Selected | classic |

Role: `personalize_form` (sections: `form_admin`; form splits: admin).

## What can go on a form

- **Fields**: move from Available to Selected. Green items with `+` are related tables you can dot-walk into. Dragging a **field type** in Form Designer, or adding a new field in Form Layout, **creates the column** on the table.
- **Sections**: group fields; one or two columns. The first section cannot be removed and its caption is the form title. With tabbed forms on, each later section is a tab. Delete a section under **System UI > Form Sections**.
- **Splits**: `|- begin_split -|`, `|- split -|`, `|- end_split -|` mark where fields split into columns. More than two columns needs the property `glide.ui.form_multiple_splits` ([[Form and Attachment Properties]]). On small mobile screens the first split's fields come before the second's.
- **Annotations**: `* Annotation` in the slushbucket. Types: Info Box Blue, Info Box Red, Line Separator, Section Details, Section Separator, Text. Plain text or HTML. Users toggle them (preference `glide.ui.show_annotations`); `glide.ui.form_annotations` = false disables them. Types are managed under **System UI > Form Annotation Types**. For translations, create **System UI > Messages** records with a shared key and write `${gs.getMessage("key")}` in the annotation.
- **Formatters**: [[Formatters]].
- **Embedded lists**: shown in red at the bottom of Available. Rows edited in an embedded list are saved **when the form is saved**. The same list can instead be a related list.
- **Related lists**: **Configure > Related Lists**; shown at the bottom of the form.
- **Charts**: `* Chart`, then **Configure chart** and pick a report. Not supported: List, Pivot, Multilevel Pivot, Calendar, Single Score.

## Personalization versus configuration

- **Personalize** changes the form for that user only; stored as a user preference named `personalize_<table>_<view>` (e.g. `personalize_alm_asset_default`). Delete the preference to reset the user.
- Plugin Form Personalization (`com.glide.ui.personalize_form`). Property `glide.ui.personalize_form` (false disables it) and `glide.ui.personalize_form.role` (default role `itil`).
- **Required form fields** (`sys_ui_element_required`, **System UI > Required Form Fields**) stop users with `personalize_form` from removing a field; only admins can. Needs the Required Form Fields plugin and `glide.ui.form.enforce_required_fields` = true. Applies to child tables, which can override it. Clear **Required** rather than deleting the record.

## Other form behaviour

- **Tabbed forms**: system user preference `tabbed.forms`; users switch it under **Preferences > Display**.
- **Customer updates indicator** in the form header (opens the update set records): user preference `owned_by_indicator.form`, for all admins or per admin.

## Gotchas

- **Never put the same editable field in two sections of a form**: it can cause data loss and break UI and data policies. Read-only duplicates are fine.
- In Core UI, the order of Additional comments and Work notes is set by the activity filter's **Configure available fields**, not by Form Layout.

## Related

- [[Configure a Form Layout]] · [[UI Actions]] · [[UI Policies]] · [[Form Templates]] · [[Attachments]]
