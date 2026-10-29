---
type: concept
tags: [concept, ai, cmdb, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > ServiceNow Otto for CMDB (42 topics, 1,836 cleaned lines, read in full through the docs site API 2026-10-29) - landing, Explore, supporting information, Configure (set up, Search CMDB, CI summarization, summarize readiness, manage duplicates, SGC diagnosis), skills (summarize CI, readiness, Service Graph search, CI form help, Explore CI, manage and resolve de-duplication, SGC diagnosis), staleness and ingestion optimizer workflows, agentic workflows (create CI, search, governance, recommend SGC, data model navigator), AI agents, property settings. MCP server, impact analysis and business application agent are in [[CMDB MCP Server, Impact Analysis and Business Application Agents]]. https://www.servicenow.com/docs/r/servicenow-platform/now-assist-for-configuration-management-database-cmdb/now-assist-cmdb-exploring.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Otto for CMDB Skills and Agentic Workflows

**In one line:** the generative AI app for the CMDB (plugin `com.snc.cmdb.gen.ai`, "ServiceNow Otto for Configuration Management Database"), which adds skills (CI summary, duplicate help, connector diagnosis, readiness summary) and agentic workflows (search, create CI, governance advice, staleness, ingestion advice) used mostly from the Otto panel in CMDB Workspace and Service Graph Workspace.

From the Brazil docs. Supported from Xanadu patch 3. LLM providers: Now LLM Service, Azure OpenAI, Google Gemini, Anthropic Claude on AWS (choose in AI Control Tower, per skill in AI Admin Hub). Languages besides English: German, French, French Canadian, Japanese, Dutch, Spanish, Brazilian Portuguese, Italian. Availability limits for in-country, FedRAMP, IL5, IRAP, self-hosted and regulated markets: KB1584492, KB0743854, KB2593939. Data goes to a central ServiceNow environment, possibly a third-party cloud; inputs and outputs are collected unless you opt out.

Related ITSM equivalents: [[Otto for ITSM Skills and Agentic Workflows]]. Access control for agents: [[Role Masking for AI Agents]], [[Agentic AI Security and Governance]].

## Setup

1. **Admin > AI Admin Hub > Settings > Plugins**, card *ServiceNow Otto for CMDB* > **Get plugins** > install from the Store (role `sn_nowassist_admin.nsa_admin`). Check *Installed*.
2. **AI Skills** tab > Technology > **CMDB** > per skill **Edit**: *General details*, *Choose inputs* (read-only), *Define availability* (conditions, users, groups), *Select display* (the **Display** switch must be on, and user roles), *Review and activate*. If the card *Will ... display in product* says No, users never see it. To reactivate later, also tick **In Product Active** in `sn_nowassist_skill_config_status`.
3. Skills live in the global domain; in a domain-separated instance they only use data from the user's domain, and prompts are not persisted by the shared services.
4. Agentic workflow and agent records are read-only: to run them autonomously, duplicate the workflow, activate it and all its agents, and (optionally) its trigger.

## Skills

| Skill | Where, roles | Notes |
|---|---|---|
| **CI summarization** | **Summarize** on a CI form or workspace (`sn_cmdb_user`) | discovery source and most recent discovery (more sources with [[CMDB 360]]), owner from `glide.cmdb.health.ci_ownership_field`, open incidents, alerts (needs Event Management), problems, upcoming changes, vulnerabilities (needs Security Operations), service instances. Health details improve with the correctness job |
| **Summarize CMDB readiness** | DF and HAM dashboards of [[CMDB Success Advisor]] (`sn_cmdb_user` or `sn_cmdb_admin`) | top issues ranked by % affected (duplicates and 90-day stale first); merges an issue with its root-cause setting; one remediation per issue chosen by your role (minimum role per action in `sn_cmdb_gen_ai_advisor_remediation_action`). **Refresh** after changing filters; **View reasoning** |
| **Search Service Graph** (search result classifier) | Service Graph Workspace search (`sn_cmdb_user`, `now_assist_panel_user`) | picks keyword search or query generation, applies implicit filters, follow-up in the panel. Also the AI search in [[CMDB Workspace]] |
| CI attribute help / Explore CI | Otto icon next to a form field, **Ask Otto** on Explore CI (`cmdb_inst_admin`) | explains attributes, follow-up questions |
| **Manage duplicate CIs** | Otto panel (`cmdb_dedup_admin`, `now_assist_panel_user`) | groups duplicate tasks by root cause (identification rules, discovery sources), suggests templates, **previews** a template's result before running it. Needs jobs *De-duplication: Populate Duplicate Task Data*, *PopulateDuplicate Task Group Daily*, and the CMDB Health correctness job |
| **De-duplication task resolution** (from Australia) | task > **Remediate** > *Use the Duplicate CI Remediator (Now Assist)* (`cmdb_dedup_admin`) | proposes main CI, attribute, relationship and related item merges and duplicate actions with reasoning; edit, then **Submit** > **Proceed**; task closes with work notes. **Changing the main CI** ends the assisted flow (go manual). Reasoning text is not refreshed after your edits. Fix the source afterwards ([[Duplicate CI Remediation]]) |
| **Service Graph Connector diagnosis** | Otto panel "Diagnose a Service Graph Connector" (`cmdb_inst_admin`, `now_assist_panel_user`) | by connector, data source or import set number (e.g. ISET...); latest failed import set, error summary (import, flow, partial and incomplete payloads for IRE) and a recommendation from a knowledge article found by AI Search |

## Agentic workflows

| Workflow (agents) | Roles | Does |
|---|---|---|
| **Search CMDB** (CI search) | `sn_cmdb_user`, `now_assist_panel_user` | "Search the CMDB for ...": keyword (name, IP, serial, MAC, asset tag), single table with one-level dot-walk, or (v3.0+) across relationships in `cmdb_rel_ci` (`sn_cmdb_gen_ai.cmdb_rel_ci.search.enabled`). Under 5 results are summarised, otherwise a list up to 100. Needs Query Generation skills and indexing (**Query Generation > Indexed Sources** > *Index All Tables* on the Entity and Dimension source records, role `sn_query_gen.admin`; wait a day). Failures: **Query Generation > Event Queue / Logs** |
| **Create configuration item** (CI creator) | `sn_cmdb_editor` + panel role (v2.5 needed `sn_cmdb_admin`) | asks the class, reads the IRE identification rule for required attributes, checks for duplicates, creates the CI; refuses classes without an identification rule. Quick link *Create CI*, or "create a ci" |
| **Provide advice on CMDB governance** (principal class manager, life cycle manager, certification and attestation manager, health metrics manager, data ownership manager, data manager) | `admin` or `system_scheduler_admin` | looks at CIs updated in 90 days: suggests and sets principal classes, checks Data Manager policies, certification and attestation, health jobs and scores, ownership quality (Managed by group, users or groups inactive or empty). Quick link or Otto |
| **Recommend service graph connector** | `sn_cmdb_admin` or `cmdb_inst_admin` | "recommend sgc" + class names with the `cmdb_ci` prefix (+ optional attributes): connectors ordered by classes supported |
| **Data model navigator** | `sn_cmdb_user`, `sn_data_model_nav.data_model_navigator_read` | answers questions on classes, fields and relationships from the indexed **Data Model Navigator** app (installed with Service Graph Workspace - Content): **All > Data Model Navigator** > Contexts, Tables, Fields, Relationships |
| **Staleness** (CMDB Staleness Agent) | **Ask Otto** on the Stale CIs card; `sn_cmdb_editor` + panel role | uses class staleness thresholds (60 or 90 days), activity signals (events, incidents, changes) to spare CIs in use, rediscovery, fixes for Discovery or SGC schedules and credentials, then retirement via [[CMDB Data Manager]]. A lighter "Replacement CI Staleness Agent" handles stale > attestation > retire > archive > delete per class. Without the role: *Review policies*; scope users: *Learn more* |
| **CMDB ingestion optimizer** | **Ask Otto** on SAM cards *Software installs missing version*, *CIs missing CPU attributes*; `sam_admin` or `sn_cmdb_admin` + panel role | ranks Discovery patterns, SGCs, specialised tools (e.g. Oracle GLAS), Agent Client Collector, client management tools (SCCM, Intune, Tanium, JAMF), grouped by software products, CI classes, infrastructure |
| **CMDB Duplicate CI Agent** (feature preview) | `cmdb_dedup_admin` | from the success advisor's Duplicate CIs **Ask Otto**: groups duplicates by class, *Accept all*, *Reject*, *Skip*; "Track Progress", *Update settings*. Do not run manual templates at the same time |

Feedback (thumbs) is stored in `sys_generative_ai_log`.

## Properties

| Property | Default | Meaning |
|---|---|---|
| `sn_cmdb_gen_ai.principal_class_suggestion_period` | 90 | days of task history for principal class suggestions (raise, e.g. 36000, on quiet instances) |
| `sn_cmdb_gen_ai.suggested_principal_classes_limit` | ? | maximum suggestions |
| `sn_cmdb_gen_ai.health_ownership_evaluation_period` | 90 | days of data for ownership evaluation |
| `sn_cmdb_gen_ai.ownership_evaluation_health_score_thresholds` | 40,60,80 | Poor / Average / Healthy bands for Managed by group coverage (the docs' wording of the bands is inconsistent) |
| `sn_nowassist_sgc.ai_search_kb_score_threshold` | 5 | relevance threshold for articles in SGC diagnosis |
| `sn_nowassist_sgc.kb_filtering_strategy` | strict | strict = the connector's category only; non-strict = others too |
| `sn_cmdb_gen_ai.cmdb_rel_ci.search.enabled` | true | relationship search in Search CMDB |

The success advisor has its own, similarly named `sn_cmdb_advisor.*` properties (180 days, 20 suggestions): see [[CMDB Success Advisor]].

## Related

- [[CMDB MCP Server, Impact Analysis and Business Application Agents]] · [[CMDB Success Advisor]] · [[CMDB Workspace]] · [[Duplicate CI Remediation]] · [[Otto for ITSM Skills and Agentic Workflows]]
