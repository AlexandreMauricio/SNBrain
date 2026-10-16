---
type: concept
tags: [concept, ai, service-catalog, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Service Catalog topic blocks in Virtual Agent powered by NLU", "Submit a request topic conversation", "Conversational Catalog Requests", "Conversational catalog item requests", "Catalog Agent for Premium chat", "LLM topic block for Conversational Catalog Requests", "Catalog item request approaches", "Configure Conversational Catalog Requests", "Catalog Agent conversational status conditions", "Catalog Conversational Coverage", "Guidelines for slot filling in catalog request", "Prefill in conversational catalog request", "Request catalog item through Now LLM", "Catalog item form slot-fill", "Service Catalog properties", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/now-assist-in-conversational-catalog-request.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Conversational catalog requests and Virtual Agent

**In one line:** Virtual Agent can take a catalog request as a chat; Brazil offers four paths, tried in order: the **Catalog Agent** (AI agent, Premium chat), the **LLM topic block**, the older **NLU topic block**, and finally the plain form.

## The four paths

| Path | Status | Notes |
|---|---|---|
| **Catalog Agent** | current, preferred for new setups | Otto AI agent in Premium chat; asks one or a few questions at a time, clarifies, branches |
| **LLM topic block** | current | "Request catalog item through Now LLM"; fallback when the Catalog Agent does not support an item; same pre-summary card > questions > summary card flow |
| **NLU topic block** | legacy | Search Catalog Item and Request Catalog Item blocks |
| **Interactive View (form)** | fallback | anything not conversational opens as a form |

Organisations on the LLM block need not migrate; the Catalog Agent takes over items as its coverage grows.

## Catalog Agent eligibility

Not conversational in Premium chat if any of: property `turn_off_nowassist_conversation`; item flagged `make_item_non_conversational`; more questions than `sn_now_assist_cr.og.question_threshold` (default **4**); catalog client scripts or UI policies that change the form; every question hidden, prefilled or read-only; unsupported question types (the page lists check box, Custom, UI Page, Custom with Label, Lookup Select Box, List Collector, Lookup Multiple Choice, Masked, table questions, Requested For, Attachment, Table Name); fields needing advanced filtering; price-affecting questions; MRVS; order guides, wizards, content items, standard change templates. Discrepancy: the same page's table then lists Lookup Multiple Choice, Lookup Select Box and Requested For (Single) as Catalog Agent variable types. Ineligible items still open as forms.

## LLM topic block (Now LLM)

- Install ServiceNow Otto for Virtual Agent (brings ServiceNow Otto in Conversational Catalog Request); role admin or catalog_admin plus flow_designer.
- Per item: **Make the item non-conversational in VA** (opt out) and **Use NLU for conversational requests** (never send this item's data to the LLM; uses the stricter NLU block if possible).
- Experience: contextual prompts, **slot filling** from the search phrase ("Windows VM with 1 TB disk" answers two questions), several answers at once, changing earlier answers, validation, exit at any time. Read-only, prefilled and already-answered questions are skipped.
- Limits: `sn_now_assist_cr.llm.conversational.request.question.limit` (default 500), `sn_now_assist_cr.llm.reference_question_choices.limit` (default 2,000,000 choices), `sn_now_assist_cr.recommend_form_question_threshold` (default 10; above it the chat suggests the form; -1 = never), `sn_now_assist_cr.llm.accept_user_input_as_is` (0-3: whether nonsense or overlong text answers are accepted; default 0).
- Fallback when AI Search finds nothing: live agent, else the record producer from subflow **Fetch generic ticket producer for conversational catalog request** (property `sn_nowassist_va.now.assist.generic.ticket.fallback.record.producer`, default *Create a generic ticket*; or your own subflow in `sn_nowassist_va.now.assist.generic.ticket.fallback.subflow`).
- Topic block inputs `catalog_item_id`, `context_json`, `execute_contextual_search`, `confirm_catalog_item`, `show_end_state_card`; outputs `record_id` (-1 if not conversational or no access), `record_table`, `status`, `variables`, `message`, `used_LLM`.

### Slot-fill quality

Clear, single-concept question labels; distinct names (not "Requested For" and "On behalf of" together); names as object then attribute (`date_required`); human names instead of codes (`laptop_charger`, not `Hardware_001_P04_power`); keep `com.glide.cs.genai.discovery.limits.skill.slots` at its default; check the model on the Conversational Catalog skill in **AI Admin Hub > Skills**. Results are probabilistic. Prefill also uses the requester's profile (department, manager, location...) and earlier chat context. The separate **Catalog item form slot-fill** skill pre-fills portal forms from what the user searched (not for order guides, MRVS, Custom, attachments, containers).

### Coverage dashboard

Plugin `sn_catalog_con_cov` (bundled with the Otto conversational catalog app). **Catalog Administration > Conversational catalog overview** or **Maintain Items > Conversational Overview**, or Catalog Builder dashboard: counts, reasons for non-conversational items, channels in 6 months, per-item **Conversational readiness** (required and recommended actions). Scheduled job **Update catalog items conversational status** every 3 days. Covers the LLM block only, not the Catalog Agent.

## NLU topic blocks (legacy)

- Plugin Service Management Virtual Agent Topic Blocks (`com.glideapp.cs.sm_topic_blocks`) plus Glide Virtual Agent or Lite. Topic **Submit a request** = **Search Catalog Item** (`query_term`, `catalogs`, `result_limit` default 5; returns `catalog_item_id` or -1, `item_type`, `is_conversational`) + **Request Catalog Item** (`catalog_item_id`, `execute_contextual_search`, `confirm_catalog_item`, `show_end_state_card`; returns `record_id`, `record_table`, `variables`).
- Conversational only if: at most `glide.sc.conversational.request.question.limit` questions (default 10); non-scripted UI policies that act from lower to higher order; no client scripts for Mobile / Service Portal; supported types only (single check box, date, date/time, lookups and choice types without pricing or advanced qualifiers, text types, reference with at most `glide.sc.va.reference_question_choices.limit` records (default 7,000), Requested For, Yes/No, containers); single-row sets only; attributes other than `ref_ac_order_by`, `allowed_extensions`, `max_file_size` are ignored; a data lookup whose setter question comes before its matcher breaks it.
- Otherwise rendered as **inline** form (no Custom / UI Page / MRVS and at most `glide.sc.va.inline_render.question.limit` = 20 questions), **pop-up** (more questions), or **window** (Custom or UI Page variables, `glide.sc.va.render_type.legacy` = true, or item types content item, order guide, wizard launcher, standard change template) opening in the portal from `sn_itsm_va.com.snc.itsm.virtualagent.portal_url` (Now Mobile: `mesp`).

## Related

- [[ITSM Virtual Agent Topics and Setup]] · [[AI Authoring for Catalog Builder]] · [[Catalog Variables and Variable Types]] (channel support table) · [[Agentic AI Security and Governance]]
