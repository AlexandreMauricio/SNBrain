---
type: reference
tags: [reference, forms-lists, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Working in Core UI > Working in the classic environment (lists: list fields, list functions, activity stream, grouped lists, list edits, personal lists; forms: headers, context menu, fields, navigate by URL, tiny URLs, activity filter, embedded and related lists incl. defined related lists, edit and personalize a form, watch list, attachments, Next Experience email client, Document Viewer, checklists), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g, chapter X1oo9mYeLZGrF1oDFABlYg). Filters and search are in their own note.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Core UI Lists, Forms and Related Lists

**In one line:** the **classic environment** is working directly in lists (`<table>_list.do`) and forms (`<table>.do`), in Core UI or inside Next Experience; this note covers what users and admins do there that the admin-side list and form notes do not.

From the Brazil docs; not tested. Admin configuration: [[List Configuration and List Controls]], [[List Editor]], [[Form Layout, Sections and Views]]. Filters: [[Filters, Condition Builder and Query Operators]]. Navigation and settings: [[Core UI Navigation, Settings and Common Elements]].

## Lists

- **Sort:** click a column (again to reverse) or right-click Sort (a to z); several columns through a filter's Add Sort. Choice fields sort by value.
- **Rows per page:** default 20; right-click the title > Show > n rows per page; applies to every list for that user.
- **Group By** (title menu or column right-click): count per group, total near the paging controls; a group shows at most one page of rows.
- **List activity stream** (icon in the title bar of task tables): live audit and journal entries of all listed records in a flyout; not the same component as the form's activity formatter, so its properties do not apply.
- **Field context menu:** Show Matching / Filter Out, Copy URL, Copy sys_id (admin), Assign to me, Approve, Reject, Assign tag. Reference icon gives a preview.
- **Action on selected rows:** Delete (admin), Add to Visual Task Board, Assign/Remove tag, and so on.
- **Edit several records:** list editor (select cells with Shift/Ctrl, then edit) for one field; **Update Selected** / **Update All** (column right-click; role `list_updater`) opens an editing form for many fields. Updating from a parent list such as `task` uses the parent form and its ACLs, so fields may not show.
- **List editor keys:** Tab or arrows to move, Enter to open and save, Shift+Enter new line, Ctrl+Enter save and stay, Esc cancel; dependent fields open a composite editor. Single-click editing is set in the personalize list dialog.
- **Personal list** (personalize icon, `personalize_list` or `admin`): columns and order for that view; Wrap column text, Compact rows, Active row highlighting, Modern cell coloring, Enable list edit, Double click to edit (these display options apply to every list); **Reset to column defaults**. Avoid a reference field as first column (its link opens the referenced record).

## Forms

- **Header (Core UI):** Back, context menu, Attachments, Show activity stream, Personalize form, More options (Email, Template bar, Annotations, Tags), Submit/Update, related actions, Delete, Previous/Next.
- **Context menu:** Save, Insert, **Insert and Stay**, Configure, Export (PDF; XML for admin), View (switching submits the form), Create Favorite, Copy URL, Copy sys_id, Show XML, History (needs auditing), Reload Form.
- **Field indicators:** mandatory asterisk (red when empty); **AI indicator** on fields filled by AI until edited.
- **Live forms:** fields changed by another user show an update icon; your own different value is not overwritten automatically and wins on save. Other viewers' avatars appear in the header (see user presence).
- **Leave without saving:** confirmation unless `glide.ui.dirty_form_support` = false.
- **Personalize form** (`itil`, `personalize_form` or `admin`; Core UI): hide fields only for yourself; cannot reorder, add fields, or hide mandatory or policy-hidden fields; **Reset** restores.
- **Activity filter:** the filter icon in the Activity header picks which fields show; *Configure available fields* sets their order.

## Navigate by URL

