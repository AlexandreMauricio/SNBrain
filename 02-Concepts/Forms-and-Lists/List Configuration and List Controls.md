---
type: concept
tags: [concept, forms-lists, roles, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "List administration" (pp. 998-1007, 1013-1026), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# List configuration and list controls

**In one line:** configuring a list (columns, calculations, controls) changes it for everyone in that view; a **list control** record decides which buttons, filters and links a list or related list shows, by option, role or script.

## Layout

- Right-click a column header, **Configure > List Layout** (role `personalize_list`). Pick the view first from the list controls menu.
- **The first non-reference column becomes the link to the record.** Put Number first.
- A user's personal list hides later changes until they reset to column defaults.
- Inactive fields stay in configured lists until removed from the layout.
- A reference column showing `(empty)` usually means another reference in the list points to an orphaned or missing record.
- `glide.ui.list.allow_extended_fields`: allows child-table fields (e.g. Caller, from Incident) on a parent table list such as Task, and filtering on them.
- **List calculations** (**Configure > List Calculations**): total, minimum, maximum, average under a column, per view, for all users. No total or average for string and date fields. For calculated fields they use the stored values.

## List control

Right-click a column header, **Configure > List Control** (role `personalize_control`); also **System UI > List Control**.

| Field | Effect |
|---|---|
| **Label** | custom title of the list or related list |
| **Omit new button** / **New roles** | hide **New**, or limit it to roles |
| **Omit edit button** | hide **Edit** on related lists |
| **Omit filters** / **Filter roles** | hide filters and breadcrumbs, or limit to roles |
| **Omit links** / **Link roles** | no links on reference columns, or limit to roles |
| **Omit drill-down link** | first column no longer links to the record |
| **Omit if empty** | a related list with no rows is not shown at all |
| **Omit columns if empty** | no headers and filters for an empty list |
| **Omit related list count** | no count on first load |
| **List edit type** | Save immediately (cell edit), Save data by rows, or Disable list editing |
| **List edit insert row** | empty row at the bottom to create records in the list |
| **List edit tag** | passed to reference qualifiers as `listEditRefQualTag` ([[Reference Qualifiers]]) |
| **Hierarchical lists** | expand a row to see its related lists in place (not in List v3) |
| **Remove pagination count** | skip the total record count so large filtered lists load faster (optionally only for named views); the Last Page icon greys out |
| **Disable Natural Language Query (NLQ)** | per list |

Embedded lists have fewer options. Example: on the Problem form, relabel the Incidents related list *Child Incidents* and tick **Omit new button**.

**Scripted conditions**: add to the List Control form the fields *Omit New Condition*, *Omit Edit Condition*, *Omit Filter Condition*, *Omit Links Condition*, *Omit Columns Condition*, *Omit Empty Condition*. The script sets `answer`; **true means omit**. On related lists `parent` is the record the list sits on:

```javascript
var answer = !(parent.active == true);   // hide Edit unless the parent task is active
answer;
```

## Default sort order

A list opened for the first time is sorted by the first of:

1. `ORDERBY` arguments in the URL.
2. User preferences `<table>.db.order` and `<table>.db.order.direction` (a system-level preference, no user and **System** ticked, gives a default for everyone).
3. The dictionary attribute `isOrder` (field only, not direction).
4. A field named **Order**, then **Number**, then **Name**, then the display field.

Task tables use **Number** when there are no URL arguments or preferences. Once a user sorts a list, that choice is remembered for them. Module-level control: [[Filter and Sort a List with URL Parameters]].

## Personal lists, detail rows, breadcrumbs

- **Personal lists**: the UI macro `list_mechanic2` turns the feature on or off; `glide.ui.list_mechanic.roles` limits it to roles (List v2). Personal lists are rows in **System UI > Lists** with a **User**.
- **Detail rows** (not in List v3): property `glide.ui.list.detail_row` = true plus the table attribute `detail_row=<field>`. Task has `all_tables.detail_row=short_description`.
- **Breadcrumb length**: `glide.ui.breadcrumb_max_entries` (default 10).
- **Hide filters and breadcrumbs by script**: a script include named `<tablename>DisplayFilter` with a function of the same name that sets `answer` to true or false.
- Field order in the Show/hide filter picker: alphabetical; `guide.ui.condition_builder.sort_labels_by_locale` (as spelled in the guide) sorts by locale.

## Context ranking

Plugin `com.glide.sorting`. A **ranking definition** (**System Definition > Ranking Definitions**: **Record table**, **Context column**, optional relationship, attributes `visible_columns` and `extra_conditions`) adds a **Rank** button to a related list so users drag records into an arbitrary order, then **Sort by rank**. After submit only Attributes can be edited. Definitions arriving by update set need **Generate Indexes**. Used by scrum for story backlogs.

## Context menus

**System UI > UI Context Menus**: add options to list title menus, column headings or list fields, globally or per table. Types: Action, Menu, Separator, Label, Dynamic actions. Scripts are client-side: the **Action script** has `g_list`, `g_fieldName`, `g_fieldLabel`, `g_sysId` (e.g. `g_list.sortDescending(g_fieldName);`); the **Dynamic actions script** uses `g_contextMenu.addAction(id, label, script, order)`; the **onShow script** decides what appears.

## Related

- [[List Editor]] · [[UI Actions]] · [[Form Layout, Sections and Views]]
