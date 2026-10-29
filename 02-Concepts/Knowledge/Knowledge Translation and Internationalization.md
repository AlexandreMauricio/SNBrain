---
type: concept
tags: [concept, knowledge, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Exploring > I18N - Knowledge internationalization, Translation management; Configuring > Activate the knowledge management internationalization plugin, Configure translation management (Activate translation management, Add a custom Localization Framework setting to enable bulk translations, ... to enable machine translation), Enable languages for a knowledge base, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/c_I18NKMInternational.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Translation and Internationalization

**In one line:** each translation is its own `kb_knowledge` record with a **Language** and a **Parent** (the base-language article); **translation management** creates translation tasks for missing languages, and from Brazil bulk and machine translation run through the **Localization Framework**.

From the Brazil docs; not tested. Platform side: [[Languages, Translation Tables and Locale]], [[Localization Framework, Workspace and Dynamic Translation]].

## Plugins and fields

- **I18N: Knowledge Management Internationalization Plugin v2** (`com.glideapp.knowledge.i18n2`): since San Diego installed with any language plugin (earlier with `com.glide.i18n`). Adds fields **Language** and **Parent** on `kb_knowledge`, the **Translated Versions** related list (articles with the same parent), business rule **knowledge query** (filters portal and search by the user's language) and UI macro **kb languages**.
- Translation management also needs Knowledge Management Advanced (`com.snc.knowledge_advanced`) and the language plugins.
- Custom languages: add `sys_choice` entries for the article language list (San Diego onward, elevated privileges); custom `sys_language` combinations (IETF BCP-47) by request to ServiceNow.
- **Per base languages**: knowledge base **Languages** field (unlock; add to the form if missing; `knowledge_admin` or `admin`). Authors can only write in those; a language is removable only when no article uses it.

## Search language

- `glide.knowman.search.default_language`: default search language other than the login language (unset = login language).
- Multi-language search: **Knowledge > Administration > Knowledge Search Properties > Enable multi language search**; see [[Knowledge Portal and Search]]. The page's wording ties multi-language search to the default-language property being enabled, which reads inconsistently (unconfirmed).

## Translation tasks (classic translation management)

- `glide.knowman.translation.enable_translation_task` = true adds **Knowledge > Translation Management**: All Open Tasks, My Assigned Tasks, Translator Mapping.
- Assignment rules per language, knowledge base or category to a translator or group; translate missing languages by hand or machine.
- Knowledge base option **Auto-create translation tasks** (translation tasks for configured languages after each publish).

### Working translation tasks

- **Translator Mapping** (`knowledge_admin` or `admin`): assignment rules on **Knowledge Translation Task** (`kb_translation_task`), e.g. condition *Translated language is English*, Assign To a user or group, optional script; only applies to unassigned tasks; assignee gets an email with links.
- **My Assigned Tasks** > task > **Translate** (needs Dynamic Translation `com.glide.dynamic_translation` and the task property; `admin`, `knowledge_admin` or `knowledge`): side-by-side panes, **Machine translate**, **Create draft article** (overwrites an existing draft translation), **Publish**. Translated versions always start at **v1.0**. The page says this route is superseded by the Localization Framework.
- Articles containing untranslated **blocks**: translate the blocks first (link in the message; results in **Translated Block Versions**; role `translator`).
- **Request translations** related link on a published article creates tasks for languages that have none.

## Bulk and machine translation (Localization Framework)

Base system in Brazil. Upgrades must set: `glide.knowman.translation.enable_lf_article_translation` = true, `glide.knowman.translation.enable_translation_task` = false, and `glide.knowman.translation.enable_localization_framework` (value not stated on the page, presumably true; unconfirmed).

**Localization Framework > Settings > New**: artifact **Knowledge**, target languages; *Workflow Preferences* **Translation -> Publish**; *Project Preferences* **Enable projects** (manual) and **Enable auto creation** (selected LRITMs bundled in one project). Machine translation: *Translation Preferences* **Enable machine translate**, a **Translator**, workflow **Auto Translation > Auto Publish**, and a **Localization manager group** (group with `localization_manager`; field appears only with projects and auto creation on).

### Bulk translation in use

- Up to **200** articles per request. Validations: language allowed in the base, blocks translated into the target, source not Retired or Outdated, source language differs, source is not itself a translation, fewer than 200 selected. The **Knowledge** artifact is in Artifact Configurations (`sn_lf_config`), active by default.
- Request (localization requester): **Knowledge > Articles**, select, **Request Translations**, pick languages, Submit → localization tasks per item and language.
- Translate (localization fulfiller): **Knowledge > Knowledge Translations > My translation request**, open a localization task, **Translate**: source/target columns (Expand all, Collapse all, Show groups with missing translations), copy and translate, **Publish Translation**. With machine translation set up, Dynamic Translation fills it automatically. Results are new `kb_knowledge` records at version **0.01** (versus v1.0 from the classic task route).

## Example

Base **Example HR Knowledge** with Languages English and Portuguese (Brazil); article *Example Leave Policy* in English is the Parent of its Portuguese translation; setting **Example KB Translation** (artifact Knowledge, target pt-BR, Translation -> Publish, Enable projects).

## Related

- [[Knowledge Management Overview]] · [[Knowledge Bases and Categories]]
