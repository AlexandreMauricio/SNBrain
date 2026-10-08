---
type: concept
tags: [concept, platform, workspace, portal, roles, domain-separation, glossary, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Builder library > UI Builder (read 2026-10-08 through the docs site): UI Builder, Exploring UI Builder, UI Builder quick start, UI Builder tutorial, UI Builder and configurable workspaces, Experience settings, Helpful resources, UI Builder glossary, Learning UI Builder, Navigate the UI Builder application (Learning Center, Guided tours, Dark theme), Learn UI Builder by example (demo experience, blank page, record page from a template, button that opens a modal, audience, conditions, customize forms within a form component), Learn about audiences, Learn about security and roles, Learn about domain separation, Working in UI Builder, Configure how users interact with your applications, Create an experience, Configure workspace experiences (general, theme, side navigation, notifications, global search), Configure portal experiences (general, theme, navigation and menus, search), Define UI experiences using app shells. https://www.servicenow.com/docs/r/application-development/ui-builder/ui-builder-overview.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# UI Builder Overview and Concepts

**In one line:** UI Builder is the visual editor for Next Experience pages: an **experience** (a workspace or a custom portal) has an **app shell** and **pages**; each page has one or more **variants** chosen by audience and conditions; a variant is built from layouts and **components** fed by **data resources** and wired with **events**.

From the Brazil docs. Pages and variants in detail: [[UI Builder Pages, Variants and Layouts]]. Components, events and styling: [[UI Builder Components, Events and Styling]]. Data, controllers and scripts: [[UI Builder Data Resources, Controllers and Client Scripts]]. The no-code route for a standard workspace: [[Workspace Builder]].

## Facts

- Open: **All > Now Experience Framework > UI Builder**. Role: `ui_builder_admin` (editing a form inside a form component needs admin).
- It does **not** build or configure base-system Service Portals such as Employee Center: those stay in Service Portal Designer.
- The page's **application scope is fixed at creation**; the scope picker in UI Builder and the platform's are the same setting. Experience settings are read-only from another scope. Protected files (protection policy) cannot be modified.
- Development can be delegated per application ([[Delegated Development and Deployment]]).
- One developer per variant at a time is the stated rule, although presence indicators exist.

## Glossary

| Term | Meaning |
|---|---|
| Experience | a set of pages with routes, variants, settings and a shell (`sys_ux_page_registry`) |
| App shell | the static frame around every page: header, footer, navigation |
| Page | a URL path inside the experience, holding layouts and components |
| Variant | a version of a page at the same path, selected by audience and conditions |
| Macroponent | the record whose JSON actually defines a page (`sys_ux_macroponent`) |
| Component | a building block with properties, styles and events (Heading, Button, List, Form ...) |
| Component ID | generated from the label, editable; used to address the component in scripts and bindings |
| Preset | ready-made property values and event mappings for a component; only some components have them |
| Data resource | a reusable definition of data to fetch for the page |
| Data binding | linking data to a component property |
| Controller | a data resource that also carries event logic and enables presets. *Data controllers* can be added by hand; *UI controllers* arrive with page templates |
| Client state parameter | a page variable (name, type, initial value) changed by scripts and events |
| Client script | client-side JavaScript of the page, run as an event handler |
| Event, event handler, event mapping | something that happens; the action taken; the link between them |
| Repeater | a component that repeats its content for each item of an array |
| Modal, popover | an overlay that takes over the page; an overlay that lets the page stay usable |
| Page collection | pages reusable across experiences in tabs or modals |
| EVAM | Entity View Action Mapper: one format for showing records as cards and lists |
| Now Code Editor | the editor for scripts, JSON, CSS and HTML inside UI Builder |

## The editor

| Area | Use |
|---|---|
| Home | recent experiences, **Create** (experience, page collection), search; tabs **Experiences**, **Page collections**, **Controllers**, **Presets**, **UI interactions**; **Help** opens the Learning Center (articles, videos, courses, guided tours) |
| Experience view | pages with their variants, conditions and audience counts; filter by name, URL, page type or variant; **Experience settings** |
| Content tree | every layout, column and component of the variant; drag to reorder; label components so they can be found |
| Toolbox | **+ Add content**: layouts and components, searchable |
| Stage | the page itself; layouts outlined in magenta, components in blue; width selector |
| Configuration panel | tabs **Config**, **Styles**, **Events** for the selection |
| Data resources, Client state, Client scripts | the lower panels |
| Header | variant picker, undo and redo (last 20 actions; not for data panel changes), errors and warnings, domain and scope, **Save**, **Preview** (or *Open URL path* to test what a real user gets) |

Dark theme: the *Choose theme* icon; the stage itself follows the user's platform theme.

## App shells

Chosen when the experience is created; an experience needs one.

| App shell | For |
|---|---|
| Workspace | headers and footers for a workspace with tabs and tools; styled through Theme Builder |
| Breadcrumb | header, breadcrumb navigation and primary navigation bar: focused flows and wizards without multitasking |
| Header | header and user menu only: minimal navigation |
| Portal | header and footer of a portal; a reference implementation of menu, utilities, logo and login |
| UXR Base Experience | routing, caching and context only, no visual parts; for experiences living inside a parent application |

## Create an experience

Home > **Create > Experience**:

| Field | Meaning |
|---|---|
| **Name** | internal name, also shown on the browser tab |
| **App Shell UI** | one of the shells above |
| **URL path** | appended to the instance URL, for example `example/app` |
| **Landing path** | path of the home page; create a page with the same path |
| **Roles** | who may open it; empty = every signed-in user |

## Experience settings

| Section | Workspace | Portal |
|---|---|---|
| General | title, description, path (letters, digits, `-`, `.`, `_`, `~`; unique); **Advanced settings** opens the record | the same |
| Branding and theming | shows the theme (Polaris by default). Change it with Theme Builder or a custom theme record | the same |
| Navigation | **Side navigation**: up to seven pages, each with **URL path**, **Icon**, **Label**, **Group** (top or bottom). Needs the workspace shell and at least two pages. Stored in a UX page property (`sys_ux_page_property`, type json) | header (advanced settings), **Navigation Menu** on or off, **Primary footer**, **Secondary footer** |
| Notifications | **Turn on notifications**; opening the record from a notification needs a `featureRoutes` page property | |
| Global search | **Show global search**, and the search source | **Enable for public pages**, **Enable for private pages**; per page, a UX page property overrides |

## Audiences

An audience decides who gets a variant. It can target role, group, user, company, department, location or a script, as allow and deny lists, with an **Order** (lower number = higher priority) and **Active**. Chosen when creating a page or variant; **Open audiences in platform** creates new ones. Targeting by department, group, location or company requires `glide.ux.user_criteria_enabled` = true.

## Domain separation

Support level Standard. It behaves like scope: a variant or dashboard in another domain is read-only until you switch domain, edit (the session moves into the record's domain for the edit), or **Create Override**.

- The framework tables are process-separated (they have `sys_override`): changing in a sub-domain a page created in global creates an override. Items that are not separated change for everyone.
- An override copies the page definition **without** its conditions and audiences (you are asked to set them), and no longer follows the original. Viewports overridden in a domain are not carried along.
- No override can be created in global when the item exists in a sub-domain, or where an override already exists in that sub-domain.
- The domain picker is not available to `ui_builder_admin` alone: it needs a role that grants it (for example `itil`) or the system property. In global, **Expand domain scope** shows sub-domain variants and overrides.
- Data shown on pages is separated only if the underlying application separates it. Declarative actions and viewports can be overridden per domain.

## Related

- [[UI Builder Pages, Variants and Layouts]] · [[UI Builder Components, Events and Styling]] · [[UI Builder Data Resources, Controllers and Client Scripts]] · [[Workspace Builder]] · [[Builder Tools Overview and Custom UI Components]] · [[Metadata File Types and Primary Tables]]
