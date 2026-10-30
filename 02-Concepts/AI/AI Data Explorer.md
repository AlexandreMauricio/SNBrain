---
type: concept
tags: [concept, ai, reporting, security, schema, troubleshooting]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > ServiceNow Otto for Platform Analytics > AI Data Explorer (Explore, Configure, source selection, Reference), read 2026-10-30. Day-to-day Use pages (write text, goals, duplicate, share steps, extended analysis detail) listed, not read one by one. https://www.servicenow.com/docs/r/now-intelligence/ai-data-explorer.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# AI Data Explorer

**In one line:** **AI Data Explorer** gives users shared documents called **explorations**, where they ask questions about instance data in natural language and collect the AI's visualizations, summaries and recommendations with their own notes. The glossary also calls it *Now Assist Explorer*.

From the Brazil docs; not tested. English only. Answers come from [[Query Generation and the Semantic Layer]]; data is sent to a central ServiceNow environment and usage data is collected for model improvement, so check availability and opt-out for your data centre (KB1584492, KB0743854, KB2593939).

## Who does what

| User | Needs | Can |
|---|---|---|
| Creator | `now_assist_explorer_user` | create, set the goal, invite |
| Participant | shared with edit, plus the role | generate visualizations, comment, maybe share |
| Viewer | shared without edit, or without the role | read only |

`now_assist_explorer_admin` (contains the user role, `sn_query_gen.admin`, `uxframework_user`) manages all explorations, workspace visibility, logs and semantic tables. The user role contains `sn_query_gen.user`. The checklist writes it `now-assist-explorer-user`: unconfirmed variant.

## Set up

1. Confirm the application is installed and the Workflow Data Fabric entitlement exists.
2. **AI Admin Hub > AI Skills** > **Data and Analytics > Analytics**: **analytics exploration** on, plus the Query Generation skills *analytics query generation*, *analytics insight generation* and, for indicators, the indicator one. Optional skills: exploration action recommendation, exploration summarization, refine text in explorations. All should share one role.
3. Grant the role. Check **Query Generation > Health page**, AI Search active, semantic layer built (entities and dimensions not 0).
4. Test with *Open incidents*, then force the source: *What do indicators show about open incidents for the last 60 days*.
5. Add custom tables to the semantic layer. Protected scopes need extra steps, see the Query Generation note.

**Record-level analysis** (skill Advanced options; include or exclude list of tables): answers read record contents. Not for indicators or queries over 50 records. **Warning from the docs:** the LLM honours record security for the asker, but only `report_view` ACLs on sharing, so people an exploration is shared with may see data about records they cannot access. Avoid it on tables with record-level security unless that is acceptable.

**Turn off indicators:** skill > **Indicators in AI Data Explorer**, or the Query Generation indicator skill for all AI applications.

**Remove the entry point in a workspace:** new record in `paai_canvas_workspace_config` with **Disabled in workspace**.

## Table or indicator

Priority: keywords, then context, then `sn_query_gen.default_source_type`.

- Indicator words: *indicator*, *KPI*, *key performance indicator*.
- Table words: *table*, *list*, *live data*, *live query*, *right now*, *at this time*, *this moment*, *as of today*.

Only automated and formula indicators; no manual, external, benchmark, targets, thresholds or forecasts. Context moves to the table when asked for records, live values, a third breakdown, or dates the indicator lacks. Combining breakdown elements: Count and Sum yes, Average and Count Distinct no; formula indicators need *Allow aggregation of multiple breakdown element scores*.

## Good questions

Short and simple, answerable with one chart or source. No definitions or cross-source comparisons. Say *these* in follow-ups to keep filters (*Of these incidents, how many are critical?*). **Extended analysis** gives more detail at more resource cost.

## Troubleshooting

Start at **Query Generation > Administration > Logs**: find the utterance, then check the entity, dimension and segment counts, **Query Constitutor Output** and **Semantic Filter Result**.

| Symptom | Likely cause | Fix |
|---|---|---|
| *Unable to understand* | no matching table | improve entity description, name the table, check AI Search and indexed sources |
| Wrong table | similar names | semantic usage instructions |
| Wrong table for some users | missing read access | table and field read ACLs |
| *Error accessing table data*, *Scope access not granted* | protected scope | ACLs and Restricted Caller Access |
| Missing field | dimension off or not in the layer | activate the dimension, update the label |
| Related fields missing | referenced table not in the layer | add the entity, enable the dimension |
| Wrong filter | bad segment | fix or disable the segment |
| No filter | no segment, vague question | manual segment, rephrase |
| Report segment wrong | stale auto segment | disable the source or segment |

## Tables

Private, readable by `admin`: `paai_canvas` (one per exploration) > `paai_canvas_conversation` (currently one) > `paai_canvas_component`; `paai_canvas_permission`, `paai_canvas_log` (licensing), `paai_canvas_workspace_config`.

**Domain separation:** Basic. Answers are limited to domains all collaborators can access; child domains cannot see parent explorations; parents see shared child ones.

## Example

*Test User* with `now_assist_explorer_user` opens an exploration titled *Example Backlog Review*, sets a goal, asks *Open incidents by priority*, then *Of these, how many are unassigned?*, and shares it with *Example Group* as viewers.

## Related

- [[Otto for Platform Analytics Skills]] · [[Query Generation and the Semantic Layer]] · [[KPI Details and KPI Signals]]
