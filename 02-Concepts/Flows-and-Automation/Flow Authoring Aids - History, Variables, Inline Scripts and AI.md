---
type: reference
tags: [reference, flows, automation, scripting, ai, javascript]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Build flows (read 2026-10-08 through the docs site): Flow execution analysis (explore, analyze, turn on), Flow generation (explore, turn on), Flow generation with images, Create a flow with Now Assist, Flow history (view, annotate, compare, delete, restore, save a copy), Flow recommendations, Flow summarization, Summarize a flow, Flow Template Builder, Inline scripts, Save as you go flows (and restore), Flow variables (create). Example page https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/inline-scripts.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flow Authoring Aids - History, Variables, Inline Scripts and AI

**What it is:** the helpers around a flow's main structure: variables, inline scripts, version history, templates and the generative AI skills. Structure itself: [[Building Flows - Properties, Triggers, Stages and Error Handling]].

## Flow variables

Like workflow scratchpad variables: created under More Actions > **Flow Variables** (**Label**, **Name**, **Type**), shown as pills in the Data panel, available everywhere in the flow.

- Set with the **Set Flow Variables** flow logic (several per block). Values are mutable; unset = null.
- Assigned top to bottom; the last assignment wins; a variable that references another must come after it.
- Types: Array.Object, Date/Time, Decimal, Floating-point number, Integer, JSON, Object, Reference, String, True/False.
- Useful to keep an original value, because trigger pills reflect later updates.

## Inline scripts

A **Script** toggle beside an input (flow, flow logic, subflow or step inputs and outputs) for small conversions and calculations. Needs role `flow_designer_scripting` or the *Allow Scripting* delegated permission. Server-side JavaScript, runs in the flow's scope as part of the flow.

- Must `return` a value of the type the input expects (a GlideRecord for a Record input, a date-time for a Date input).
- Data comes from `fd_data`, always dot-walked:

| Target | Syntax |
|---|---|
| Trigger | `fd_data.trigger.current` |
| Output of step N | `fd_data._2__create_task` (number, two underscores, name) |
| For Each item | `fd_data._2__for_each.item` |
| Flow variable | `fd_data.flow_var.<name>` |
| Subflow input | `fd_data.subflow_inputs.<name>` |
| Action input (inside an action) | `fd_data.action_inputs.<name>` |

```javascript
// inline script on a String input of a flow action (server-side, flow scope)
var shortDesc = fd_data.trigger.current.short_description;
return 'Follow-up: ' + shortDesc;
```

- Type-ahead after `fd_data.` lists what exists; save the flow to refresh it.
- Records from Look Up Records are reachable only through a For Each item.
- Prefer transform functions for standard formatting, and a script include (`new MyScriptInclude().functionOne()`), custom action or subflow for anything reusable. Do not re-implement record actions in script. Declare variables with `var`.
- Calling integration APIs from an inline script counts against Integration Hub licensing.

## History

Sidebar **History** icon while editing (flows and subflows alike).

| Aspect | Detail |
|---|---|
| Entry types | Force saved, Autosaved, Activated/Published, Deactivated, Restored, Deployed (created, or arrived by update set or repository) |
| Per entry | timestamp name, user, type; **Add annotation**; favourite (up to 20, never overwritten); **Delete**, **Save as copy** (new flow), **Restore** (creates a Restored entry) |
| Compare | More actions on an entry > **Compare Entry**: side by side; added green, removed red, changed blue; expand a changed step to see the inputs |
| Limits | 100 entries per flow (`sn_flow_designer.maximum_flow_history_records_per_flow`); autosaves by the same user within 60 minutes collapse into one (`sn_flow_designer.autosave_version_interval`) |

Deleted entries cannot be recovered.

## Flow Template Builder

Plugins App Engine Studio (`sn_app_eng_studio`) and Flow Template Builder (`sn_flow_template`). On a flow: More actions > **Save flow as a template** > *Template setup*: per input choose **Use default value**, **Collect new user input** (creates a template variable, which cannot be deleted later) or **Use template variable**. **Activate**. Templates are stored in `sys_app_template`; the wizard's field order and texts in `sys_app_template_wizard`. In App Engine Studio: app > **Logic and automation > Add** > template > answer the wizard. Template authors cannot create templates in Global.

## Generative AI skills

All from ServiceNow Otto for Creator (`sn_now_creator`, separate subscription), turned on under **AI Admin Hub > Skills > Creator**; users need `now.assist.creator` plus a flow authoring role. Each build counts as an assist. Availability varies by region and data centre; output must be reviewed.

| Skill | Does |
|---|---|
| Flow generation | **New > Flow / Subflow > Build with Now Assist**: name, scope (fixed once previewed), directions; preview in diagram view with the directions shown as annotations and generated pill values; **Rebuild**, **Discard**, **Save and edit**. Unknown steps become placeholders, which block activation |
| Flow generation with images | the same from one image, optionally with text |
| Flow recommendations | one to five suggestions for the next step, from the names of the steps before; only ServiceNow-shipped components, no Store spokes or custom ones. Per-flow preference *Show recommendations* |
| Flow summarization | More Actions > **Flow summary / Subflow summary > Summarize**; regenerate with the refresh icon |
| Flow execution analysis | execution details > sidebar **Summarize > Analyze flow**: root cause and potential fixes. With reporting off it only works for runs in Error |

Writing directions: trigger first, then steps in order; exact names of actions, flow logic and tables; `#Table` hash tags to pin a table (useful when two tables share a label); number the branches of "do the following in parallel"; quote literal values. Supported triggers: scheduled, record, SLA, inbound email, Service Catalog. The generator knows common and recently published actions and subflows on the instance (refreshed hourly).

## Related

- [[Building Flows - Properties, Triggers, Stages and Error Handling]] · [[Subflows in Workflow Studio]] · [[Flows, Subflows and Actions Overview and Architecture]]
