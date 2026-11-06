---
type: reference
tags: [reference, portal, reporting, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Improving search engine optimization for portals (10 topics), Posting announcements to portal users (4), Analyzing portal performance and usage (9), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g).
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Service Portal SEO, Announcements and Usage Analytics

**In one line:** making public portal pages findable (readable URLs, meta tags, titles, hreflang, sitemaps), broadcasting announcements, and measuring portal use and page performance.

From the Brazil docs; not tested. Knowledge-specific SEO (canonical URLs for articles, the KB sitemap): [[Knowledge Portal and Search]].

## SEO

Only **public** pages are indexed. All of these are on the page record (`sp_page`).

- **Human readable URLs:** `https://<instance>/<suffix>/<guest language>/<keywords>?id=<page>&<params>`. Field **Human readable url structure**: static text, variables or both (`faq/%short_descr`, `%category/%short_descr`); letters, digits, hyphens, one slash, `%`. Lowercased, spaces to hyphens, disallowed characters dropped, at most 75 characters. Guests are redirected to the readable URL on first load; signed-in users get the URL rewritten without a redirect. Instance switch: `glide.service_portal.enable_human_readable_urls` (default true). Canonical URLs must include the keywords: use `getHumanReadableUrl` methods of `SPSEOUtilsSNC` (global) in the SEO script include.
- **Dynamic page variables** (related list on the page; used by readable URLs and titles): Name (starts with `%`, no spaces), Order, URL query parameter, Relevant table column (default Sys ID), Table, Table field, Query condition. For titles, duplicate names are not supported; the latest updated wins when several match.
- **Dynamic page title:** for example `%first_name - %title`; not applied to the Knowledge portal's article view page.
- **Meta tags** related list: Name (or `ROBOTS` with Content `INDEX, FOLLOW` (default), `NOINDEX, FOLLOW`, `INDEX, NOFOLLOW`, `NOINDEX, NOFOLLOW`), Content (text or variables such as `%description`), and **Content variables** (same fields as page variables; the earliest created wins; the table field must be readable by guests).
- **Main tag:** container, row or column Semantic tag = Main ([[Service Portal Pages, Containers and Page Route Maps]]).
- **hreflang and canonical:** tick **Use SEO script**; default script include `SPSEOHeaderTags` adds hreflang for each active language; override `generateCanonicalURL` and `generateCustomTagsForSEO`.

**Sitemap Generator** (`sn_ux_seo_sitemap`, from the instance or the Store; the Knowledge note says it is in the base system from Brazil, inactive): **Sitemap Generator > Sitemap Configuration** (`sys_ux_seo_sitemap_config`: Name, Description, Active), definitions in `sys_ux_sitemap_definition` of Type **Script** or **Static** (`loc`, `lastmod`, `changefreq`). Jobs *Sitemap Scheduler* (daily at midnight) and *SitemapPurgeScheduler*. `glide.sitemap.page.count` URLs per sitemap page (default 750, at most 5,000; keep 750 with hreflang); above it an index file `sitemap-<config sys_id>.xml` is built. **Copy Sitemap URL** for Google Search Console or `robots.txt`. Non-public URLs are dropped and logged in Application Logs (scope Sitemap Generator, message "The given URL ... is not public"), except URLs on custom domains; excluding redirects and NOINDEX pages is up to you.

## Announcements

Plugin `com.glide.service-portal.announcements` (active on new instances). Roles `announcement_admin`, `sp_admin` or `admin`. **Service Portal > Announcements** (`announcement`):

| Field | Does |
|---|---|
| Name, Active, Title, Summary | internal name; shown title and text (translatable in `sys_translated_text`) |
| From, To | display window; empty To = until deactivated |
| Display style | `announcement_style` (Name, Background and Foreground color, Alignment); base *Normal* (blue) and *Urgent* (red) |
| Type | **Banner** (above the page), **Widget** (Announcements widget instances) or a custom type |
| Glyph, Glyph alt text | icon for banners |
| Public, Unauthenticated only | show before login; only to guests |
| Roles | when not public (or use user criteria) |
| Display first | ahead of others; ties follow `glide.service_portal.announcement.default_sort_order` (default Start Date Descending) |
| Click target | None, Page, URL in current tab, URL in new tab, with Details page / URL / link text (default "Learn More") |
| Dismiss options | dismiss for good, for the session, or not at all |
| Portals | empty = all |

Banners always use the display style; widget instances only with **Use Display Style**. **Custom types:** add a value in **Announcement Consumer Type** (`announcement_consumer_type`) and set it as the widget instance's Type.

## Usage and performance

- **Usage Insights for Service Portal** (plugin `com.glide.service-portal.analytics`, roles `portal_analytics_admin`, `portal_analytics_viewer`): portal record > **Create Analytics Settings** (`sys_analytics_bucket`), optional **Enable Unauthenticated User Tracking**; then activate the inactive **Privacy Notice** announcement for guests (it shows only on portals with analytics settings). Events tracked automatically: Submit Catalog Request, Order Catalog Item, Submit Record Producer Request, View Knowledge Article, Initiate Search, Search Result Selected, Successful Login, PortalPageLoad, SP File Attach; custom events with `SNAnalytics`. Properties `glide.analytics.tracking.force_allowed.portals` (no consent pop-up) and `glide.analytics.tracking.restricted.portals` (no tracking). Platform side: [[Usage Insights]].
  - **Variant to check:** the overview page says tracking is **enabled for all portals by default**; the *Track Usage Insights* page says **by default tracking is not enabled** for portals. Both kept.
- **Performance Analyzer:** for suffixes in `sp_allow_perf_debug_option_for_portals` (default `sp`), admins get an icon on each page; enter benchmarks (widget load, ACL, DB call and business rule time in ms, Ajax call time, Ajax waiting time in s), **Validate** without using the instance meanwhile, then review widgets over the limits and **Show preview**.
- **Portal Analyzer:** scheduled job *Portal Analyzer* > Execute Now, then `sp_portal_analyzer.list`: every widget per page with its customisation level, page views and visits; export before upgrades.

## Example

Public page *example_faq* with Human readable url structure `faq/%short_descr`, a dynamic page variable `%short_descr` on `kb_knowledge` by `sysparm_article` = Number, a ROBOTS meta tag `INDEX, FOLLOW`, and a banner announcement *Example Maintenance* (style Urgent, From and To set, dismiss for the session, portal *Example Support Portal*).

## Related

- [[Service Portal Overview and Configuration]] · [[Usage Insights]] · [[Knowledge Portal and Search]] · [[Service Portal Widget Misbehaves or Loads Slowly]]