| Goal | URL |
|---|---|
| Inside the frame | `nav_to.do?uri=<page>` |
| List / filtered list | `<table>_list.do?sysparm_query=active=true^escalation=2` |
| Record | `<table>.do?sys_id=<sys_id>` or `?sysparm_query=number=<number>` |
| New record with values | `<table>.do?sys_id=-1&sysparm_query=priority=1^caller_id=javascript:gs.getUserID()` (on a form the query **sets** values) |
| Other parameters | `sysparm_view`, `sysparm_view_forced=true`, `sysparm_order`, `sysparm_order_direction=desc`, `sysparm_force_row_count=5`, `sysparm_result_view`, `^EQ^GROUPBYcategory`, `&CSV` (also XML, PDF, UNL) |

**Tiny URLs** (plugin on by default): `glide.use_tiny_urls` converts some redirect URLs longer than `glide.tiny_url_min_length` (default 1024) to short internal ones; not the URL of an opened record. Email links use `glide.email.override.url` for a custom base URL. More parameters: [[Filter and Sort a List with URL Parameters]].

## Related and embedded lists

- **Embedded lists** save with the form; deleting an existing row only marks it until save.
- **New** from a related list applies the list filter to the new record (reference, string, boolean and choice fields with *is* or *=*).
- **When related lists load:** Preferences > Display > *Loads related lists in classic forms* (Core UI: system settings > Forms): With the Form, After Form Loads, On-demand; user preference `glide.ui.related_list_timing` = `default`, `deferred`, `ondemand`.
- **Default filter:** build a filter on the related list, then **Set as Default Filter** (not List v3).
- **Edit button:** List Control > **Omit edit button**; for one-to-many lists also tick **Reference floats** on the reference field's dictionary entry. Defined related lists have no Edit button.
- **Edit default filter** (List Control, `personalize_list`): limits the records offered in the Edit slushbucket.
- **Fields shown under a selected item:** System UI > Views > `sys_ref_list` > Lists > the table > List Elements.

### Defined related lists (relationships)

**System Definition > Relationships** (`sys_relationship`, role `related_list_admin`): Name, **Applies to table**, **Queries from table**, **Query with** script (`current` = records of the queried table, `parent` = the displayed record), and with **Advanced**: *Apply to* and *Query from* scripts setting `answer`, and *Insert Callback*. `current` and `parent` are not available in *Queries from*; `gs` is. The list refreshes only when the form is saved. Add it through Configure > Related Lists. Base example: *Incidents by Same Caller*.

```javascript
// Relationship "Query with" (server, global): tasks opened by the user shown on the form
// Applies to table: User [sys_user]; Queries from table: Task [task]
current.addQuery('opened_by', parent.sys_id);
```

## Watch list, email client, checklists

- **Watch list** (`watch_list`, glide_list): lock icon to edit; add yourself, users, or free email addresses. Admin: notification *Users/groups in fields* > Watch list; dictionary attributes `no_email=true` (hide the email box) and `maintain_order=true` (order buttons in the slushbucket). A second watch list for work notes can get its own notification. See [[Email Notifications]].
- **Next Experience email client in Core UI:** create `glide.ui.load_seismic_email_client` = true; opened from More Actions or Reply/Forward on an activity email. Adds drafts, templates, response templates, quick messages, Now Assist; loses bulk attachment download/removal, S/MIME and SMS sending and customized email components. UI business rules may need rewriting against `sys_email_draft`. See [[Email Client]].
- **Checklists** (task tables; plugin active on new instances): add the **Checklist** formatter; only after the record is saved; Create new or from template; save as template limited to a **User Group** (blank = creator only); templates in `checklist_template`; deleting a template leaves checklists made from it.
- Attachments and Document Viewer: [[Attachments]], [[Document Viewer, PDF Generation and Document Conversion]].

## Example

Relationship *Example Open Tasks by Same Location* applying to `incident`, querying `task`, Query with `current.addQuery('location', parent.location); current.addActiveQuery();`, added to the incident form; and a checklist template *Incident - Example Network Triage* shared with *Example Network Group*.

## Related

- [[Core UI Navigation, Settings and Common Elements]] · [[Filters, Condition Builder and Query Operators]] · [[List Configuration and List Controls]] · [[Form Layout, Sections and Views]] · [[Formatters]] · [[Reference Fields]] · [[Form Templates]]
