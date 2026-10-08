---
type: reference
tags: [reference, platform, javascript, flows, automation, notifications, email, import-sets, reporting, forms-lists, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Building pro-code applications > ServiceNow SDK > Reference > ServiceNow Fluent API reference (read 2026-10-08 through the docs site): Dashboard API, Email Notification API, Flow API (Flow, Subflow, wfa.trigger, wfa.action, wfa.flow_logic, wfa.dataPill, wfa.subflow), Import Sets API, List API. Property tables are condensed; the long code samples are replaced by short ones of our own. https://www.servicenow.com/docs/r/application-development/servicenow-sdk/fluent-flow-api.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Fluent API - Dashboards, Notifications, Flows, Import Sets and Lists

**What it is:** the ServiceNow Fluent objects for dashboards, email notifications, flows and subflows, transform maps and list layouts. Second part of [[ServiceNow Fluent API Reference]], which explains `$id`, `$meta`, `Now.include` and the three forms a script property takes.

From the Brazil docs. Fluent code is compiled at build into records; nothing here runs by itself.

## Dashboard (`par_dashboard`)

| Level | Table | Properties |
|---|---|---|
| `Dashboard` | `par_dashboard` | `name` (required), `active`, `tabs`, `permissions`, `visibilities` (default: the base visibility rule) |
| `tabs[]` | `par_dashboard_tab` | `name` (required), `widgets`; order = array order. Its `active` flag has no effect |
| `widgets[]` | `par_dashboard_widget` | `component` (name such as `single-score`, `vertical-bar`, `line`, `list`, or the sys_id of a `sys_ux_macroponent`; names resolve at build), `height`, `width` (max 48), `position: { x, y }` (all required), `componentProps` |
| `permissions[]` | `par_dashboard_permission` | one of `user`, `group`, `role` (object or sys_id); `canRead` (true), `canWrite` (false), `canShare` (false), `owner` (false; at least one user should be owner) |
| `visibilities[]` | `par_dashboard_visibility` | `experience`: a `Workspace` object or the sys_id of a `sys_ux_page_registry` record. This is how a dashboard becomes a workspace home page |

The grid is 48 units wide. `componentProps` depends on the component:

| Property | Content |
|---|---|
| `dataSources[]` | `label`, `sourceType: 'table'`, `tableOrViewName`, `filterQuery` (encoded query), `id` |
| `metrics[]` | `dataSource` (a data source id), `id`, `aggregateFunction` (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `COUNT_DISTINCT`), `aggregateField`, `axisId` |
| `groupBy[]` | `groupBy: [{ dataSource, groupByField }]`, `maxNumberOfGroups`, `showOthers` |
| `trendBy` | `trendByFrequency` (`date`, `week`, `month`, `year`), `trendByFields: [{ field, metric }]` |
| `headerTitle`, `sortBy` (`value`, `label`, `field`) | |

| Visualisation kind | Needs | Not allowed |
|---|---|---|
| Trend (line) | `dataSources`, `metrics`, `trendBy` | |
| Group (bar) | `dataSources`, `metrics`, `groupBy` | `trendBy` |
| Simple (single score) | `dataSources`, `metrics` | `groupBy`, `trendBy` |

## EmailNotification (`sysevent_email_action`)

`table` and `triggerConditions` required. Do not target Task (`task`) itself. Other top-level properties: `name`, `description`, `category` (default: the base email category), `notificationType` (`email`, or `vcalendar` for a meeting invitation, which cannot be digested), `active` (true), `mandatory` (false), `enableDynamicTranslation` (false).

| Object | Properties |
|---|---|
| `triggerConditions` | `generationType` (required): `engine` (record inserted or updated; then `onRecordInsert` and / or `onRecordUpdate` must be true), `event` (`eventName` required; `affectedFieldOnEvent` `parm1` or `parm2`), `triggered` (manual; the other properties do not apply). `condition` (filter query), `advancedCondition` (script returning true or setting `answer`; both must pass), `weight` (0 to 1000, default 0), `order` (default 100, max 9999), `itemTable`, `item` |
| `recipientDetails` | `recipientUsers` (objects, sys_ids or addresses), `recipientGroups`, `recipientFields` (reference fields such as `assigned_to`, or a field holding an address), `excludeDelegates`, `isSubscribableByAllUsers`, `sendToCreator`, `eventParm1WithRecipient`, `eventParm2WithRecipient` (all false by default) |
| `emailContent` | `contentType` (`text/html` default, `text/plain`, `multipart/mixed`), `subject`, `messageHtml` (required for html and mixed), `messageText` (required for plain and mixed), `template` (`sysevent_email_template`), `style` (`sys_email_style`), `smsAlternate` (140 characters), `importance` (`low`, `high`), `includeAttachments`, `omitWatermark`, `from`, `replyTo`, `pushMessageOnly`, `pushMessageList` (`sys_push_notif_msg`, same table), `forceDelivery` (ignore the user's preferences). `message` is deprecated |
| `digest` | `allow` (false: everything else ignored), `default`, `type` (`single` = repeated triggers on one record, `multiple` = across records), `defaultInterval` (`sys_email_digest_interval`), `subject`, `html`, `text`, `template`, `separatorHtml`, `separatorText`, `from`, `replyTo` |

- Field values are inserted as `${field}`; inside a TypeScript template literal write `\${field}`.
- A template is accepted only if it has the same scope and table, the same scope and no table, or the same table and global scope.
- Weight: among duplicates (same table and recipients) only the highest weight is sent, the rest go to the Skipped mailbox.
- Recipients must be active users with an address on their primary notification device (`cmn_notif_device`).

Background: [[Email Notifications]], [[Email Watermarks, Digests, Retention and Translation]], [[Notification Variables and Links]].

## Flow and Subflow (`sys_hub_flow`)

Imported from `@servicenow/sdk/automation`: `Flow`, `Subflow`, `wfa`, `trigger`, `action`, `FlowVariables`. Column types for inputs, outputs and variables come from `@servicenow/sdk/core`.

```ts
// compiled into a flow record; the flow itself runs server side in the Flow Engine
import { action, Flow, wfa, trigger } from '@servicenow/sdk/automation'

export const exampleFlow = Flow(
  { $id: Now.ID['example_flow'], name: 'Example Flow', runAs: 'user' },          // 1 configuration
  wfa.trigger(trigger.record.created, { $id: Now.ID['example_trigger'] },         // 2 trigger
    { table: 'incident', condition: 'priority=1', run_flow_in: 'background' }),
  (params) => {                                                                   // 3 body
    wfa.flowLogic.if(
      { $id: Now.ID['if_no_group'], condition: `${wfa.dataPill(params.trigger.current.assignment_group, 'reference')}ISEMPTY` },
      () => {
        wfa.action(action.core.updateRecord, { $id: Now.ID['set_state'] }, {
          table_name: 'incident',
          record: wfa.dataPill(params.trigger.current.sys_id, 'reference'),
          values: TemplateValue({ state: '2' }),
        })
      })
  })
```

| Configuration | Values / default |
|---|---|
| `name` (required), `description` | |
| `runAs` | `user` (default: the roles of whoever started it) or `system` (bypasses role-based ACLs) |
| `runWithRoles` | roles used while running |
| `flowPriority` | `LOW`, `MEDIUM` (default), `HIGH` |
| `protection` | `read` (read-only) or empty |
| `access` | `public` (default) or `package_private` |
| `flowVariables` | object of column definitions |
| Subflow only | `inputs`, `outputs` (objects of column definitions), `category` |

**Triggers** (`wfa.trigger(type, { $id, annotation }, inputs)`):

| Family | Types |
|---|---|
| `trigger.record` | `created`, `updated`, `createdOrUpdated` |
| `trigger.scheduled` | `daily`, `weekly`, `monthly`, `repeat`, `runOnce` (for example `{ time: Time({ hours: 9, minutes: 0, seconds: 0 }) }`) |
| `trigger.application` | `inboundEmail`, `serviceCatalog`, `slaTask`, `knowledgeManagement`, `remoteTableQuery` |

Record trigger inputs: `table` (required), `condition`, `run_on_extended` (`'false'`), `run_flow_in` (`any`, `background`, `foreground`), `run_when_setting` (`both`, `interactive`, `non_interactive`), `run_when_user_setting` (`any`, `one_of`, `not_one_of`) with `run_when_user_list`, and for updates `trigger_strategy` (for example `unique_changes`). Inbound email inputs: `target_table`, `email_conditions`, `order`, `stop_condition_evaluation`.

Data available in the body: `params.trigger.current`, `params.trigger.previous`, `params.trigger.table_name`, `params.flowVariables`; for a subflow `params.inputs`, `params.outputs`; for a catalog trigger `params.trigger.request_item`; for inbound email the examples use both `params.trigger.email.subject` and `params.trigger.subject` / `from_address` / `inbound_email` (inconsistent in the page: check with `now-sdk explain`).

**Actions** (`wfa.action(action.core.<name>, { $id, annotation }, inputs)`; assign to a `const` to use the outputs, such as `result.Record.<field>` or `result.Records`):

| Group | `action.core.` |
|---|---|
| Records | `createRecord`, `createOrUpdateRecord`, `updateRecord`, `updateMultipleRecords`, `deleteRecord`, `lookUpRecord`, `lookUpRecords` |
| Communication | `sendNotification`, `sendEmail`, `sendSms` |
| Approval and tasks | `askForApproval`, `waitForApproval`, `createTask`, `createCatalogTask` |
| Catalog | `submitCatalogItemRequest`, `getCatalogVariables`, `recordProducer` |
| Other | `log`, `waitForCondition`, `waitForMessage`, `slaPercentageTimer` |

The examples also use `getAttachmentsOnRecord` and `copyAttachment`, which are not in the supported list.

**Flow logic**: `if` and `elseIf` (`condition` required), `else`, `forEach` (first argument: the array or records to loop over; the callback receives the item), `waitForADuration`, `exitLoop`, `endFlow`, `skipIteration`, `setFlowVariables` and `assignSubflowOutputs` (take the schema, `params.flowVariables` or `params.outputs`, then the values). Each takes `{ $id, annotation, label }`.

**Data pills**: `wfa.dataPill(<expression>, '<type>')` wraps a runtime value (trigger field, action output, subflow output) with its data type (`string`, `reference`, `boolean`, `integer`, `array.string`, `records` ...).

**Calling a subflow**: `const r = wfa.subflow(mySubflow, { $id, annotation }, { ...inputs, waitForCompletion: true })`; default is not to wait. Outputs are read as `r.<output>`.

**Discrepancy:** the reference tables write `wfa.flow_logic.<name>` while every complete example writes `wfa.flowLogic.<name>`; the examples are the more likely form (?).

Background: [[Flows, Subflows and Actions Overview and Architecture]], [[Flow Trigger Types Reference]], [[Flow Core Actions Reference]], [[Flow Logic Reference]], [[Subflows in Workflow Studio]].

## ImportSet (`sys_transform_map`)

Define in this order: (1) the staging table with `Table`, extending Import Set Row (`sys_import_set_row`); (2) the data source with `Record` on `sys_data_source`, whose `import_set_table_name` is the staging table; (3) the transform map with `ImportSet`, whose `sourceTable` is the same name.

| Property | Values / default |
|---|---|
| `name`, `targetTable`, `sourceTable` | required. Target: own scope, global, or a table writable by other applications. Source: own scope |
| `active` | **false** by default |
| `order` | 100 |
| `runBusinessRules` | true; false = like `setWorkflow(false)` |
| `enforceMandatoryFields` | `no` (default), `onlyMappedFields`, `allFields` |
| `copyEmptyFields`, `createOnEmptyCoalesce` | false |
| `runScript`, `script` | map-level script, a function `(source, target, map, log, isUpdate)` |
| `fields` | `{ targetField: 'sourceField' }` or `{ targetField: { ... } }` (rows in `sys_transform_entry`) |
| `scripts[]` | transform event scripts (`sys_transform_script`): `when` = `onStart`, `onBefore`, `onAfter` (default), `onReject`, `onForeignInsert`, `onChoiceCreate`, `onComplete`; `order`, `active`, `script` as a function `(source, map, log, target)` |

Field map object: `sourceField`, `coalesce` (false), `coalesceCaseSensitive`, `coalesceEmptyFields`, `choiceAction` (`create`, `ignore`, `reject`), `referenceValueField` (which column of the referenced table to match), `dateFormat`, `useSourceScript` with `sourceScript` (a function `(source)` returning the value).

The literal `NULL` in capitals is reserved: it clears a field. The vault has no note on import sets and transform maps yet.

## List (`sys_ui_list`)

`List({ $id, table, view, columns: [{ element: 'name', position: 0 }, ...] })`; all three required. `view` is a `Record` on `sys_ui_view`, a view name, or `default_view` imported from `@servicenow/sdk/core`.

## Related

- [[ServiceNow Fluent API Reference]] · [[Fluent API - Service Catalog, SLA, Service Portal and Workspace]] · [[Source-Code Development - Fluent, JavaScript Modules and React]]
