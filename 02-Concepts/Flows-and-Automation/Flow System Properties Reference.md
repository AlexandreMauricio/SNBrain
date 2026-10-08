---
type: reference
tags: [reference, flows, automation, instance-admin, admin]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Reference > Workflow Studio flow system properties (read 2026-10-08 through the docs site). https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/flow-designer-system-properties.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flow System Properties Reference

**What it is:** the system properties that tune the flow engine and the designer. Defaults are those the Australia docs state; not checked on an instance.

**Where:** *Page* = **Process Automation > Properties**. *Table* = System Properties (`sys_properties`). *Add* = the property does not exist until you create it in `sys_properties`. See [[System Properties]].

## Limits

| Property | Default | Where | Controls |
|---|---|---|---|
| `sn_flow_designer.max_actions` | 50 | Page | actions per flow or subflow |
| `sn_flow_designer.max_action_steps` | 20 | Page | steps per action |
| `sn_flow_designer.max_action_vars` | 20 | Table | inputs per action |
| `sn_flow_designer.max_script_variables` | 20 | Table | input plus output variables per Script step |
| `sn_flow_designer.max_iterations` | 1000 | Page | loop iterations (Do Until, Go back to). A change does not reach flows already running |
| `sn_flow_designer.max_decision_branches` | 100 | Table | branches of Make a decision |
| `sn_flow_designer.action_picker_limit` | 1000 | Page | records a look up action or step returns; the rest are ignored |
| `sn_flow_designer.trigger_picker_limit` | 1000 | Page | records a trigger lookup returns |
| `com.glide.hub.flow_engine.indirect_recursion_limit` | 3 | Page | times a flow may be re-entered indirectly in one transaction; 1 forbids it |
| `com.glide.hub.flow_api.default_execution_time` | 30000 ms | Table | how long a Flow API call may run; bounded by the REST transaction quota (60 s) |
| `com.glide.cs.fdih.interactive.timeout` | 120 s | Table | Integration Hub action timeout (the docs call it the "action workflow" timeout; exact scope unconfirmed) |

Raising the limits risks hitting the transaction quota that stops flows after one hour.

## Logging and reporting

| Property | Default | Where | Controls |
|---|---|---|---|
| `com.snc.process_flow.reporting.level` | Off | Page | execution details: Off, Basic, Full, Trace ([[Flow Administration, Execution Details and Access]]) |
| `com.snc.process_flow.reporting.serialized.val_size_limit` | 16384 bytes | Table | truncation of runtime values in the details; 0 or less = never truncate (costly) |
| `com.glide.hub.flow_engine.log_level` | WARN | Page | engine messages written to `sys_flow_log`: DEBUG, INFO, WARN, ERROR |
| `com.glide.hub.flow_engine.listener_trace.threshold` | ERROR | Page | system log entries caused by the flow (for example a business rule it fired) copied to the flow log: None, DEBUG, INFO, WARN, ERROR |
| `com.glide.hub.flow.approval.logging` | WARN | Page | log level of Ask for Approval |
| `com.glide.oneapi.fdih.async.quick.mode` | true | Add | flows run from a custom AI skill use quick mode (no execution details). Set false, with reporting on, to debug them |

## Designer

| Property | Default | Where | Controls |
|---|---|---|---|
| `sn_flow_designer.input_scripts_enabled` | true | Page | inline scripts allowed at all |
| `sn_flow_designer.flow_variables_enabled` | true | Table | flow variables allowed |
| `sn_flow_designer.autosave_version_interval` | 60 min | Page | autosaves by one user within the interval collapse into one history entry |
| `sn_flow_designer.maximum_flow_history_records_per_flow` | 100 (30 to 200) | Page | history entries kept per flow; the oldest is overwritten |
| `sn_flow_designer.action_picker.popular_actions.max_number` | 10 | Table | size of the Popular list |
| `sn_flow_designer.action_picker.popular_actions.last_num_of_days` | 7 | Table | usage window behind it |

## Stages

| Property | Default | Where | Controls |
|---|---|---|---|
| `com.glide.hub.flow_engine.stage_display.show_duration` | true | Page | durations in the stage column |
| `com.glide.hub.flow_engine.stage_display.show_approvers` | true | Add | approver names in the stage field |
| `com.glide.hub.flow_engine.stage_display.show_approvers_limit` | 5 | Add | how many; above 10 can break list rendering |
| `com.glide.hub.flow.current_stage_status_on_cancel` | complete | Add | status of the running stage when the flow is cancelled (`cancelled` or `complete`); later stages always become cancelled |

## Approvals (Ask for Approval)

| Property | Default | Where | Controls |
|---|---|---|---|
| `com.glide.hub.flow.approval.allow_inactive_entity` | INDIVIDUAL,GROUP | Add | approvals for inactive approvers: `INDIVIDUAL` (inactive users named directly), `GROUP` (inactive groups; their active members still get approvals), both, or empty (none). Inactive group members never get one |
| `com.glide.hub.flow.approval.default_approval_field` | true | Add | use the table's default approval field when the input is empty. False = behave like legacy workflow approval activities |
| `com.glide.hub.flow.approval.show_approver_name_in_audit` | true | Add | audit comment names the approver; false = the user who started the flow |
| `com.glide.hub.flow.approval.show_higher_role_audit_comment` | true | Add | comment when the decision was allowed by a role |
| `com.glide.hub.flow.approval.show_delegate_audit_comment` | true | Add | comment when a delegate decided |
| `com.glide.hub.flow.approval.show_impersonate_audit_comment` | true | Add | comment when decided while impersonating |

## Other

| Property | Default | Where | Controls |
|---|---|---|---|
| `com.glide.hub.pause_low_priority_flows_enabled` | true | Table | pause low-priority flows when high-priority ones queue |
| `com.glide.hub.flow.restricted_caller_access.track_flows_as_source` | true (false on instances upgraded from San Diego or earlier) | Table | flows and actions as sources of restricted caller access requests; turning it on means regenerating and approving the privileges |
| `com.glide.hub.flow_engine.wait_for_email_reply_input_state` | sent,send-ready | Add | email types Wait For Email Reply accepts (also `send-translation-ready`) |

Properties named in other notes and not on this page: `com.snc.process_flow.reporting.iteration.lastn`, `sn_flow_designer.save_as_you_go_enabled`, `glide.hub.flow.inbound_email_trigger.show_advanced`, `sn_flow_designer.sync_action_execution_timeout_in_seconds`, `glide.fdih.retry.max_count`, `glide.fdih.retry.max_time_in_seconds`.

## Related

- [[Flow Administration, Execution Details and Access]] · [[Flows, Subflows and Actions Overview and Architecture]] · [[Flow Logic Reference]]
