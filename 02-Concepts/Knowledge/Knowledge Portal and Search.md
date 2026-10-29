---
type: concept
tags: [concept, knowledge, portal, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Configuring > Configure the Knowledge Management Service Portal (Enable external or public users, Knowledge Management Service Portal widgets and its 13 instance-option pages, Search using the Knowledge Management Service Portal, Integrating Knowledge Management features with the Service Portal, Configure custom SEO tags, Enable and configure AI Search), Configure knowledge bases for a portal, Activate the sitemap configuration and definition records, and Exploring > Sitemap Generator for the Knowledge Portal, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/knowledge-management-service-portal.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Portal and Search

**In one line:** the **Knowledge Portal** (Knowledge Management Service Portal, plugin `com.snc.knowledge_serviceportal`, URL `/kb`) is where users browse knowledge bases, search, read articles and give feedback; it replaces the old KM v3 homepage (`com.snc.knowledge3`, being deprecated since Washington DC).

From the Brazil docs; not tested. Part of [[Knowledge Management Overview]].

## Basics

- Active by default since Madrid; needs `com.snc.knowledge3` and Service Portal for Enterprise Service Management (`com.glide.service-portal.esm`).
- Pages: `kb_home` (homepage), `kb_search` (search results), `kb_article_view` (article). Its portal record is **Service Portal > Portals > Knowledge Portal**. Change the default portal URL with `sn_km_portal.glide.knowman.serviceportal.portal_url`.
- `sn_km_portal.glide.knowman.serviceportal.enable_redirect` = true sends users of v2/v3 pages to the portal (not for incident contextual search, Connect or global search); `sn_km_portal.glide.knowman.serviceportal.portal_url` = suffix (default `kb`). The user page names it `glide.knowman.serviceportal.enable_redirect` without the prefix (unconfirmed variant).
- Pages honour the KM system properties; widget **instance options** override them. Edit with Ctrl + right-click > Instance Options (`sp_admin`, `knowledge_admin` or `admin`), after switching to the scope **Knowledge Management - Service Portal**.
- **Which knowledge bases appear**: portal record > **Knowledge Bases** related list > Edit. Empty = all knowledge bases; mapped = only those, in every widget and search.

## Widgets

| Page | Widgets |
|---|---|
| Homepage | Knowledge Homepage Search (title "Welcome to Knowledge"), Knowledge Bases Browse (tiles, Order By any field or `article_count`, Ask a Question / Create Article buttons), Featured / Most Useful / Most Viewed Articles (table `kb_knowledge`, display and secondary fields, max records, restrict to one knowledge base) |
| Search results | Knowledge Breadcrumbs, Knowledge Search (empty search, instant search with 500 ms wait, minimum characters), facets: **Field** (knowledge base, category, author; Single / Multi / Dropdown select), **Tags**, **Resource**, **Query** (rating, views, last modified; JSON facet options; only shown if a field facet exists), Knowledge Language Widget, Knowledge Result Sort (default `Views:desc,Newest:desc,Alphabetical`), Knowledge Selected Filter, Knowledge Result (default sort `sys_view_count:desc`, Infinite Scroll by default or Standard Pagination) |
| Article view | Knowledge Article Content (Hide All Actions, Show Version Information, **Create Incident** action with URL default from `glide.knowman.create_incident_link`, Redirect to the latest article), Knowledge Article Helpful (percentage, labels), Knowledge Article Comments (rating, comments, attachment count and size), **Knowledge Attachments** (must be added next to Article Content; not always added on upgrade), Related Catalog Item (`kb_2_sc`, target `sc_cat_item`, max 5, URL parameter `sys_kb_id`), Knowledge Related Articles (`kb_2_kb`, manual mappings first, then predicted), Affected Products, Most Recent Tasks, Most Useful |

Facet notes: **Fetch Maximum Values** loads all values (slower); otherwise `glide.knowman.search.facet_depth` (default 300) limits it. With `glide.knowman.search.apply_acls` = true a facet value can show with no matching results. **Show category hierarchy** goes four levels deep and allows one category at a time.

## Search

- Matches short description, content and attachments; results include articles, pinned articles and social Q&A.
- **Multi-language search**: **Knowledge > Administration > Knowledge Search Properties > Enable multi language search** (needs `com.glideapp.knowledge.i18n2` or a language plugin); selection kept per session. See [[Knowledge Translation and Internationalization]].
- "Did you mean": **System Properties > Text Search**, `glide.ts.dym.enable_spell_correct` and `glide.ts.dym.enable_chain_suggest` = true ([[Zing Text Search and Global Search]]).
- **AI Search**: off by default for new and existing customers (the portal uses Zing until enabled). Portal record > **Enable AI Search**, Search Application = Knowledge Portal Search Configuration, Search Results Configuration = Knowledge Portal Search. View count and Rating facets do not exist with AI Search ([[AI Search Overview]]). *Variant:* the "Integrating with the Service Portal" page says the Knowledge Portal supports only Zing, not AI Search (older statement; unconfirmed for Brazil).

## What users see

- Homepage (`/kb`, logged-in users; upgrades must also set `glide.knowman.serviceportal.enable_redirect`): profile menu, search, counters (bases, articles), **Ask a Question** (role `knowledge`), overflow > **Create Article**, base tiles with Subscribe and Show All (up to eight), **Featured**, **Most Useful** (top 5 helpful), **Most Viewed** (top 5). Mobile responsive.
- Search page: sort Views / Newest / Alphabetical / Relevancy (last choice remembered), facets Language, Knowledge Base, Category, Author, Tags, Resource, Rating (n stars and up), Last Modified, View Count (days from a portal property). Filters reset on a new search. *Variant:* the user page says the language selection is kept across logins, the search configuration page says per session only (unconfirmed).
- Custom widgets using the `KnowledgeSearchService` angular service need the dependency `sn.knowledgeApplication` (Service Portal > Dependencies, in the KM - Service Portal scope). Portal search uses the **Knowledge Base Search** search context; do not change its definition ([[Contextual Search]]).
- Article page: breadcrumb, number, Subscribe, actions (Edit with contribute access, **Flag** article, **Download as Word** for Word-authored articles), language list (when translations exist), content with author, date and views, **Copy Permalink** (latest version the user may see: published for readers, newest for contributors), Helpful?, rating, comments, attachments, Related Items, Related Articles, Affected Products, Most Recent tasks, Most Useful.
- Article URLs: `/kb?id=kb_article_view&sysparm_article=<number>&sysparm_language=<code>` or `kb_view.do?sysparm_article=<number>&sysparm_language=<code>`; `sys_id` also accepted; when `sysparm_article` and `sys_kb_id` point to different articles, `sysparm_article` wins. Both return the latest version, in that language if a translation exists.

## Mobile

- Classic mobile: **Self-Service > Knowledge Base**, browse, read, search (no editing or comments).
- **Now Mobile** **Information** applet (plugin `com.glideapp.knowledge.mobile_requestor`, on by default): Recently Viewed (5, last 30 days), Popular (5; 3 on the app home), browse categories (parent articles under a dummy *Other*), search *Services, Articles or People* > Articles, article page with up to 5 related articles and items and attachments, rate (1-3 stars create a feedback task), helpful, comments with likes and replies (delete own; knowledge admins and owners can delete any). External users can use it too.

## Public and external users

`admin`: **Service Portal > Pages**, open `kb_home`, `kb_article_view` and `kb_search` (scope Knowledge Management - Service Portal): tick **Public** for unauthenticated users, or add role `snc_external` for external users. Then give them read access on the knowledge bases through user criteria ([[Knowledge Base Access and User Criteria]]). CSM can do this automatically.

## Using it inside the main Service Portal (`sp`)

- **Page Route Map** (Service Portal > Page Route Maps): portal Service Portal, route from `kb_view2` to `kb_home`, Active. The **Knowledge Article View** route map (sends every article to `kb_article_view`) is active by default since New York.
- Search: build a small widget **Search Within** whose server script builds `/sp?id=kb_search&keyword=<q>&kb_knowledge_base=<kb>` and drop it on `sp_search` in the Designer.
- Drop Knowledge Featured / MostUseful / MostViewed Articles widgets on the `index` page.

## SEO and sitemaps

- Default tags: tick **Use SEO script** on the `kb_article_view` page record → canonical URL (e.g. `https://<instance>.service-now.com/csp?id=kb_article_view&sysparm_article=<number>`) plus `hreflang` links for each translation and a self-referencing one. Script include chain: `SPSEOHeaderTagsSNC` (read-only default for portal pages) → `SPSEOHeaderTags` (override) → `SPSEOHeaderTagsArticleViewSNC` (read-only, article page) → `SPSEOHeaderTagsArticleView` (yours to edit).
- Script include `SPSEOHeaderTagsArticleView` (server, scope Knowledge Management - Service Portal): `generateCanonicalURL`, `generateHrefLangArray`, `generateCustomTagsForSEO`, `generateSEOTags`. Tags are only added for user agents listed in `glide.knowman.serviceportal.seo_user_agent`.
- **Sitemap Generator** (base system from Brazil, inactive): **Sitemap Generator > Sitemap Configuration**, record `sitemap_config_KB` in `sys_ux_seo_sitemap_config`, tick Active and set the definition Type to true. Regenerated daily. Check by hand that only the portal's public, non-redirecting, non-retired, non-expired articles are included.

## Related

- [[Knowledge Management Overview]] · [[Knowledge Base Access and User Criteria]] · [[AI Search Overview]] · [[Zing Text Search and Global Search]]
