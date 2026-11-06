---
type: reference
tags: [reference, workspace, forms-lists, email, ai, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Configurable Workspace UI (122 topics: Explore, Configure, Administer lists, forms, Activity stream and emails, Use, Reference incl. list of workspaces and glossary), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g, chapter wt7pOLYlDshAZJ1NuuCeYg). Declarative actions are in their own note. The linked "UIB Setup" component pages are in the UI Builder docs and not read here.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Configurable Workspace Administration - Lists, Forms, Activity Stream and Email

**In one line:** a Configurable Workspace is a UI Builder experience on the **Workspace App Shell**; its lists, forms, Activity stream, compose area and sidebar tabs are components, and the settings that are not component properties live in system properties, UX page properties and a few configuration tables.

From the Brazil docs; not tested. Building pages: [[UI Builder Overview and Concepts]], [[UI Builder Pages, Variants and Layouts]]. Buttons: [[Declarative Actions in Workspaces]]. A prebuilt workspace: [[Service Operations Workspace for ITSM]]. Many properties below must be **created** in `sys_properties` (the docs say "add a system property").

## Parts of a workspace

| Part | Components (configured in UI Builder) |
|---|---|
| List page | **List page** template: **Record List** bundle (Record List Header, Presentational List), **List menu** (Default lists, My lists), **Predicate Builder** (filter conditions) |
| Record page | **Standard record page** template: **Form** bundle (Form component + Form controller), related lists as tabs (Record List bundle) |
| Activity stream | **Activity Stream** component |
| Compose | **Activity Stream Compose** (comments, work notes), **Email composer** (full, separate tab) and **Email composer (mini)** (on the record) |
| Sidebar | **Tabs** component: Agent assist, Attachments, Form templates (more in prebuilt workspaces) |

**Create an experience** (`ui_builder_admin` or `admin`): Now Experience Framework > UI Builder > **Create > Experience**: Name, App shell UI **Workspace App Shell**, URL path (from the name), Landing path (`home`), Roles (empty = every logged-in user). Then **Create a new page** from a template or from scratch, name and URL path, review URL parameters, and a **variant** with Audiences (roles; empty = everyone with experience access) and optional Conditions. Prebuilt workspaces are edited in UI Builder rather than rebuilt.

## Lists

| Setting | How |
|---|---|
| Live updates | create `glide.lists.live_list_enabled` = true; then per template in UI Builder (**Let users control live updates**: Never (default), Only by refreshing, Automatically) or per list page in `sys_ux_list` > **Extensible List Feature Flags** > Live Updates (Off, Manual refresh, Automatic refresh) |
| AI indicators off | `glide.ai.list_indicators.enabled` = false |
| Record count in the background | `glide.ui.fetch.list.record.count.asynchronously` = true (large tables) |
| Related list adds in the background | `glide.ui.mra.async` = true and `glide.ui.mra.threshold` (default 100); per modal through a declarative action payload, which wins over the properties |
| Group a related list | Now Experience Framework > System UI > **Related Lists** > entry > **Group By Field** |
| Export to Google Sheets | OAuth app on the Google Sheets API, an application registry, connection and credential aliases; then Export > Google Sheets |

## Forms

| Setting | How |
|---|---|
| Warn on browser back/forward with unsaved data (whole page, including composer) | **UX Page Property** (`sys_ux_page_property`) on the page: `confirmPopStateNavigationWhenDirty` = true |
| Unsaved field dot, and its background colour | page properties `enableUnsavedFieldIndicator` and `enableBgColorForUnsavedFieldIndicator` = true (or per page in UI Builder). Not on time_worked, password, domain_path; colour not on boolean, conditions, days_of_week, email_script, field_list, field_name, file_attachment, glide_time, glide_utc_time, integer_time, slush_bucket, time_worked, timer, user_image, css, json, percent_complete, radio |
| Reflow off (stacked layout at 400% zoom; needs the latest UI Builder layouts) | instance `glide.ux.autoreflow.disable` = true; experience **Disable Auto Reflow** on `sys_ux_app_config`; page on `sys_ux_screen` |
| Personalize Form | roles that may use it: `glide.ui.personalize_form_role`; hide it: `glide.ui.personalize_form` = false |
| Advanced view rules | **View Rules** (`sysrule_view_workspace`) > **Advanced** + client **Script** choosing the variant at runtime (ES12 toggle) |
| @mention suggestions only for people who can see the record | `glide.ui.mentions.check_record_visibility` = true |
| Form header | **UX Form Header** (Table, Primary field, Subheading, Header Image), added to the workspace's **UX Header Configuration** (*Workspace Form Headers* list). Roles `workspace_admin`, `ui_builder_admin` or `admin` |
| Highlighted values | **UX Highlighted Values** (Table, Field) in the workspace's **UX Highlighted Value Configuration**; **Enable Background Color** there (same unsupported types as above). Users can show colour names: Preferences > Accessibility > *Highlighted value label in lists* |
| Script fields with a code editor | `glide.ui.workspace.script.code_editor.enable` = true, `glide.ui.workspace.script.code_editor.autoresize_line_limit` |
| Auto-resize | `glide.ui.textarea.autoresize_line_limit`, `glide.ui.journal.use_html` (journal text areas become HTML), `glide.ui.journal.html.editor.autoresize` and `..._line_limit`, `glide.ui.html.editor.autoresize_line_limit` (with the plugin in `glide.ui.html.editor.v5.enabled_plugins`), `glide.activity.compose.html.autoresize` and `..._line_limit` |
| Journal HTML toolbar and Enter key | `glide.ui.journal.html.plugins`, `glide.ui.journal.html.toolbar`, `glide.ui.journal.newline_behavior` = default (Enter block, Shift+Enter `br`), block, linebreak or invert |
| Text commands (`/<key>` shortcuts) | **UI Text Command** (`sys_ui_text_command`; `form_admin` or `admin`): Name, **Command Name** (the key after `/`), Table, Applies To (Field Type or Email), Field Type (Journal Input, HTML), Action (Insert Content, Replace Content, Custom Event), Action Script. Turn all off: `glide.ui.enable_text_commands` = false |
| Character counter on journal fields | `glide.ui.textarea.character_counter` = true |
| Hide journal fields (entries only in the Activity stream) | **UX View Rules Configurations** > workspace > record type > Form Settings > **Hide Journal Input Fields** (`form_admin`) |
| Inline validation for strings | **Regex Tables** (`sys_ui_regex`: Name, Regex pattern such as `^\d{10}$`) mapped in **Field Regex Mapping Tables** (`sys_ui_field_regex_mapping`): Table, Field name, Placeholder Text, Field message and type (suggestion, info, warning, positive, critical), Order, Active, Inherited, Regex Pattern, **Input Format** mask (`0` digit, `a` letter, `*` any, `[]` optional, `{}` fixed text, for example `{EMP-}0000`) |
| Form template semantic search | `com.glide.ais.semantic_search` = true and `glide.template.sematic_search` = true (spelled *sematic* on the page; unconfirmed whether that is the real name) |
| Resize every modal on a record page | UI Builder > Modals > Modal Container > **Enable Resize** with minimum and maximum sizes |

