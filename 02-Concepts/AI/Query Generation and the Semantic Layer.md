---
type: concept
tags: [concept, ai, reporting, schema, security, access-control]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > ServiceNow Otto for Platform Analytics > Query Generation (Explore, Configure, Reference), read 2026-10-30. Pages on customizing semantic metadata and the manual segment data model and shipping were listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/query-generation.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Query Generation and the Semantic Layer

**In one line:** **Query Generation** is the hidden shared back end that turns a plain-language question into an executable query, with a summary, a visualization and follow-up suggestions, for AI Data Explorer and the other analytics AI features.

From the Brazil docs; not tested.

## How it works

1. **Decide the source:** what the calling application supports, then an explicit source, keywords, context, and finally `sn_query_gen.default_source_type` (default `table`). More than two breakdown levels falls back to table.
2. **Table data:** a semantic filter narrows entities to the 12 closest, then dimensions, so the LLM is grounded in real tables and columns.
3. **Indicators:** not in the semantic layer; searched in `pa_indicators`, passing the 12 closest. Automated and formula only, not Benchmark or Data Snapshots.
4. The LLM writes a semantic query; a **constitutor** translates it into an executable one.

Building blocks:

| Block | Table | Meaning |
|---|---|---|
| **Entity** | `sn_query_gen_entity` | a table; generated, read only |
| **Dimension** | `sn_query_gen_dimension` | a queryable column; can traverse references (`caller_id.department`) if the referenced table is in the layer. One page writes `sn_query_gen_dimensions`: unconfirmed variant |
| **Segment** | `sn_query_gen_segment` | a filter with business meaning: *open* = `active=true` |

Not supported: variable, tag and domain path fields. Operators include `=`, `!=`, `>`, `<`, `LIKE`, `IN`, `NOT_IN`, `BETWEEN`, `CONTAINS`, `STARTSWITH`, `ENDSWITH`, `ISEMPTY`, `DYNAMIC`, `INSTANCEOF`, `ON`.

## Adding tables

**All > Query Generation > Administration > Semantic table config** (`sn_query_gen_table_config`) > **New**, or list action **Enable for Query Generation** on `sys_db_object` or `sys_db_view` lists. Supports tables, database views (session scope must match the view) and Workflow Data Fabric tables. Options: **Enable Semantic Generation** and **Include Child Hierarchy** (both on). Task-extended tables and some base tables are in by default. Every table added can slow load and runtime. Roles: `admin`, `now_assist_explorer_admin`, `sn_query_gen.admin`.

Database views answer cross-table questions in one query.

## Protected scopes

Tables in protected scopes (such as Human Resources Core or Employee Profile) ignore the plugin's ACLs. Two steps:

1. **Scoped ACLs** (`admin` or scope admin), server side, in the protected scope. Switch to the scope, filter ACLs on `paai_canvas_component`, open each operation, **Insert and Stay**, then set the advanced script:

   | Operation | Script |
   |---|---|
   | read | `answer = new sn_pa_ai_canvas.AICanvasACLUtilPublic().canReadComponent(current);` |
   | write, create | `answer = new sn_pa_ai_canvas.AICanvasACLUtilPublic().canEditCanvas(current);` |
   | delete | `answer = new sn_pa_ai_canvas.AICanvasACLUtilPublic().isRecordOwner(current);` |

2. **Approve the Restricted Caller Access records** that are generated when data is fetched. Approval page not read in detail.

## Tuning

Check it is repeatable first, since the LLM sometimes just errs. Capture the utterance, classify the failure as entity, dimension, segment or ACL, make one change, retest, confirm in the logs.

**Health page** (**Query Generation > Health page**): entitlements, LLM and AI Search, semantic layer, plugins, enabled products, properties. No components: run **Generate Semantic Layer**. *No entities and dimensions* with components present: re-index. Role written `sn_query_generation.admin` here and `sn_query_gen.admin` elsewhere: unconfirmed variants.

**Metadata:** semantic description, label (works as a search alias) and usage instructions (injected into the prompt). Column settings in `sn_query_gen_column_config`.

**Segments:**

| | Manual | Automated |
|---|---|---|
| Source | `sn_query_gen_segment_table_config`, by admins | reports, report sources, indicator sources, modules, filters |
| Weight | ×1.05 | standard |
| LLM | keeps all filters unless irrelevant | critiques each filter |
| Ships by | update set | generated at runtime |

**Indicator scope control:** `sn_query_gen_indicator_config` lists trusted indicators, with optional descriptions; they get a second search and a relevance boost, tuned with `sn_query_gen.indicator.boost.scale_factor` (create it; 1.0 disables). Optional and additive: an empty list changes nothing.

## Roles and jobs

- `sn_query_gen.user`: call the service through an app; calling applications' roles should contain it.
- `sn_query_gen.admin`: tables, Health page, metadata, manual segments.

| Job | Runs |
|---|---|
| Generate Semantic Layer | at install, then on demand |
| [Query Generation] Sync Segments Job | at install, then weekly on Sundays |
| [Query Generation] Semantic Entity Auto-Scaling Job | at install, then daily at 20:23:00 |

Also `sn_query_gen_utterance_bank`, `sn_query_gen_log`, `ais_search_profile`, `ais_datasource`.

## Logs

`sn_query_gen_log` has one row per call: **Utterance**, **Status**, **Error message**, **Total time** and component times (LLM, RAG, filter, ACL), **Semantic Filter Results**, **Utterance Bank Results**, **Entities**, **Query Constitutor Output**, **Response**, **Dot walked**, counts of entities, dimensions and segments.

## Properties

| Property | Meaning | Default |
|---|---|---|
| `sn_query_gen.default_source_type` | fallback source | `table` |
| `sn_query_gen.hidden_insights.groupby.min_fields` | group-by fields for extended analysis | 5 |
| `sn_query_gen.segment_enabled` | use segments | true |
| `sn_query_gen.segments.disable.filter`, `.manual_segment`, `.pa_cubes`, `.report`, `.report_sources`, `.sys_app_module` | exclude a segment source; applied at the next sync | false |
| `sn_query_gen.segments.ais_batch_fetch_enabled` | search manual and automated separately | not recorded |
| `sn_query_gen.segments.indicator.inactivity_threshold_multiplier` | how recent an indicator must be | 1 |
| `sn_query_gen.segments.manual_segment_scale_factor` | manual weight | 1.05 |
| `sn_query_gen.segments_match_threshold` | minimum similarity | 0.70 |
| `sn_query_gen.segments.max_filter_length` | longest segment, characters | 2000 |
| `sn_query_gen.segments.reports.last_viewed_threshold_days` | recent report | 180 |
| `sn_query_gen.segments_search_limit` | AI Search results | 12 |
| `sn_query_gen.segments_result_limit` | segments returned | not recorded |

## Example

Add `ast_contract` with child hierarchy, confirm rows in **Entities** and **Dimensions**, then add manual segment *Example Expiring Contracts* so users can ask *How many expiring contracts are there?*.

## Related

- [[AI Data Explorer]] · [[Otto for Platform Analytics Skills]] · [[Database Views]]
