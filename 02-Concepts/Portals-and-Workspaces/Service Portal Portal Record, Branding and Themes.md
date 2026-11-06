---
type: reference
tags: [reference, portal, forms-lists, service-catalog, knowledge, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Configuring Service Portal > Upgrading Service Portal, Create a portal (with homepage, 404 page, header menu, catalog, knowledge base, Agent Chat), Defining portal styles (branding, La Jolla theme, create a theme, dark theme, theme variants, text resize, right-to-left), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g, chapter OFjs1RDVvgc21MGFMDYYuQ). Access Management Automation and Cloud Deployment Automation store apps summarised in one line each.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Service Portal Portal Record, Branding and Themes

**In one line:** what the **Portal** (`sp_portal`) record controls (URL, pages, menu, catalogs, knowledge bases, login, search), and how portal styling stacks from Bootstrap through theme, branding, page and widget CSS.

From the Brazil docs; not tested. Overview and tables: [[Service Portal Overview and Configuration]]. Pages and layout: [[Service Portal Pages, Containers and Page Route Maps]]. Roles: `admin` or `sp_admin` unless stated.

## Portal record fields

**Service Portal > Portals > New**.

| Field | Does |
|---|---|
| Title | browser title shows `<Page Title> - <Portal Title>`; **Hide portal name** drops it |
| URL suffix | `<instance>.service-now.com/<suffix>`; unique; avoid reserved words such as `portal`, `cms` and JavaScript terms |
| Homepage, KB home page, Login page, 404 page, Catalog home page, Catalog category home page | pages used for those roles; with no 404 page set, property `glide.service_portal.default_404_page` (default `404`, the page with the Breakout Game widget) |
| Logo, Icon | header logo (also in Branding Editor), favicon |
| Default | the instance's main portal |
| Application | read-only, Global by default |
| Main menu | an **Instance with Menu** (`sp_instance_menu`) record shown in the header |
| Theme | **Theme** (`sp_theme`) |
| Inactive, Alternate portal | deactivate and redirect ([[Service Portal Access, Login and Redirects]]) |
| Quick start config | JSON listing table, sys_id and field of records the Branding Editor edits (for example a widget instance title as tag line, a container background image) |
| CSS variables | portal-level Sass variables; variables only, rules go in CSS Includes |
| Support right-to-left languages | generates mirrored CSS |
| Use portal-specific authentication, Enable local login, Portal Identity Providers (Okta, Microsoft Azure), Identifier first login, Enable early redirection | per-portal login |
| Enable favorites | favorite icon on catalog items and KB articles plus a **My Favorites** header item (Service Portal only; clone the menu item elsewhere; may need adding to the form) |
| Enable AIS, Search Application, Search Results Configuration | AI Search ([[Service Portal Search Configuration]]) |
| External user registration configuration | self-registration link on the login widget |

Related lists: **Knowledge Bases** (none selected = all), **Catalogs** (`sc_catalog`; none = all active catalogs the requester can reach; catalog search still follows the AI Search source).

**Associated store apps:** *Access Management Automation* (catalog items and flows for Okta, Microsoft Entra ID and Active Directory; role `sn_acc_mgmt_sc.access_mgmt_user`; seven decision tables set approvers, assignees and the failure subflow) and *Cloud Deployment Automation* (AWS CloudFormation stacks; role `sn_cloud_dpmt_atmn.cloud_deployment_automation_user`) are added to a portal's Catalogs list. Both need Integration Hub and their spokes ([[Integration Hub Spokes Catalog]]).

## Header menu

1. The theme needs a **header** (and optionally a footer) from **Header | Footer** (`sp_header_footer`); *Stock Header* and *Sample Footer* are the base ones; **Fixed Header** / **Fixed Footer** keep them on screen. Colours: Branding Editor > Theme Colors > Navbar.
2. Create an **Instance with Menu** record: Title, **Widget** (a menu-type widget such as *Header Menu*), Application (same scope as the source table), **Additional options, JSON format** (switches such as `enable_cart`, `enable_wishlist`, `auto_update_cart`, `auto_update_wishlist`, `enable_live_chat`, each as `{"displayValue": "true", "value": true}`).
3. Add **Menu Items** (table `sp_rectangle_menu_item` per general knowledge; the page does not name it): Label, Parent menu, Parent menu item (nesting), Order, Type (**Page**, **URL** with URL target `_blank`, **Service Catalog**, **Catalog Category**, **Catalog Item**, **Knowledge Base**, **KB Topic**, **KB Article**, **KB Category**, **Filtered List**, **Scripted List**), Condition (server script such as `gs.hasRole("sp_admin")`; `false` hides), Glyph.
4. Set the portal's **Main menu**.

**Language selector:** property `glide.sp.portals.language_selector_enabled` lists portal sys_ids (default: the Knowledge `/kb`, Customer Support `/csm` and Customer Service `/csp` portals). Shown when a language other than English is active, also to guests.

## Agent Chat in a portal

