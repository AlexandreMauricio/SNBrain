---
type: reference
tags: [reference, ai, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Enable AI Experiences > AI agents and agentic workflows > AI agents library > ServiceNow AI Platform AI agents (61 topics) and ServiceNow Otto for Creator AI agents (9 topics), read 2026-11-06 through the docs site API (map UBGwc5glUUjVANqQeiJeZA). Roles and workflows taken from each agent page; sub-agents of Knowledge Management, MID Server, Notifications and Setup Hub listed by name only.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# AI Agents Library - Platform and Creator Agents

**In one line:** the shipped AI agents that are not tied to one product: record, survey, SLA, ACL and work-planning helpers, AI Control Tower housekeeping, and the Otto for Creator agents for builders.

From the Brazil docs, not tested. Whether an agent is present depends on licence, tier and plugins ([[AI Platform Map, Roles and Product Tiers]]). How agents, roles, triggers and channels work: [[AI Agent Studio, Agentic Workflows and AI Control Tower]]. A dash (–) means the role was not captured from the page; check the page before relying on it.

**Two role columns:** *allowed role* is who may use the agent; *data access role* is what the agent itself can read and change (the role masking in [[Role Masking for AI Agents]]).

## Work on records

| Agent | Does | Allowed role | Data access role | Used in |
|---|---|---|---|---|
| Record management | fetch, create, update a record, link a KB article, copy an attachment | `snc_internal`, `sn_uxc_gen_ai.platform_ai_record_mgmt` | `sn_uxc_gen_ai.platform_ai_record_mgmt`, `itil` | Process emails for tasks |
| Record field value prediction | predicts fields of an incoming record | `sn_uxc_gen_ai.platform_ai_field_predictor` | same, plus `itil` | Classify tasks; HR and legal triage |
| ServiceNow record navigator | turns "show me open P1 incidents" into clickable list views | – | – | Actionable Navigation |
| Request status | answers on the user's own existing tickets | `snc_internal` | `nobody` (as written) | Default VA Workflow |
| Approval assistance | answers on the user's approvals | `approver_user`, `sn_request_approver_read`, `snc_internal` | not defined | – |
| Image processor | creates a task from an uploaded image | `sn_uxc_gen_ai.platform_ai_image_processor` | same | Process images for new tasks |
| Issue readiness | checks if a ticket is complete enough for a fulfiller | `sn_uxc_gen_ai.platform_ai_issue_readiness` | same | – |
| Explain SLA | explains a task's SLAs and breakdown | `sn_uxc_gen_ai.sn_aia_sla_explain` | `itil` | Explain SLA |

## Resolution and planning

| Agent | Does | Allowed role | Used in |
|---|---|---|---|
| Next action recommendation | resolution steps from similar records, knowledge and web search | `sn_uxc_gen_ai.platform_ai_next_best_action` | Generate resolution plans |
| Decomposition | splits resolution steps into substeps and creates records | `sn_uxc_gen_ai.platform_ai_decomposition_agent` | Generate resolution plans |
| Web research and recommendation | resolution steps from web search | `sn_uxc_gen_ai.platform_ai_web_search_recommender` | – |
| Problems investigation | root cause, impact and resolution plan for a problem | `sn_uxc_gen_ai.platform_ai_problem_investigator` | Investigate problems |
| Issue trend analysis | recurring issues across grouped tasks | `sn_uxc_gen_ai.platform_ai_analyze_trnds` | Analyze task trends |
| Prioritize work, Update work plan | score the user's tasks by priority and SLA, then save the plan | `sn_uxc_gen_ai.platform_ai_work_planner` | Generate my work plan |
| Work allocator | assigns backlog tickets by workload and performance | `snc_internal` (data: `sn_uxc_gen_ai.platform_ai_work_allocator`) | Help Optimize Team Productivity |
| Search Q&A | fallback that searches resources when no other agent fits | not defined | – |

## Surveys

Survey analysis (trends and metrics from survey data, `sn_uxc_gen_ai.platform_ai_improve_services`, workflow *Identify ways to improve service*); Survey filling data collection and Survey response suggestion (propose answers from the case, incident or request, `sn_uxc_gen_ai.platform_ai_survey_response`, workflow *Propose survey responses*). See [[Surveys Overview and Survey Designer]].

## Administration and security

| Agent | Does | Allowed role |
|---|---|---|
| ACL Explainer | explains the ACLs on a table or field for an operation: roles, conditions, scripts, admin overrides | – (workflow *ACL Intelligence Workflow*) |
| Access Analysis | – (the page gives only its title) | – |
| Domain Separation (called Domain Visibility in its text) | manages users' domain visibility in the Otto panel | – |
| Error analysis and remediation | investigates Error Framework codes and runs preset fixes | – |
| Troubleshooting | triages a failed ATF test | `atf_triager` |
| Model provider configuration | says whether third-party LLM providers are OEM or bring-your-own-key | `sn_na_center.nac_user` |
| AI Analytics Q and A | answers questions about AI Analytics KPIs and dashboards | – |
| Web automation | fills forms, clicks and extracts data on web pages | `snc_internal` (data: `sn_aaa.web_agent_runtime`) |
| Smart documents | summaries, FAQs and answers on Document Management content | `snc_internal` |

**AI Control Tower (AICT) agents:** security analyzer (context and a confidence score for an AI security event), AI asset description auto-populator, deactivate dormant asset (analysis plus an offboarding change request), life cycle task reminder (emails owners of overdue tasks), outcome ranker (ranks insights per persona). Roles not captured.

## Agent families listed by name only

| Family | Agents | Allowed role |
|---|---|---|
| Knowledge Management | Content insights, KB content consolidation, KB content creation | `knowledge_admin`, `knowledge_manager` |
| MID Server (MID Guardian) | MID common, MID keystore, MID network, MID upgrade | `sn_itom_mid_grdn.admin` |
| Notifications | Email generator, Intent executor, Intent identification, Notification, Notification content | `snc_internal`, `snc_external` |
| Setup Hub | Group and roles assignment, IA operational data workflow, Implementation plan executor, generator and manager, Initialize IA orchestrator, SLA management, SSO configuration, Update set | `sn_ia_config.ia_user` |
| Content Understanding | contract search and document processing agents | `platform_ml_di.*` roles |

## Otto for Creator agents

| Agent | Does | Allowed role |
|---|---|---|
| Build Agent | builds and deploys full-stack apps into update sets ([[Build Agent]]) | – |
| Catalog AI agent | gathers and validates inputs for a catalog item | `snc_internal` |
| Module creator | turns a request into an application navigator module definition | `snc_internal` (data: `admin`) |
| Release lifecycle documentation | writes release notes and update set descriptions (4,000 characters at most) | `update_set_admin` |
| Theme Builder | creates and manages UI themes | `ui_builder_admin` |
| UI builder AI agent | edits pages and answers questions in UI Builder | `snc_internal` (data: `ui_builder_admin`) |
| Playbook activity context, Playbook data gathering and processing | fill forms and gather data inside playbook activities | – (workflow *Playbook Activity Assist*) |

## Example

To let *Test User* ask the ACL Explainer about *Example Table*, check the agent is active in AI Agent Studio, give the user the allowed role the page names, then ask in the Otto panel which ACLs govern read on `x_example_table`.

## Related

- [[AI Agents Library - CMDB, ITOM and Asset Agents]] · [[Otto for ITSM Agentic Workflows and AI Agents Reference]] · [[AI Agent Studio, Agentic Workflows and AI Control Tower]] · [[Access Control Lists (ACLs)]]
