---
type: concept
tags: [concept, platform, ai, portal, knowledge, integrations]
status: documented
source: ServiceNow Australia Platform Administration PDF, "AI Search" (pp. 1138-1480), "AI Search Admin console" and "Platform Analytics Solution for Advanced AI Search Management Tools" (pp. 1481-1550), "External Content Connectors" (pp. 1551-1999), read 2026-10-01 at summary depth. Read in full: architecture and feature overview, query language, content security, navigation. Not transcribed: per-form field tables, the per-connector setup procedures (about 40 connectors), Genius Result configuration details, REST ingestion API
sn-release: Australia
verified:
updated: 2026-10-01
---

# AI Search overview

**In one line:** AI Search is the default search engine for Service Portal, Now Mobile, Virtual Agent, workspaces and Next Experience global search; it has its own index, fed from tables and external systems, and is configured in four layers: indexed sources, search sources, search profiles, search applications.

Not available on personal developer instances. The legacy engine is described in [[Zing Text Search and Global Search]].

## The four layers

| Layer | What it defines | Where |
|---|---|---|
| **Indexed source** | a table (or external system) whose records go into the index: child tables, attachments, translated and referenced fields, field mappings | **AI Search > AI Search Index > Indexed Sources** |
| **Search source** | a filtered subset of an indexed source | **AI Search > Search Experience > Search Sources** |
| **Search profile** | a search experience: its search sources, synonym / stop word / typo dictionaries, Genius Result configurations, result improvement rules. Must be **published** | **AI Search > Search Experience > Search Profiles** |
| **Search application** | where the profile is used (a portal, a workspace, global search): facets, limits, suggestion types | **AI Search > Search Experience > Search Applications** (`sys_search_context_config`) |

Base indexed sources: knowledge articles, catalog items, users. Others you add.

- Defining an indexed source indexes **changes from then on**; existing records need **Index All Tables** on the indexed source (wait for **Ingestion State** = indexed).
- Role `ais_admin`; `search_application_admin` for applications. Logs: **AI Search > AI Search Logs**.

## Features

- **Genius Results**: answer cards above the results (a knowledge article answer, a catalog item to order, a person's profile), triggered by query intent.
- **Result improvement rules**: boost, block or promote results under conditions.
- **Synonyms, stop words, typo handling**: per profile, per language.
- **Lemma normalisation**: word forms match automatically for about 25 languages, no configuration.
- **Facets** and source buckets for filtering results.
- **Auto-complete suggestions** from recent and popular searches ([[Zing Text Search and Global Search]] describes the shared suggestion tables).
- **Machine-learning relevancy**: tuned automatically from search signals.
- **Semantic / hybrid search** and AI-generated answers with the corresponding subscription.
- Translated content: by default only results in the session language; search languages per country and a global-language fallback can be configured.

## Query language

| Query | Finds |
|---|---|
| `conference room` | both terms, any order, any field (AND). Property `glide.ais.query.search_operator` can make it OR |
| `"conference room"` | the phrase; linguistic features and wildcards still apply inside quotes |
| `a OR b` | either |
| `email -signature` | exclude the term or phrase after the hyphen |
| `the%e` | one-character wildcard, after at least three literal characters |
| `acc*` | any-length wildcard, after at least three literal characters |
| `***` | everything, unranked |

- Terms match whole indexed words: `exam` does not find `example`.
- Not case-sensitive. Text between `<` and `>` is stripped from the query.
- A multi-term query with no results is automatically retried as OR, requiring at least half the terms.
- **Fuzzy numeric search**: an all-digit term matches record numbers ignoring prefix and leading zeros (`23583` finds `KB00023583`); `glide.ais.query.enable_fuzzy_number_match`.

Differences from Zing: negation is only `-`; wildcards need three leading characters; quotes do not switch off stemming.

## Security

Results are trimmed to what the user may read.

- **Early binding** (default): security filters are added to the query. Covers non-scripted ACLs, before-query business rules, domain separation, and user criteria for knowledge and catalog items.
- **Late binding**: each result is also checked with `canRead()`. Used automatically when a table has scripted table-level ACLs or an early filter errors; can be forced per indexed source (**Force Late Binding**) or globally (`glide.ais.security.force_late_binding`). Slower, and facet counts can exceed the results shown.
- Encrypted fields are not indexed.
- External documents carry their own permissions (everyone, users/groups read and deny), mapped to platform users through a user mapping.

## External content

- Plugin External Content for AI Search (`com.glide.ais.external_content`): ingest documents through an API with a schema table.
- **External Content Connectors** (Store application, cloud-hosted instances): scheduled **content crawls** and **permission crawls** against systems such as SharePoint Online, Confluence, Jira, Google Drive, OneDrive, Teams, Slack, Box, Dropbox, GitHub, Zendesk, Workday, SAP SuccessFactors, another ServiceNow instance, or a generic web crawler (about 40 connectors). Each gets an indexed source and a default search source; add the search source to a profile to make it searchable. Crawls consume **Integration Hub transactions**.

## Administration tools

- **AI Search Admin console**: guided configuration and testing of search solutions per application type.
- **Advanced AI Search Management Tools**: dashboards of query traffic, indexed document counts per profile and month, and a result preview (jobs refresh the data hourly).
- Catalog variables can be indexed (`glide.ais.ingestion.index_catalog_variables`).

## Related

- [[Contextual Search]] · [[Otto for Setup and Multi-Instance Trust]]