Needs **Glide Virtual Agent** (`com.glide.cs.chatbot`, subscription) or **Agent Chat** (`com.glide.interaction.awa`). **Service Portal > Agent Chat** (`sp_agent_chat_config`): Active, Name, Portals (none = all), Public (before login), Roles (none = everyone), Order (lowest wins; one configuration applies per portal), **Server script** returning an object passed to the chat (has `$sp`):

```javascript
// Agent Chat configuration server script (server, scope of the record)
(function($sp) {
    return { catalogs: $sp.getValue('catalogs') };
})($sp);
```

Portal suffix, page ID and language are passed automatically; table and sys_id when they are in the URL. Per-page data: inject `spContextManager` in a widget and call `spContextManager.addContext('agent-chat', {...})` (or `updateContextForKey` if the key exists); a Virtual Agent topic reads it as `vaContext.<key>` ([[Virtual Agent Overview and Assistant Designer]]). Button look: theme variables `$sp-agent-chat-btn-close`, `$sp-agent-chat-btn-open` (image URLs from `db_image`), `$sp-agent-chat-bg`. Upgrades: copy the old *Virtual Agent Service Portal* widget options into this record and delete its instances; hide **Live Chat** with `enable_live_chat` false in the menu JSON.

## How styles stack

The docs list these levels, lowest first: **Bootstrap 3.3.6** defaults (helper classes such as `visible-lg`, `hidden-md` work in any CSS field) → Branding Editor colours (stored in the portal's **CSS variables**) → **Theme** CSS variables → page **Page Specific CSS** → container, row and column CSS classes → widget **CSS** → widget instance **CSS** (overrides everything). Accessibility defaults can override portal CSS.

**Variant to check:** the *Defining portal styles* page says the theme **overrides** Branding Editor colours, while the configuration overview and the portal field help say Branding Editor changes **override** the theme ("the theme is the lowest level"). [[Service Portal Overview and Configuration]] records the second reading. Both kept until tested.

**Branding Editor** (Service Portal Configuration > Branding Editor): *Quick Setup* tab (title, logo scaled to at most 46 px high and 200 px wide, logo padding, tag line and colour, homepage background colour or image, driven by Quick start config) and *Theme Colors* tab (Navbar, Brand, Text). Changes preview live.

## Themes

**Service Portal > Themes** (`sp_theme`): Name, **Turn off SCSS compilation**, Application, Header, Footer, Fixed header/footer, **CSS variables** (Sass variables such as `$navbar-inverse-bg`). Related lists:

- **CSS Includes** (`sp_css_include`, linked through `m2m_sp_theme_css_include` with an Order): Source **Style Sheet** (`sp_css`) or **URL**; **Lazy Load** (asynchronous; set the same on every include of a theme; avoid when unstyled content flashes); **RTL CSS file URL**.
- **JS Includes**: Source **UI Script** (`sys_ui_script`) or **URL**.

**Coral theme variants:** on the Coral theme, **Theme Variant Mappings** > New: Name, Theme variant (for example *Coral Dark*), optional **Matching Next Experience Theme Variant** and **Virtual Agent branding**. Users pick *Dark mode* in their profile's Theme Variants (guests from the top menu > Theme). **La Jolla branding**: plugin `com.glide.service-portal.themes.la-jolla`, active on new instances, updates unmodified `/sp` and `/sp_config` records (images in `db_image`).

**Text resize up to 200%:** property `glide.service_portal.resize_text.<suffix>.enable_rem_conversion` (true on new instances, false on some upgraded ones; set true), and `glide.service_portal.resize_text.<suffix>.base_font` for the base font size. Custom CSS in pixels may need converting to rem.

**Right-to-left:** tick **Support right-to-left languages** on the portal; theme, page, widget and instance SCSS is converted (RTLCSS), but plain CSS files in includes or dependencies, internal and inline CSS are not. In widgets use `[dir="rtl"]` or `.rtl` selectors, `$sp.isRTLEnabled()` on the server or `g_portal_isrtl` on the client, and directives such as `#{"/*rtl:ignore*/"}`, `/*rtl:prepend:10px*/`, `/*rtl:append:3rem*/`, `/*rtl:replace:30px*/`, `/*rtl:insert:25px*/`. Event *PortalPageLoad* in Usage Insights shows how many users view in RTL languages.

## After an upgrade

- **Knowledge Article View** page route map (`kb_article` → `kb_article_view`): activate for versioning, article comments and Word import.
- **Validation scripts** (System Definition > Validation Scripts): activate the *Mobile / Service Portal* version; to use **UI Type** All, export and delete the Desktop version first. Portal fields validate on submit on desktop and on leaving the field on mobile.

## Example

Portal *Example Support Portal* (suffix `examplesp`), theme *Example Theme* with header *Stock Header* fixed, main menu *Example Header Menu* with items *Example Catalog* (Type Service Catalog) and *Example Admin Page* (Type Page, Condition `gs.hasRole('sp_admin')`), Catalogs *Example Catalog*, and an Agent Chat configuration *Example Chat Config* passing the portal's catalogs.

## Related

- [[Service Portal Overview and Configuration]] · [[Service Portal Pages, Containers and Page Route Maps]] · [[Service Portal Widget Development]] · [[Service Catalog in Employee Center, Service Portal and Mobile]] · [[Knowledge Portal and Search]]
