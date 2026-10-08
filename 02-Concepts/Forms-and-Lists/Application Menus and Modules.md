---
type: concept
tags: [concept, platform, forms-lists, roles, encoded-query, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Testing and debugging applications > Automated Test Framework (ATF) > Test step categories > Application Navigator category (read 2026-10-08 through the docs site), which embeds the topics Create an application menu, Create a module, Module link types, Encoding module URIs. https://www.servicenow.com/docs/r/application-development/automated-test-framework-atf/test-steps-application-navigator-category.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Application Menus and Modules

**In one line:** the application navigator is made of **application menus** (`sys_app_application`) containing **modules** (`sys_app_module`); a module is a link to a list, a form, a report, a URL or a script, shown only to users with the right roles.

From the Brazil docs. Tables per file type: [[Metadata File Types and Primary Tables]]. As source code: `ApplicationMenu` in [[ServiceNow Fluent API Reference]]. Testing visibility: [[ATF Test Step Categories Reference]].

## Application menu

**System Definition > Application Menus > New** (role admin).

| Field | Meaning |
|---|---|
| **Title** | display name |
| **Roles** | who sees the menu; empty = everyone, when active |
| **Category** | menu category that gives the style (default *Custom Applications*) |
| **Hint** | tooltip |
| **Order** | position; empty = the category's default order |
| **Active** | |

**A menu with no modules does not appear.**

## Module

Open the menu (list, or the pencil icon beside it in the navigator) > *Modules* related list > **New**.

| Tab | Field | Meaning |
|---|---|---|
| | **Title**, **Application menu**, **Order**, **Hint** (deprecated in Core UI) | |
| Visibility | **Roles** | empty = everyone who can see the menu |
| Visibility | **Override application menu roles** | the module is reachable without the menu's roles (the module's own roles still apply) |
| Link Type | **Link type** | below |
| Link Type | **Table** | only tables and database views of the module's scope are listed |
| Link Type | **Filter**, **View name**, **Arguments**, **Window name** | per link type |

| Link type | Opens |
|---|---|
| List of Records | the table's list, with **Filter** and **View name** |
| List Filter | an empty list waiting for a filter (for large tables) |
| New Record | a new form; **Arguments** can apply a template |
| Single Record | one record's form |
| Search Screen | a blank search form (starts-with matching only; `&sysparm_result_view=<view>` for the result view) |
| Run a Report | a saved report |
| Homepage, Content Page, Map Page, Timeline Page | the selected page |
| Assessment; Survey | an assessment-based survey; a legacy survey |
| URL (from Arguments) | any URL; **Window name** to open a new window. Use **relative** links for pages of the instance (`catalog_home.do?sysparm_view=catalog_default`): an absolute URL keeps pointing at the development instance after the update set moves |
| Script (from Arguments) | runs the script in **Arguments** |
| HTML (from Arguments) | raw HTML in the navigator; legacy UI15 and UI11 only |
| Documentation Link | a documentation page in a new tab |
| Separator | a divider; with a **Title** it becomes a collapsible section |

## Encoding module arguments

Everything in a module URI must be URL-encoded (property `glide.ui.encode_module_uri`, on by default; modules created before New York may break after upgrade). The **Filter** is always encoded by the platform and appended as `sysparm_query` (`active=true` becomes `sysparm_query=active%3Dtrue`). For **Arguments**:

| Filter set? | Arguments start with | Who encodes | Result |
|---|---|---|---|
| No | `^` | platform | caret removed, encoded, appended through `sysparm_query` |
| No | `&` | **you** | ampersand removed, appended as is |
| No | anything else | platform | encoded, appended through `sysparm_query` |
| Yes | `^` | platform | filter and argument encoded together in `sysparm_query` |
| Yes | anything else | **you** | filter encoded; arguments appended unchanged |

```text
&sysparm_fixed_query=assigned_to%3Djavascript%3Ags.user_id()
```

(the unencoded form `&sysparm_fixed_query=assigned_to=javascript:gs.user_id()` breaks the module).

## Related

- [[Metadata File Types and Primary Tables]] · [[List Configuration and List Controls]] · [[Form Layout, Sections and Views]] · [[Users, Groups and Roles Overview]]
