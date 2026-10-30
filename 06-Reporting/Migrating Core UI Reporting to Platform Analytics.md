---
type: concept
tags: [concept, reporting, schema, update-sets, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Platform Analytics experience > Platform Analytics Migration Center (all sub-pages), read 2026-10-30. https://www.servicenow.com/docs/r/now-intelligence/data-migration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Migrating Core UI Reporting to Platform Analytics

**In one line:** the **Migration Center** moves Core UI dashboards, reports, interactive filters and Performance Analytics widgets into the Platform Analytics experience, in full or in part; content it cannot convert goes in as iframes (**compatibility mode**).

From the Brazil docs; not tested. It exists only on **upgraded** instances: net new Xanadu or later instances have no Migration Center, no *Ready to migrate* column and no *Switch to Next UI* button.

**Update sets cannot carry migrated content.** Test on one non-production instance, then repeat the migration on production.

## Process

1. Remove unused dashboards (`pa_dashboards.list`) and reports (**Reports > Administration > All**).
2. Open the Migration Center. **Unconfirmed variants of the path:** **All > Performance Analytics > Migration Center** and **All > Platform Analytics Administration > Migration Center**.
3. **Start moving** (or **Try your content** for a limited test); optionally tick *Prevent users from creating Core UI analytics during migration*; **Migrate**.
4. Review: **Fully migrated** and **Compatibility mode** tabs, **Compare**, **View Logs**.
5. **Activate**. Nothing is visible in the experience until then. Menus then redirect to **Platform Analytics > Library**.

Roles: `admin` for full migration and activation; `pa_admin`, `report_admin` and `dashboard_admin` can evaluate. If content changes later, a banner offers **Migrate again**. Upgrades automatically migrate content that has become compatible.

After migration, Core UI reports, PA widgets and filters can no longer be added to Platform Analytics dashboards.

## Partial migrations

| Scope | Where | Role |
|---|---|---|
| Selected dashboards | **Platform Analytics > Library > Dashboards**, rows with *Ready to migrate* = Yes > **Switch to Next UI**; or `pa_dashboards.list` > **Migrate Dashboard** | `dashboard_admin` or higher |
| Own dashboards | **Self-Service > Dashboards**, banner on the dashboard | owner; `admin` or `dashboard_admin` for any |
| Reports | `sys_report.list` > **Migrate Report** | `report_admin`, `dashboard_admin` or higher |
| Scheduled reports | `sysauto_report.list` > **Migrate Scheduled Report** | `report_admin` or `report_scheduler` |
| Filters | **Platform Analytics Administration > Core UI Artifacts > Interactive Filters** > **Migrate filter** | not stated |
| PA widgets | **Platform Analytics Administration > Core UI Artifacts > Widgets** > **Migrate PA widget** | not stated |

*Ready to migrate* values: Yes, No, Already migrated, Not applicable. Editing a Yes dashboard sets it back to No until re-evaluated.

Behaviour to remember:

- Content used on one dashboard stays local to it after migration; content used on several goes to the library.
- Re-migrating a changed dashboard overwrites the migrated one. A changed report overwrites the migrated visualization in a **full** run or when migrated again from `sys_report.list`, but not in a partial migration of dashboards.
- Delete a migrated dashboard before re-migrating it, to avoid duplicated content.
- Reports do not auto-redirect to the migrated visualization, because dashboards using them still need them.
- Non-responsive dashboards nobody opened have empty canvases and migrate with empty tabs: open them first.

## Not migrated, or compatibility mode

- **Not migrated:** dashboards with dynamic content blocks; widget title alignment; debug filter, user-preference filters, cascading Choice to Choice filters, filtered list content; role restriction of dashboard access; group edit rights (sharing drops to view, reshare it); *Show Distribution* and *Show Bullet chart* on scorecards; Calendar year view.
- **Header and colour** are lost on visualizations used on several dashboards.
- **Compatibility mode (iframe; may perform worse):** anything that is not a PA widget, report or interactive filter, including custom filters, content blocks, gauges and gadgets. Report types Control, Trendbox, Histogram, Funnel, Pyramid. PA widgets Workbench, Text Analytics, Treemap, Previous period charts, Spider, Relative compare. Also sort by dot-walked field, reporting on variables, Group by on duration fields, hierarchy breakdowns on filters, and several scorecard options.

## Table mapping

| Item | Core UI | Platform Analytics |
|---|---|---|
| Dashboards | `pa_dashboards` | `par_dashboard` |
| Dashboard groups | `pa_dashboards_group` | `analytics_category` |
| Reports | `sys_report` | `par_visualization` |
| PA widgets | `pa_widgets` | `par_visualization` (blank cell on the page, inferred from the merged table) |
| Interactive filters | `sys_ui_hp_publisher` | `par_component_filter` |
| Scheduled reports | `sysauto_report` | `sysauto_par`, `par_export_visualization`, `par_notification_email` |

Virtual table for the scheduled export form: `snpar_sched_export_v_scheduled_export_visualization`.

Bridging and log tables, each row with type bulk, owner, list or upgrade; logs can be empty because only problems are logged: `par_coreui_migration_bridge_dashboard`, `..._sysauto`, `..._widget`, `..._component`.

## Properties

| Property | Effect |
|---|---|
| `com.glide.par.coreui.migration.enabled` (create it) | false before migrating disables **Start moving** and **Activate**; false afterwards disables only **Activate** |
| `com.glide.par.coreui.migration.admin_redirection.enabled` (create it) | true sends `admin` and `dashboard_admin` from responsive dashboards to the migrated one; false keeps Core UI |
| `com.glide.par.coreui_single_migration.enabled` | false hides the owner's migrate banner |
| `com.glide.par.unified_analytics.enabled` | false hides the library banner on instances that will not migrate; also governs both kinds of dashboard coexisting (true on net new and upgraded Australia) |

**Exclude artifacts:** add the column **Do not migrate in bulk** to `sys_report`, `pa_widgets`, `sys_ui_hp_publisher` or `pa_dashboards` lists and set it true (if not editable, change the list control's **List edit type** to *Save data by rows*).

## Roll back

`par_dashboard.list` > select > **Rollback** (`dashboard_admin`), or **Switch to the Core UI** in the dashboard's More actions (analytics managers, admins, and owners for what they migrated). Content comes back as iframes. UI Builder (technical) dashboards cannot be rolled back.

## Example

On a test instance, set **Do not migrate in bulk** on *Example Legacy Gauge Dashboard*, run a full migration, compare *Example Service Desk Overview*, read its log in `par_coreui_migration_bridge_dashboard`, then **Activate**.

## Related

- [[Platform Analytics Experience Overview]] · [[Platform Analytics Dashboards]]
