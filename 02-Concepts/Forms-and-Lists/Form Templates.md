---
type: concept
tags: [concept, forms-lists, task, scripting, glide-api]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topic "Using form templates" (pp. 775-784), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Form templates

**In one line:** a template is a saved set of field values for a table that a user, a module, a schedule or a script can apply to fill a new record.

## How it works

- Managed at **All > System Definition > Templates** (role `template_editor_global` or admin), or saved from a filled form with the **+** on the template bar.
- Visibility: **User**, **Groups**, or **Global**. With a user or group set, nobody else sees it unless Global is ticked.
- **Table** can be Global to make it usable on all tables. Only tables in the template's scope are listed.
- Applying a template from a form is subject to the `save_as_template` ACL on each field it changes.
- The template's own **Short description** is just a description; it does not fill the form's short description.
- Dot-walked fields can be selected but are not applied to the form.

## Automatic templates

A template whose **Name equals the table name** (e.g. name `cmdb_ci_win_server` on that table) applies automatically to records users create on that table. Always global (User and Groups are ignored). Not applied to records created by business rules, UI actions or workflows. Otherwise a template name **cannot** match a table name.

## Parent and child templates

For task tables with child tasks (Change and Change Task, Incident and Incident Task):

- Add to the Template form: **Next Related Child Template**, **Next Related Template**, **Link element**.
- Parent template: **Next Related Child Template** = the first child template.
- Each child template: **Link element** = the field referencing the parent (e.g. Change request), and **Next Related Template** = the next child (empty on the last).
- **Child templates are only applied when the parent template is applied from a module**, not from the template bar on a new form.

Module for a template: **Link Type** = *URL (from Arguments)*, **Arguments** = `<table_name>.do?sys_id=-1&sysparm_template=<template_name>`.

## Scheduled records

On a template record, **Schedule** opens a Scheduled Entity Generation form to create records from it on a recurring basis (e.g. a weekly task).

## In scripts

```javascript
// on the current record
current.applyTemplate('example_template_name');

// on a new record
var rec = new GlideRecord('incident');
rec.initialize();
rec.applyTemplate('example_template_name');

// by sys_id
GlideTemplate.get(templateSysId).apply(rec);
```

With child templates, the parent record is inserted first so the children have a valid reference.

## Template bar

Shown at the bottom of forms; lists available templates, with buttons for all templates, create and disable. Users toggle it from the form's more-options menu (**Toggle Template Bar**). Hide it for one table with the property `glide.ui.show_template_bar.<TABLENAME>` = false.

## Related

- [[Form Layout, Sections and Views]] · [[UI Actions]]
