---
type: reference
tags: [reference, platform, javascript, service-catalog, sla, portal, workspace, client-script, ui-policy, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Building pro-code applications > ServiceNow SDK > Reference > ServiceNow Fluent API reference (read 2026-10-08 through the docs site): Service Catalog API (CatalogItem, CatalogItemRecordProducer, CatalogUiPolicy, CatalogClientScript, VariableSet), Service Level Agreement API, Service Portal API (SPWidget, SPAngularProvider, SPWidgetDependency, CssInclude, JsInclude), Workspace API. Property tables are condensed; the long code samples are replaced by short ones of our own. https://www.servicenow.com/docs/r/application-development/servicenow-sdk/fluent-service-catalog-api.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Fluent API - Service Catalog, SLA, Service Portal and Workspace

**What it is:** the ServiceNow Fluent objects for catalog items, record producers, catalog UI policies and client scripts, variable sets, SLA definitions, Service Portal widgets and workspaces. Third part of [[ServiceNow Fluent API Reference]], which explains `$id`, `$meta`, `Now.include` and script properties.

From the Brazil docs. All objects are imported from `@servicenow/sdk/core`. Fluent code is compiled at build into records.

## CatalogItem (`sc_cat_item`)

`name` required. An item needs a fulfilment process: `flow` (Flow object or sys_id; preferred, and it wins when several are given), `executionPlan` (`sc_cat_item_delivery_plan`) or `workflow` (legacy, `wf_workflow`).

| Group | Properties (default) |
|---|---|
| Identity | `shortDescription`, `description`, `meta` (search tags, Zing only), `state`, `version` (1), `order` (0), `owner`, `active` (true), `checkedOut` |
| Where | `catalogs` (sys_ids of `sc_catalog`), `categories` (`sc_category`; a catalog must be given first), `assignedTopics` (taxonomy topics; needs plugin `sn_ect`), `availability` (`desktopOnly` default, `mobileOnly`, `both`), `hideSP`, `visibleStandalone`, `visibleGuide`, `visibleBundle` (true) |
| Who | `roles`, `availableFor` and `notAvailableFor` (sys_ids of user criteria, `user_criteria`; "not available" wins), `accessType` (`restricted` default, or `delegated` = can be requested for someone else; needs a Requested For variable) |
| Questions | `variables` (object of variable definitions), `variableSets` (`[{ variableSet, order }]`), `showVariableHelpOnLoad`, `startClosed` |
| Fulfilment | `flow`, `executionPlan`, `workflow`, `fulfillmentGroup`, `fulfillmentAutomationLevel` (`unspecified`, `manual`, `semiAutomated`, `fullyAutomated`), `deliveryTime: { days, hours }`, `entitlementScript`, `model` (`cmdb_model`), `vendor`, `location` |
| Price | `cost` (0), `pricingDetails` (`[{ amount, currencyType, field }]`, field = `price` or `recurring_price`), `recurringFrequency` (required with a recurring price), `billable`, `ignorePrice` (default **true**), `omitPrice`, `mobileHidePrice`, `displayPriceProperty` |
| Order form | `requestMethod`: `order` (default; **Order Now**, confirmation, delivery details), `request` (**Request**, confirmation, no delivery details), `submit` (**Submit**, nothing else). `hideAddToCart`, `hideAddToWishList`, `hideDeliveryTime`, `hideQuantitySelector`, `hideSaveAsDraft`, `hideAttachment`, `mandatoryAttachment`, `customCart`, `useScLayout` (true), `makeItemNonConversational` |
| Pictures | `icon` (27 x 27), `picture`, `mobilePicture`, `mobilePictureType` (`desktopPicture` default, `mobilePicture`, `noPicture`) |
| Deprecated | `image`, `deliveryPlanScript`, `noCart`, `noOrder`, `noOrderNow`, `noProceedCheckout`, `noQuantity`, `noSearch` |

The description of `makeItemNonConversational` contradicts its name ("if true, the item can be requested from a conversational experience"); by the name, true should block Virtual Agent (?).

Variable types seen in the examples (the page gives no full list): `SingleLineTextVariable`, `MultiLineTextVariable`, `SelectBoxVariable` (`choices: { value: { label, sequence } }`), `ReferenceVariable` (`referenceTable`, `referenceQualCondition`), `EmailVariable`; also named: `AttachmentVariable`, `ContainerVariable`, `HtmlVariable`, `CustomVariable`. Common properties: `question`, `mandatory`, `order`, `defaultValue`; in a record producer `mapToField: true` with `field`.

```ts
import { CatalogItem, SingleLineTextVariable, SelectBoxVariable } from '@servicenow/sdk/core'
export const exampleItem = CatalogItem({
  $id: Now.ID['example_item'], name: 'Example Request', shortDescription: 'Request an example thing',
  catalogs: ['<sys_id of the catalog>'], categories: ['<sys_id of the category>'],
  variables: {
    reason: SingleLineTextVariable({ question: 'Reason', mandatory: true, order: 100 }),
    size: SelectBoxVariable({ question: 'Size', order: 200,
      choices: { small: { label: 'Small', sequence: 1 }, large: { label: 'Large', sequence: 2 } } }),
  },
  flow: exampleFlow, requestMethod: 'request',
})
```

## CatalogItemRecordProducer (`sc_cat_item_producer`)

`table` and `name` required. The table must be in the same scope or allow create from other scopes. Shares the identity, audience, question, picture and hide properties of `CatalogItem`, plus:

| Property | Meaning (default) |
|---|---|
| `script` | server side, **before** the record is created: set fields on `current`; variables as `producer.<name>`. Do not call `current.update()` or `insert()`, do not set `sys_class_name`, avoid `setAbortAction()` |
| `postInsertScript` | server side, after insert; `current.update()` allowed; overrides target values and template values |
| `saveScript` | runs at every step save in Catalog Builder, before `script` |
| `redirectUrl` | `generatedRecord` (default) or `catalogHomePage` |
| `allowEdit` | false; true = the user may edit the created record |
| `canCancel` | false; shows **Cancel** |
| `view` | view used, for example `ess` |
| `saveOptions` | "advanced options"; not explained |

## CatalogUiPolicy (`catalog_ui_policy`)

`shortDescription` required, plus `catalogItem` **or** `variableSet` (with `appliesTo: 'set'`).

| Property | Default |
|---|---|
| `catalogCondition` | encoded query on variables: `` `${item.variables.priority}=high^EQ` `` |
| `actions[]` (`catalog_ui_policy_action`) | `variableName` (required, as `item.variables.<name>`), `visible`, `mandatory`, `readOnly`, `disabled`, `cleared`, `valueAction` (`setValue` with `value`, or `clearValue`), `variableMessage` with `variableMessageType` (`info`, `warning`, `error`), `order` (100) |
| `onLoad` | true |
| `reverseIfFalse` | true |
| `appliesOnCatalogItemView` | true (order form) |
| `appliesOnRequestedItems`, `appliesOnCatalogTasks`, `appliesOnTargetRecord` | false (fulfiller forms; record produced) |
| `runScripts`, `executeIfTrue`, `executeIfFalse` | client side; each wrapped in `function onCondition() {}` |
| `runScriptsInUiType` | `desktop` (default), `mobileOrServicePortal`, `all` |
| `isolateScript` | true |
| `active`, `global` (true), `inherit` (false), `vaSupported` (false) | |

## CatalogClientScript (`catalog_script_client`)

Client side. `name` required; `catalogItem` or `variableSet` (`appliesTo: 'set'`).

| Property | Values / default |
|---|---|
| `type` | `onLoad`, `onChange` (needs `variableName`; start with `if (isLoading) return;`), `onSubmit` (return false to block; avoid GlideAjax here) |
| `uiType` | `desktop` (default), `mobileOrServicePortal`, `all` |
| `script` | `Now.include` or inline |
| `appliesOnCatalogItemView` (true), `appliesOnRequestedItems`, `appliesOnCatalogTasks`, `appliesOnTargetRecord` (false) | |
| `active`, `global`, `vaSupported`, `publishedRef` | |

Note the spelling difference from the form-level `ClientScript`, whose `uiType` value is `mobile_or_service_portal`.

## VariableSet (`item_option_new_set`)

| Property | Values / default |
|---|---|
| `title` (required), `internalName` (generated from the title), `name`, `description` | scripts must use the internal name |
| `type` | `singleRow` (default) or `multiRow` |
| `layout` | `normal` (default), `2down`, `2across` |
| `displayTitle` | false; true = collapsible header |
| `order` | 100 |
| `setAttributes` | for example `max_rows=10` |
| `readRoles`, `writeRoles`, `createRoles` (multi-row only) | |
| `variables`, `version` (0) | |

Multi-row sets do not accept attachment, container, HTML or custom variables. Inside one item, set internal names must differ from each other and from variable names.

Background: [[Request Management Data Model and Process]], [[UI Policies]].

## Sla (`contract_sla`)

`name` required. Import `Duration` for the duration.

| Property | Values / default |
|---|---|
| `table` | `incident` |
| `type` | `SLA` (default), `OLA`, `Underpinning contract`; reporting only |
| `target` | `response` or `resolution`; filtering and reporting only |
| `duration` | `Duration({ days, hours, minutes, seconds })`; required unless `durationType` is set |
| `durationType` | sys_id of a relative duration (`cmn_relative_duration`); with `relativeDurationWorksOn` = `Task record` (default) or `SLA record` |
| `scheduleSource` | `sla_definition` (default; then `schedule`, a `cmn_schedule` sys_id, is required), `task_field` (then `scheduleSourceField`), `no_schedule` (24x7) |
| `conditions` | `{ start, stop, pause, resume, reset, cancel }`, encoded queries |
| `whenTo.resume` | `on_condition` (default) or `no_match` (resume when the pause condition stops matching) |
| `whenTo.cancel` | `on_condition` (default), `no_match` (cancel when the start condition stops matching), `never` |
| `resetAction` | `cancel` (default) or `complete` the current task SLA before creating the new one |
| `retroactive` | `{ start: false, setStartTo: '<field>', pause: true }` |
| `timezoneSource` | `task.caller_id.time_zone` (default), `task.caller_id.location.time_zone`, `task.cmdb_ci.location.time_zone`, `task.location.time_zone`, `sla.timezone` (then `timezone` required, such as `US/Pacific`) |
| `advancedConditionType` | `none` (default), `advanced`, `advanced_journal`, `advanced_system`, `advanced_journal_and_system` |
| `conditionType` | sys_id of an SLA condition class (`sla_condition_class`) |
| `flow` / `workflow` | what runs at milestones and breach; default: the Default SLA flow |
| `overrides`, `vendor` (`core_company`), `domainPath` (`/`), `enableLogging` (false), `active` | |

```ts
import { Sla, Duration } from '@servicenow/sdk/core'
Sla({
  $id: Now.ID['example_p1_resolution'], name: 'Example P1 Resolution', table: 'incident', target: 'resolution',
  duration: Duration({ hours: 4 }), scheduleSource: 'no_schedule',
  conditions: { start: 'priority=1', pause: 'state=3', stop: 'state=6' },
  whenTo: { resume: 'no_match' },
})
```

Background: [[SLA Definitions and Task SLAs]], [[Schedules and Schedule Entries]].

## Service Portal

| Object | Table | Properties |
|---|---|---|
| `SPWidget` | `sp_widget` | `name` (required), `id` (no spaces), `category` (`custom` default, `standard`, `otherApplications`, `sample`, `knowledgeBase`, `servicePortal`, `serviceCatalog`), `htmlTemplate`, `customCss` (CSS or SCSS), `clientScript` (the AngularJS controller), `serverScript` (fills `data`), `linkScript`, `controllerAs` (`c`), `dataTable` (`sp_instance` or an extension of it), `fields`, `optionSchema`, `demoData`, `docs` (`sp_documentation`), `hasPreview` (false), `public` (false = signed-in users only), `roles`, `dependencies`, `angularProviders`, `templates` (`sp_ng_template`: `$id`, `id`, `htmlTemplate`), `description` |
| `SPAngularProvider` | `sp_angular_provider` | `name` (required), `clientScript`, `type` (`directive` default, `factory`, `service`), `requires` |
| `SPWidgetDependency` | `sp_dependency` | `name` (required), `angularModuleName`, `includeOnPageLoad` (false = only when the widget loads), `portalsForPageLoad` (sys_ids of `sp_portal`; empty = all), `cssIncludes` and `jsIncludes` (`[{ order, include }]`) |
| `CssInclude` | `sp_css_include` | `name` (required), `url` **or** `spCss` (sys_id of `sp_css`), `rtlCssUrl`, `lazyLoad` (only with `spCss`) |
| `JsInclude` | `sp_js_include` | `name` (required), `url` (absolute) **or** `sysUiScript` (sys_id of `sys_ui_script`) |

`optionSchema` entries: `name`, `label`, `section` (`data`, `behavior`, `documentation`, `presentation`, `other`), `type` (`string`, `boolean`, `integer`, `reference`, `choice`, `fieldList`, `fieldName`, `glideList`, `glyphIcon`), all required; `defaultValue`, `hint`.

Where the widget scripts run: `clientScript` and `linkScript` in the browser, `serverScript` on the server, in the application's scope. The Service Portal samples give `$id` as a plain string instead of `Now.ID[...]`.

## Workspace

Creates records in UX Application (`sys_ux_page_registry`), `sys_ux_app_config`, `sys_ux_registry_m2m_category`, `sys_ux_page_property`, `sys_ux_screen_type`, `sys_ux_app_route`, `sys_ux_screen` and `sys_ux_macroponent`.

| Object | Table | Properties |
|---|---|---|
| `Workspace` | (above) | `title`, `path` (kebab case; the URL is `/now/<path>/<landingPath>`), `tables`, `listConfig` (all required), `landingPath` (`home`), `active` |
| `UxListMenuConfig` | `sys_ux_list_menu_config` | `name` (required), `description`, `active`, `categories` |
| `categories[]` | `sys_ux_list_category` | `title`, `lists` (required), `order`, `active`, `description` |
| `lists[]` | `sys_ux_list` | `title`, `table` (required), `columns` (comma-separated string), `condition` (encoded query), `order`, `active`, `applicabilities` (`[{ $id, applicability }]`) |
| `Applicability` | `sys_ux_applicability` | `name` (required), `roles` (Role objects or sys_ids) or `roleNames` (comma-separated), `description`, `active` |

- A workspace needs ACLs on its routes: an `Acl` of type `ux_route` whose `field` is `<path>.*`.
- Its home page can be a dashboard: list the workspace in the `visibilities` of a `Dashboard` ([[Fluent API - Dashboards, Notifications, Flows, Import Sets and Lists]]).

```ts
import { Workspace, UxListMenuConfig, Applicability } from '@servicenow/sdk/core'
const everyone = Applicability({ $id: Now.ID['example_users'], name: 'Example users', roleNames: 'x_acme_example.user' })
const lists = UxListMenuConfig({
  $id: Now.ID['example_lists'], name: 'Example lists',
  categories: [{ $id: Now.ID['cat_items'], title: 'Items', order: 10, lists: [
    { $id: Now.ID['open_items'], title: 'Open', table: 'x_acme_example_item', condition: 'active=true^EQ',
      columns: 'number,title,stage', applicabilities: [{ $id: Now.ID['open_items_app'], applicability: everyone }] },
  ] }],
})
export const exampleWorkspace = Workspace({
  $id: Now.ID['example_workspace'], title: 'Example Workspace', path: 'example-workspace',
  tables: ['x_acme_example_item'], listConfig: lists,
})
```

Background: [[Service Operations Workspace Configuration and Customization Reference]] for how configurable workspaces are adjusted in the UI.

## Related

- [[ServiceNow Fluent API Reference]] · [[Fluent API - Dashboards, Notifications, Flows, Import Sets and Lists]] · [[Source-Code Development - Fluent, JavaScript Modules and React]]
