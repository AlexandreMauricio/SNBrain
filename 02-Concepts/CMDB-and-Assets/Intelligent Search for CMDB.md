---
type: concept
tags: [concept, cmdb, ai, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Intelligent Search for CMDB (one topic, read in full through the docs site API 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/intelligent-search-cmdb.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Intelligent Search for CMDB

**In one line:** a natural language query (NLQ) box that turns a plain-English sentence ("linux servers running Example App") into a CMDB query over CI classes and relationships, running it directly or opening it in CMDB Query Builder.

From the Brazil docs. **English-language instances only**: not supported when the instance's preferred language is something else.

## Where it appears

| Place | Detail |
|---|---|
| [[CMDB Workspace]] | Home view and the *Explore and Search* view; the workspace's AI search (Otto) falls back to it. Results paging and limits are in that note |
| Service Graph Workspace | *Search and Explore* view (no vault note) |
| CMDB Query Builder | NLQ inside the builder, controlled by `glide.cmdb.query.nlq.activated` (default true) |

## How a search runs

- Searches only the CMDB class hierarchy (tables), CIs and their relationships. Suggestions and spelling correction appear while typing.
- No ambiguity, one table: results come back as a list.
- No ambiguity, several tables: **View in Query Builder** opens the query fully built on the Query Builder canvas.
- Ambiguous table or relationship words: a **Refine your query** dialog offers synonyms and labels per phrase in drop-downs; pick and **Go**.
- Not convertible at all: no results, a feedback form instead (sent to ServiceNow). **Results Feedback** also lets you rate results.
- **Search tips** has examples for single and multi-table searches, filtering and relationships, and links to the implicit relationships table.

## Tables behind it

| Table | Content | Who edits |
|---|---|---|
| NLQ Sample Search (`sn_cmdb_ws_nlq_sample_search`) | sample searches offered when clicking in the box | `sn_cmdb_admin`, by editing the records (`sn_cmdb_ws_nlq_sample_search.list`); changes show in CMDB Workspace, Service Graph Workspace and Query Builder |
| NLQ Sample Search Table (`sn_cmdb_ws_nlq_sample_search_table`) | tables referenced by the samples | |
| NLQ Synonym (`nlq_synonym`) | pre-filled synonyms mapping words to tables, columns and relationships (e.g. "linux server" to *Linux Server*, *Server*, *Virtual Machine Instance*); add your own | see the NLQ synonyms docs (not read) |
| NLQ CMDB Implicit Relationship (`nlq_cmdb_implicit_relationship`) | implied class-to-class relationships | NLQ admins, **All > NLQ > CMDB Implicit Relationships** |
| NLQ Query Logs (`nlq_query_log`) | searches run; used by the workspace adoption metrics ([[CMDB Workspace Insights and SGC Central]]) | |

## Implicit relationships

Teach the search a link it cannot infer, typically around service offerings and application services. Fields: **From table** (`from_table`, the parent class), **Filters** on the from table, **To table** (child class), **Relationship** (e.g. *Contains::Contained by*: from contains to), **Skipped table** (the class implied in between and not shown in Query Builder).

The docs' example: "business service offerings with P1 incidents in the last 10 days" is not understood until such a relationship exists.

## Related

- [[CMDB Workspace]] · [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]] · [[CI Relationships]] · [[Contextual Search]]
