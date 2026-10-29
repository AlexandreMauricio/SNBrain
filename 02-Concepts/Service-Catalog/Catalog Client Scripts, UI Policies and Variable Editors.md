---
type: concept
tags: [concept, service-catalog, client-script, ui-policy, scripting]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Service Catalog client scripts", "Service catalog UI policy", "Create a UI policy for catalog items", "Service Catalog variable editors", "Configure the default variable editor for a task-extended table", "Service Catalog properties", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_CatalogClientScriptCreation.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Catalog client scripts, UI policies and variable editors

**In one line:** catalog client scripts and catalog UI policies are the catalog versions of client scripts and UI policies: they attach to an **item or variable set** instead of a table, act on variables, and can also run where the answers are shown later (RITM, catalog task, produced record).

## Catalog client scripts (client-side, browser)

- **Catalog Administration > Catalog Client Scripts**. **Applies to**: *A Catalog Item* or *A Variable Set*, then pick it with a reference field. **Type**: onLoad, onChange (bound to a **variable**, not a field), onSubmit. **UI Type**: Desktop, Mobile / Service Portal, All.
- Uses: get/set values, show/hide, mandatory, validate submit, add to cart, order immediately.
- Variables need a **Name** to be listed or scripted.
- On RITM or catalog task forms a table field and a variable with the same name clash: the field wins; address the variable as `g_form.setValue('variables.<name>', ...)`.
- `g_form.refreshSlushbucket('<list collector>')` refreshes a list collector. `g_service_catalog.isOrderGuide()` tells if the item is shown inside an order guide (Service Portal).
- Asynchronous GlideAjax is allowed but every AJAX call is flagged by the item diagnostic; DOM manipulation is discouraged (breaks on upgrade).

## Catalog UI policies

- **Catalog Administration > Catalog UI Policies**. Same **Applies to** choice. **Catalog Conditions** on the item's (or set's) variables; set variables appear as `set_name » variable_name`. **On load**, **Reverse if false**, **Order**, optional scripts (**Run scripts**, Execute if true / false) for anything beyond the built-in actions. **Global** and **Inherit** are not used for the catalog.
- **Catalog UI Policy Actions**: per variable or whole variable set: **Mandatory**, **Visible**, **Read Only** (Leave alone / True / False), **Value action** (Set value / Clear value), **Field message type** and **Field message**. Set value does not work on Attachment and Masked (use Clear value). Clear value does not work on sets and containers. On an MRVS, actions apply to the whole set only.
- Variables in a condition must be on the form (hidden or read-only is fine) and named.
- Mandatory and Read only do not apply to Break, Container Split/End, UI Macro, Label, UI Page; Visible does not apply to Break and Container Split/End.
- Item policies run before variable set policies by default; `glide.sc.ui_policy.variable_set_run_first` = true reverses it.
- Supported inside [[Service Catalog Wizards]].

## Where they run: the four "Applies on" boxes

| Check box | Where |
|---|---|
| **Applies on a Catalog Item view** | the order form (requester) |
| **Applies on Requested Items** | RITM form, through the VEditor (fulfiller) |
| **Applies on Catalog Tasks** | catalog task form, through the VEditor |
| **Applies on the Target Record** | record created by a record producer, through the default variable editor |

## Priority of states

Mandatory beats read-only and hidden: a mandatory variable without a value cannot be hidden or made read-only; making a hidden or read-only variable mandatory shows it or makes it editable. Same for a container or set that holds such a variable. Between conflicting actions on a variable and its set, the action with the lowest order wins.

## Variable editors (how fulfillers see answers)

| Editor | For | Reads from | Notes |
|---|---|---|---|
| **VEditor** (`com.glideapp.servicecatalog.VEditor`) | RITM and catalog task (Default view) | `sc_item_option` | only these two tables |
| **Default variable editor** (`com.glideapp.questionset.DefaultQuestionEditor`) | records made by record producers on task-extended tables | `question_answer` | on Incident and Change by default; add formatter `com_glideapp_questionset_default_question_editor` (**System UI > Formatters**) to other tables' forms |

- Never activate the **Variables** column of [[task]]; the editors depend on it being inactive.
- Read-only editor: `g_form.setVariablesReadOnly(true)` in Core UI and workspace (not for catalog forms or Service Portal), or activate the onLoad client script **Variable Editor Readonly** on `sc_req_item` / `sc_task` (can be made conditional). Service Portal: `"readonly_variable_editor": "true"` in the portal's **Quick start config** (UI Page and Macro variables still render).
- Agent Workspace: the formatter in the Workspace view becomes a **Variables** section (not if placed inside another section). Macro, Macro with Label and UI Page are not shown; Multiple Choice, Numeric Scale and Lookup Multiple Choice show as select boxes.
- `glide.sc.hide_variable_editor_background` hides the editor's border and background; `glide.sc.variable.snapshot` orders RITM variables as on the order panel followed by execution-plan variables (true) or merged by order (false).

## Related

- [[UI Policy or Client Script]] (platform-level comparison) · [[UI Policies]] · [[Catalog Variables and Variable Types]] · [[Create a Catalog UI Policy]] · [[Debugging Service Catalog Items]]
