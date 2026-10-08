---
type: concept
tags: [concept, flows, automation, scripting, integrations, javascript]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Build actions (read 2026-10-08 through the docs site): Building actions, Getting started with actions, Create an action in Workflow Studio, Create an action input from a step input, Test an action, Copy an action, Dynamic inputs (get started, data gathering actions for dynamic choice / dynamic template / dynamic inputs, configuration options), Dynamic outputs (get started, data gathering action for a dynamic object, configuration options), Action error evaluation, Add error condition, Retry policy, Create conversational action skill, Configure conversational settings, Configure LLM to generate descriptions, Test conversational action, Complex data (create, save, load data structure), Create a custom action to generate an object from a record, Create a custom flow to generate an object for each record in a list, Script support for complex data, Create a custom action to generate an array of objects / of strings from a list of records. Section start https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/actions.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Custom Actions, Dynamic Inputs and Error Evaluation

**In one line:** an action is a reusable, published sequence of *steps* with declared inputs and outputs; a custom action is how you package script, record operations or an integration call so flow authors can use it without code.

Context: [[Flows, Subflows and Actions Overview and Architecture]]. Shipped actions: [[Flow Core Actions Reference]]. Steps: [[Flow Action Steps Reference]]. Data types: [[Flow Data Types and Transform Functions]].

## Three kinds of action

| Kind | Open it? | Change it? |
|---|---|---|
| ServiceNow core action (Ask for Approval, Create Record ...) | no | no |
| Spoke action | yes, read-only | copy it, edit the copy |
| Custom action | yes | yes: role `action_designer`, which reaches actions in **every** scope |

## Anatomy

| Part | Notes |
|---|---|
| Properties | **Action name**, **Description**, **Application**, **Domain**, **Accessible From**, **Category**, **Protection**, **Action annotation** |
| **Inputs** | label, name, type, mandatory, advanced options. From a step input: pill picker > **+** beside *Inputs* creates one named after the step and field (for example `create_record_table_name`) |
| Steps | each has **If this step fails**: *Stop the action and go to error evaluation* or *Don't stop the action and go to the next step* (only for steps nothing later depends on) |
| **Outputs** | created in edit mode, then mapped to step pills after **Exit Edit Mode** |
| **Error Evaluation** | see below |

- Input and output names cannot be `sys_id`, `sys_created_by`, `sys_created_on`, `sys_updated_by`, `sys_updated_on` or `sys_mod_count`.
- **Step Status** pills (**Code** 0 or 1, **Message**) exist per step and cannot be customised. **Action Status** (**Code**, **Message**) is what the flow sees.
- **Test** (roles `flow_designer`, `flow_operator`, `action_designer` or admin; optional background run), then **Publish**. A draft is invisible to flow authors unless they turn on *Show draft actions*.
- **Copy action**: not for ServiceNow default actions or protected ones.
- Actions run as the user who initiates the session.

Typical first custom action: wrap the *Ask for Approval* step with fixed approve and reject rules and a due date, expose only the record and the approver as inputs, and publish it as a standard "manager approval".

## Error evaluation

Without it, an action's status is the status of its last step. The **Error Evaluation** section holds *error conditions*, checked top to bottom like else-if; the first match sets the result.

| Field | Meaning |
|---|---|
| **Label** | make it describe the failure |
| Conditions | usually on Step Status pills or step outputs (an HTTP status code, an empty result) |
| **Don't treat as error** | the match is reported as success |
| **Action Status Code**, **Action Status Message** | what the flow's error handler receives ([[Building Flows - Properties, Triggers, Stages and Error Handling]]) |

Specific conditions before general ones; fewer than 10; use Step Status to tell apart several steps of the same type.

## Retry policy (integration steps)

**Process Automation > Integration Hub > Retry Policy** (roles `connection_admin` or `credential_admin`; needs Integration Hub). Applies to REST, SOAP and JDBC steps.

| Field | Options |
|---|---|
| Conditions | on the response, operators *is*, *is not*, *contains*, *contains not* |
| **Retry Strategy** | Exponential Backoff (multiplier 2), Fixed Interval, Honor "Retry-After" header (REST and SOAP) |
| **Interval**, **Count** | count is capped by `glide.fdih.retry.max_count` (the docs give the default as 0, meaning? unconfirmed) |
| **Max Elapsed Time** | capped by `glide.fdih.retry.max_time_in_seconds` (default 86400, at most 604800) |

