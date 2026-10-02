---
type: concept
tags: [concept, platform, forms-lists, encoded-query, knowledge]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Search administration" and "Zing text indexing and search engine" (pp. 1027-1137), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Zing text search and global search

**In one line:** Zing is the built-in keyword search engine behind the list **for text** search, the `123TEXTQUERY321` query term, Core UI global search and (where AI Search is not configured) Next Experience global search; it works on a per-table **text index** of words.

AI Search is the newer default engine for portals, mobile and Virtual Agent: [[AI Search Overview]].

## Where users meet it

| Place | Behaviour |
|---|---|
| List search, field = **for text** | searches every indexed field of the table; becomes the filter `Keywords are <terms>` |
| Global search (header) | searches several tables, results grouped by table |
| Knowledge search, legacy portal search | same engine |
| Scripts | `gr.addQuery('123TEXTQUERY321', 'email server')`; text index groups use `123TEXTINDEXGROUP321` |

A list search on a specific column is **not** Zing: it is an ordinary field filter with its own wildcards ([[List Configuration and List Controls]]).

## Search syntax

| Syntax | Meaning |
|---|---|
| `email server down` | all words (implicit AND) |
| `"email password"` | exact phrase, in that order; stop words, punctuation and wildcards inside quotes are ignored |
| `OR` or `\|` | either term. **Operators must be upper case** |
| `NOT`, `-term`, `!term` | exclude; the symbol must touch the term; a query cannot be only exclusions |
| `te%t` | exactly one character |
| `pl*d` | zero or more characters |

- Only **one Keywords condition** per filter; it cannot be combined with an OR condition group in the condition builder.
- Knowledge search retries with OR when AND finds little (`glide.knowman.search.operator`).
- Too many wildcard expansions (`glide.ts.max_wildcard_expansion`) gives a "refine your search" message.
- A record **number** typed in global search opens the record directly (exact match; prefixes from `sys_number`). Optional fallback for other tables: `glide.ui.text_search.enable_fallback_number_search` and `glide.ui.text_search.fallback_table_list`.
- Results always respect ACLs.

## What is indexed

- Tables with **Text index** enabled (the table's collection dictionary entry / **System Definition > Text Index Configurations**). Enabled by default for Task, User, Knowledge and core data tables. **Inherited by child tables**; to exclude one child, add attribute `no_text_index=true` on that child's collection entry (clearing the checkbox on a child does nothing).
- Excluded always: fields named `sys_*` (except `sys_class_name`, `sys_tags`), Date, Date/Time, Duration, True/False and Workflow fields, fields with `no_text_index=true`, Edge-encrypted fields.
- **Words**: split on spaces; punctuation kept where it forms company names (`H&R`, `Coca-Cola`), product or record numbers, host names, IPv4 addresses, acronyms (`u.s.a.` = `usa`).
- **Junk filter** (`text_index_filter_junk`, on by default): single characters and two-digit numbers are not indexed.
- **Stop words**: global list (**System Definition > Text Index Stop Words**), per-table list with a mode (*Neither Index nor Query*, *Index but do not Query*, *Not a Stop Word*), and **automatic** stop words (job *TS Index Stats* nightly: words more frequent than the table's **Auto threshold**).
- **Stemming** (Porter; English, French or German via `glide.ts.stemming_language`, one language per instance): `planned` matches `plan`. Side effect: an acronym like `AMS` stems to `am`, a stop word, and finds nothing; fix by deactivating that stop word.
- **Attachments**: indexed for Knowledge by default; other tables with attribute `attachment_index=true` on the table itself (not inherited). Types: doc/docx, xls/xlsx, ppt/pptx, pdf, txt, html and a few more. Only Knowledge results display the attachment.
- Multi-row variable sets: property `glide.ts.index.variableset`.
- New tables arriving by update set have text indexing off.

## Relevance

Score = **frequency** (one point per occurrence) + **sequence** (10^n points for n query words appearing in order) both multiplied by the field's **weight** (`ts_weight`, default 1, max 255).

Default weights: `task.number` 50, `task.short_description` 10, `kb_knowledge.number` 50, `kb_knowledge.short_description` 10, `kb_knowledge.meta` 10.

- TF-IDF (rare words count more): attribute `text_index_enable_idf` then **Enable IDF Score** on the text index (on for Knowledge).
- **Query mode** per table: AND (default), OR, AND_OR (AND first, OR if nothing), plus a **Partial Match Rule** such as `75%` or `3<70%` (up to 3 terms all required, above that 70 percent).
- **Synonyms**: off by default. Enable in text search properties, create dictionaries (**Text Index Synonym Dictionaries**) with sets `car,auto` (two-way) or `IOT=>RFID,chip` (one-way), **Publish All Dictionaries**. Synonym hits weigh 10 percent (`glide.ts.synonym.expanded.boost`).
- V4 index format (BM25 scoring) is needed for **text index groups** that search several tables as one; task tables cannot be in a group.

## Global search configuration

| UI | What defines the searched tables |
|---|---|
| Next Experience | **search sources** (`sys_search_source`: table plus conditions) linked to the search application *Now Experience Search Configuration* (`sys_search_context_config`). Defaults: incidents, changes, change tasks, problems, requests, requested items, catalog tasks, users, groups, companies, knowledge, catalog items |
| Core UI | **search groups** (**System Definition > Search Groups**, `ts_group`): Tasks, People & Places, Knowledge & Catalog |

- The fields shown per result come from the table's list view named **text_search** (`glide.ui.text_search.view`): first string field = title, a long field = description, up to 10 others.
- Properties (**System Properties > Global Text Search**): `glide.ui.can_search` (roles allowed: itil, text_search_admin, admin), `glide.ui.text_search.rowcount` (10 per table, Core UI), `glide.ts.global_search.parallelism` (4), `glide.ui.no_text_search`. Next Experience preview limit: `sys_aw_global_search_config`.
- Fewer active groups and tables = faster global search.

## Maintaining indexes

- Indexes update continuously (job *text index events process*, every 30 seconds).
- **Regenerate Text Index** (text index record) purges and rebuilds: searches on the table return nothing meanwhile, and large tables take hours.
- Rebuild without downtime:

```javascript
new GlideTextIndexEvent().indexUpdate('kb_knowledge', 'null');
```

- One record only: `gs.eventQueue('text_index', gr, '<table>', 'update', 'text_index');`
- Regenerate after: changing stop words, weights (V3), junk filter, stemming language; after renaming users or groups (old display values stay indexed).
- **System Definition > Text Indexes** shows state, last duration, counts. **Debug Text Search** (Session Debug) prints how a query was parsed. **Reset Text Search Caches** if stemmed term numbers differ from `ts_word`.

## Search suggestions and signals

- Plugin Search Suggestions: every search is logged in `sys_search_event` (query, **Has results**, **Click rank**, **Refinements**); job *Build Search Suggestions* (daily) turns them into `sys_search_suggestion`; *Prune Search Suggestions* (weekly) keeps 500,000. Events kept 180 days (auto flush).
- Useful analysis: queries with **Has results** = false (content gaps); average click rank (lower is better).
- Exclusions: `sys_search_suggestion_blacklist` (words or regular expressions); roles `suggestion_exempt`, `cannot_read_suggestions`.
- Properties `glide.search.suggestions.enabled`, `glide.service_portal.search_as_you_type_behavior` (Suggestions or Typeahead).

## Roles

`ts_admin` (indexes, stop words, synonyms), `text_search_admin` (search groups), `search_application_admin` (search applications).

## Related

- [[Text Search Returns No Results]] · [[Contextual Search]] · [[Dictionary Attributes Reference]]
