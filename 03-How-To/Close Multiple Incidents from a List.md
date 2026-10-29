---
type: how-to
tags: [how-to, incident, ui-action, script-include, forms-lists]
status: documented
source: ServiceNow Brazil ITSM docs, Incident Management > Incident resolution and closure > Close multiple incidents from list; Create a UI action to close multiple incidents, read 2026-10-29. https://www.servicenow.com/docs/r/it-service-management/incident-management/t_CreatingAUIAction.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Close Multiple Incidents from a List

**Goal:** close several incidents in one go with the same **Resolution code** (`close_code`) and **Resolution notes** (`close_notes`), either with the built-in list edit or with a custom list UI action that asks for both in a dialog.

From the Brazil docs; not tested. Scripts below are summarised from the documented pattern, not copied; test in a sub-production instance first. Related: [[Incident Management Overview and Lifecycle]], [[incident]].

## Option A: Update Selected (no build)

Roles: `itil`, `list_updater`, `sn_incident_write` or `admin`. In the Incident (`incident`) list tick the records > right-click a column header > **Update Selected** > set **State** to Resolved or Closed, fill the **Resolution Information** section (code and notes) > **Update**. Needs `list_updater` (or one of the listed roles) and runs the normal business rules per record.

## Option B: a "Close incidents" list action

Roles to build: `admin`, or `business_rule_admin` and `ui_action_admin`. Agents then close from the list's **Actions** menu without `list_updater`; every selected incident gets the same close note. Three parts, all in the **global** scope:

| Part | Where it runs | What it does |
|---|---|---|
| Script include `IncidentClosure` (**Client callable** ticked, extends `AbstractAjaxProcessor`) | server | method `closeIncidents` reads `sysparm_incidents` (comma-separated sys_ids), `sysparm_closeCode`, `sysparm_closeNote`; queries `incident` with `sys_id IN ...`; for each sets `state` = 7 (Closed), `close_code`, `close_notes`; `update()` |
| UI page `mandatory_fields_to_close_incident_ui` | client (Jelly HTML + client script) | dialog with a **Resolution code** select (the incident close codes) and a required **Resolution Notes** text area; **OK** is disabled until both have values; on OK it calls `GlideAjax('IncidentClosure')` with the selected sys_ids (read from the modal preference `selected_incidents`), then destroys the modal and refreshes `GlideList2.get('incident')`; Cancel destroys the modal |
| UI action **Close incidents** on Incident | client | **List choice**, **List v2 Compatible**, **Client**, **Show update** ticked; **Onclick** `closeIncidents()`; condition: state is not 7; the function gets `GlideList2.get('incident').getChecked()`, opens `new GlideModal('mandatory_fields_to_close_incident_ui')` with title *Close Incidents* and preference `selected_incidents`, and renders it |

Cautions (inference): the script include writes `state` 7 directly, skipping Resolved, so SLAs, notifications and close rules fire as for a direct close; the close code values in the select must match your instance's choice list for `close_code` (they differ per instance; check `sys_choice`); a client-callable script include should check the caller's rights (for example `gs.hasRole('itil')` or `canWrite()` per record) before updating.

## Example

UI action *Example Bulk Close* on `incident` with dialog page *example_bulk_close_dialog* and script include *ExampleIncidentClosure*; an agent ticks 15 duplicate incidents, picks *Closed/Resolved by Caller*, enters *Duplicate of INC0000000 (example)* and confirms.

## Related

- [[Incident Properties Reference]]
