---
type: concept
tags: [concept, portal, workspace, instance-admin, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Next Experience UI (137 topics; Explore and Configure overviews, activation considerations, Readiness Checker, global variables, system property names), read at overview depth 2026-10-30. Step pages and property descriptions not read. https://www.servicenow.com/docs/r/platform-user-interface/next-experience-readiness-checker.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Next Experience UI and Unified Navigation

**In one line:** the current platform interface, unifying the classic environment and workspaces under one header of navigation, search, notifications and preferences.

From the Brazil docs; not tested. Never assume it is on: some instances keep Core UI, and `glide.ui.polaris.experience` = false turns it off.

## Unified Navigation

Controls for navigating, reaching records and data, notifications and preferences; a custom menu can be added. Add a workspace to the **Workspaces** menu; order it by creating `glide.ui.next_experience.workspace_sorting` = Order, then numbering the workspaces.

- **Scope pickers:** application, domain and update set. A red circle on the icon means a non-Global application scope is selected, which matters when you make changes.
- **User menu (admin):** elevate roles, impersonate users, configure a workspace.
- **All Menu Editing:** create application menus and modules directly in the All menu.

## Configuration

- **Activation:** during an upgrade or later. **Readiness Checker** shows whether users rely on applications not compatible with Next Experience.
- **Landing pages:** several start page options. Existing dashboards or landing logic take precedence.
- **Themes:** Polaris and Coral are included. **Theme Builder** creates and publishes themes. Theming reaches classic lists, forms and dashboards, not custom components.
- **Search:** searchable tables, fields shown, workspaces in the search context menu.
- **In-product notifications**, **banner announcements** (all or chosen experiences).

## Scripting

Client scripts can test `NOW.isUsingPolaris` to see whether Next Experience applies to the page.

```javascript
// Client script (client): test whether the page runs in Next Experience
if (NOW.isUsingPolaris) {
    // Next Experience behaviour
}
```

## Properties named

`glide.ui.polaris.experience`, `glide.ui.polarisberg`, `glide.ui.polaris.dark_themes_enabled`, `glide.ui.polaris.core_ui_exclude_dark_mode`, `glide.ui.polaris.global_search`, `glide.ui.polaris.menus`, `glide.ui.polaris.history.url.param_blocklist`, `glide.ui.polaris.nav_filter_accuracy_score`, `glide.ui.polaris.login.show_illustrations`, `glide.ui.polaris.login.style.*`. Meaning of most not read.

## Example

Add workspace *Example Agent Workspace* to the Workspaces menu, set its order, and publish theme *Example Brand Theme*, previewing with *Test User*.

## Related

- [[Service Operations Workspace for ITSM]] · [[Service Portal Overview and Configuration]] · [[Adoption Services, Boards and Legacy UI Tools]] · [[System Properties Reference]]
