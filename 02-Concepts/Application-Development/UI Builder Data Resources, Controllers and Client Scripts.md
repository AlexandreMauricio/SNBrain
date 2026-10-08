---
type: reference
tags: [reference, platform, workspace, portal, javascript, client-script, glide-api, encoded-query, ai, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Builder library > UI Builder > Advanced UI Builder and Component Builder (read 2026-10-08 through the docs site): Advanced UI Builder, Configure components and repeaters, Add and configure components, Supported functions in the component formula editor, Add repeaters to components, Optimize page loading performance, Dynamically expose data in UI Builder pages, Add and configure data resources to a page, Add Now Assist skills to your page, Bind data to UI Builder pages using controllers (add, edit, delete, Controller API), Create custom controllers, Connect data components (and with formulas), Client state parameters (two walkthroughs), Define and bind client scripts to components, Multi-table data configuration, Fetch data from multiple sources, Entity View Action Mapper (and adding an EVAM data resource), Edit code with the Now Code Editor, Component Builder, Create custom components to reuse across pages, Enable configuration of components with inherited controllers. The stopwatch sample script and the long walkthroughs are condensed. With the three other UI Builder notes this covers the whole UI Builder section (about 10,400 cleaned lines). https://www.servicenow.com/docs/r/application-development/ui-builder/data-resources.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# UI Builder Data Resources, Controllers and Client Scripts

**What it is:** how a UI Builder page gets data (data resources and controllers), how values are bound to component properties, the page's variables (client state parameters) and client scripts, repeaters, loading performance, and building reusable components in Component Builder.

From the Brazil docs; the docs mark most of this as advanced. Vocabulary: [[UI Builder Overview and Concepts]]. Components and events: [[UI Builder Components, Events and Styling]].

## Binding syntax

| Prefix | Source | Example |
|---|---|---|
| `@context.props.<name>` | page parameters (URL) and properties inherited from the parent | `@context.props.table` |
| `@context.session` | the session | `@context.session.user.firstName` |
| `@data.<resource id>.<path>` | a data resource or controller output | `@data.lookup_record_1.result.number.displayValue` |
| `@state.<name>` | a client state parameter | `@state.selected_caller` |
| `@elements.<component id>.<property>` | another component on the page | `@elements.list_menu_1.selectedListId` |
| `@payload.<field>` | the event being handled | `@payload.value` |
| `@item.value.<field>` | the current item inside a repeater | `@item.value.number.displayValue` |

The **data binding modal** (the bind icon on any property) offers *Data types* (page properties, data resources, client states, event payload, repeater) as draggable pills, *Formulas*, a JSON view, and **Use script**. A context binding needs a test value or a fixed value to show anything in the editor.

## Data resources

Added in the *Data and scripts* drawer: **+** > **Data resource** > pick (grouped by application, then by kind) > **Add** > configure > give it a label and ID. Several instances of the same resource are allowed. The preview shows the returned JSON. Errors show until the required inputs are filled.

| Type | What it is |
|---|---|
| Controller | data plus event logic; enables presets |
| GraphQL | queries and mutations |
| REST | REST API requests |
| Transform | a server script that reshapes input data |
| Client state | client-side data, including the GlideForm (`g_form`) API; **one GlideForm per page** |
| Composite | several resources packaged as one |

Common ones: *Look up a single record*, *Look up multiple records* (**Table**, **Return fields**, **Order by**, **Max results**, **Edit conditions**; output `results`), *GlideRecord Query*, *Table route map*, *Multi-table data*.

| Topic | Detail |
|---|---|
| Inherited or local | inherited resources come from the surrounding shell or parent and are read-only; local ones are added to the page |
| When to evaluate | **Immediately** (on load; right for core content) or **Only when invoked** (by an event handler; faster first load) |
| Events | Data Fetch Initiated / Succeeded / Failed, each mappable to handlers; the usual handler on a resource is **REFRESH** |
| Conditions | can be bound to client state, which is how filters are driven |

**Multi-table data**: one resource with several **Data sources** (table, sort field, name, return fields, conditions); give every source the **same return fields in the same order**. Output path: `output > data > GlideMultiDatasource_Query > getMultiDatasourceData > items`; inside a repeater the fields are under `value > fields`.

**EVAM** (Entity View Action Mapper): standardises records from different sources as cards or lists, with a grid / list toggle on the Data set component; configured in JSON. Resources: *EVAM Data Resource* (composite: EVAM definition, page size / number / cursor, filter preference), *Fetch EVAM Data* and *Fetch EVAM Metadata* (GraphQL), *Search EVAM Data Resource* (config ID, search context config ID, search term, facet and search filters, pagination token). Multi-table data is the simpler alternative that stays in UI Builder.

**Now Assist skills**: drawer > Now Assist skills > **+** > a skill (default: Generate Content, Sentiment Analysis, Summarize; it must be enabled in the skill kit and activated in the AI admin console). Trigger it with an event handler **Execute** passing the inputs, and bind the output (`result > response`) to a component.

## Controllers

A controller is the data resource behind presets: it brings data to components and takes changes back.

- Page templates add their controllers; these cannot be deleted from a template-built page. A controller can be on a page only once.
- By hand: drawer > **+** > Data resource > the controller > configure. The page says the **record controller** is the only one that can be added manually in Brazil, while other pages add list and modeless-dialog controllers implicitly through components (?).
- Form / record controller inputs: **Table**, **Sys ID** (`-1` = a new record; a full GUID is generated so that attachments can be stored before the first save).
- Outputs are read as `@data.<controller id>.<category>.<property>`, for example `@data.gform.table`, `@data.gform.form.view`. Inspect them in the data panel (top-level outputs, then child categories). Preset event mappings can be disabled or extended but not edited.
- **Custom controller**: home > **Create > Controller** > **Name**, **Description** > add data resources, external controller dependencies (**Name**, **Label**, **Controller**), client state parameters and client scripts.

## Client state parameters

Page variables: **Name** (no spaces), **Type** (String, Number, Boolean, JSON), **Initial value**. Created in the drawer (**+** next to Client state parameters); the panel also previews them as JSON.

- Bind them to component properties (`@state.<name>`); when the value changes, only the bound components redraw.
- Change them with the handler **Update client state parameter** (a new value, a binding, or a formula such as `ADD(@state.count, 1)`), or from a client script with `api.setState`.

## Client scripts

Client-side JavaScript of the page (runs in the browser), written in the drawer (**+** next to Client scripts) and attached as an event handler. A script can read data resource results, set client state, run data resource operations and emit events. A script include or associated components can be attached; they arrive in `imports`.

```js
// UI Builder page client script: client side; attach to a component event as a handler
function handler({ api, event, helpers, imports }) {
  api.setState('selected_caller', event.payload.value);          // update a client state parameter
  api.emit('NOW_UXF_PAGE#ADD_NOTIFICATIONS', {                    // show an alert on the page
    items: [{ id: 'example_alert', status: 'info', icon: 'circle-info-outline',
              content: { type: 'string', value: 'Filter applied' }, action: { type: 'dismiss' } }]
  });
}
```

- Seen in the docs' samples: `api.state.<name>`, `api.setState(name, value)`, `api.data.<resource id>.results`, `api.emit(event, payload)`, `helpers.timing.setInterval` / `clearInterval`, `event.payload`. A script used for a *property value* has the form `function evaluateProperty({ api, helpers }) { return ... }`; inside a repeater the item is `api.item`.
- Alert `status` values: `critical`, `high`, `moderate`, `warning`, `info`, `positive`, `low`; content `type` `string` or `html`.

**Now Code Editor**: the editor used for these scripts and for JSON, CSS and HTML. Format (Shift+Alt+F), check syntax (Shift+Alt+C), suggestions (Ctrl+Space), toggle comment (Ctrl or Cmd + /), command palette (F1), expand (Ctrl+M), minimap, word wrap, diff view (side by side or inline). The Script Debugger can be launched from it; breakpoints, conditional breakpoints and logpoints work only for JavaScript with debugging on. Macros: `for`, `method`, `info`, `doc`, `vargr`, `vargror`.

## Formulas

| Kind | Functions |
|---|---|
| General | `CONCAT(...)`, `IF(condition, then, else)`, `EMPTY(value)`, `LEN(list)`, `PICK(array, field)`, `RANGE(from, to)`, `SUM(array)`, `TRANSLATE(text)`; math functions such as `ADD` and `SUB` appear in the walkthroughs |
| Array tests | `ALL_*` (true if every item matches), `ANY_*` (true if some item matches), `WHERE_*` (returns the matching items), each with `EQ`, `NEQ`, `GT`, `GTE`, `LT`, `LTE`, `EMPTY`, `NOTEMPTY`, `ONEOF`, `NOTONEOF` |

```text
CONCAT("Welcome, ", @context.session.user.firstName)
IF(@context.props.bare, "bare page", "not bare page")
```

The docs' description of `TRANSLATE` is that of a character-replacement function while its example is a message translation: by the example, it returns the translated text (?).

JSON-valued properties with a schema get a low-code JSON editor (objects, arrays, **Hide unset items**).

## Repeaters

A repeater renders its content once per item of its **Data array** (an array, or an array of objects). Bind the array to a resource output (`@data.look_up_multiple_records_1.results`), then bind the components inside to `@item.value.<field>.displayValue`; the record's sys_id is at `value > _row_data > uniqueValue`. Unbound components inside simply repeat identically. Styles on the repeater (grid, columns, gap) lay the copies out.

## Loading performance

Page menu > **Manage performance settings**:

| Setting | Meaning |
|---|---|
| **Progressive loading** / **Full page loading** | show the page while components still load, or wait for everything (with a *Page loader threshold duration* as the maximum wait) |
| Priority tab | **Make high priority** for the components to load first |
| Cache and headers tab | per data resource, **Activate data policy** to cache its data |

## Component Builder

Home > **Create > Component** (**Name**, **Categories**, **Description**, **Icon**), then build it like a page: layout, components, data resources, client state, client scripts, events, plus **+ Add property** to expose configurable properties (label, ID, default) and test values. It appears in the toolbox; editing it updates every page that uses it. **Duplicate** from its settings.

| | Component Builder | ServiceNow CLI (`ui-component`) |
|---|---|---|
| How | drag and drop in UI Builder | code: HTML, CSS, JavaScript ([[Builder Tools Overview and Custom UI Components]]) |
| Stored in | `sys_ux_macroponent` | `sys_uib_toolbox_component` |
| Can use controllers and data resources | yes | |
| Fits | simple to moderate, reusable page parts | complex custom components |

- **Custom component or page collection**: a component for a reusable part of a page maintained in one place; a page collection for whole pages or tab sets reused across experiences.
- Data resources added inside a component are private to it. With **Inherit configurations from parent** (advanced configuration of the resource) the component looks for a resource of the same type on the page: none found = it creates one from its own configuration; one = it connects; several = it takes the first.
- Custom components exist only on the instance where they were made until moved by update set or application install. They are upgrade-safe when their policy is read-only. There is no governance over duplicates: audit them.

## Related

- [[UI Builder Overview and Concepts]] · [[UI Builder Pages, Variants and Layouts]] · [[UI Builder Components, Events and Styling]] · [[Builder Tools Overview and Custom UI Components]] · [[Workspace Builder]]
