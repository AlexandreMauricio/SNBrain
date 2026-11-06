---
type: reference
tags: [reference, forms-lists, instance-admin, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Working in Core UI > User interface configuration > context-sensitive help, overview help pages, system user guide, audio files, storing images in the database, view management (views, view rules, navigation handler), welcome pages, enabling and using accessibility features, customizing instance appearance (Basic Configuration UI16, Core UI themes, menu categories, CSS theme support, default CSS styles), company profile, banner and favicon, field label help, read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g, chapter X1oo9mYeLZGrF1oDFABlYg). NVDA and JAWS setup steps skimmed, not recorded.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Core UI Help, Views, Images and Appearance

**In one line:** the Core UI admin settings for help content (help contexts, What's New panels, the system user guide), form and list **views** with view rules and navigation handlers, images and audio stored in the database, accessibility, and the Core UI branding (Basic Configuration UI16, CSS themes, company profile, banner, favicon).

From the Brazil docs; not tested. Most branding here applies only when Next Experience is off; Next Experience uses [[Next Experience Themes and Theme Builder]]. Form layout and view tables: [[Form Layout, Sections and Views]].

## Views

- A **view** is a named subset and order of fields for a form or list (Default view, Advanced, Self-Service `ess`, Mobile, and so on; never delete base views or `rpt-temp<sys_id><user>` report views). Admins and `personalize` create them from Configure > Form Layout or List Layout > *New* (names: letters, digits, `_`). `admin` or `view_changer` switch views. Delete in **System UI > Views**.
- The view a user switches to is saved as a **user preference** and wins over `sysparm_view` in a URL, unless `sysparm_view_forced=true`. Switching a form's view submits it (onSubmit client scripts run); not possible on an unsaved new form.
- **View rules** (System UI > View Rules): Name, Active, **Advanced** (script instead of conditions), Match Conditions Any/All, Conditions, Table, **Device type**, View (case-sensitive, exact). A saved user preference can stop a rule applying: delete the preference and clear the cache (`cache.do`, costly). The docs give an advanced script forcing non-`itil` users to `ess` (sets `answer`; parameters `view`, `is_list`). Table name not given on these pages; variants recorded in [[Form Layout, Sections and Views]] (`sysrule`, `sysrule_view`) and for workspaces `sysrule_view_workspace`.
- **Navigation handler** (`sys_navigator`): a scripted view rule per table, run each time a form of that table is requested; sets `answer` to the URL. By default it wins over view rules; create `glide.ui.view_rule.check_after_nav_handler` = true and have the handler set `answer` only when it must force a view, so view rules apply otherwise. The docs' sample scripts declare `now_GR` but use `gr`, mix `g_uri` and `g_url`, and the second has a misplaced parenthesis (docs slips).

```javascript
// Navigation handler script (server, global): ESS view for users with no roles
// Table field: <your table>; corrected sketch of the docs example
var rec = new GlideRecord('<your table>');
if (rec.get(g_uri.get('sys_id')) && !gs.getUser().hasRoles()) {
    g_uri.set('sysparm_view', 'ess');
    answer = g_uri.toString('<your table>.do');
}
```

## Help content

- **Context-sensitive help:** **System UI > Help Contexts**: Type Form, List or Record (Record shows a Document field), Table, Language, Active, **ServiceNow Product Documentation** (clear it for your own), URL or page name. Relative names are appended to `help.base.default`; absolute URLs (containing `://`) ignore it. Do not change `glide.help.default.page` or `help.base.servicenow`. Priority: customer over base, user's language over default, closer table in the hierarchy over farther; list help covers the form when no form help exists, and the reverse.
- **Overview help (What's New):** `sys_ui_overview_help` pages with panels (Title, Order, Roles, Condition, Image, Text); **System UI > Overview Help**; hide with `glide.product.show_what_is_new` = false.
- **System user guide** (Core UI): **System User Guide > Administration** > Help Pages, Help Page Sections, help documents; entry point `$sys_product_help.do` (other pages by id). Customized base records stop receiving upgrades.
- **Field label help** (`personalize_dictionary`): right-click label > **Configure Label**: Hint (tooltip), URL (opens in a new tab; URL target unused). Links not supported in Workspace.
- In-product help for Next Experience: [[Adoption Services, Boards and Legacy UI Tools]].

## Images and audio

- **Images** (`db_image`, **System UI > Images**, roles `image_admin` or `content_admin`): Name used in HTML, Active, Category, Image; **Image Zip Upload** for many (path separators become `_`, names up to 100 characters). Types .gif, .jpg, .png, .bmp (and others per page); .ico not through this upload per the images page, yet the favicon page says to upload the .ico there (variant). `glide.ui.strict_content_types` restricts extensions shown.
- **`db_image` is public**: unauthenticated users can read every image. Use an attachment (`sys_attachment`, [[Attachments]]) for anything restricted.
- **Audio** (.mp3, .ogg; plugin `com.glide.db_audio`, on by default on new instances; role `image_admin`): referenced with an HTML `<audio>` tag.

## Accessibility (Core UI)

Not on by default. Per user: system settings > **Accessibility enabled** (turns on *Accessible tooltips on forms* the first time) or the *Enable Accessibility* skip link; admins set preferences `glide.ui.accessibility`, `glide.ui.accessibility.accessible.tooltips`. **High contrast:** a user preference `glide.css.theme.ui16` (System cleared, the user, value = sys_id of the *Contrast UI* theme). First-field focus on form load: property `glide.ui.focus_first_element` (List v3 instances: preference `glide.ui.accessibility.focus_first_field`). Skip links, tab-through, arrow keys in slushbuckets and tabs; WCAG 2.2 AA claimed for some products.

## Welcome pages (Core UI login)

**System UI > Welcome Page Content**: sections (Welcome, Using, Login, Demonstration, More Information) with Short Description, Active, Display order, Application. Next Experience login page: [[Next Experience Themes and Theme Builder]].

## Appearance and branding (Core UI)

- **System Properties > Basic Configuration UI16:** `glide.product.description` (banner text), `glide.product.name` (browser tab title), `glide.sys.default.tz`, banner image `glide.product.image.light` (scaled to 20 px high), `glide.sys.date_format`, `glide.sys.time_format`, colours as `css.$navpage-header-bg`, `css.$navpage-header-color`, `css.$navpage-header-divider-color`, `css.$navpage-nav-bg`, `css.$subnav-background-color`, `css.$navpage-nav-color-sub`, `css.$navpage-nav-selected-bg`, `css.$nav-highlight-bar-active` / `-inactive`, `css.$nav-hr-color`, `css.$navpage-nav-bg-sub`, `css.$navpage-nav-selected-color`, `css.$navpage-nav-unselected-color`, `css.$navpage-nav-border`; base theme `glide.ui.base_theme.selected_theme` (La Jolla replaced Cobalt from Madrid). Also **System Properties > CSS** and **UI Properties**.
- **Banner image property disagrees:** the Basic Configuration table names `glide.product.image.light`; the company-profile and banner pages name `glide.product.image` (System Properties > System). Both kept. A company record's banner image overrides the property.
- **Themes** (System UI > Themes; per user in system settings > Theme): Name, CSS (`$variable: value`, `!important` allowed), Active, **Device** = Concourse (Core UI), Doctype (UI15), Browser (UI11). Defaults include `$navpage-header-bg: #293e40`, `$nav-highlight-bar-active: #82c9b8`. Give each instance (dev, test, prod) a distinct theme to avoid working in the wrong one. Survey header colour: `css.list.row.survey.background.color`. Menu categories style application labels.
- **Company profile:** **System Properties > My Company** (primary company): Banner text, **Primary**, UI16 Banner Image, address and contacts.
- **Banner link:** `glide.banner.image.url`, `glide.banner.image.url_target` (`gsft_main`, `_top`, `_blank`). **Favicon:** `glide.product.icon`. Window title = `glide.product.name` + `glide.product.description`; `glide.product.name.style` / `.description.style` take CSS; `css.banner.background.image` adds a background. From San Diego, use banner announcements instead of the description for messages.

## Example

On the dev instance set `glide.product.name` = *Example Company - DEV* and theme *Example Dev Orange* (Device Concourse) as the system theme; create help context *Example Incident Form Help* (Form, `incident`, URL to an internal knowledge article).

## Related

- [[Form Layout, Sections and Views]] · [[Core UI Navigation, Settings and Common Elements]] · [[Next Experience Themes and Theme Builder]] · [[Attachments]] · [[System Properties Reference]]
