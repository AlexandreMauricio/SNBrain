---
type: reference
tags: [reference, platform, scripting, javascript, schema, access-control, business-rule, client-script, script-include, ui-action, ui-policy, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Building pro-code applications > ServiceNow SDK > Reference > ServiceNow Fluent API reference (read 2026-10-08 through the docs site): ServiceNow Fluent API reference, ServiceNow Fluent language constructs, and the API pages Access Control List, Application Menu, Automated Test Framework Test, Business Rule, Client Script, Cross-Scope Privilege, Property, Record, Role, Script Action, Script Include, Scripted REST, Table, UI Action, UI Page, UI Policy. Property tables are condensed (name, values, default); the long code samples are replaced by short ones of our own. The page itself says the newest API documentation is on GitHub. https://www.servicenow.com/docs/r/application-development/servicenow-sdk/servicenow-fluent-api-reference.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ServiceNow Fluent API Reference

**What it is:** the objects used in `.now.ts` files to declare application metadata, with the table each one writes to and its properties. This note holds the language constructs and the security, script, data and form APIs; the rest are in [[Fluent API - Dashboards, Notifications, Flows, Import Sets and Lists]] and [[Fluent API - Service Catalog, SLA, Service Portal and Workspace]].

From the Brazil docs. Language and project layout: [[Source-Code Development - Fluent, JavaScript Modules and React]]. Tools: [[ServiceNow IDE and ServiceNow SDK]]. `now-sdk explain <topic>` prints this documentation in the terminal ([[ServiceNow SDK CLI Reference]]).

Fluent code runs nowhere by itself: the build turns each object into a record. The scripts it carries run where that record type runs (server or client), in the application's scope.

## All APIs and their tables

| Object | Table | Import from |
|---|---|---|
| `Acl` | `sys_security_acl` | `@servicenow/sdk/core` |
| `ApplicationMenu` | `sys_app_application` | core |
| `Test` | `sys_atf_test` | core |
| `BusinessRule` | `sys_script` | core |
| `ClientScript` | `sys_script_client` | core |
| `CrossScopePrivilege` | `sys_scope_privilege` | core |
| `Dashboard` | `par_dashboard` | core |
| `EmailNotification` | `sysevent_email_action` | core |
| `Flow`, `Subflow` | `sys_hub_flow` | `@servicenow/sdk/automation` |
| Import Sets | `sys_transform_map` | see the second note |
| `List` | `sys_ui_list` | core |
| `Property` | `sys_properties` | core |
| `Record` | any table | core |
| `Role` | `sys_user_role` | core |
| Script Action | `sysevent_script_action` | core |
| `ScriptInclude` | `sys_script_include` | core |
| Scripted REST | `sys_ws_definition` | core |
| Service Catalog | `sc_cat_item`, `sc_cat_item_producer` | see the third note |
| SLA | `contract_sla` | see the third note |
| Service Portal | `sp_widget` | see the third note |
| `Table` | `sys_db_object` | core |
| UI Action | `sys_ui_action` | core |
| `UiPage` | `sys_ui_page` | core |
| UI Policy | `sys_ui_policy` | core |
| `Workspace` | `sys_ux_page_registry` and related | core |

## Language constructs

| Construct | Use |
|---|---|
| `Now.ID['name' or number]` | value of `$id`: a readable key hashed into the record's sys_id at build. Only for defining, never for referring |
| a `const` holding an object | how to refer to metadata of the **same** application: `roles: [managerRole]` |
| `Now.ref('table', 'sys_id' or { column: 'value' })` | refer to a record of **another** application not defined in source, by sys_id, by coalescing values, or both |
| `Now.include('./path/file')` | take a property's text from a file (script, HTML, CSS) so it gets proper highlighting; syncs both ways |
| `Now.attach('./path/image')` | attach an image (`jpg`, `jpeg`, `png`, `gif`, `bmp`, `ico`, `svg`) to a field of type `user_image`; syncs both ways; assign to a `const` to reuse |

```ts
import { Role, Record } from '@servicenow/sdk/core'
const managerRole = Role({ $id: Now.ID['manager_role'], name: 'x_acme_example.manager' })
Role({
  $id: Now.ID['admin_role'], name: 'x_acme_example.admin',
  containsRoles: [managerRole, Now.ref('sys_user_role', { name: 'itil' })],
})
```

## Properties shared by most objects

| Property | Meaning |
|---|---|
| `$id` | required almost everywhere: `Now.ID[...]` |
| `$meta: { installMethod }` | `'demo'` = written to `metadata/unload.demo`, installed only with *Load demo data*; `'first install'` = written to `metadata/unload`, installed only the first time |
| `protectionPolicy` | on script-bearing objects: `read` (visible, not editable after install) or `protected` (script hidden and encrypted in memory); unset = customisable |
| script properties | three forms: a function imported from a JavaScript module; `Now.include('path')`; or an inline string / template literal |
| `active` | default true |

## Acl (`sys_security_acl`)

One operation per rule. Must have at least one of roles, security attribute, condition, script.

| Property | Values / default |
|---|---|
| `type` | `record` (default), `rest_endpoint`, `ui_page`, `processor`, `graphql`, `pd_action`, `ux_data_broker`, `ux_page`, `ux_route`, `client_callable_flow_object`, `client_callable_script_include`. Cannot be changed later: delete and recreate |
| `operation` (required) | `execute`, `create`, `read`, `write`, `delete`, `conditional_table_query_range`, `data_fabric`, `query_match`, `query_range`, `edit_task_relations`, `edit_ci_relations`, `save_as_template`, `add_to_list`, `report_on`, `list_edit`, `report_view`, `personalize_choices`. Must be `execute` for types `client_callable_*`, `graphql`, `processor`, `rest_endpoint` |
| `table`, `field` | required `table` for `record`, `pd_action`, `ux_*`; `field` may be `*` |
| `name` | required for `rest_endpoint`, `ui_page`, `processor`, `graphql`, `client_callable_*` |
| `roles` | Role objects or sys_ids |
| `condition` | filter query |
| `script` | must evaluate to true or set `answer`; not supported for `graphql`. Condition **and** script must both pass |
| `securityAttribute`, `localOrExisting` | predefined condition; `Local` (default) or `Existing` |
| `decisionType` | `allow` (default) or `deny` |
| `adminOverrides` | default true (the `nobody` role still beats it) |
| `active`, `description` | |

Roles background: [[Users, Groups and Roles Overview]]. The vault has no note on access control rules yet.

## ApplicationMenu (`sys_app_application`)

`title` (required), `active`, `roles` (Role objects or names), `category` (a `Record` on `sys_app_category`), `hint`, `description`, `name`, `order` (default 100).

## Test (`sys_atf_test`)

`Test({ $id, name, description, active, failOnServerError (default true) }, (atf) => { ...steps... })`. A step's outputs can feed later steps: `const out = atf.form.submitForm({...})` then `recordId: out.record_id`.

| Category | Steps (`atf.<category>.<step>`) |
|---|---|
| `applicationNavigator` | `applicationMenuVisibility`, `moduleVisibility`, `navigateToModule` |
| `email` | `generateInboundEmail`, `generateInboundReplyEmail`, `generateRandomString`, `validateOutboundEmail`, `validateOutboundEmailGeneratedByFlow`, `validateOutboundEmailGeneratedByNotification` |
| `form` | `addAttachmentsToForm`, `clickDeclarativeAction`, `clickModalButton`, `clickUIAction`, `declarativeActionVisibility`, `fieldStateValidation`, `fieldValueValidation`, `openExistingRecord`, `openNewForm`, `setFieldValue`, `submitForm`, `uiActionVisibility` |
| `form_SP` | `addAttachmentsToForm`, `clickUIAction_SP`, `fieldStateValidation_SP`, `fieldValueValidation_SP`, `openForm_SP`, `openServicePortalPage`, `setFieldValue_SP`, `submitForm_SP`, `uiActionVisibilityValidation_SP` |
| `reporting` | `responsiveDashboard`, `responsiveDashboardSharing` |
| `rest` | `sendRestRequest`, `assertStatusCode`, `assertStatusCodeName`, `assertResponseTime`, `assertResponseHeader`, `assertResponsePayload`, `assertResponseJSONPayloadIsValid`, `assertJsonResponsePayloadElement`, `assertResponseXMLPayloadIsWellFormed`, `assertXMLResponsePayloadElement` |
| `server` | `addAttachmentsToExistingRecord`, `checkoutShoppingCart`, `createUser`, `impersonate`, `log`, `recordDelete`, `recordInsert`, `recordQuery`, `recordUpdate`, `recordValidation`, `replayRequestItem`, `runServerSideScript`, `searchForCatalogItem`, `setOutputVariables` |
| `catalog` | `addItemToShoppingCart`, `openCatalogItem`, `openRecordProducer`, `orderCatalogItem`, `setCatalogItemQuantity`, `setVariableValue`, `submitRecordProducer`, `validatePriceAndRecurringPrice`, `variableStateValidation`, `validateVariableValue` |
| `catalog_SP` | the same with `_SP`, plus order guide steps (`openOrderGuide_SP`, `navigatewithinOrderGuide_SP`, `addOrderGuidetoShoppingCart_SP`, `reviewIteminOrderGuide_SP`, `reviewOrderGuideSummary_SP`, `submitOrderGuide_SP`, `validateOrderGuideItem_SP`) and multi-row variable set steps (`addRowToMultiRowVariableSet_SP`, `saveCurrentRowOfMultiRowVariableSet_SP`) |
| `uiTestScript` | `runTest` |

Not every field of a step form exists as a Fluent property.

## BusinessRule (`sys_script`)

Server side. `name` and `table` required.

| Property | Values / default |
|---|---|
| `when` | `before` (default), `after`, `async`, `display` |
| `action` | array of `insert`, `update`, `delete`, `query` |
| `order` | 100 |
| `script` | module function, `Now.include`, or inline |
| `condition` | JavaScript condition, evaluated separately (do not also put it in `filterCondition` or the script). For async rules, `glide.businessrule.async_condition_check` = true re-evaluates it before running |
| `filterCondition` | filter query |
| `roleConditions` | Role objects the acting user must hold |
| `setFieldValue` | encoded set-values string |
| `addMessage`, `message` | show a message |
| `abortAction` | default false; true aborts the database action (a message can still be shown) |
| `active`, `description`, `protectionPolicy` | |

Background: [[Business Rules]].

## ClientScript (`sys_script_client`)

Client side (browser). `name` and `table` required.

| Property | Values / default |
|---|---|
| `type` | `onLoad`, `onChange`, `onSubmit`, `onCellEdit` |
| `field` | for `onChange` and `onCellEdit` |
| `uiType` | `desktop` (default), `mobile_or_service_portal`, `all` |
| `appliesExtended` | false; true = also child tables |
| `global`, `view` | true = all views; false = only `view` |
| `isolateScript` | default false. The page's wording of the two values contradicts itself (?); on the form the equivalent is **Isolate script** |
| `messages` | strings available through `getMessage()` |
| `script` | `Now.include` or inline (no module functions: modules are server side) |

## CrossScopePrivilege (`sys_scope_privilege`)

All required: `status` (`requested`, `allowed`, `denied`), `operation` (`create`, `read`, `write`, `delete` for tables; `execute` for script includes and scriptable objects), `targetName`, `targetScope`, `targetType` (`sys_db_object`, `sys_script_include`, `scriptable`). Background: [[Application Access Settings and Cross-Scope Privileges]].

## Property (`sys_properties`)

| Property | Values / default |
|---|---|
| `name` (required) | `<scope>.<name>` |
| `value` | stored as a string whatever the type: `gs.getProperty()` returns `'true'`, not a Boolean |
| `type` | `string`, `integer`, `boolean`, `choicelist`, `color`, `date_format`, `image`, `password`, `password2`, `short_string`, `time_format`, `timezone`, `uploaded_image` |
| `choices` | for `choicelist`: `['Blue=0000FF', 'Red=FF0000']` (label=value) |
| `roles` | `{ read: [...], write: [...] }`, Role objects or names |
| `ignoreCache` | false = flush all server caches on change (current value everywhere); true = flush only the properties cache, for values changing more often than monthly |
| `isPrivate` | false; true = kept out of update sets |
| `description` | |

## Record (any table)

`Record({ $id, table, data: { field: value, ... } })`. The way to define metadata that has no API of its own (menu categories, UI views, data sources, email templates) and demo data (with `$meta.installMethod: 'demo'`). Field values may use `Now.include` and `Now.attach`. The page's examples write some field names in camelCase (`shortDescription`, `callerId`) and others in snake case (`url_suffix`); which form is required is not stated (?).

## Role (`sys_user_role`)

| Property | Values / default |
|---|---|
| `name` | `<scope>.<name>` |
| `containsRoles` | Role objects |
| `assignableBy` | roles allowed to assign it |
| `canDelegate` | true |
| `grantable` | true (can be granted on its own) |
| `elevatedPrivilege` | false; true = must be elevated to before use |
| `scopedAdmin` | false; true = an application administrator role ([[Application Administration and Collaboration Descriptors]]) |
| `description` | |

## ScriptAction (`sysevent_script_action`)

Server side, run by an event. Required: `name`, `script`, `eventName`. `active` defaults to **false**. `order` 100, `conditionScript` (for example `"gs.hasRole('x_acme_example.user')"`), `description`. Background: [[Events and the Event Queue]].

## ScriptInclude (`sys_script_include`)

Server side. The docs recommend JavaScript modules for new reusable code.

| Property | Values / default |
|---|---|
| `name` (required) | must equal the class (or function) name in the script |
| `script` (required) | `Now.include` or inline; one class or one function |
| `apiName` | `<scope>.<name>` |
| `accessibleFrom` | `package_private` (default: own scope only) or `public` |
| `callerAccess` | `restriction` (cross-scope calls need approval) or `tracking` (auto-approved and logged) |
| `clientCallable` | false; true = callable through GlideAjax (subject to an ACL) |
| `mobileCallable`, `sandboxCallable` | false; sandbox only when really needed |
| `active`, `description`, `protectionPolicy` | |

## RestApi (`sys_ws_definition`)

| Level | Table | Properties |
|---|---|---|
| `RestApi` | `sys_ws_definition` | `name`, `serviceId` (both required; the id appears in the URI), `active`, `shortDescription`, `consumes` and `produces` (default `application/json,application/xml,text/xml`), `docLink`, `enforceAcl` (Acl objects or sys_ids; `[]` = none; default *Scripted REST External Default*), `policy` (`read`, `protected`), `routes`, `versions` |
| `routes[]` | `sys_ws_operation` | `script` (required; module function, include or inline), `path` (default `/`; parameters as `/items/{id}`), `method` (`GET` default, `POST`, `PUT`, `PATCH`, `DELETE`), `name`, `version` (required when the API has versions), `authentication` (true), `authorization` (true = ACLs enforced), `internalRole` (true = requires `snc_internal`, only with the Explicit Roles plugin), `enforceAcl`, `consumes`, `produces`, `requestExample`, `shortDescription`, `parameters`, `headers`, `active` |
| `parameters[]`, `headers[]` | `sys_ws_query_parameter`, `sys_ws_header` | `name` (required), `required` (false), `exampleValue`, `shortDescription` |
| `versions[]` | `sys_ws_version` | `version` (required), `active`, `deprecated`, `isDefault` (reachable without the version in the path), `shortDescription` |

```ts
// handler runs server side in the application scope when the endpoint is called
import { RestApi } from '@servicenow/sdk/core'
import { process } from '../server/handler.js'
RestApi({
  $id: Now.ID['example_api'], name: 'Example API', serviceId: 'example_api',
  versions: [{ $id: Now.ID['v1'], version: 1, isDefault: true }],
  routes: [{ $id: Now.ID['get_item'], path: '/items/{id}', method: 'GET', version: 1, script: process }],
})
```

The page's own ACL sample uses `operations: ['execute']` (plural, array) while the ACL page defines `operation` (singular string).

## Table (`sys_db_object`)

Export the object under a variable with the same name as the table to get column type-ahead.

| Property | Values / default |
|---|---|
| `name` (required) | `<scope>_<name>`, lower case, 80 characters at most. To add columns to a table of another scope: give that table's name followed by `as any` and prefix each column with your scope (`x_acme_example_mycolumn`) |
| `schema` (required) | object of `key: <Type>Column({...})`; the key is the column name |
| `extends` | parent table (must be extensible and reachable) |
| `label` | string, or array of label objects; default = the name |
| `display` | the display column |
| `extensible` | false |
| `accessibleFrom` | `public` (default) or `package_private` |
| `callerAccess` | `none` (default), `tracking`, `restricted` |
| `actions` | what scripts of other scopes may do: `read` (default), `create`, `update`, `delete` |
| `allowWebServiceAccess`, `allowNewFields`, `allowUiActions`, `allowClientScripts` | false |
| `audit`, `readOnly`, `textIndex`, `liveFeed` | false |
| `scriptableTable` | false; true = a remote table |
| `attributes` | dictionary attributes as key and value |
| `index` | `[{ name, element, unique }]` |
| `autoNumber` | `{ prefix: 'pre', number: 1000, numberOfDigits: 7 }` (`sys_number`); also needs a column whose default is `'javascript:getNextObjNumberPadded();'`. Changing the digit count can renumber existing records |
| `licensingConfig` | `ua_table_licensing_config`; only for partners selling on the Store (`licenseModel` `none`, `fulfiller`, `producer`, and related conditions) |

These mirror the application access settings of a table: [[Application Access Settings and Cross-Scope Privileges]].

**Column types** (`sys_dictionary`): `StringColumn`, `MultiLineTextColumn`, `HTMLColumn`, `TranslatedTextColumn`, `TranslatedFieldColumn`, `ChoiceColumn`, `RadioColumn`, `ListColumn`, `SlushBucketColumn`, `BooleanColumn`, `IntegerColumn`, `DecimalColumn`, `FloatColumn`, `DateColumn`, `DateTimeColumn`, `CalendarDateTime`, `BasicDateTimeColumn`, `DueDateColumn`, `IntegerDateColumn`, `ScheduleDateTimeColumn`, `OtherDateColumn`, `TimeColumn`, `DurationColumn`, `ReferenceColumn`, `DocumentIdColumn`, `TableNameColumn`, `FieldNameColumn`, `FieldListColumn`, `SystemClassNameColumn`, `UserRolesColumn`, `DomainIdColumn`, `DomainPathColumn`, `ScriptColumn`, `ConditionsColumn`, `TemplateValueColumn`, `ApprovalRulesColumn`, `NameValuePairsColumn`, `JsonColumn`, `UrlColumn`, `EmailColumn`, `Password2Column`, `GuidColumn`, `VersionColumn`, `BasicImageColumn`, `GenericColumn`. Background: [[Field Types Reference]].

| Column property | Values / default |
|---|---|
| `label` | string or label objects (`language`, `label`, `hint`, `help`, `plural`, `url`); stored in `sys_documentation` |
| `maxLength` | under 255 = single line, 255 or more = multi-line box. Do not shorten a column that holds data |
| `mandatory`, `readOnly` | false |
| `readOnlyOption` | `instance_configured`, `display_read_only` (read-only in the UI, writable by client scripts and server APIs), `client_script_modifiable` (client scripts yes, server APIs no), `strict_read_only` (nothing) |
| `active` | true |
| `default` | default value |
| `choices` | on choice-capable types: `{ value: { label, sequence, hint, inactive, dependentValue, language } }` (`sys_choice`) |
| `dropdown` | `none` (default; not enforced), `dropdown_without_none` (needs a default), `dropdown_with_none`, `suggestion` |
| `dynamicValueDefinitions` | `{ type: 'calculated_value', calculatedValue: fn }`, `{ type: 'dynamic_default', dynamicDefault }`, `{ type: 'dependent_field', columnName }`, `{ type: 'choices_from_other_table', table, field }` |
| `functionDefinition` | function field: `"glidefunction:concat(short_description, ' ', caller_id.name)"` |
| `attributes` | dictionary attributes |
| `referenceTable` | on `ReferenceColumn` (seen in the Flow examples) |

```ts
import { Table, StringColumn, ReferenceColumn, IntegerColumn } from '@servicenow/sdk/core'
export const x_acme_example_item = Table({
  name: 'x_acme_example_item', label: 'Example Item', extends: 'task', display: 'title',
  autoNumber: { prefix: 'EXI', number: 1000, numberOfDigits: 7 },
  schema: {
    title: StringColumn({ label: 'Title', maxLength: 100, mandatory: true }),
    owner: ReferenceColumn({ label: 'Owner', referenceTable: 'sys_user' }),
    stage: StringColumn({ label: 'Stage', dropdown: 'dropdown_without_none', default: 'draft',
      choices: { draft: { label: 'Draft', sequence: 1 }, done: { label: 'Done', sequence: 2 } } }),
  },
})
```

The Import Sets example on the docs site writes columns as an array (`columns: [{ name, type, max_length }]`), which contradicts this page's `schema` object.

## UiAction (`sys_ui_action`)

`table` (or `global` for all tables) and `name` required. Child tables inherit the action.

| Property | Values / default |
|---|---|
| `actionName` | name used in scripts |
| `script` | runs on the server unless `client.isClient` is true; `Now.include` or inline |
| `condition` | JavaScript condition. `current` is not available for list context menu actions; on a related list button `parent` is the parent record |
| `showInsert` (false), `showUpdate` (true), `showQuery` (false), `showMultipleUpdate` (false) | when it shows |
| `form` | `showButton`, `showLink` (Related Links), `showContextMenu` (all false), `style` (`primary` blue, `destructive` red, `unstyled`) |
| `list` | the same plus `showListChoice` (Actions list), `showBannerButton`, `showSaveWithFormButton`. Bottom buttons and Actions choices show regardless of condition (evaluated per record on execution); a banner button's condition only looks at the first row |
| `client` | `isClient` (false), `onClick` (function name, such as `'reopenIncident()'`), `isUi11Compatible`, `isUi16Compatible` |
| `workspace` | `isConfigurableWorkspace` (false = legacy workspace), `showFormButtonV2`, `showFormMenuButtonV2`, `clientScriptV2` (`function onClick(g_form) {}`) |
| `roles`, `includeInViews`, `excludeFromViews`, `overrides`, `order` (100), `hint`, `comments`, `messages`, `isolateScript`, `active` | |

Background: [[UI Actions]].

## UiPage (`sys_ui_page`)

| Property | Values / default |
|---|---|
| `endpoint` (required) | `<scope>_<page_name>.do`, no spaces |
| `html` | Jelly or XHTML inline, `Now.include`, or for React an imported `index.html` (`import page from '../../client/index.html'`). Imported HTML syncs one way only: source to instance |
| `direct` | false; true = omit the standard page HTML, CSS and JavaScript (required for React) |
| `clientScript` | browser |
| `processingScript` | server, on submit of a `<g:ui_form/>`; may be a module function |
| `category` | `general`, `homepages`, `htmleditor`, `kb`, `cms`, `catalog` |
| `description` | |

React detail: [[Source-Code Development - Fluent, JavaScript Modules and React]].

## UiPolicy (`sys_ui_policy`)

`table` and `shortDescription` required.

| Property | Values / default |
|---|---|
| `conditions` | filter query; re-checked only when a user changes a field by hand, not after a UI action, context menu action or list edit |
| `onLoad` | true |
| `reverseIfFalse` | true |
| `global`, `view` | true = all views; else the named view (or `default_view`) |
| `inherit` | false; when inherited, the child table's policy runs first whatever the order |
| `order` | 100 |
| `runScripts`, `scriptTrue`, `scriptFalse` | client side, each `function onCondition() {}`; both required when `runScripts` is true |
| `uiType` | `desktop` (default), `mobile-or-service-portal`, `all` |
| `isolateScript` | false |
| `actions[]` (`sys_ui_policy_action`) | `field` (required), `visible`, `readOnly`, `mandatory` (true, false or `'ignore'`, the default), `cleared`, `value` with `valueAction` (`set_value`, `clear_value`, `ignore`), `fieldMessage` with `fieldMessageType` (`error`, `info`, `warning`, `none`), `table`. Processed in array order |
| `relatedListActions[]` (`sys_ui_policy_rl_action`) | `list` (a relationship sys_id, or `table.field` for a reference-based list; empty = all related lists), `visible` (true, false, `'ignore'`) |
| `modelId`, `modelTable`, `description`, `active` | `setValues` is deprecated |

The three spellings of the same choice differ per object: `mobile_or_service_portal` (ClientScript), `mobile-or-service-portal` (UiPolicy), `mobileOrServicePortal` (catalog objects). Background: [[UI Policies]].

## Related

- [[Source-Code Development - Fluent, JavaScript Modules and React]] · [[ServiceNow IDE and ServiceNow SDK]] · [[ServiceNow SDK CLI Reference]] · [[Metadata File Types and Primary Tables]]
