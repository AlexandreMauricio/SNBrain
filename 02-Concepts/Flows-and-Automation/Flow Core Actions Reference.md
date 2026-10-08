---
type: reference
tags: [reference, flows, automation, service-catalog, email, sla, ai]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Reference > Workflow Studio actions (read 2026-10-08 through the docs site): Workflow Studio actions and each action page - Add Worknote Link to Context, Ask for Approval, Associate Record to Email, Create Catalog Task, Create Flow Data, Create Record, Create or Update Record, Create Task, Copy / Delete / Look Up / Move Attachment, Delete Record, Execute Skill, Fire Event, Get Attachments on Record, Get Catalog Variables, Get Email Header, Get Latest Response Text From Email, Log, Look up email attachments, Look Up Record, Look Up Records, Move Email Attachments to Record, Record Producer, Send Email, Send Notification, Send SMS, SLA Percentage Timer, Submit Catalog Item Request, Update Multiple Records, Update Record, Use an AI agent, Wait For Condition, Wait For Email Reply, Wait For Message. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/flow-actions.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flow Core Actions Reference

**What it is:** the actions of the *ServiceNow Core* spoke, present on every instance and usable in any flow or subflow by `flow_designer` or admin. They cannot be opened or edited. Custom ones: [[Custom Actions, Dynamic Inputs and Error Evaluation]]. Logic blocks: [[Flow Logic Reference]].

