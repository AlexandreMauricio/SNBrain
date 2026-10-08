---
type: concept
tags: [concept, workspace, portal, flows, forms-lists, admin]
status: documented
source: ServiceNow Australia Build workflows PDF, "Designing Playbook Experience" (pp. 172-210: components, bundles, customizing in UI Builder, adding bundles to pages, Guided activity view, layout bundles, playbooks in Service Portal with theme mapping, content items, widget and designer options, running and errors, mobile configuration and embedding), read in full 2026-10-08; the PDF ends on p. 210 in the middle of the mobile embedding procedure
sn-release: Australia
verified:
updated: 2026-10-08
---

# Playbook Experience Design for Workspace, Portal and Mobile

**In one line:** Playbook Experience is the runtime side of a playbook: UI Builder components that show stages and activity cards in a configurable workspace, a Service Portal page or the mobile app.

Playbooks are built first ([[Playbooks Overview and Components]]). Needs the Playbook Experience (`sn_playbook_exp`) and Playbook Experience Component apps. Workspaces and Service Portal need nothing more after the page is designed; mobile needs an extra embedding step.

## Components

| Component | Role |
|---|---|
| Playbook Stage Picker | *vertical*: every playbook on the parent record, its stages, and per stage how many activities remain and are in progress; *horizontal*: stages of one playbook (more than 5 paginate; switching playbooks needs the playbook picker from a template) |
| Playbook Activity Picker | navigate between activities (expands under each stage vertically; a collapsible list horizontally) |
| Playbook Activity Viewer | where cards are worked. **Activity View**: *Stacked* (all cards of the stage), *Focused* (one selected card), *Guided*, *Wizard* |
| Playbook Modals | required for cancelling a playbook and adding optional activities |
| Playbook Custom Layout UI Controller | data resource whose **presets** fill each component's inputs and events. Custom components are possible but get no presets |

Controller settings: **Parent Table** and **Parent SysID** (for example `context.props.table`, `context.props.sysId`; sys_id `-1` means "no record yet" and shows a record generator form), the **Playbook Experience**, **Activity View Mode**, **Record Generator Query**, and context ids of a selected playbook, stage or activity for deep links.

## Bundles and templates

A *template* is a whole new page; a *bundle* is the same wiring dropped onto a new or existing page (toolbox > search "bundle"). Each bundle brings controller, presets, viewer, pickers, modals and client scripts.

| Bundle | Behaviour | Page template |
|---|---|---|
| Focused Vertical / Focused Horizontal | one activity at a time | yes |
| Stacked Vertical / Stacked Horizontal | several activities visible | yes |
| Horizontal Wizard | numbered steps across the top, linear | no |
| Guided Layout | no pickers; the user answers in sequence, earlier answers fold into an accordion; for Guided Decision playbooks | no |

If a bundle renders too narrow, set the container's min-width to 100%.

### Build a page (roles `ui_builder_admin`, admin)

**Now Experience Framework > UI Builder** > the shipped *Playbook Experience Builder* experience (or your own, app shell *UXR Base Experience Shell*) > new page from a Playbook Experience template, the *Standard record* template, or scratch. Page parameters: `table`, `sysId` (required); `query`, `extraParams`, `views`, `selectedTabIndex`, `experience`, `selectedPlaybook`, `selectedStage`, `selectedActivity` (optional). Then a page variant (audiences by role, group, user, company, department, location or script; conditions). Without a template: add the controller as a data resource, add a tab, a *Resizable panes* component, stage picker left, activity viewer right, modals on the tab, and pick the controller preset on each.

**Guided activity view** (admin, `playbook.admin`): Playbook Activity Viewer > **Activity View** = Guided. One activity at a time, used by the shipped Employee Center self-service playbooks (experience *Guided Self-Service in Employee Center*). Not supported with it: parallel activities, optional activities, stage picker components, the *Pending Item Visibility* setting.

## Service Portal

Playbooks appear to requesters as catalog-like items; the user can save and resume, go back to earlier steps, and open records or lists in modals. Roles: admin or portal admin to set up; `snc_internal` or `snc_external` to run.

1. **Theme mapping** (only if the portal theme differs a lot from the UI Builder theme): a system property named `ux_portal_theme_to_uib_theme_mapping.<portal theme sys_id>` whose value is `<sys_ux_theme sys_id>[,<sys_ux_style sys_id>]`. Delete the property to turn the mapping off.
2. **Playbook Content Item** (**Playbook Experience > Playbook Content Items**): **Name**, **Active**, **Catalogs** and **Category** (without them it cannot be found by search), icon, picture, **Short description**, **Table** (default Incident), **Record ID** (`-1` to use the record generator), **Playbook Experience** (default *Global Playbook Experience*), **Playbook Experience Record Generator**, **Portal Page** (default the shipped Playbook Portal page), **Title**, **Meta** tags.
3. **Designer** (**Service Portal > Service Portal Configuration > Page Editor** > the playbook page > widget options): **Playbook UIB Page URL**, **Open Record Widget**, **Open Record is Pop Up**, **Open List Widget**, **Extra Params**; presentation: **Height** (default 850px), titles, messages, buttons (JSON), view and size (sm, md, lg; default lg) of the open-record and open-list modals, **Activity View**, **Playbook Experience ID**, *Prevent URL Update on Submit*.

In the portal a **record generator** replaces the record producer: the requester fills it and moves on with Next or Continue.

The **Portal Playbook widget** is an iframe onto the UI Builder portal page; it relays events (open record, open list) through session storage. Do not edit the shipped widget, page or content item: clone the widget (**Service Portal > Widgets**), keep all its actions and options, and give the clone a different iframe URL.

URL parameters when launching: `layoutType` (`custom`, else standalone), `table`, `sys_id`, `playbookExperienceid`.

| Message | Cause |
|---|---|
| 404 page not found | table or sys_id missing or wrong in the URL |
| Configuration Error | the record does not exist in that table |
| There are not playbooks available | the record exists but does not meet any playbook's conditions |
| No Activities Available | activities hidden by role or run conditions |
| No filtered results | the filter leaves nothing in that stage |

Further checks: execution logs on the `sys_pd_context` record (Today's Executions); the flow debugger; instance logs around the run; minimum component versions (the guide names 25.1.x); browser console.

## Mobile

1. Same design as for a workspace, plus an **action assignment**: **Workspace Experience > Actions & Components > Related Items** (or **Contextual Side Panel**) > **New**: **Action label**, **Action name**, **Implemented as** = UI Component, component `now-playbook-experience`, **Workspace**, **Table**, **View**, **Order**.
2. *Advanced View* > **Component Attributes**: `playbookExperienceId` (empty = global experience), `parentSysId` = `{{sysId}}`, `parentTable` = `{{table}}`, `compactMode` (true for the side panel, false for a related item), `isNewParentRecord` = `{{isNewRecord}}`.
3. **Conditions**: script condition `sn_playbook.PlaybookExperience.parentRecordContainsPlaybook(current)` (server-side; shows the playbook only when the record has a process execution), plus roles and record conditions as needed.
4. Embed: **System Mobile > Mobile App Builder** > application scope > **Screens > New > Mobile Web**: name, icon, and the playbook URL including `web_controller_spinner=on`, for example `/now/playbook-mobile/playbook/<table>/-1/params/view/stages?web_controller_spinner=on`. Then **Mobile app configs** (the PDF stops here; the remaining steps are not captured).

## Related

- [[Playbooks Overview and Components]] · [[Playbook Activities, Decisions and Variants]] · [[Service Operations Workspace Configuration and Customization Reference]] · [[ITSM Mobile Agent]]
