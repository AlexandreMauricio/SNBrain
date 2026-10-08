---
type: reference
tags: [reference, platform, schema, fields, forms-lists, ui-policy, flows, roles, domain-separation, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Builder library > Table Builder (read 2026-10-08 through the docs site; whole section, about 3,280 cleaned lines): Table Builder, Exploring Table Builder, Accessing Table Builder, Accessing Form Builder, Table Builder workflow and navigation, Domain separation and Table Builder, Using an application scope, Using Table Builder, Data (Spreadsheet view, Fields view, Schema view, Preview your data, Delete a table, Edit table properties), Forms (choose a form view, customize the layout, add fields, modify field properties, annotations, formatters, embedded lists, preview), Policies and rules, Flows, Reference (Table properties, Field configuration, Formulas for column values, Add a formula to a column, Policies and rules properties). The worked examples of each formula function are omitted. https://www.servicenow.com/docs/r/application-development/form-builder-glide-family-release/tb-landing-page.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Table Builder

**What it is:** one screen for a table's columns, its data, its form views, its UI policies and its record-triggered flows, instead of the separate dictionary, form layout and flow tools. Form Builder is its **Forms** tab, also reachable by itself.

From the Brazil docs. The former *Table Builder for App Engine* is merged into it, so schema view, spreadsheet view, flows and the PDF extractor are now in the one application (some pages still say these need the App Engine "exclusive low code capability" licence: unclear which is current (?)). Underlying concepts: [[Tables, Records and Table Relationships]], [[Dictionary Entry Form]], [[Form Layout, Sections and Views]].

## Opening it

| From | How |
|---|---|
| Navigation filter | `<table>.builder` (Data tab, fields), `<table>.sheet` (Data tab, spreadsheet), `<table>.view` (Forms tab), `<table>.flow` (Flows tab). Example: `incident.builder` |
| Menu | **All > Table Builder** > search the table > **Open** |
| App Engine Studio / ServiceNow Studio | the table's menu > **Edit** |
| UI Builder | select a form component > **Edit form view** (opens the Forms tab) |
| A form (Form Builder only) | form context menu > **Configure > Form Builder**, or the table's Related Links |

The header has the table picker, **domain** and **scope** pickers (the scope picker changes the session scope, and vice versa), undo and redo (not after a save), a menu (**Advanced view** = the classic table record, **Form designer**, **Properties**, **Delete table**), **Preview** and **Save**.

## Who can use it

| Role | Gives |
|---|---|
| `personalize_dictionary` | Data tab, field configuration, dictionary changes |
| `personalize_form` | Forms tab |
| `personalize_rules` | Policies and rules tab |
| `personalize_choices` | choices of a field |
| `flow_designer` | Flows tab (with `personalize_form` and `personalize_dictionary`) |
| admin, or an App Engine Studio user role with delegated developer permissions | everything in their applications |

Give a new table at least one role with read, or **Preview** is disabled. Deleting a table needs delete access on `sys_db_object`; editing its properties needs write access.

## Data tab

Each **column of the table is shown as a row**.

| View | Use |
|---|---|
| **Fields** | add (**+ Add new field**), relabel, rename, retype, set default, choose the display column; the side panel (icon on the left of a row) holds the full configuration and the delete icon. Filter options show inactive fields or hide inherited ones |
| **Spreadsheet** | the records as a grid: add and edit records, sort, right-click a cell to *show matching*, **Filter**, column menu (properties, insert left or right, duplicate, hide, pin, delete), **Manage columns**. Pins are per user. Rows that fail a policy or business rule on save are listed for correction or **Revert record changes** |
| **Schema** | read-only diagram of the table and its relations: zoom, expand tables, choose tables, show extended fields and field types, group fields (extended, reference, type), sort, legend |

Limits stated:

- A column name cannot be changed once it holds saved data; changing the label of a new column changes its name automatically.
- A column cannot be deleted while it holds data, if it is inherited, or if it is one of the system columns.
- A parent table cannot be deleted before its children. Deleting asks you to type `delete`.
- Only one column can be the display value: clear the old one first.

**Table properties** (menu > Properties): *General information*: **Table label**; under Advanced **Make extensible** and **Add record number** with **Prefix**, **Starting number**, **Number of digits** ([[Record Numbering]]). *Access*: **Accessible From** (all scopes or this scope only) and the read, create, update, delete boxes for other scopes ([[Application Access Settings and Cross-Scope Privileges]]).

### Field configuration (side panel)

| Section | Settings |
|---|---|
| Field details | **Label** (with tooltip, plural, URL), **Active** (an inactive field disappears from the form editor; reactivate from the Data tab), **Mandatory**, **Read only option** (*Display Read Only* or *Strict Read Only*; the old **Read only** box is deprecated: [[Read-Only Field Options]]) |
| Default value | constant, or **Use dynamic default** |
| Function definition | for a function field, chosen under Advanced settings at creation ([[Function Fields]]) |
| Reference | the table, and a qualifier: *Simple* (condition builder), *Advanced* (encoded query or JavaScript), *Dynamic* ([[Reference Qualifiers]]) |
| Dependent field | make choices depend on another field of the table |
| Choices | **Label**, **Value**, **Dependent value**, **Domain**, **Active**; *Use the choices from another field*; **Show choices as** dropdown (needs a default, otherwise None becomes it), dropdown with None, or suggestions (Core UI only) ([[Choice Lists]]) |
| Attributes | dictionary attributes ([[Dictionary Attributes Reference]]) |
| Formula | a calculated value without script, below |

### Formulas

Side panel > Formula > **+ Add** > type in the formula editor > **Submit** (validated on submit). Only for columns of tables in the current application's scope; not for function fields, unsupported types, or columns that already have a scripted calculated value. Functions can be nested; column names are used as variables. Comparison operators (`=`, `<>`, `>`, `<`, `>=`, `<=`) work on numbers only, and `IF` cannot compare strings.

| Group | Functions |
|---|---|
| Math | `SUM`, `SUBTRACT`, `MULTIPLY`, `DIVIDE` (each left to right over all arguments), `AVERAGE`, `MIN`, `MAX`, `POWER(base, exponent)`, `MODE`, `COUNTIF(values..., criteria)`, `INDEXMATCH` (first non-empty argument) |
| Text | `CONCATENATE`, `LENGTH`, `LOWERCASE`, `UPPERCASE`, `TITLECASE`, `REPLACE(source, target, replacement)`, `SUBSTRING(source, start, length)`, `FIND` (case-sensitive) and `SEARCH` (case-insensitive) `(search, source, from)` returning the position or -1, `ISBLANK` |
| Date and time | `NOW()`, `TODAY()` (start of day, UTC), `DATE(year, month, day)`, `DATEVALUE(text)`, `DAY`, `MONTH`, `YEAR`, `WEEKDAY` (1 = Sunday), `TEXT(date, format)`, `TIMEDIFF(a, b)` (a duration), `DATEDIF(start, end, "D"/"M"/"Y")`, `WORKDAY(start, days, holidays...)`, `NETWORKDAYS(start, end, holidays...)` (inclusive of both ends) |
| Logic | `IF(condition, then, else)`, `AND`, `OR`, `IFERROR(expression, fallback)` |

```text
CONCATENATE(first_name, " ", last_name)
IF(DATEDIF(sys_created_on, NOW(), "D") >= 30, "Old", "Recent")
```

## Forms tab (Form Builder)

Left: elements to add (Fields, Components, Formatters, Embedded lists). Middle: the editor. Right: properties of the selection.

| Task | How |
|---|---|
| Pick or create a view | view list, or the actions menu: **Add new form view**, **Duplicate this form view**, configure a related list or UI action, **All form views** (searchable, sortable cards). The menu shows only when opened from a studio |
| Sections | drag **Section** from Components; one or two columns; **Merge with section above** (one title, two layouts) and **Detach**; move with arrows; delete |
| Fields | drag from the list (tick several to drag together); **+ Add a field** creates a column; the x removes it from the view only |
| Annotation | drag **Annotation**; types Info Box Blue, Info Box Red, Line Separator, Plain Text, Section Details, Section Plain Text, Section Separator, Text; plain or rich text |
| Formatter, embedded list | drag from their lists. **Both work only in Core UI forms** ([[Formatters]]) |
| Field properties | select the field: *Properties* tab (with **More properties available** for the dictionary entry) and *UI Policies* tab |
| Preview | **Save**, then **Preview**: pick or create a record; *Open form in Platform* |

Fields of types that only Core UI supports carry an exclamation mark.

## Policies and rules tab

Only **UI policies** are edited here; access controls, client scripts, business rules and workspace view rules are listed read-only with a link to each record and to the full list.

UI policy: **Add new policy** (inactive link = wrong scope) > *Policy details*: **Short description**, **Order**, **Active**, and under advanced settings **Apply to all views**, **On load**, **Reverse if false**, **Inherit** > *When these conditions are met* (condition sets) > *Do the following*: per field **Mandatory**, **Visible**, **Read only** (Leave alone, True, False), **Clear the field value** > **Add UI policy**. Scripts and related-list actions are added afterwards in the classic record. Behaviour: [[UI Policies]].

**Workspace view rule** fields: **Name**, **Table**, **View** (default view when empty or invalid), **Roles**, **Conditions**, **Hide section navigation**, **Disable section collapsing**, **Default tab order**.

## Flows tab

Lists, as cards, the flows triggered by records of this table (search, sort, filter). **Add new flow** > **Name**, **Description**, advanced options (**Protection**, **Run as**, **Run with roles**) > trigger: record created, updated, or created or updated > continue in the embedded Workflow Studio editor > **Save** (a draft; only **activated** flows run). Card menu: **Copy**, **Delete** (type `DELETE`). Back to the list: actions menu > **All flows**. Detail: [[Building Flows - Properties, Triggers, Stages and Error Handling]].

## Domain separation

Support level Standard, **only when opened from UI Builder** (not from App Engine Studio). Switch the session domain to create overrides of form layout, sections and UI policies; dictionary changes (labels and the like) need no override. A layout override at a lower domain needs both the form and the section record. A single-section form has only a section record (`sys_ui_section`) and no form record (`sys_ui_form`): **adding a second section to a form that already has domain overrides breaks them**.

## Related

- [[App Engine Studio Building Reference]] · [[ServiceNow Studio Overview, Access and Navigation]] · [[Field Types Reference]] · [[Field Administration]] · [[Builder Tools Overview and Custom UI Components]]