**Finding actions in the picker:** search by action or spoke name; **Most Recent** (yours); **Popular** (the organisation's, rebuilt by a job every seven days); **Installed spokes**.

Record actions enforce server-side rules (data policies, business rules, dictionary mandatory fields). UI policies never apply.

## Records

| Action | Inputs | Outputs | Notes |
|---|---|---|---|
| **Create Record** | Table, Fields (template values) | Record, Table | cannot set several journal fields at once (comments and work notes) |
| **Create or Update Record** | Table, Fields, per field **Determines uniqueness** | Record, Table, Status (`created`, `updated`, `error`), Error Message | updates the record matching the unique fields, otherwise creates. No unique field = always creates. More than one match = error, nothing updated |
| **Create Task** | Table (a Task extension), Field Values, **Wait** | Task, Table | set **Parent** to attach it. Wait pauses until the task is inactive; accepts a True/False pill |
| **Update Record** | Record, Table, Field Values | Record, Table Name | when the record comes from a script, return null if nothing matched: some GlideRecord lookups would otherwise hand over every record |
| **Update Multiple Records** | Table, Conditions, Field Values, Order by, Sort Type, Don't fail on error | Count, Error Message, Status (0 / 1) | replaces Look Up Records + For Each + Update |
| **Delete Record** | Record | none | |
| **Look Up Record** | Table, Conditions, Order by, Sort Type, **If multiple records are found** (return first / fail the step), **Don't fail on error** | Record, Table, Status (0 / 1), Error Message | for a reference field compare against the pill's **Sys ID**: [Requested by] [is] [Caller > Sys ID] |
| **Look Up Records** | Table, Conditions, Order by, Sort Type, **Max Results** | Records (list of sys_ids), Table, Count | keep Max Results at 1000 or less; process with For Each; conditions can come from an inline script |

Guarded update inside an inline script (server-side, flow scope):

```javascript
var ci = new GlideRecord('cmdb_ci');
if (ci.get(fd_data.trigger.current.cmdb_ci.sys_id))
    return ci;
return null;
```

## Approvals and waiting

| Action | Inputs | Outputs | Notes |
|---|---|---|---|
| **Ask for Approval** | Record, Table, **Approval Reason** (stored on Approval `sysapproval_approver`), **Approval Field**, **Journal Field**, **Rules**, **Due Date** | **Approval State** | see below |
| **Wait For Condition** | Record, Table, Conditions, Enable Timeout, Duration, Schedule | State (0 / 1) | see below |
| **Wait For Email Reply** | Record (an outbound Email `sys_email`), Enable Timeout, Duration, Schedule | Email Reply, State (0 = reply, 1 = none) | the email needs a target record and type sent or send-ready (`com.glide.hub.flow_engine.wait_for_email_reply_input_state`). Feed it the output of Send Email. Timeout in days rather than hours. An existing reply means no pause |
| **Wait For Message** | Message, Enable timeout, Duration | Payload, State (0 / 1) | resumes when a script calls the flow API `sendMessage(contextSysId, message, payload)` with the same text. Replacement for the workflow activity *Wait for WF Event*. Pairs with *Go back to* to resubmit a rejected approval |
| **SLA Percentage Timer** | Percentage | Scheduled End Date/Time, Status, Total Duration (seconds; null unless Completed) | see below |

### Ask for Approval rules

Rule sets, each *Approve* or *Reject*, joined by OR:

- **Anyone approves**, **All users approve**, **All responded and anyone approves**, **% of users approve**, **# of users approve**.
- Approvers: users, groups, a field of a record, or **Manual approvers** (whoever is added to the record's Approvers related list).
- Always pair approval with a rejection rule (or a due date): a rule set with no counterpart that is not met ends as **Cancelled**; with neither, the flow waits forever.
- **Due Date** approves, rejects or cancels automatically after a duration, optionally on a schedule.
- Approvals are created for inactive users and groups too unless `com.glide.hub.flow.approval.allow_inactive_entity` says otherwise.
- Never ask for approval on the same record in two branches of *Do the following in parallel*.

Approval State values: `not requested`, `requested`, `approved`, `rejected`, `cancelled`, `not_required`, `skipped`. Background: [[Classic Approvals]].

### Wait For Condition rules

- Re-evaluated only when a field of **that record** changes. Conditions must use fields of the record's own table: no dot-walking, no catalog variables. To watch a related record, look it up and wait on it.
- A condition relative to time ("created more than 2 days ago") is never met: use *Wait for a duration*.
- At least one condition. A Conditions-type pill can supply them dynamically.
- If the record is deleted the flow continues.
- With **Enable Timeout** a **Duration** is required, optionally on a **Schedule** (10 hours on an 8-5 schedule spans business days).
- Cancel flows whose condition can no longer happen.
- Unsupported tables: audit (`sys_audit*`), email (`sys_email*`), events and notifications (`sysevent*`), import sets, logs (`syslog`, `sp_log`), ECC queue and MID tables, scheduled jobs (`sys_trigger`), update sets, upgrade history, text index (`ts_*`), user sessions and preferences, legacy workflow contexts (`wf_*`), `sys_dictionary_override`, and other system tables.

### SLA Percentage Timer

Only in a flow started by the **SLA Task** trigger (never in a subflow). The end time is the given percentage of the SLA's total duration (50% of 24 hours = 12 hours), independent of elapsed-time fields.

| Status | When | Flow then |
|---|---|---|
| Waiting | end time in the future; also after a resume | waits |
| Completed | end time reached | continues |
| Paused | SLA paused; a new end time is computed on resume | waits |
| Skipped | end time already past when the SLA attached | continues |
| Repair | the same, when the flow was started by an SLA repair | continues |
| (null) | SLA cancelled or stopped | flow ends Cancelled |

Give each timer in a flow its own cumulative percentage (25, 50, 75), branch on Status, and start from a copy of the shipped SLA flows. See [[SLA Definitions and Task SLAs]].

## Service Catalog

| Action | Inputs | Outputs | Notes |
|---|---|---|---|
| **Create Catalog Task** | Table, **Requested Item**, Short Description, Fields, **Wait**, **Template Catalog Item**, **Catalog Variables** (slush bucket) | Catalog Task | the template item only fills the variable list (no pills); chosen variables show on the task |
| **Get Catalog Variables** | **Submitted Request** (the requested item), **Template Catalog Items and Variable Sets**, **Catalog Variables** | one pill per variable | values as of the moment it runs; run it again after a wait if they may change |
| **Submit Catalog Item Request** | Catalog Item (plus its variables as extra inputs), Quantity, Special Instructions, Delivery Address, Requested for, Don't fail on error, Wait for Completion, Enable timeout, Duration, Schedule | Requested Item, Status (0 success, 1 error, 2 timeout), Error Message | not supported: list collector, lookup multiple choice, lookup select box variables |
| **Record Producer** | Catalog Item, Catalog Item Inputs, Don't fail on error | Record, Table, Status (0 / 1), Error Message | "Record generation failed" usually means other logic inserting records aborted it |

For the last two, escape quotation marks in string pills with the *Replace String* transform (values are stored as JSON). Data model: [[Request Management Data Model and Process]].

## Email, notifications and events

| Action | Inputs | Outputs | Notes |
|---|---|---|---|
| **Send Email** | Target Record, Table, To, CC, BCC, Subject, Body | Email | addresses separated by commas or spaces, or user / group pills (group needs a group email, or **Include members**). Recipients within `glide.email.smtp.max_recipients`. Body takes inline styles only; `${...}` template variables are not processed, replace them with pills. Replies update the target record. ACLs apply when the flow runs as the user |
| **Send Notification** | Record, Table, Notification (`sysevent_email_action`) | none | predefined recipients and content ([[Email Notifications]]) |
| **Send SMS** | Recipients (user or group pills only), Message | Email | uses the email-to-text gateway, which carriers have dropped: prefer Notify |
| **Fire Event** | Event (`sysevent_register`), Record, Table, Parameter 1, Parameter 2 | none | writes to Event (`sysevent`) ([[Events and the Event Queue]]) |
| **Associate Record to Email** | Email Record, Target Record | none | sets the email's Target |
| **Get Email Header** | Email Record, Target Header | the header value | first header when names repeat; for example `X-ServiceNow-Source` |
| **Get Latest Response Text From Email** | Email Record | Latest Response Text | the newest reply or forward only; whole body for an email of type New |
| **Look up email attachments** | Email record | Email Attachment (`sys_email_attachment`) records | loop with For Each |
| **Move Email Attachments to Record** | Email Record, Target Record | none | |

## Attachments

| Action | Inputs | Outputs | Notes |
|---|---|---|---|
| **Look Up Attachment** | File Name (empty = all), Source Record | Attachment Sys ID (first match, a string), Attachment List (JSON string of `sys_id`, `file_name`, `file_size_in_bytes` when several match) | turn the sys_id into a record with Look Up Record on `sys_attachment` |
| **Get Attachments on Record** | File name (partial allowed), Source Record | Attachment List (records), Count | |
| **Copy Attachment** | Source Attachment Record, Target Record, Table | none | |
| **Move Attachment** | Source Attachment Record, Target Record, Table | none | removes it from the other record |
| **Delete Attachment** | Source Record, Table, Attachment File Name, Delete All Attachments? | none | every attachment with that name is deleted |

## Logging and context

| Action | Inputs | Notes |
|---|---|---|
| **Log** | Log level (Error, Warn, Info), Log message | writes to `sys_flow_log`, shown in the execution details. Typed text is limited to 255 characters; pill values are not |
| **Add Worknote Link to Context** | Table, Record, Journal Field | writes a link to this run's execution details into a journal field |
| **Create Flow Data** | Definition (`sys_flow_data_definition`), Assigned To, Assignment Group, Wait for user input | output Record (`sys_flow_data`). Collects input from the person working a playbook activity ([[Playbook Activities, Decisions and Variants]]) |

## AI

| Action | Needs | Inputs | Outputs |
|---|---|---|---|
| **Execute Skill** | Now Assist Skill Kit | Workflow, Product, Feature, Skill Config (dynamic choices), Skill Inputs | Output (dynamic object) |
| **Use an AI agent** | Now Assist AI agents plugin (Flow Designer Gen AI spoke) | AI Agent, **Support User** (reviews in supervised mode), **Objective**, Wait for completion, **Execution mode** (Autonomous / Supervised), **Expected outputs** (label, name, type each), Conversation label, Context Memory | Execution Plan Record, Agent Output, Agent Message, Agent Status (success / failure) |

In supervised mode the flow pauses until the support user answers in the Now Assist panel.

## Related

- [[Flow Logic Reference]] · [[Flow Action Steps Reference]] · [[Flow Data Types and Transform Functions]] · [[Building Flows - Properties, Triggers, Stages and Error Handling]]
