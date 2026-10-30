---
type: concept
tags: [concept, ai, roles, instance-admin, script, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform Administration > Search administration > AI Search (Search disparities, Assign AI Search roles, Indexed source retention policies and filter conditions, Purge stale records, Indexed source guardrails, Semantic index configuration overview, Genius Results overview), read 2026-10-30. The other pages of the 244 in this section, including the system properties reference and External Content Connectors (210 topics), not read. https://www.servicenow.com/docs/r/platform-administration/r_AvailableSystemProperties.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# AI Search Indexing, Relevancy and Result Differences

**In one line:** how to control what goes into the AI Search index, why index size affects speed, and why the same question gets different answers from different search tools.

From the Brazil docs; not tested. Basics are in [[AI Search Overview]].

## Why results differ between tools

This is expected behaviour, not a fault.

| Tool | Search mode | Interaction | LLM |
|---|---|---|---|
| **AI Search** | keyword | search field | none |
| **Otto Genius Results** | hybrid: keyword and semantic vector | search field | top results sent in one prompt |
| **Otto for Virtual Agent** | hybrid | chat | agentic, keeps conversation context |

AI Search stays consistent until data changes, though machine learning relevancy can reorder results over time. LLM answers can vary even for the same input at the same moment.

## Roles

| Role | Can |
|---|---|
| `ais_admin` | indexed sources, search sources, profiles, dictionaries, Genius Results, result improvement rules |
| `search_application_admin` | search application configurations for Zing and AI Search; includes `ais_admin` and `personalize_dictionary` |
| `ais_high_security_admin` | bypass filters in Search Preview; elevated privilege, used by elevation only |
| `ais_external_content` | external content APIs; for integration users; `admin` does not need it |

## Controlling the index

- **Retention policy:** index only records updated within a period. **Required** for `task` and its child tables, optional for others.
- **Filter conditions:** a record must match them all. Filters reduce records indexed per event, not the number of events.
- **Stale records:** past retention or no longer matching. Purged automatically every day.
- **Guardrails:** on by default for Task (`task`) and Alert (`em_alert`) and their child tables, **10 million records** each. Applied after filters and retention; the most recently changed records stay.
  - Limit is read from `ais_guard_rail_limit_data_source`, then `glide.ais.ingestion.guard_rails_enabled_datasources`.
  - Only a ServiceNow employee can change them; up to 24 hours to apply.

Search slows with index size, the number of indexed sources, the number of indexed fields, and indexing frequency. So exclude open, frequently updated records where you can.

**Manual purge:** server-side background script, **All > System Definition > Scripts - Background**, global scope, `admin` (or the role in `glide.script_processor.admin`). It creates an event and returns without waiting.

```javascript
// Background script (server, global): purge stale index records for one table
new sn_ais.IndexEvent().purgeFilteredDocuments('kb_knowledge');

// Omit the table to purge stale records for all tables
// new sn_ais.IndexEvent().purgeFilteredDocuments();
```

## Semantic index configuration

For semantic vector search and RAG (Retrieval-Augmented Generation). Plugin `com.glide.ais.semantic_search`, activated with any Otto application; `ais_admin`.

Elements: indexed source, embedding models, chunking strategy with parameters, and semantic index fields, one per field or attachment set, in order. Several configurations can exist per source, but each extra one costs indexing performance. If the **Semantic Index Configuration** related list shows on an indexed source (**All > AI Search > AI Search Index > Indexed Sources**), it is active.

## Genius Results

A configuration has a trigger and answer logic, and must be linked to a search profile.

- **Trigger:** Always, NLU (intent match), or Term (a single term or phrase).
- **Order** is set per profile, lower first. The search application's **Genius Results Limit** caps the cards.
- A trigger can fire and still show nothing: answers appear only at very high confidence.

## Example

Indexed source *Example Incident Source* on *Incident* (`incident`): retention of 2 years, filter *State is Closed*. Search profile *Example Portal Profile* links it to Genius Result *Example Password Answer*, trigger Term, *password*. Test with *Test User* in Search Preview.

## Related

- [[AI Search Overview]] · [[Zing Text Search and Global Search]] · [[Contextual Search]] · [[Explicit Roles and Elevated Privilege Roles]]
