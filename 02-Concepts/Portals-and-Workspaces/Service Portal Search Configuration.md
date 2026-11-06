---
type: concept
tags: [concept, portal, ai, scripting, integrations, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Configuring Service Portal > Configuring search in a portal (20 topics: AI Search in Service Portal, enable, reclassify widgets, results action, theming; Zing search, search sources, pagination, typeahead template, external KB tutorial, GitHub example, facets, suggestions, text index group, default and contextual sources), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g).
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Service Portal Search Configuration

**In one line:** a portal searches with **AI Search** (default on new instances) or legacy **Zing** through **search sources**; facets, suggestions and per-widget settings refine what users find.

From the Brazil docs; not tested. Engines: [[AI Search Overview]], [[Zing Text Search and Global Search]]. Widgets: [[Service Portal Base Widget Library]].

## Which engine

| | AI Search | Zing (legacy) |
|---|---|---|
| Default | new and zBoot instances; **off on upgraded instances** until enabled on the portal | some portals still use it |
| Portals | Service Portal, Employee Center, Consumer Service Portal, Business Portal, Customer Service Portal, or custom portals built from them (list in `glide.service_portal.enable_ais_portal.allow_list`) | any |
| Sources | defined in the AI Search application (the portal's Search Sources related list disappears) | **Search Sources** on the portal |
| Features | suggestions, natural language, typo handling, personalised results, genius results with actions, facets and tabs; modern browsers only | text index, facets, suggestions or typeahead |

**Enable AI Search:** portal record > **Enable AI Search**, then **Search Application** (engine, results and suggestion limits) and **Search Results Configuration** (how results display). Widgets can override both in their instance options. Knowledge results need the search profile linked to a knowledge bases search source. Search widgets cloned or customised before an upgrade may not work: bring their code up to date (Portal Analyzer, widget diagnostics), then run fix script **Reclassifying Search widgets** with the instance sys_ids, which moves them to class `sp_instance_ais`. Do it in that order, or the widgets cannot take the AI Search code later.

**Search Results Action** (Service Portal > AI Search > Search Results Action): which portal page opens for a result from an AI Search source: Portal(s) (empty = all active), AI Search Source, Action name (navigation actions only), Order (lowest wins, ties to the oldest), **Portal page**, **Payload query parameters** (payload fields to URL parameters, from the action's payload definition) and additional parameters (for example `view` = `sp`). Genius result buttons are EVAM actions ([[Entity View Action Mapper (EVAM)]]).

**Theming:** about 45 `$now-sp-*` variables (font, text, tab, pill, button, border radius, genius result colours) in the theme's CSS variables or a CSS Include. Example override: a style sheet (`sp_css`) with `sn-search-facets { --now-color--divider-tertiary: 0px !important; }`, a CSS Include pointing to it, and an `m2m_sp_theme_css_include` row linking it to the theme. Title highlight colour needs `removeHitHighlighting` false in the EVAM view template.

## Search sources (Zing)

**Search Source** records (from the portal's related list or Service Portal > Search Sources), fields:

| Tab | Fields |
|---|---|
| main | Name, ID (no spaces), Application, Roles (used when user criteria is off), **Search page template** (AngularJS result layout) |
| Data Source | **Is scripted source**; simple: **Table** (must be text-indexed), Conditions, Primary display field, Display fields, **Paginate results** (default true); scripted: **Data fetch script**, **Facet generation script** |
| Typeahead | Enable typeahead, Advanced typeahead config with a **Typeahead template**, Typeahead glyph, Page |

A **data fetch script** (server, scope of the source) receives `query` (and `queryLocation`, `count`, `facets`) and returns an array of result objects; set `primary` (main text), `url` and `target` (`_blank`) for external links:

```javascript
// Search source data fetch script (server, scope of the search source)
(function(query) {
    var results = [];
    var gr = new GlideRecord('x_example_article');
    gr.addQuery('123TEXTQUERY321', query);
    gr.setLimit(20);
    gr.query();
    while (gr.next()) {
        results.push({ primary: gr.getDisplayValue(), url: '?id=example_page&sys_id=' + gr.getUniqueValue() });
    }
    return results;
})(query);
```

External sources call REST from the script (the docs tutorials use `sn_ws.RESTMessageV2` against another instance's Table API, and `GlideHTTPRequest` against GitHub, both with basic auth inline; prefer a REST message with a stored credential: [[Outbound REST Messages]]). Facets may misbehave on non-ServiceNow sources, and text index groups do not support external sources.

**Pagination of scripted sources:** each "Load more results" reruns the script with `queryLocation` (the `query_location` of the last item returned); use `setLocation()` (global) or `chooseWindow()` (scoped), set `query_location` on each result and `isLastResult = true` on the last one. Do not page the facet script. Results per query come from the Search Page or Faceted Search instance options. (The docs example declares `now_GR` but then uses `gr`: as printed it would fail.)

## Facets

Rendered by Faceted Search on `sp_search`; on upgraded instances activate the **Search** page route map. Simple sources: **Facets** related list, fields Name, Selection type (**Single**, or **Multiple** = OR), Active, **Use mapped facet filters** (then **Facet Filters** with a Mapped query such as Updated on Today), Order, Field (True/False, Choice, Decimal, Floating Point, Integer, IP Address, Long, Reference, String, URL), Sort. Use indexed fields and no more than 30 filter items. Scripted sources build facets with `SPScriptedFacetService` and `SPScriptedFacet` (scoped). Turn facets off per source with property `glide.service_portal.disable_facets_for_search_sources` (sys_ids, no spaces).

## Suggestions, index groups and defaults

- **Suggestions** replace typeahead; switch with `glide.service_portal.search_as_you_type_behavior`. Data in `sys_search_event`, `sys_search_source_event`, `sys_search_suggestion`; custom search widgets feed them with `GlideSPSearchAnalytics`. On upgrades, scheduled job **Populate Suggestions to avoid Cold Start - Portals** seeds them once (portals array; source `text_search` or `sp_log`, which keeps 90 days; push custom source names and sys_ids). Heavy: run off-peak; not supported with domain separation.
- **Text index group:** add the **Text Index Group** field to the portal form; base group `portal_index_group` covers catalog items and knowledge.
- **Default sources:** `glide.service_portal.default_search_sources` (ordered sys_ids) when the portal has none.
- **Contextual search:** Typeahead Search instance option **Contextual Search Sources** limits results on that page (for example catalog only on the catalog page).
- Results show as plain text; limit sources with conditions such as Active is true.

## Example

Search source *Example Articles* (ID `example_articles`) on `x_example_article`, condition Active is true, primary field Title, paginated, with a facet *Example Category* (Field Category, Multiple) and a mapped facet *Updated this week*; on the catalog page the Typeahead instance limits contextual sources to *Example Catalog Items*.

## Related

- [[AI Search Overview]] · [[Zing Text Search and Global Search]] · [[Service Portal Base Widget Library]] · [[Knowledge Portal and Search]] · [[Service Portal Overview and Configuration]]
