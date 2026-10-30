---
type: concept
tags: [concept, portal, roles, service-catalog, security, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal (240 topics; read Understanding Service Portal, core concepts, URL navigation, Supported features, Configuring overview, Managing portal access, roles, properties list; overviews of the other sections), 2026-10-30. Step pages, base widget list and SCSS variables not read. https://www.servicenow.com/docs/r/platform-user-interface/service-portal/service-portal-roles.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Service Portal Overview and Configuration

**In one line:** a responsive self-service interface over the platform: a portal record sets the URL suffix and theme, pages hold containers, rows and columns, and widgets supply the content.

From the Brazil docs; not tested. Active by default through **Service Portal for Enterprise Service Management** (`com.glide.service-portal.esm`). An alternative presentation layer, so not every platform feature works in it. Content stays in its own application: knowledge articles are authored in Knowledge, catalog items in Service Catalog.

## Parts and tables

| Part | Table | Holds |
|---|---|---|
| **Portal** | `sp_portal` | URL suffix, homepage, knowledge base, catalog, header menu, branding |
| **Page** | `sp_page` | layout, public flag, roles |
| **Container** | `sp_container` | layout rows and columns |
| **Widget** | `sp_widget` | HTML, CSS, client and server scripts |
| **Widget instance** | `sp_instance` | one widget placed on a page, with its options |
| **Theme** | `sp_theme` | look of the whole portal |
| Page route map | `sp_page_route_map` | sends one page to another |
| Log | `sp_log` | portal log |

A page has no fixed link to a portal: it just exists, and any portal can open it by ID.

**CSS order:** styles on a page or widget override Branding Editor settings, which override the theme; Bootstrap defaults apply if nothing is defined.

## Tools

**Service Portal > Service Portal Configuration** opens the configuration page: Branding Editor, Designer (drag widgets onto pages), page and widget editors. Everything created there is also a normal record in the platform tables.

Configuration needs `admin` or `sp_admin`.

## URLs

`https://<instance>/<portal suffix>/<guest language>/<keywords>?id=<page id>&lang=<language>&<page parameters>`

- `/sp?id=index`: suffix `sp`, page `index`. Widgets link with `?id=sc_home`.
- A widget's parameters are found in its server script's `$sp.getParameter` calls. Missing ones can give "You are either not authorized or record is not valid".
- With article versioning, knowledge URLs must include the version.

## Access

- **Public pages:** several base pages are public; filter **Public [is] true** to review them.
- Page roles, widget security, and **user criteria** on pages, widgets, instances, announcements and search sources (`glide.service_portal.user_criteria_enabled`, default true).
- Login, SSO, MFA, identifier-first login, early redirection, e-signature, external self-registration, PIV or CAC cards.
- **Domain separation:** the supported-features page says Data only level; the reference page says unsupported. Unconfirmed variants.

## Not supported

- **No plans:** @ mentions, click-through pop-ups, embedded lists, **UI macros**, formatters, **UI actions marked Client**, nested container catalog variables, survey wizards, OpenFrame.
- **Client scripts** run only if **UI Type** is Mobile / Service Portal or All, and must use the mobile GlideForm API. This is a common cause of catalog forms behaving differently: see [[Scripting Overview - Script Types and Where They Run]].
- Catalog forms use a two-column layout, so complex forms may not display as expected.

## Roles

| Role | Can |
|---|---|
| `sp_admin` | portal configuration; contains `evam_admin`, `taxonomy_admin`, `search_application_admin`, `announcement_admin` |
| `announcement_admin` | post announcements |

## Other features

- **Announcements:** banner or widget types, with display styles.
- **SEO:** human-readable URLs, meta tags, dynamic titles, `hreflang`, **Sitemap Generator**.
- **Performance:** evaluate a page against benchmarks, list widgets per page, widget diagnostics.
- **Search:** see [[AI Search Overview]].
- **Deactivate a portal**, optionally redirecting users.

## Selected properties

| Property | Default |
|---|---|
| `glide.service_portal.default_404_page` | 404 |
| `glide.sp.show_console_error` | true |
| `glide.service_portal.enable_human_readable_urls` | true |
| `glide.service_portal.enable_acls_for_encoded_query_in_list` | true |
| `glide.service_portal.enforce_cross_scope_check_in_form` | true |
| `glide.sp.theme.parse_scss` | true |

## Example

Portal *Example Support Portal*, suffix `examplesp`, theme *Example Theme*, homepage *example_home*. *Test User* opens `/examplesp?id=example_home`.

## Related

- [[Service Portal Widgets]] · [[Catalogs, Categories and the Catalog Home Page]] · [[Next Experience UI and Unified Navigation]] · [[Entity View Action Mapper (EVAM)]]
