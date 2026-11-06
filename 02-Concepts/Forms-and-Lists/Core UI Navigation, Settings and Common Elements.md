---
type: reference
tags: [reference, forms-lists, users, instance-admin, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Working in Core UI > Core UI (navigator, history, system settings), Common UI elements (log in, navigate directly to a table, tree picker, dot-walking, list collector, activity streams and mentions, enable or disable menus and modules, tags, user presence), Browser support, Core UI keyboard shortcuts, and User interface configuration > response time indicator, navigation stack, navigation action cancellation, user preferences and preference settings, read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g, chapter X1oo9mYeLZGrF1oDFABlYg).
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Core UI Navigation, Settings and Common Elements

**In one line:** Core UI (UI16, the interface before Next Experience) has a banner frame, an application navigator (All, Favorites, History) and a content frame; its per-user settings, the navigator commands, tags, user presence and user preferences (`sys_user_preference`) still matter in the classic environment.

From the Brazil docs; not tested. The newer header: [[Next Experience UI and Unified Navigation]]. Lists and forms: [[Core UI Lists, Forms and Related Lists]].

## Navigator

- Filter matches applications, modules and favorites (favorites first). **Commands** typed in the filter: `<table>.list`, `<table>.form` or `<table>.do` (new record), `<table>.config` (`personalize_all.do`), `<table>.filter` (empty list, filter before loading a big table). Upper case (`.LIST`, `.FORM`) opens a new tab. The table name must be the dictionary name.
- **Favorites:** star on a module or application, Create Favorite on a list or form context menu, or drag a breadcrumb, record title, list link or report to the Favorites tab; one per list or form view. Edit Favorites to reorder, rename, change icon.
- **History:** `sys_ui_navigator_history`; 30 entries by default, `glide.ui.nav.history_length`. UI pages are not tracked.
- Disable a menu or module: **System Definition > Application Menus** > Active, or module Active (*Change active state* on several); read-only, protected or private-scope items cannot change. See [[Application Menus and Modules]].

## System settings (gear icon, Core UI only)

| Tab | Settings |
|---|---|
| General | Accessibility enabled, Accessible tooltips on forms, Data visualization patterns, Compact the user interface, Compact list date/time, Keyboard shortcuts, Home (homepages or dashboards), Date/Time (Calendar, Time Ago, Both), Language, Time zone (session only), Domain and *Show domain picker in header* (`domain_admin` or `admin`), printer friendly version |
| Theme | Core UI theme |
| Lists | Wrap longer text |
| Forms | Tabbed forms, Related list loading |
| Notifications | channels, categories, personal notifications ([[Notification Preferences and Channels]]) |
| Developer (admin) | application and update set pickers in the header, JavaScript Log and Field Watcher, ATF Page Inspector |

## Common elements

- **Tree picker:** dictionary attribute `tree_picker=true` (role `personalize_dictionary`) on references to hierarchical tables (a parent field pointing to the same table), dependent CIs, or users by group. At most 1000 nodes, property `glide.ui.group_heirarchy.max_nodes` (spelled *heirarchy* on the page; unconfirmed). Not shown in mobile apps.
- **Dot-walking:** chains like `incident.assigned_to.company`; recommended at most three levels; in filters through *Show Related Fields*; in slushbuckets through the expand icon on fields marked +; in server scripts `current.opened_by.manager`; in templates and notifications `${assigned_to.department.manager.mobile_phone}`.
- **List collector (slushbucket):** double-click or arrows to move, Shift/Ctrl for several, filter and search the available side; `glide.xmlhttp.excessive` (integer, default 100) sets how many available items load.
- **Activity streams:** list, record (activity formatter) and Visual Task Board streams; pasted images; antivirus scan of attachments. **@mentions** create a `live_notification` record and send the *Activity Stream @Mention Email* (unless unsubscribed, or the user follows the record in Connect); the mention is not written to the parent's journal. Name shown: `glide.ui.activity.displayname`.
- **Log in:** `https://<instance>.service-now.com`; *Remember me* can be turned off by admins; custom URLs are the only supported vanity method.

## Tags (`label`)

**System Definition > Tags** or **Self-Service > My Tags**. Viewable by **Me** (private), **Groups and Users** (shared), **Everyone** (global; `admin` or `tags_admin`). Types: Standard, Most Active, Most Recent, Most Active Record, Most Recent Record (only Standard and Most Recent Record show on **Tagged Documents**). Names are case-insensitive, no punctuation; a private tag sharing a name with a shared one gets `[private]` appended; two shared or global tags cannot share a name.

