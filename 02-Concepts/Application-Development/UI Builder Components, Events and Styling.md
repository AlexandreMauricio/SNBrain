---
type: reference
tags: [reference, platform, workspace, portal, javascript, client-script, forms-lists, ai, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Builder library > UI Builder > Working in UI Builder (read 2026-10-08 through the docs site): Customize UI Builder pages using components, Automatically configure components using presets, Create custom presets, Change the default appearance of components, Enhance accessibility with focus management, Duplicate a component, Conditional renderers, Learn components by example (dynamic filtered card displays, alert messages, flyout menu filter), Page collections (and creating one), Change data visualizations, Add tabbed content, Add a contextual sidebar, Add forms to UI Builder pages, Create modals (and add modal to component), Viewport components (viewport, viewport modal, viewport-enabled tabs), Popovers, Modeless dialogs (add, events), Configure alerts to auto-dismiss, Manage actions in UI Builder pages, Define map events, Event payloads, Configure an event handler manually and with Now Assist, Bind events (component, page, data resource, link to another page, declarative action), Disable preset event mappings, Delete an event handler or mapping, Track unsaved changes, UI interactions (create, edit, duplicate, trigger, delete, toolbox steps, demo data), Manage the visual style, View experience theme, Custom style classes and rules, Collaborate, Find and fix issues, Now Assist panel. The three worked examples are condensed to their pattern. https://www.servicenow.com/docs/r/application-development/ui-builder/work-components.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# UI Builder Components, Events and Styling

**What it is:** how components are configured in UI Builder, the overlay and container components (tabs, modals, popovers, modeless dialogs, viewports, page collections), how events are wired to handlers, reusable UI interactions, styling, and the helper tools (version compare, issue finder, AI panel).

From the Brazil docs. Vocabulary: [[UI Builder Overview and Concepts]]. Layouts and variants: [[UI Builder Pages, Variants and Layouts]]. Data resources, controllers, client state and scripts: [[UI Builder Data Resources, Controllers and Client Scripts]].

## Configuring a component

Three tabs: **Config** (properties), **Styles**, **Events**. Each property takes one of:

| Mode | Meaning |
|---|---|
| Static | a typed or picked value |
| Data binding | bound to a data resource, page property (`@context.props.<name>`), client state, event payload, or repeater item |
| Script | JavaScript returning the value (client side, in the browser) |
| Formula | functions combined in the formula editor (for example `CONCAT`) |

- **Component ID**: select the component's name in the panel; unique; used in scripts and bindings.
- **Component visibility** (eye icon): hide or show by binding or script, with a test value. It depends on data, not on who is looking (that is what variants and audiences are for).
- **Duplicate**: right-click > Duplicate, or Ctrl/Cmd-D; copies properties, bindings and events.
- **Conditional renderer** component: **+ Add condition** as an empty container, a card, or a single component; **Condition** must evaluate to a Boolean true.
- If the stage does not reflect a change: menu > Developer > **Reload Stage** (does not save).
- Admins can decide which property sections show, through UI policies.

### Presets

A preset fills a component's properties and event mappings from a **controller**; preset-set fields are read-only.

- Applied by default when the page came from a template or the needed controller is already present; otherwise choosing a preset adds the controller after asking for its required properties. Tick **Presets available** in the toolbox to see which components have one.
- Override a value: the lock icon on the field (you then own that configuration). **Remove current preset**, or component name > **Reset component**.
- Bindings a preset can hold: controller outputs (`@data`), event payloads (`@payload`), session (`@context.session`), formulas.
- Sub-pages do not inherit controllers and so cannot use presets (Brazil).
- Own presets: home > **Create > Preset** > **Name**, **Component**, **Controller**, **Description** > set test values, configure properties, drag data onto fields, add events.

## Containers and overlays

| Component | Notes |
|---|---|
| **Tabs** | horizontal or vertical. Tab kinds: *empty container* (static), *repeater* (one tab per item of a data array with `label` (required), `icon`, `count`, `fields`), *related list* (one tab per related list of the record; needs a record controller), *page collection*. In preview only one placeholder tab shows for the generated kinds |
| **Contextual sidebar** | vertical tabs beside the content (attachments, comments ...), configured like tabs |
| **Form** | several forms per page are possible (inline tab, modal). Each has a form controller; **exactly one** must have **Is mapped to app Shell** = true: that one handles the global events (`CTRL_RECORD#SCREEN_STATUS_CHANGED`, `#UPDATE_CONFIGURATION_MENU_REQUEST`, `#PHONE_REQUESTED`, `#FORM_LOADING_STATE_CHANGED`). Forms created before Xanadu need the *Form controller preset* applied first. **Edit Form** on the stage opens Form Builder ([[Table Builder]]) |
| **Modal** (content tree > Modals and popovers > **+**) | types: Alert, Confirm, Confirm and destroy, Custom (own layout and components), iframe (source URL; *disable sandbox* lifts the iframe restrictions), Modal viewport. Settings: header, content, button labels, size (Small to Fullscreen), **Prevent Default ... Button Action**, **Defer modal content loading**. Opened by the handler **Open or close modal dialog** |
| **Popover** | small overlay that closes when you click elsewhere; handler **Open Popover** > *Create a new popover* |
| **Modeless dialog** | floating, movable, minimisable window that leaves the page usable; several per page; parts: header actions, content, footer. Adds a *Modeless dialog controller* and a *Minimized dialogs* dropdown. Handlers: **Open** (heading, minimized heading, category, **Single instance**, instance ID), **Close**, **Minimize**, **Update**, **Dirty** |
| **Viewport** | a slot that renders pages of a page collection, so content can be extended without owning the parent page. Opened with the handler **UXF Macroponent Viewport Load Requested**, giving the viewport's element ID. A **viewport modal** holds one sub-route. **Replace with viewport tabs** on a Tabs component is permanent and discards the tab content |
| **Alert** | Types info, warning, error and the status family (critical, high, moderate, low, positive). Auto-dismiss: Experience settings > *Configure alerts* per type with a timeout, then optionally overridden per alert in the **Add alert notifications** handler (experience-level must be on first) |

**Page collections** (`sys_ux_extension_point`): groups of pages reused across experiences inside tabs, viewports and viewport modals. They are **sandboxed**: no access to the parent's URL parameters or data resources, only to the controller named on the collection and passed in at run time; the only way back is to dispatch an event the parent listens for. Create: home > **Create > Page collection** > **Name**, **App shell UI**, **Component** (Tabs, Viewports, Viewport Modals), **Description** > a controller (and any it depends on) with label and id > pages with their own audiences and conditions. Page templates are not supported inside.

## Events

Nothing happens until an event is mapped to a handler: Events tab > **Add event mapping** (or **Add handler** under an event) > event > handler > configure its payload > **Add**.

| Event source | Examples | Stored |
|---|---|---|
| Component | Button clicked, Row clicked, Selected items changed, Card clicked | on the page |
| Page (select **Body**) | *Page ready*, *Page property changed* | page event mappings on the macroponent (`sys_ux_macroponent`) |
| Variant | relays of dispatched events up to the shell; created automatically on save when a component event is mapped to a shell handler | on the screen (`sys_ux_screen`) |
| Dispatched / handled events | events the page emits (modelled on a parent handler) or exposes for others (payload fields defined by hand or from a template) | `sys_ux_event` |
| Data resource | Data Fetch Initiated / Succeeded / Failed (Operation Initiated / Succeeded / Failed) | |
| Declarative action | for components such as Action bar and List: **Configure declarative action event mapping** binds the action (defined under Workspace Experience > Actions & Components, table `sys_declarative_action_assignment`) to a handled event | |

| Handler group | Handlers |
|---|---|
| Inherited (from the shell) | **Link to destination** (a page of the experience with its parameters, or an external URL), **Add parameters to URL**, **Open or close modal dialog**, Breadcrumb URL changed |
| Page-level | **Add / Remove / Clear alert notification**, **Set loading state**, **Update client state parameter** (also shown as *Set client state parameter*), **UXF macroponent viewport load requested**, focus handlers (**Set focus on**, **Focus parent page**), *Screen status changed to dirty* |
| Data resource | the resource's operations, typically **REFRESH** |
| Client scripts | any client script of the page |
| UI interactions | reusable flows, below |

- **Payload**: data an event carries (`@payload.<field>`); bind it into the handler's fields. When a payload is undocumented, log it from a client script (`console.log(event.payload)`).
- **Link to destination**: fill each parameter of the target page (required ones are starred) with `@payload.*` values. A component's own link property beats the handler. Target pages copied from Base Agent Workspace templates only work if both experiences use the same app shell; the *Link to destination Relay* handlers found on such copies do not work but show the right payload names.
- A preset's event mapping can be **disabled** instead of deleted. Deleting a handler leaves the mapping; the delete-all icon removes the mapping.
- Now Assist can configure *link to destination*, *open or close modal* and *viewport load requested* handlers from a sentence.

Recurring pattern (filter a list or cards by a selection): a client state parameter holds the selection > the data resource's condition is bound to it > the selector's change event has two handlers: *Set client state parameter* from `@payload.value`, then the data resource's **REFRESH**.

## UI interactions

A reusable flow of UI and logic, built in a diagram editor and triggered from any page event or from a declarative action. Declarative actions decide **where a button appears**; a UI interaction defines **what happens**, without owning or changing the page. For long-running, record-based sequences use a playbook instead ([[Playbooks Overview and Components]]).

- Create: home > **Create > UI interaction** (or **Now Experience Framework > UI interactions**) > name, **Type**, description > add steps between Start and End > **Inputs** (String, True/False, Choice, Reference, JSON) > **Save**. It runs only once attached to an event: Events tab > **Add handler** > the interaction (a needed form or list controller is added automatically).
- **Type is fixed after creation** (Generic; Form, needs a form controller; List, needs a list controller), as are input IDs and types once referenced. Deleting is only possible when the *Usage* section of its Settings tab is empty, and is permanent.
- **Duplicate** (Settings tab) gives an independent copy in the current scope; custom components and declarative actions are not copied.

| Steps | Outgoing events |
|---|---|
| Logic: **If/Else** (first true branch runs), **And** (parallel branches, evaluated top to bottom) | none |
| **Add alert notification** | Alert action selected |
| **Server script** (server side; needs at least one user role) | Success, Error |
| Navigation: **Close workspace tab**, **Navigate to record / route / URL** | none |
| Modals: **Alert**, **Confirm**, **Confirm and destroy**, **User input** (fields typed in or taken from a table), **Create modal** (custom, built in component builder) | Modal closed; Primary / Secondary button clicked |
| Modeless dialog: **Form**, **Create modeless dialog** | closed; Primary / Secondary button clicked |
| Form type, field actions: add or clear field message, clear value, set invalid, label, placeholder, read-only, required, value, visibility | none |
| Form type, form actions: add or clear form alerts, **Execute client script**, **Execute UI action** (one enabled for configurable workspace), **Refresh form**, **Save**, **Submit form using UI action**, **Validate**, show or hide annotations | Success and/or Error on the executing ones |
| List type: **Execute client script**, **Group by column**, **Refresh list**, **Set query**, **Sort** | Success / Error on script and refresh |

A step with no outgoing event does not report completion: continue after it through an **And** branch.

Demo interactions (search `DEMO`; duplicate before changing; their declarative actions are inactive): Cascade delete (must be duplicated into **global** scope), Close incident, Report knowledge gap, Create new record, Reassign records, Open modal to display table / sys_id / form view, Save form and close tab.

## Styling

- **Styles tab** per element: Alignment, Background, Border, Layout, Shadow, Sizing (px, %, em, rem), Spacing (margin, padding), accessibility (ARIA region name, role, heading level) on layouts; **View and edit CSS** for raw CSS. Some components have built-in styles that CSS here cannot override: use the theme.
- **Style classes and rules**: Styles tab > `...` next to **Style class** > **+ Add class** / **+ Add rule** with CSS, then pick it on any component or container of the page (role admin).
- **Theme**: Polaris by default; shown under Experience settings > Branding and theming; changed with Theme Builder or a custom theme record.

## Helpers

| Tool | Use |
|---|---|
| Presence | avatars of developers on the same page; a banner asks to reload when someone else saved; simultaneous edits end in **Overwrite and save** |
| **Compare versions** (page menu) | Added, Modified, Moved, Deleted items between versions |
| **Find and fix issues** | experience view section and a header button next to Save: missing configuration, errors, accessibility, each naming the component |
| Now Assist panel (needs the Otto for Creator plugin) | *Conversational help* (answers from the documentation, not about your instance), *Page building* (add components, bindings, client state, handlers from a prompt), *Page insights* (what is on a page, how it is bound, unused client scripts). Review what it generates |

## Related

- [[UI Builder Overview and Concepts]] · [[UI Builder Pages, Variants and Layouts]] · [[UI Builder Data Resources, Controllers and Client Scripts]] · [[UI Actions]] · [[Otto for Creator and Otto for App Engine]]
