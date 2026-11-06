---
type: concept
tags: [concept, portal, workspace, instance-admin, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Next Experience UI (137 topics), first read at overview depth 2026-10-30 (https://www.servicenow.com/docs/r/platform-user-interface/next-experience-readiness-checker.html), then read in full 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g, chapter tOzx0pRKZUQl__6I1N82hg) - activation, Readiness Checker, admin user menu, custom Unified Navigation menus, All Menu Editing and its modules, Workspaces menu, search, pickers, global variables, system properties, instance performance, favorites, preferences, keyboard shortcuts, follow records. Themes and landing pages are in their own notes; notifications in Provider Notifications.
sn-release: Brazil
verified:
verified-by:
observed-in: [pdi-1]
updated: 2026-11-06
---

# Next Experience UI and Unified Navigation

**In one line:** the current platform interface, unifying the classic environment (lists and forms) and configurable workspaces under one header, the **Unified Navigation**, with menus, search, scope pickers, notifications and preferences.

From the Brazil docs; not tested. Never assume it is on: some instances keep Core UI, and `glide.ui.polaris.experience` = false turns it off. Themes: [[Next Experience Themes and Theme Builder]]. Start pages: [[Next Experience Landing Pages and Start Pages]]. In-product notifications: [[Provider Notifications]].

## Activation

- New instances have it on. During an upgrade it switches on unless `glide.ui.next_experience.opt_out` = true (only for instances not yet using it). `glide.ui.polaris.experience` = false turns it off for the whole instance and wins over every other property and user preference.
- `glide.ui.polaris.on_off_user_pref_enabled` (default true) shows a toggle so each user can turn it off (Preferences > User Experience; sets the user preference `glide.ui.polaris.use`).
- **Readiness Checker** shows which users rely on features that do not work in Next Experience: Guided Tours, Connect Chat, Connect Support, Live Feed, Follow.
- Not supported in Next Experience: Connect Chat (from Brazil the Sidebar replaces part of it), Connect Support, homepages (read-only), Live Feed, the JS console log. ATF does not test UI Builder pages, workspaces or landing pages. Following records works only from the classic form.

## Unified Navigation

- **Menus:** All, Favorites, History, Workspaces, Admin, Notifications, Help, user menu; Otto panel. `glide.ui.polaris.menus` = false hides them (hiding per role is preferred). `glide.ui.polaris.nav_filter_accuracy_score` (default 75; 100 = exact) controls menu filtering. A Display preference lets a filter search every menu except History.
- **Custom menu:** **Unified Navigation Menu** record (Name, Menu Active, Order, Application, **Hidden Roles**, **Visible Roles**), then configurable menu items of type Application or Module. Table names not given on the page.
- **Workspaces menu:** open the workspace's UX application, related list **UX Application Category M2Ms** (`sys_ux_registry_m2m_category`), New: Experience Category **Workspace**, Application, UX Application, Order. Ordering needs `glide.ui.next_experience.workspace_sorting` = `Order` (create it); lowest order first.
- **Search:** on by default (`glide.ui.polaris.global_search`); search sources, the `text_search` list view per table, workspaces in the search context menu ([[Zing Text Search and Global Search]]).
- **Admin user menu:** Impersonate user, Elevate role (only the base system admin can elevate; [[Explicit Roles and Elevated Privilege Roles]]), **Configure Workspace** (Configure workspace in UI Builder, Configure page for list or form items) when a workspace is in focus.
- **Banner announcements** (`announcement_admin` or `admin`): Heading (100 characters), Summary (200), Start, End, Color, link (label 50 characters, same or new window), **Non-dismissible**, **Non-stackable**, **Show for** (all logged-in users, roles or groups, or anonymous plus logged-in), Icon and tooltip, Content position; then **Associated to Configurations** > *Unified Navigation* config (lower mapping order = higher priority). A dismissed banner returns at the next session while active.
- **Toast position:** Preferences > Notifications > Next Experience > **Notification toast banner location** (default top right).

## All Menu Editing

Edit application menus and modules in place from the All menu (**Edit application** icon); changes save automatically; can be turned off per organization by a system user preference (name not given), falling back to the UI16 workflow.

- **Next Experience Application Menu:** Title, Roles (empty = everyone when active), Description, then add modules.
- **Next Experience modules** (built in the editor): **Dashboard** (data visualizations with data sources and conditions), **List** (table, view, saved filter), **New Record** and **Single Record** (table, view, form layout editor: sections, one or two columns, merge or detach, fields). Each has Roles, **Override app menu roles**, Hint.
- **Classic modules** (still edited in UI16): List of records, URL, Documentation link, New record, Run a report, Map page, Assessment, Timeline page, HTML, Search screen, List filter; separators and folders organize the menu.

## Scope pickers and instance tools

Application, Domain, Update set and **Crypto module** pickers (the last when the key management setting is opt_in). A red circle means a non-Global application scope. `glide.ui.next_experience.instance_tools_disabled` = false shows the instance tools row (scope and update set) and hides the picker icon. Domain picker roles: [[Domain Separation Administration]].

Picker keyboard shortcuts are off until two properties per picker are created: `glide.ui.keyboard.shortcuts.polaris.application_picker.enabled` / `.key_combo` (default `ctrl+alt+a`), `...domain_separation_picker...` (`ctrl+alt+d`), `...update_set_picker...` (`ctrl+alt+u`). The general shortcut table also gives Control+Alt+a for the **All menu**. Control+Alt+a opening the All menu was tested by the user (verified pdi-1 2026-11-06), with the picker shortcut properties not known to exist there; what happens once `application_picker.enabled` is created is still untested.

## Scripting

Client scripts (client side, global) can test `NOW.isUsingPolaris` (Next Experience applies to the page) and `NOW.isPolarisWrapper` (the page runs inside the Unified Navigation; exists only there). Scoped server API: `PolarisUI`.

```javascript
// Client script (client): reload the page inside the Unified Navigation if it is outside it
if (NOW.isUsingPolaris && (!top.NOW || top.NOW.isPolarisWrapper !== "true")) {
    var currentPath = window.location.pathname + window.location.search;
    top.window.location.href = "/now/nav/ui/classic/params/target/" + encodeURIComponent(currentPath);
}
```

## System properties (Brazil list)

| Property | Default | Meaning |
|---|---|---|
| `glide.ui.polaris.experience` | true | Next Experience on or off, instance-wide |
| `glide.ui.next_experience.opt_out` | false | do not switch on during upgrade |
| `glide.ui.polaris.on_off_user_pref_enabled` | true | per-user on/off toggle |
| `glide.ui.polarisberg` | true | disables Core UI styles for lists and forms in Next Experience |
| `glide.ui.polaris.dark_themes_enabled` | true | dark theming |
| `glide.ui.polaris.core_ui_exclude_dark_mode` | true | no dark theme in the classic environment |
| `glide.ui.polaris.global_search` | true | header search |
| `glide.ui.polaris.menus` | true | header menus |
| `glide.ui.polaris.history.url.param_blocklist` | `["tinyId"]` | URL parameters ignored when de-duplicating History |
| `glide.ui.polaris.list_style.enable_highlighted_value_style` | true | highlight colour on list cells (false = a dot) |
| `glide.ui.polaris.style.hide_empty_list_image` | true | hide the no-records graphic (Core UI only) |
| `glide.ui.polaris.nav_filter_accuracy_score` | 75 | menu filter accuracy |
| `overview_help.visited.navui` | true | whether the onboarding pop-up appears at first login |
| `glide.ui.polaris.login.*` | | login page; see the themes note |
| `glide.ui.next_experience.seismic_developer_tool_user_pref_enabled` | | false removes a developer tool from the Debugging preferences |

## Instance performance

**System Logs > Client Interactions**: one row per interaction kept up to seven days, with Total UI Time, Content Download Time, **UXF Screen Route** (*Classic* for lists and forms), Referrer, Application, Type (`PAGE_LOAD`, `NAVIGATION`, `IN-PAGE`), Interruption, and metrics such as `fci_time`, `network_latency`, `client_cache_hit_rate`, `total_sql_time`, `total_business_rule_time`, `page_variant_sys_id`. Server side: add **Interaction ID** to the list, then search `syslog_transaction` by **Client Interaction ID**. See [[Monitoring and Troubleshooting Instance Performance]].

## Preferences (user menu > Preferences)

Searchable modal with categories: **Display**, **Accessibility** (show date and time formats on forms, patterns instead of colours in charts, keyboard shortcuts, show buttons without hover, data tables for charts, reduce motion, accessibility in Classic, keyboard focus on truncated text, voice input for the Otto panel, do not auto-dismiss page alerts, auto-focus page alerts), **Debugging** (admin; UX source maps, slows the UI when left on), **Theme**, **Notifications**, **Language & Region** (language when a language plugin is active, country, date and time formats, session time zone), **Workspace** (ribbon and contextual side panel shown on load, lazy loading; only with a workspace in focus), **User Experience** (Next Experience off, start page). Admins set global defaults as system-wide records in User Preferences. Operating system forced colours win over themes.

## Keyboard shortcuts

Turned on in Accessibility preferences; Control+/ lists those for the current screen; users can remap (at least one modifier) and **Restore Defaults**. Selected Windows defaults: compose email Control+Alt+e, new record Shift+Alt+n, favorite Control+Shift+f, impersonate Control+Shift+i, landing page Control+Alt+z, domain toolbar Control+Alt+t, refresh list Shift+Alt+r, save Control+s; menus: All Control+Alt+a, Admin Control+Shift+a (both verified pdi-1 2026-11-06), Favorites Control+Alt+f, Help Control+Shift+/, History Control+Alt+h, Workspaces Control+Alt+w, Notifications Control+Shift+k, Otto Alt+Shift+a (voice Alt+Shift+v), user menu Control+Shift+u; focus: global search Control+Alt+g, main content Control+Alt+p, workspace / page / record tabs Control+Alt+2 / 3 / 4. macOS uses Command or Option equivalents.

## Example

Add *Example Agent Workspace* to the Workspaces menu with order 10 (after creating `glide.ui.next_experience.workspace_sorting` = Order), create Unified Navigation menu *Example Tools* visible to *Example Admin Role*, and schedule banner *Example Maintenance Window* for all logged-in users, non-dismissible.

## Related

- [[Next Experience Themes and Theme Builder]] · [[Next Experience Landing Pages and Start Pages]] · [[Configurable Workspace Administration - Lists, Forms, Activity Stream and Email]] · [[Service Operations Workspace for ITSM]] · [[Adoption Services, Boards and Legacy UI Tools]] · [[System Properties Reference]] · [[Impersonation]]
