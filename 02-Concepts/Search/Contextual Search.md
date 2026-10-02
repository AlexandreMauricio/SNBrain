---
type: concept
tags: [concept, knowledge, incident, forms-lists, service-catalog]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Contextual search" and "Intelligent Search for CMDB" (pp. 2000-2039), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Contextual search

**In one line:** the **Related Search Results** panel on a form (and under a record producer): as the agent types the **Short description**, knowledge articles, catalog items and similar records appear, with actions such as **Attach** or **Order**. Its purpose is deflection: solve it from existing knowledge before, or instead of, working the ticket.

Plugin Contextual Search (`com.snc.contextual_search`), active by default. Uses the Zing engine ([[Zing Text Search and Global Search]]).

## Pieces

| Piece | What | You can |
|---|---|---|
| Search resource | scripted source: knowledge articles, catalog items, pinned articles, community questions | not create or change |
| Searcher | a group of search resources (for example *Knowledge and catalog*) | not create or change |
| Additional resource | one table plus condition (*Resolved Incidents, last 6 months*, *Open Incidents*) or a Predictive Intelligence similarity solution (*Similar Incidents*) | edit condition and description |
| **Search context** (`cxs_context_config`) | a searcher plus additional resources; **Searcher text** (group label), **Search on tab**, **Enable wildcard searches** | create |
| **Table configuration** (`cxs_table_config`) | which table/form uses which context: title, limit, results per page, roles, condition, search fields, filter configurations, search actions, email configurations | create |
| Record producer configuration (`cxs_rp_config`) | same for one variable of a record producer | create |
| Search result display configuration | card title, description and extra fields per resource table | edit |

Menu **Contextual Search**. Role admin.

## How a search is triggered

- Default search field: **Short description** (`com.snc.contextual_search.widget.form.default_field`). More fields can be added under **Search Fields** (keep them short: under about 100 characters).
- **Search on tab** ticked: runs when the user leaves the field (recommended). Unticked: runs after a pause in typing (`com.snc.contextual_search.wait_time`, 1000 ms; minimum 3 characters, `com.snc.contextual_search.min_length`).
- **Enable related search box** lets the agent search other words without changing the short description; **Enable source selector** lets them switch source.
- Only fields visible on the form trigger searches.
- The panel is collapsed on existing records and open on new ones by default (properties `...open_collapsed_existing_records`, `...open_collapsed_new_records`).

## Narrowing results

- **Filter configurations** on the table configuration: map a form field to a field of the resource (for example article category = incident category), or a scripted filter.
- **Resource configuration properties** on the search context: knowledge **Condition** (restrict to one knowledge base), catalog name, **Search operator** `IR_AND_OR_QUERY` (default: all terms, else any), `IR_AND_QUERY`, `IR_OR_QUERY`.
- **Search as**: show results the caller could see (tab *My Results* and a tab for the other user), useful when the agent has more access than the requester.
- Results always respect the searching user's access.

## Actions on a result

- **Attach** (knowledge): writes a link (or a copy) of the article into **Additional comments** by default; per table via **Use custom field for attach note** / **Attach note field** on the search action, globally via `glide.knowman.attach.fields`. The article's attachments are not copied. **Show on new record** makes Attach available before the first save.
- **Order** (catalog item), **This helped** (cannot be disabled), preview.
- Every action is logged: `cxs_relevant_doc` (search session, where displayed, record) and `cxs_rel_doc_detail` (action, position, user). Report on these to measure deflection.

## In notifications

An email configuration on the table configuration plus `${mail_script:cxs_EmailSearchResults}` in the notification body adds knowledge links (three by default) based on the record's short description, filtered to what the **User field** user (for example Opened by) may read.

## Base behaviour

- Incident form: table configuration for Incident with the *Incident Deflection* style context.
- Record producer *Create New Incident* searches as the user types. One variable per record producer.
- Predictive Intelligence resources (*Similar Incidents*, *Similar Knowledge Articles*...) need the Predictive Intelligence and Predictive Intelligence for Contextual Search plugins.

## Intelligent Search for CMDB

A natural-language query box for CIs in CMDB Workspace; complex queries open in CMDB Query Builder. Implicit relationships it understands are stored in `nlq_cmdb_implicit_relationship`.

## Related

- [[Configure Contextual Search on a Form]] · [[AI Search Overview]] · [[Mail Scripts]]
