---
type: concept
tags: [concept, reporting, schema, roles, update-sets, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Platform Analytics experience > Dashboards (Explore, Working with in-line dashboards, Configure, Technical dashboards overview and comparison, Reference, Terms), read 2026-10-30. Technical dashboard drilldown, filter event handler and local data instance procedures not summarised. https://www.servicenow.com/docs/r/now-intelligence/analytics-center-dashboards.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Platform Analytics Dashboards

**In one line:** a dashboard (`par_dashboard`) is a shareable canvas of data visualizations, filters and other elements, optionally tabbed, found in **All > Platform Analytics > Library > Dashboards**.

From the Brazil docs; not tested. Core UI and Platform Analytics dashboards sit together in the library when `com.glide.par.unified_analytics.enabled` is true.

## Ways to build one

1. **Inline editor** in the experience: no developer needed; try this first.
2. A generic **UI Builder** page with visualization components: most freedom, most configuration.
3. Inline dashboard placed in a UI Builder page through the **Dashboard page template**.
4. **Technical dashboard**: a UI Builder page exposed as a dashboard, so it stays in the library with details and sharing.

| | Inline | Technical |
|---|---|---|
| Create | any internal role | `ui_builder_admin` |
| Content | filters, headings, images, lists, visualizations | any UI Builder component |
| Duplicate, export | yes | no |
| Data sources | predefined | also manual JSON and local data instances |
| Drilldown | default and **Chart interactions** | custom event per visualization |
| Filter events | preconfigured | manual client-script handlers |
| Filter values across sessions | kept per viewer | not kept |

Start technical dashboards from the library (**Technical editor** tile), never directly in the **Advanced Dashboards** experience, or the page will not be listed. They cannot be moved by update set or rolled back to Core UI.

Core UI dashboards can be created from the library on upgraded instances when `com.snc.par.coreui.dashboard_create.enabled` is true, but not on instances net new on Xanadu or later.

## Elements

Data visualization, Divider, Filter, Filter Group, Heading, Image, List, Process Mining - Map, Rich Text, Workbench, Usage Insights funnel, ServiceNow Otto context menu. Reports and PA widgets cannot be placed directly: use data visualizations.

- Elements above the tabs (**top stage**) show on every tab, and filters there apply to all tabs.
- **Workbench** needs `com.snc.pae.workbench_enabled` = true and is created only in Core UI (iframe).
- **Grouping** needs `par.dashboard.widget.group.enabled.dashboards.list` = ALL, -1 or a dashboard sys_id.
- **Otto context menu**: a default one is added for `sn_pa_aia_insights.summary_user`; skills are set up in **AI Admin Hub > Experiences** on table `par_dashboard` (`now_assist_admin`). Respects applied filters.
- **Process Mining map**: needs an existing project and `sn_process_optimization_analyst`; filters apply only if on the project's table and a breakdown field of it.
- Default sizes in the docs: 6 columns by 3 rows; 48 by 18; 11 by 11. The mapping to element types is ambiguous on the page.

Editing a library element changes it everywhere. Without edit rights, **Unlink from library** gives a local copy. Delete on elements or tabs has no confirmation.

**Edit lock:** one editor at a time; the viewer sees the locker's initials instead of **Edit**; More actions can clear the lock (use with care). Editing outside the dashboard's application scope lets you change but not save.

## Sharing and rights

Share from More actions, as **viewer** or **editor**, to users, groups or roles (sharing to roles needs read on `sys_user_role`). Share to `dashboard_user` for all authenticated users who have at least one role. Editors need to be in the dashboard's scope. Viewers can change content but not save it. Shared rights do not extend to the visualizations outside the dashboard, and raw data (lists) still follows data access: others see a message instead.

| Task | Role |
|---|---|
| Create, duplicate, print, bookmark | any role (with access) |
| Edit, delete | creator or shared editor; `dashboard_admin` for any; technical also `ui_builder_admin` |
| Schedule refreshes | `dashboard_admin` or higher |
| Schedule export | `par_scheduler` (own or shared); `dashboard_admin` for any; delete needs `sn_par_sche_export.par_scheduler_admin` (contained in `dashboard_admin`) |
| Categories | create: `analytics_categories_admin` or `platform_analytics_admin`; assign: anyone who can edit |
| Tab cache timeout | `admin` |

**Unconfirmed variant:** certify needs `admin` on the Configure page; `admin` or `dashboard_admin` on the Certify page and in the terms.

Recipient lists can be narrowed or enriched through reference qualifiers and the *Reference auto completer columns* attribute on `par_dashboard_permission` (and `par_notification_email_recipients` for exports).

## Refresh and cache

- **Scheduled repetition** (minimum 10 minutes): reloads only while the dashboard is open; turns off data cache and vice versa.
- **Enable data cache**: expiry 1, 2, 4, 8, 12 or 24 hours. *Real time update* or *Refresh after being away for X min* on a visualization overrides it.
- `next_experience.dashboard.tab.timeout`: minutes tab content stays cached, default 20, instance-wide.
- `par_dashboard_cache`: delete a row to regenerate a dashboard's layout cache when troubleshooting. The docs also say this table is removed on upgrade from before Australia: unconfirmed.

## Export

- **Export** (More actions; inline only): PDF or PowerPoint, one visualization per page or slide, optional tabs and applied filters, download or email. Calendar, geomap and indicator scorecards are skipped; lists only in PDF, at the end; headings and rich text are not exported.
- **Printer friendly**: lists show only the first lines.
- **Scheduled export** (More actions > **Schedule**; list at **Library > Scheduled Export**): several dashboards and visualizations in one email, ZIP option, **Omit if no records**, **Use conditions** with a script. The condition script runs server side in the **script sandbox** (no function definitions; the last expression must be boolean). See [[Script Sandbox and Guarded Script]].

| Element | Dashboard export | Visualization export |
|---|---|---|
| Calendar, indicator scorecard, pivot, geomap | none | none |
| Lists | PDF | PDF, Excel, embedded list, CSV |
| Other visualizations | PowerPoint, PDF | PowerPoint, PDF, PNG, JPEG, embedded PNG |

Restrict instance-wide: `glide.par.export.enabled` (default true), `glide.par.export.allowed_roles` (default empty = all).

## Admin tasks

- **Library for admins**: statistics (not viewed in 3, 6, 12 months, deactivated over 3 months), Activate, Deactivate, Delete, **Switch to Next UI**, columns Views, UI version, Ready to migrate, Visibility.
- **Dashboard Visibility** only allows adding to a workspace; it does not show the dashboard there.
- **Delete** is irreversible and runs the **Delete Dashboard** subflow, which can be extended; output codes 1 success, 2 failed, 3 initiated. Plugin dashboards come back by repairing the plugin.
- **Home page**: user preference `my_home_navigation_page`, **System** ticked, no user, string, `$pa_dashboard.do` for the last visited dashboard, or `/now/platform-analytics-workspace/dashboards/params/edit/false/sys-id/<dashboard_sys_id>` for one. Set a User for specific people. The vault also holds `$pa_dashboards.do?id=<sys_id>` under `glide.login.home` ([[Local Authentication - Login, Password Policy and Password Reset]]): unconfirmed variant.

### Move with an update set (inline only)

In the source, activate a new update set, open `par_dashboard_list.do`, open the dashboard, Additional actions > **Unload Dashboard** once its content is final, complete the set, retrieve it on the target. It carries the dashboard, tabs, security, settings, and saved visualizations and filters; other content must be in the set or already on the target, otherwise errors result.

## Domain separation

Standard. Records, tabs and widget containers are separated; widget content follows its own domain. Global dashboards are visible to everyone shared with; parent domain dashboards to child domains when shared, needing delegated administration, read only. Do not edit a separated dashboard from global.

## Tables

| Table | Holds |
|---|---|
| `analytics_dashboard` | parent of `par_dashboard*` and `pa_dashboard*`, common fields |
| `par_dashboard` | library dashboards; technical ones belong to Advanced Dashboards |
| `par_dashboard_canvas`, `par_dashboard_tab` | names and layouts; tabs |
| `par_dashboard_widget`, `par_dashboard_widget_group`, `par_dashboard_widget_group_mapping` | placed components; groups |
| `par_dashboard_config` | macroponent definition per visualization type |
| `par_dashboard_filter` | filters per dashboard |
| `par_dashboard_permission`, `par_dashboard_visibility` | sharing; workspaces |
| `par_dashboard_user_metadata` | a viewer's persisted options, also card images |
| `par_export`, `par_export_dashboard`, `par_export_job` | scheduled exports and attempts |
| `par_notification`, `par_notification_email`, `par_notification_email_recipients` | export emails |

Most extend `sys_metadata`. Insight tables are in [[Proactive Analytics Insights on Dashboards]]. Translatable element fields use `sys_ui_message`.

## Example

Dashboard *Example Service Desk Overview* with tabs *Today* and *Trends*, filter *Example Assignment Group* above the tabs, shared with *Example Group* as viewer and scheduled weekly as a PDF to *Test User*, with **Omit if no records** on.

## Related

- [[Platform Analytics Experience Overview]] · [[Migrating Core UI Reporting to Platform Analytics]] · [[Workspace Builder]] · [[Fluent API - Dashboards, Notifications, Flows, Import Sets and Lists]]