The page's description of `glide.ui.html.editor.v5.enabled_plugins` repeats a line-limit text that does not fit its name (docs inconsistency; inference that it lists editor plugins).

## Activity stream

- Stacked journal view: `glide.ui.activity.journal.stacked` = true (not shown when the stream has mandatory fields); rich text: `glide.ui.journal.use_html` = true.
- Keep **Post** usable when Comments or Work notes are mandatory by UI policy: `glide.activity.compose.can_post_mandatory_fields` = true.
- Avatars on tiles: `glide.activity.show_tile_icons` = true. Tile icon, background and colour per table: dictionary attributes *Workspace activity stream tile icon*, *background*, *icon color*.
- **Tags** (filter entries by states not in the filter lists): Activity Stream component > Configure > Tags > Data Source, then Label, Icon, Color, Table, Description.
- Stop a user creating filter sets: role `workspace.activity_stream_restrict_create_filter_set`.
- Most recent reply first: UI Builder component property plus `glide.activity.last_viewed_timestamp.local_storage_limit` and `..._retention_days` (timestamps kept in the browser).
- Users: search the stream, save **filter sets** (Post Types, Field Changes), filter by tags, and Preferences > Workspace > *Expand activity stream items by default*.

## Email

- **Email Client Templates** (`email_client_admin`): Name, Table, Conditions, Content, Recipients. Collapse the end of a body behind an ellipsis with a `collapsible-content` div in HTML content (the page prints the tag as `<div id:collapsible-content>`; cannot be re-collapsed once expanded). See [[Email Client]].
- Response templates in journal fields off: `glide.ui.enable_response_templates` = false ([[Response Templates]]).
- Sign and encrypt from the composer: needs S/MIME ([[S-MIME Email Encryption]]).
- Agents (`email_composer`): full composer (More actions > **Compose Email**, new tab) or mini composer (Email tab in Compose); Reply To / From, Cc/Bcc, email templates, response templates and quick messages from Agent Assist or the footer, attachments from the computer or the record (names shown to 100 characters), drafts saved automatically. Shortcuts in the body: `/r` response templates, `/d` drafts, `/e` email templates. Recipients are pills: drag between To, Cc and Bcc; invalid or blocked addresses disable Send.

## AI features for users

**AI filter assist** (natural language to an encoded query, typed or spoken; licence dependent), **Track record list changes** (role `sn_ai_filter_tracker.user`; task tables, fewer than 100 records, five lists at a time, not related lists), **Group similar items** (groups by short description, summarise, post the summary as work notes), **AI field recommendations** (sparkle icon), **Screen Summarization** (Store app; Ctrl+U, then Alt+P page or Alt+S section, read aloud by a screen reader). Users need `workspace_user`.

## Prebuilt workspaces (Brazil list)

Workspace (the base), Audit, Cloud Discovery, CMDB ([[CMDB Workspace]]), Compliance, Continuous Authorization and Monitoring, CRM, Digital Portfolio Management, Enterprise Architecture, Platform Analytics, Resource Management, Service Operations Workspace for ITSM and for ITOM, Workforce Optimization for ITSM.

## Example

In *Example Agent Workspace*: create `glide.lists.live_list_enabled` = true and set the *Example Incidents* list page to Manual refresh; add page property `enableUnsavedFieldIndicator` = true; map regex *Example Employee ID* (`^EMP-\d{4}$`, input format `{EMP-}0000`) to `u_employee_id` on *Example Request*; add text command *Example Greeting* (`/g`, Insert Content, Journal Input).

## Related

- [[Declarative Actions in Workspaces]] · [[UI Builder Overview and Concepts]] · [[Next Experience UI and Unified Navigation]] · [[Next Experience Client APIs (g_modal, GlideForm, GlideList)]] · [[Workspace Builder]]
