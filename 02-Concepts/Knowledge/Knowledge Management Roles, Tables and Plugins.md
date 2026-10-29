---
type: reference
tags: [reference, knowledge, roles, schema, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Reference > Domain separation and Knowledge Management, Additional plugins for Knowledge Management, Components installed with Knowledge Management Core, Components installed with knowledge blocks, Knowledge Management roles, Quick start tests for Knowledge Management, Understanding access to the Knowledge knowledge base, Knowledge Management v3 homepage and Service Portal comparison, Knowledge subscription email notification templates, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/r_KnowledgeRoles.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Management Roles, Tables and Plugins

From the Brazil docs; not tested. Access by user criteria: [[Knowledge Base Access and User Criteria]].

## Roles

| Role | Can | Contains |
|---|---|---|
| `knowledge` | contribute to the default base, Knowledge menu; a **fulfiller** role (requesters read, rate and comment but cannot write) | none |
| `knowledge_manager` | for bases they manage: categories, pinning, approvals, base form; given automatically to base owners and managers | `knowledge` (the Core components page says it contains `knowledge_admin`, which looks reversed; unconfirmed) |
| `knowledge_admin` | all bases, create bases, all KM admin tasks (not scoped bases) | `knowledge` |
| `knowledge_coach` | AQI reviews, write/edit/review, coach | ? |
| `knowledge_domain_expert` | AQI reviews, write/edit/review, create ownership groups | ? |
| `knowledge_group_manager` | edit members of own ownership groups (not the manager); gets feedback tasks | `knowledge_group_member` |
| `knowledge_group_member` | approve, edit, retire their group's articles | `knowledge` |
| `kcs_candidate`, `kcs_contributor`, `kcs_publisher` | KCS levels (contributor validates in their area; publisher writes external-facing articles) | `knowledge` |
| `admin` | flows, properties, forms, dashboards | (page lists `sn_templated_snip.template_snippet_admin`, `sn_employee.admin`, `taxonomy_admin`, `sn_ace.ace_user` near admin; meaning unclear) |

Other roles met in KM pages: `sn_km_ml.knowledge_curation_user`, `sn_ssa_core.self_service_manager`, `user_criteria_admin`, `translator`, localization requester / fulfiller, `sn_voice_doc.user` (documents), `agent_workspace_user`. Prefer these specialised roles to `admin`. See also [[Base System Roles]].

## Tables (Knowledge Management Core, `com.glideapp.knowledge`)

| Label | Name |
|---|---|
| Knowledge (articles) | `kb_knowledge` ([[kb_knowledge]]) |
| Knowledge Base | `kb_knowledge_base` ([[kb_knowledge_base]]) |
| Knowledge Category | `kb_category` |
| Related Articles / Related Catalog Items | `kb_2_kb` / `kb_2_sc` |
| Knowledge Feedback (flags, comments) / Knowledge Feedback Task | `kb_feedback` / `kb_feedback_task` |
| Knowledge Keyword / Knowledge keyword (article ↔ keyword) | `kb_keyword` / `kb_knowledge_keyword` |
| Who Can / Cannot Read, Can / Cannot Contribute | `kb_uc_can_read_mtom`, `kb_uc_cannot_read_mtom`, `kb_uc_can_contribute_mtom`, `kb_uc_cannot_contribute_mtom` |
| Knowledge Use (views and uses) | `kb_use` |
| Knowledge Related to Products | `m2m_kb_ci` |
| Knowledge Comment Likes | `m2m_kb_feedback_likes` |
| Knowledge Applied to Tasks | `m2m_kb_task` |
| CSM Table Map / CSM Field Map | `csm_table_map` / `csm_field_map` (task → article mappings) |

Others: `kb_knowledge_block` (extends `kb_knowledge`), `m2m_kb_knowledge_to_block`, `m2m_kb_to_block_history` (blocks); `kb_article_template`, `kb_article_template_definition`, `kb_template_*` (templates); `kb_version`; `kb_translation_task`; `kb_quality_checklist`, `kb_checklist_question`, `kb_article_checklist_answer` (AQI); `kb_usage_metrics`; `ts_query_kb` (searches); `kb_task_knowledge_coverage` (demand insights); `ds_redaction_audit_log` (documents).

## Plugins

Core `com.glideapp.knowledge` (base for all), KM V3 `com.snc.knowledge3` (activate when upgrading from Eureka or earlier), Advanced Installer `com.snc.knowledge_advanced.installer` and Advanced `com.snc.knowledge_advanced` (needs all bases on v3), Predictive Intelligence `com.snc.knowledge_ml` (activates `com.snc.contextual_search_ml`; may need a licence), PA content pack `com.snc.pa.knowledge_v2`, i18n `com.glideapp.knowledge.i18n2`, Knowledge Document `com.snc.knowledge_document`, External Content Integration `com.snc.knowledge.external_integration` (copies external content: check reuse rights), Wiki Support `com.glideapp.knowledge2.wiki`, KCS Capabilities `com.snc.knowledge_kcs_capabilities`, Word add-in `com.snc.knowledge.ms_word`, Knowledge Blocks `com.snc.knowledge_blocks`, Knowledge Overview `com.sn_knowledge_overview` (reports), Product Entitlements `com.snc.kb_product_entitlements` (Affected Products), Now Mobile screens `com.glideapp.knowledge.mobile_requestor`. More in [[Knowledge Management Overview]].

## Domain separation (Standard)

- Separated: bases, user criteria, articles, categories, feedback, versions, templates, external sources. An article made with a template from another domain may be invisible in its own domain.
- Readers: own domain, child domains and global (global users: everything; parent: own, global, children; child: own and global), when criteria allow.
- Authors: bases in their domain, children and global (with contribute criteria); new articles land in the author's current domain; global articles can be checked out from other domains only with `glide.knowman.allow_edit_global_articles`. A version's domain follows the latest version (updates `kb_version`, `kb_knowledge`, `kb_feedback`, `sys_attachment`). Contains-domains allow authoring by toggling domain scope.
- Known issues: AQI tables not domain separated (and `kb_article_checklist_answer` has no Order field, random order); comments are stored in the article's domain, not the user's. See [[Domain Separation Support Levels by Application]].

## Demo base and tests

- The demo **Knowledge** base has (since Paris) *Any User* in Can Read and *Guest User* in Cannot Read; better to create your own bases.
- **Quick start ATF tests** (suite *KM: Knowledge Management*; need Core, Advanced Installer, Blocks and CSM demo data): KCS article with approval publish, multi-version article, article and base subscriptions, user criteria, KCS article from a case, AQI, requester search and not-helpful feedback task, create/edit from feedback task, pinned article click rank in `ts_query_kb`, ownership group permissions and subscriptions, blocks search, approval retire and publish, feedback to group manager, template selector, make outdated current, related articles and items widgets, versioned article in Agent Workspace, scheduled publish ([[ATF Quick Start Tests by Application]]).
- Subscription email templates (edit in **System Notifications > Email > Notifications**, `admin` or `knowledge_admin`): KM Subscription: Article published, Article revised in KB (base); Article checked out, Article revised, Article commented (article); each links to the user's Notification Preferences.

## Related

- [[Knowledge Management Properties Reference]] · [[Knowledge Management Overview]]
