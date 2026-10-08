---
type: reference
tags: [reference, platform, workspace, portal, encoded-query, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Builder library > UI Builder > Working in UI Builder (read 2026-10-08 through the docs site): Manage UI Builder pages and page variants, Create a page in UI Builder, Create a page from a template, Create a page from a legacy template, Edit a page, Add an audience to your UI Builder page, Enable the user criteria property, Test values in a page, Create a page variant, Edit page variant settings, Control the conditions for a page variant, Use pages across experiences (enable, add shared pages), Responsive authoring (component visibility, component configuration, styles, layout, breakpoints), Learn how to view and test your experience, Resolve a missing page definition, Organize components in UI Builder pages, Column layouts, Upgrading layouts, Using Flexbox layouts, Using CSS Grid layouts, Change the layout of a page created in Quebec or Rome. The four responsive-authoring walkthroughs are condensed to their technique. https://www.servicenow.com/docs/r/application-development/ui-builder/work-pages.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# UI Builder Pages, Variants and Layouts

**What it is:** how a UI Builder page is defined (path, type, URL parameters), how the variant a user gets is chosen (audience, conditions, order), how pages are shared between experiences, how a page adapts to screen sizes, and how layouts arrange components.

From the Brazil docs. Vocabulary and the editor: [[UI Builder Overview and Concepts]]. What goes inside the layouts: [[UI Builder Components, Events and Styling]].

## A page

| Setting | Detail |
|---|---|
| **Name** | unique |
| **URL path** | generated from the name; unique; letters, digits, `-`, `.`, `_`, `~`, words separated by `/` or `-` |
| **Type** | None, Dashboard, Knowledge base, List, Record (a landing page gets Landing). Only helps filtering in the experience view |
| Required parameters | pieces of data the page cannot work without (`table`, `sysId`, `query`); they appear as path segments, and components can bind to them |
| Optional parameters | name and value pairs, in any order |
| Scope | the session scope at creation; cannot be changed |

Create: experience > **+** next to Pages > **Create a new page** > a template (**Use template**) or **Create from scratch instead** > name, path, type > parameters > **Looks good** > variant name (first one is *Default*), audiences, conditions > **Build responsive** (default) or **Build without responsive** > **Create**. Edit later: More actions > **View settings**.

| Start from | Result |
|---|---|
| Scratch | empty page; the only way to get responsive authoring (since Xanadu Store Release 1) |
| Template (for example *Standard record*) | layout, configured components, data, modals, controllers that enable presets, parameters and test values |
| Legacy template (**View legacy templates**; role admin) | choose **Use the original page (customization limited)** = a reference that keeps receiving upgrades, or **Copy contents of the page (fully customized)** = no further updates |

**Test values**: sample values for the URL parameters (for example table `incident` and a sys_id) so the editor and preview have data; a data resource is then bound to them (table bound to `context.props.table`).

## Variants

A variant is another version of the page at the **same path**. When a user opens the path, the system checks audience, conditions and order and serves the matching variant.

| Setting | Meaning |
|---|---|
| **Name** | |
| **Availability** | **Active** = can be served |
| **Order** | lower number = higher priority; decides between variants whose conditions are equal |
| **Conditions** | **Parameter** (only the page's own parameters; a sub-page also sees outputs of the parent's controllers), **Operator** (is, is not, starts with ...), **Value**. AND or OR chains through the buttons; mixing both needs **Enter as text** with an encoded query |
| **Audiences** | each with its own order and active flag; a user in several gets the highest priority one. Role admin is stated for editing audiences |

```text
table=task^sysId=<sys_id>^ORsysId=<other sys_id>
```

- Create: **+** > **Add a variant to a page** > **+ Add variant** > scratch or template. Or the variant's menu > **Duplicate variant** (the usual way to make an admin-only or table-specific copy).
- Typical use: one *Standard record* page with variants `table=task`, `table=incident`, and so on.
- In the experience view the Conditions column has **View**, and the Audiences column shows a count.

**Missing page definition**: a variant is backed by a UX screen (`sys_ux_screen`) that points to a macroponent (`sys_ux_macroponent`). If the reference is lost (partial import, manual edit) the page will not render: open the variant record > UX Screens tab > the screen > set **Page Definition** to the right macroponent (find it in `sys_ux_macroponent.list`, filtered by the application) > **Update**.

## Preview and test

- **Preview** opens the current variant in an overlay without saving: modals, viewports, live data; change test values (**Apply**) and form factor there. Those changes stay when you return to the editor.
- **Preview > Open URL path** asks the server for the path, so you see the variant a real user would get.
- Inactive variants and page collections (sub-pages) cannot be previewed.

## Pages shared across experiences

One page, several experiences, a single source: edits appear everywhere.

1. In the owning experience: Experience settings > **Open app config** > the page > tick **Use across experiences** > **Update**. All *linked pages* (routes it navigates to in the same source experience) must be specified.
2. In the receiving experience: **+** > Advanced > **Add a page from another experience** > the page > **All Variants** or specific ones > review the URL > **Order of evaluation**, **Audiences**, **Conditions**, **Description** > **Complete**.

Shared pages show a two-page icon and the name of their source experience. Configuration is done in the platform records; UI Builder only shows them.

## Responsive authoring

| Form factor | Width |
|---|---|
| Desktop | 1281 px and up |
| Tablet | 501 to 1280 px |
| Mobile | 500 px and below |
| Custom breakpoints | up to three: form-factor menu > **+ Add breakpoint** > width. A breakpoint covers its width and everything below, down to the next one. The three defaults cannot be changed |

- Only for pages created **from scratch** with *Build responsive*. Other pages use **reflow**: content stacks vertically by itself (also what makes pages usable at 400% zoom).
- **Changes cascade downwards only**: a change made at tablet also applies to mobile unless mobile overrides it; nothing flows up to desktop. Overridden fields carry a form-factor icon.
- Techniques, each set per form factor from the icons above the stage: hide or show a component (**Component visibility > Hide component**, for example buttons on desktop and a dropdown on mobile), change component configuration (a list with 1 column, small header, hidden pagination details), change styles (margin, heading level), change layout (a column's **Direction**).
- Global whatever the form factor: number of columns, *Stack columns below*, accessibility options, and **controller properties**.

## Layouts

A layout is a container; UI Builder uses ordinary CSS (Flexbox, Grid, absolute positioning).

| Layout | Use |
|---|---|
| Column layout (Basic options) | one to six columns, equal or different widths; several per page; empty columns as white space. Columns cannot be shown or hidden by condition |
| Flexbox | one-dimensional: **Direction** (row, column, reversed), **Align items**, **Justify content**, and under advanced options **Gap** and wrapping |
| Grid | two-dimensional: **Columns**, **Rows**, **Direction**, **Gap**, and under advanced options align / justify items and content |

Column layout operations (content tree menu, stage, or configuration panel): add column before or after, rename, drag a divider to resize (percentages total 100), **Distribute columns evenly**, reorder by dragging, **Column gap**, delete. Inside a column: **Gap** between components (a custom value such as `300px` through the pencil), **Direction** row or column, reverse. Advanced layout options: **Stack columns below** (a width under which columns stack) and **Height**, **Min. H**, **Max. H** (useful around tall components such as lists).

Any layout: Styles tab > *Show advanced configuration options* > **View and edit CSS**.

### Old layout systems

- The layout system changed in San Diego (simpler content tree, no slots). Variants from Quebec or Rome are marked with a red dot: open > **Update layout** > compare both versions > **Keep new** or **Use old**. Only the layout is converted; complex pages may need manual realignment.
- Pages from before Quebec (row and column system) cannot be upgraded: rebuild them.
- In the old system, layouts are edited as JSON through **Edit layout code** (slots with `slotName`, `flex`, `grid-area`; **Reset to original**). Layout templates live in `sys_uib_template`.

## Related

- [[UI Builder Overview and Concepts]] · [[UI Builder Components, Events and Styling]] · [[UI Builder Data Resources, Controllers and Client Scripts]] · [[Workspace Builder]]