- **Auto-assign:** *Conditions for Labels* embedded list (Label Table records: Name, Table, conditions); the tag is removed when the record stops matching; no dot-walked conditions. `tags_admin` needs ACLs on `label_table` and `label_auto` (read, write, create) created by `security_admin`.
- **Notify on change:** Label Entries > Notify onchange, Notify when, Notify script.
- **Zing indexing:** collection dictionary attribute `text_index_tags` = `everyone_only` or `all_shared`, then Generate Text Index; private tags never indexed ([[Zing Text Search and Global Search]]).
- **Merge** (My Tags > Merge Tags): merged tags are deleted. Tag conditions are not supported in reports on database views. Encoded query operators for tags: [[Filters, Condition Builder and Query Operators]].

## User presence (Core UI)

Avatar dot: green online, orange recently logged out, none offline; a number when several users view a record. Avatars come from the Live Feed profile, not `sys_user`. `glide.ui.presence.disabled` = true turns it off; `glide.ui16.live_forms.enabled` = false hides live form updates, form presence, the activity formatter look and attachments in the stream (plugin `com.glide.ui.form_presence`). Check interval `glide.ui.presence.time_back_minutes` (2), cache `glide.ui.presence.cache_seconds` (5).

## Keyboard shortcuts (Core UI)

Global search Alt+Ctrl+G, toggle navigator Alt+Ctrl+C, navigator filter Alt+Ctrl+F, impersonate Alt+Ctrl+I, main content Alt+Ctrl+P (Mac: Control+Option). Turned on per user in Preferences > Accessibility. All off: system user preference `glide.ui.keyboard.shortcuts.enabled` = false (one page spells it `glide.ui.keyboard.shorcuts.enabled`); one off: `glide.ui.keyboard.shortcuts.<name>.enabled`; keys: `glide.ui.keyboard.shortcuts.<name>.key_combo` (names `global_search`, `impersonator`, `main_frame`, `navigator_filter`, `navigator_toggle`); in input fields: `glide.ui.keyboard.shortcuts.allow_in_input_fields`.

## Page behaviour

- **Response time indicator** (bottom of lists and forms): total, network, server, browser milliseconds; off with `glide.ui.response_time` = false.
- **Navigation stack:** where Submit/Update and Back return. A module argument `sysparm_stack=<url>` pushes a page; a business rule `gs.setRedirect('<url>')` overrides it.
- **Navigation cancellation (Request Manager):** `glide.request_manager.cancel_other_transaction` (true), `glide.request_manager.always_cancel` (default `home,sys_report_template`; add read-only pages only), `glide.request_manager.cancel_reference_completer` (true); a module's **Uncancelable by Other Modules** blocks it. Needs `sysparm_cancelable=true` on both transactions.
- **Browser support (Brazil):** Chrome, Edge Chromium, Firefox and Firefox ESR (latest and two previous), Safari 18.2+; no Internet Explorer since Washington; Core UI supported on tablets, not phones (phones get the mobile UI).

## User preferences (`sys_user_preference`)

- A record with **System** ticked and no User is the global default (only one per name); a user record overrides it. Some defaults only appear once a user changes the setting.
- Admin edits to a user's record apply at their next session; deleting it falls back to the default. Global records travel in update sets; user records do not.
- Limit: 10,000 preferences per user before degradation.
- Examples from the base list: `tabbed.forms`, `table.compact`, `table.wrap`, `list_edit_enable`, `list_edit_double`, `glide.ui.related_list_timing`, `glide.ui.javascript_editor`, `recent.impersonations`, `overview_help.visited.navui` (system preference = true hides the Next Experience welcome splash shown to admins after an upgrade that did not turn it on), `user.can.logout`, `mobile_rowcount`.

## Example

Create a system user preference `glide.ui.keyboard.shortcuts.main_frame.key_combo` = `ctrl+alt+m`, a global tag *Example Major Incident Watch* auto-assigned to `incident` where priority is 1, and a module argument `sysparm_stack=incident_list.do` on *Example Create Incident*.

## Related

- [[Core UI Lists, Forms and Related Lists]] · [[Core UI Help, Views, Images and Appearance]] · [[Next Experience UI and Unified Navigation]] · [[Impersonation]] · [[Dictionary Attributes Reference]] · [[Record Hierarchies and Hierarchical Queries]]
