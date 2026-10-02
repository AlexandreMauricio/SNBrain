---
type: concept
tags: [concept, platform, integrations, service-catalog, knowledge]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Dynamic Translation" (pp. 2155-2203), "Localization Framework" (pp. 2204-2261), "Localization Workspace" (pp. 2262-2316), read 2026-10-01 at summary depth (overviews, workflows, roles and key procedures; the per-screen field tables and error-message lists were not transcribed)
sn-release: Australia
verified:
updated: 2026-10-01
---

# Localization Framework, Localization Workspace and Dynamic Translation

**In one line:** three layers on top of the translation tables: **Dynamic Translation** machine-translates user-typed text on demand, **Localization Framework** runs translation of content (catalog items, knowledge, Virtual Agent topics) as tasks with approvals, and **Localization Workspace** is the request-and-track front end for it.

For the static UI text and the tables behind it see [[Languages, Translation Tables and Locale]].

## Dynamic Translation

- Plugin `com.glide.dynamic_translation`. Needs a subscription tier that includes it and at least one language plugin.
- Translation is done by an **external machine translation provider** through a spoke: Microsoft Azure Translator and Google Cloud Translation are partly preconfigured; any other can be added with custom detect and translate subflows. Configurations in `sn_dt_translator_configuration`; one must be default for **detection** and one for **translation**. Text leaves the instance: check the provider's privacy terms and test in sub-production.
- Where it shows:
  - **form fields**: add dictionary attribute **Dynamic Translation Enabled** = true on the field (String, Multi-line, Wide text, HTML). A translate icon appears next to the field; the user toggles original/translated;
  - **activity streams** (comments, work notes): tables listed in an allow-list property;
  - **Agent Chat** (each side sees their own language), Virtual Agent, knowledge articles with the Localization Framework.
- Nothing is stored translated: it is a display-time translation into the user's language.
- Provider limits: Google about 5,000 characters recommended per request; Microsoft 50,000.
- **Exclusion Framework** (on by default, property `sn_dt.dynamic_framework.enable_exclusion_framework`): rules in `sn_dt_exclusion_rules` (exact match such as product names, or pattern match such as record numbers) that shield text from translation; provider tags in `sn_dt_provider_exclusion_pattern`. A **Test Exclusion Rule** page tries a rule against sample text.
- Language codes that differ between ServiceNow and the provider need a language code mapping.

## Localization Framework

Plugin Localization Framework Installer (`com.glide.localization_framework.installer`), activated with language plugins. No domain separation support.

- **Artifact** = a type of translatable content: catalog items, surveys and NLU models out of the box; Virtual Agent topics, knowledge articles (property `glide.knowman.translation.enable_lf_article_translation`), HR document templates, and email notifications/templates/layouts (plugin `com.glide.notification.translation`) with their plugins. Custom artifacts are possible (`sn_lf_config`).
- Requesting a translation of an item into a language creates a **localization requested item** (LRITM, `sn_lf_requested_item`) and **localization tasks** (`sn_lf_task`); items can be bundled into **projects** (`sn_lf_project`).
- **Settings** (`sn_lf_setting`) per artifact and language choose the workflow, combining: optional **business approval**, **translation** (manual, machine via Dynamic Translation, or sent to a translation management system, TMS, such as RWS or XTM, or by email/export-import), optional **translation approval**, then **publish** (manual or automatic).
- Fulfillers work in a side-by-side comparison screen: source text, target text, machine translate, save draft, publish.
- **Insights** dashboard shows how much of each artifact is translated per language.
- Roles: `localization_admin` > `localization_manager`, `localization_editor`, `localization_fulfiller`, `localization_requestor`.

## Localization Workspace

A workspace for content owners (roles `sn_lw.user`, `sn_lw.terminology_manager`): a wizard to request translation of several content types into several languages with a chosen provider, with an informational cost estimate; it finds untranslated or partly translated content automatically and creates Localization Framework projects. Source must be English in this release. Request states: Draft, Submitted, In progress, Complete, Closed: Project Incomplete. **Language Asset Management** stores glossaries (uploaded from a spreadsheet template; storage and editing only in Australia).

## Which to use

| Need | Use |
|---|---|
| An agent must read a comment written in another language | Dynamic Translation on the activity stream |
| A few custom labels and choices | translate by hand: [[Translate a Field Label and a Choice]] |
| The whole service catalog or knowledge base in three languages, with review | Localization Framework (with or without machine translation) |
| Business owners ordering translations themselves | Localization Workspace |

## Related

- [[Dictionary Attributes Reference]] · [[Languages, Translation Tables and Locale]]
