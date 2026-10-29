---
type: reference
tags: [reference, knowledge, instance-admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Reference > Knowledge Management properties (portal, search, article view, homepage, other, article versioning, subscription, AQI, external content integration, actionable feedback, group ownership), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/r_KnowledgeProperties.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Management Properties Reference

Most are on **Knowledge > Administration > Properties**; some exist only in `sys_properties` (add them if missing). From the Brazil docs; not tested. Defaults are as the page states them; several groups apply only to the legacy KM v2 portal and are listed briefly.

## Portal (legacy pages)

- KM v2 only: `glide.knowman.columns`, `glide.knowman.content_block_limit`, `glide.knowman.show_only_populated`, `glide.knowman.show_descriptions`, `glide.knowman.section_limit`, `glide.knowman.section_sort` (Published, View count, Alphabetically), `glide.knowman.section_sort_direction`, `glide.knowman.home_titlesonly`, `glide.knowman.portal_search_focus`, `glide.knowman.frameless_logo`.
- `glide.knowman.show_unpublished` plus `glide.knowman.section.view_roles.review`, `.draft`, `.stagesAndRoles` (`state:[roles];`): roles that see unpublished articles in portal lists and search. Retired: only `knowledge_admin`.
- `glide.knowman.search.articles_per_page` (KM v3 lazy loading).
- `glide.knowman.view_age.days` (default 30; 0 = all views, job off): **deprecated since Vancouver**, set to 0; scheduled job **Count Knowledge Use** (absent for new customers since Paris).
- `glide.knowman.use_session_cache_for_most_useful_articles` (true).
- `glide.knowman.serviceportal.seo_portals` (portal sys_ids for SEO indexing; empty = all; listing one turns on SEO suggestions while authoring), `glide.knowman.serviceportal.use_numbered_url.portals` (use `sysparm_number` instead of `sys_kb_id` in widget links), `glide.knowman.serviceportal.seo_user_agent` (crawler patterns).
- `glide.knowman.enable_view_as_user` (false): search and view as another user.

## Search (Zing only; AI Search has its own configuration)

| Property | Meaning |
|---|---|
| `glide.knowman.order.search` | Number of Views, Relevancy, Last Modified (KM app search, not global search) |
| `glide.knowman.search.operator` | OR, or AND then OR |
| `glide.knowman.search.show_author` / `show_last_modified` / `show_published` / `show_category` / `show_view_count` / `show_relevancy` (only with Relevancy order) / `show_knowledgebase` / `show_rating` / `show_article_number` | what results show; with versioning, author shows as Authored by (≤ 1.0) or Revised by |
| `glide.knowman.search.attachment` | Do not show / Show only link (default since San Diego) / Show with text snippet (older default; slowest) |
| `glide.knowman.add_blocks.search_results` | 6-25 |
| `glide.knowman.search.instant_results` | default No |
| `glide.knowman.search.default_language` | e.g. `en`, `fr`, `es`, `it`, `de`; overridden by multi-language search |
| `glide.knowman.enable_multi_language_search` | true = search several languages |
| `glide.knowman.blocks.enable` | false = no new blocks or insertions, Enable blocks greyed out, existing blocks still shown |
| `glide.knowman.search.facet_depth` | 300 |
| `glide.knowman.search.apply_acls` | apply knowledge ACLs to results |

## Article view

`glide.knowman.recent_tasks.display`, `glide.knowman.recent_tasks` (Most Recent Tasks); `glide.knowman.show_rating_options` (+ `.roles`) as master switch for the rating section, then `glide.knowman.show_yn_rating`, `glide.knowman.show_star_rating`, `glide.knowman.show_flag` each with `.roles` (roles must also be in the master list); `glide.knowman.create_incident_link.display`, `glide.knowman.create_incident_link`; `glide.knowman.show_user_feedback` (When article loads / When user clicks link / Never) + `.roles`; `glide.knowman.feedback.display_threshold`; `glide.knowman.use_live_feed`; `glide.knowman.max_comments_per_user_daily` (empty = unlimited).

## Homepage

`glide.knowman.show_number_on_homepage`, `glide.knowman.default_keyword` (Featured content keyword), `glide.knowman.show_number_on_categories`, `glide.knowman.show_home_if_one_kb`, `glide.knowman.default_pinned_section_header_title`.

## Other

| Property | Meaning |
|---|---|
| `glide.knowman.attach.fields` | field that gets number and content when **Attach to Task** is used (journal field, dot-walk allowed; empty = `comments`) |
| `glide.knowman.contextual_search.show_read_only_article` | read-only article view from contextual search (on by default; add if missing) |
| `glide.knowman.import.hide_import_functionality`, `glide.knowman.import.show_publish_checkbox` (yes), `glide.knowman.import.max_document_size` (30 MB recommended) | Word import |
| `glide.knowman.submission.workflow`, `glide.knowman.task_kb` | knowledge from incidents/problems |
| `glide.knowman.text.check_can_read` | check field ACLs on `kb_knowledge.text` / `kb_knowledge.wiki` before previews |
| `glide.knowman.enable_approval_notification` | approval emails (on) |
| `glide.knowman.allow_edit_global_articles` | non-global domain users may check out global articles |
| `glide.knowman.list.filter` | filter invisible articles before building `kb_list` (slow on big bases) |
| `glide.knowman.translation.enable_translation_task` | translation tasks (locks the base of existing articles) |
| `glide.knowman.block_access_with_no_user_criteria`, `glide.knowman.apply_article_read_criteria` | see [[Knowledge Base Access and User Criteria]] |
| `glide.knowman.enable_article_expiry_notification` | monthly expiry email |
| `glide.knowman.usage_metrics_duration` | 60 |
| `glide.knowman.enable_article_replacement_on_retire` | true (another page says existing/upgraded instances must set it to true by hand; unconfirmed) |
| `glide.knowman.allow_retire_block` | retire blocks still used in articles (with a warning pop-up) |
| `sn_km_word.glide.knowman.word.xframe`, `sn_km_word.glide.knowman.enable_document_download` | [[Knowledge Management Add-in for Microsoft Word]] |

## Feature groups

- **Versioning**: `glide.knowman.versioning.enabled`; `glide.knowman.versioning.enable_minor_edits` (owner, admin or manager may edit published articles without a new version); `glide.knowman.versioning.minor_edit_fields` (default `valid_to`; `attachments` allows attachment changes).
- **Subscriptions**: `glide.knowman.enable_km_subscription`, `.roles` (default `knowledge`), `.workflow_state` (default `draft,review,published`).
- **AQI**: `glide.knowman.aqi_pass_score` (70, 1-100), `glide.knowman.aqi.article_workflow_states`.
- **External content** (scope `sn_km_intg`): `max_content_size` (2 GB, read-only), `max_article_size` (8 MB, read-only), `allow_content_types` (Office types etc.; also `application/xml`, `video/mp4`, `audio/mpeg`), `reject_content_types` (read-only, wins; octet-stream, disk images, executables), `ui_label_for_external_content` ("External Content"); full names `sn_km_intg.glide.knowman.external.<name>`. These differ from the per-source parameters (400 MB, 4000 KB) in [[Knowledge External Content Integration]].
- **Actionable feedback**: `glide.knowman.feedback.enable_actionable_feedback_for_flag`, `..._for_helpful`, `..._for_rating` (threshold 1-5, 0 = off), `glide.knowman.feedback.enable_explicit_feedback` (only when details given; no task if the dialog is closed or "Other" has no reason).
- **Ownership groups**: `glide.knowman.ownership_group.enabled`, `.override`, `.allow_self_approval` (see the name variant in [[Knowledge Feedback, Ownership Groups and Article Quality]]).
- **Knowledge Center** (`sn_km_center.*`, `sn_km_gen_ai.*`): see [[Knowledge Center]] and [[Knowledge Center Article Optimization and Health Score]].
- Other properties met elsewhere: `glide.knowman.serviceportal.enable_redirect`, `sn_km_portal.glide.knowman.serviceportal.portal_url`, `glide.knowman.sp.search_context`, `glide.knowman.seo.pages.meta_description.length`, `glide.knowman.ownership_group.enable_self_approval` (variant), `glide.knowman.search.apply_role_based_security` (add it).

## Related

- [[Knowledge Management Overview]] · [[Knowledge Portal and Search]]