A connection alias can carry a default retry policy; a step can override it. Check attempts under **System Logs > Outbound HTTP Requests**.

## Dynamic inputs and outputs

For integrations where the valid choices or fields live in the other system. Plugin *ServiceNow Flow Designer - Introspection* (`com.glide.hub.flow_designer_introspection`), Integration Hub subscription.

| Variable type | The flow author sees |
|---|---|
| **Dynamic Choice** (input) | a dropdown filled at design time |
| **Dynamic Template** (input) | a field/value template whose fields come from the other system |
| **Dynamic Inputs** (input) | a set of extra inputs generated at design time |
| **Dynamic Object** (output) | an output object whose structure is discovered at design time |

Each is fed by a **data gathering action**: a normal action, usually a REST step plus a Script step, with exactly one output named `output` of type **JSON**, whose content has a top-level `data` property.

```javascript
// Script step inside a data gathering action (server-side, action's scope)
(function execute(inputs, outputs) {
    var result = { data: [] };
    result.data.push({ label: 'Example Field', name: 'example_field', type: 'string' });
    outputs.fields = JSON.stringify(result);
})(inputs, outputs);
```

| For | `data` shape |
|---|---|
| Dynamic Choice / Template / Inputs | array of `{label, name, type, ...}`. Input types allowed: choice, datetime, decimal, email, html, integer, password2, reference, string |
| Dynamic Object | `{type: 'object' or 'array.object', attributes: {child_type: 'object'}, children: [{name, label, type}]}`. Child types: string, integer, datetime, choice, boolean, object and the array variants |

Options on the dynamic variable: **Action** (the data gathering action), **Depends-On Another Input** (re-query when that input changes), choice dropdown with or without *None*, **Max length**, **Hint**, **Default**.

Limits: 5000 items for choices and templates, 40 inputs for Dynamic Inputs, and 300 seconds to answer (`sn_flow_designer.sync_action_execution_timeout_in_seconds`). A script error in the data gathering action shows as a warning on the input and leaves it empty. The docs' worked examples call the instance's own REST API through a connection alias (table schema and one-record queries); any credential lives in the alias, never in the action.

## Complex data

**Object** and **Array.Object** (and Array.String, Array.Integer ...) variables hold structured data.

- Build the structure in the variable editor: add child elements of type Array, True/False, Choice, Date/Time, Integer, Object, String. Keep it under seven levels.
- **Save as Template** / **Start from Template** reuse a structure. A loaded template is a copy: later changes to the template do not reach it.
- Array pills need **For Each** to reach their items. An object pill used as an input makes its children read-only.
- The structure is stored in `sys_complex_object` and travels in update sets with its parent.
- A complex pill mapped to a String input becomes a JSON string.

In a Script step, create an input variable mapped to earlier data and an output variable of the complex type, then assign by element name. Elements dot-walk by name: `outputs.contact.email_addresses[0].email`.

```javascript
// Script step in a custom action (server-side). Input variable userRecords = Records pill
// from a Look Up Records step; output variable contacts = Array.Object with child object
// elements name and email.
(function execute(inputs, outputs) {
    var contacts = [];
    while (inputs.userRecords.next()) {
        contacts.push({
            name: inputs.userRecords.getDisplayValue('name'),
            email: inputs.userRecords.getValue('email')
        });
    }
    outputs.contacts = contacts;
})(inputs, outputs);
```

The array-of-strings variant is the same with `Array.String` and a plain value pushed per record. Map the action output to the script output afterwards.

## Conversational action skills

A published action can be offered to AI assistants exactly like a subflow: **Conversational settings > Create a new skill**, description, discoverable assistants, roles, per-input and per-output visibility and defaults, autonomous mode, **Test > Trigger via a conversation**. Settings are described in [[Subflows in Workflow Studio]].

## Related

- [[Flow Core Actions Reference]] · [[Flow Action Steps Reference]] · [[Flow Data Types and Transform Functions]] · [[Flow Administration, Execution Details and Access]]
