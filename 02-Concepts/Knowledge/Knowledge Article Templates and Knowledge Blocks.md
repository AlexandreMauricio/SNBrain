---
type: concept
tags: [concept, knowledge, schema, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Exploring > Knowledge article templates, Knowledge blocks; Configuring > Activate knowledge blocks, Enable knowledge blocks for each knowledge base, Configure knowledge article templates (Create an article template, preview text for the standard template, Restrict access to fields, Generate SEO information), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/knowledge-article-templates.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Article Templates and Knowledge Blocks

**In one line:** **article templates** give articles a fixed set of fields (each template is a child table of `kb_knowledge`); **knowledge blocks** are reusable pieces of content, each with its own user criteria, inserted into articles so readers only see the parts meant for them.

From the Brazil docs; not tested. Both come with Knowledge Management Advanced (`com.snc.knowledge_advanced`).

## Article templates

- Structure in `kb_article_template` (with `child_table`), fields in `kb_article_template_definition`.
- Pre-defined (inactive by default except Standard, which cannot be deactivated):

| Template | Fields | Table | SEO tag field |
|---|---|---|---|
| Standard | Text | `kb_knowledge` | Text |
| FAQ | Question, Answer | `kb_template_faq` | Question |
| How To | Introduction, Instructions | `kb_template_how_to` | Introduction |
| What Is | Explanation | `kb_template_what_is` | ? |
| KCS Article | Issue, Environment, Cause, Resolution | `kb_template_kcs_article` | Issue |

- Activate: **Knowledge > Administration > Article Templates**, Active = true. A template shows only if active and linked to the knowledge base (base's **Article Templates** related list; empty list = all templates allowed). Articles from before Kingston use Standard.
- Templates cannot be deleted (each has a child table); deactivate instead.
- **New template** (`knowledge_admin` or `admin` plus `personalize_form`; needs also `com.snc.knowledge_advanced.installer`): name in lowercase ASCII, digits and underscores; **Article Templates Field** related list: field name, type (HTML, String, Integer, Date, Date and time), order, mandatory, expand/collapse, heading style and field style (CSS), preview text. Then add the fields to the Knowledge form layout (Create New, pick the base and template, Configure > Form Layout). Authors see new templates after their next login. For duplicate-article search on the new table set its contextual search **Search context** = *Knowledge ML Search* ([[Contextual Search]]).
- Standard template preview text: copy `setPreviewTextForStandardArticle` from script include `ArticleTemplateUtilSNC` into the override `ArticleTemplateUtil` (server-side script include, global) and return your text.
- **SEO**: template's **SEO Description Tag** = a template field (length from `glide.knowman.seo.pages.meta_description.length`); existing articles need the fix script **Populate Meta Description on KB Articles**.
- **Field-level security** (`security_admin`): encrypt a template column (String, Date, Date/Time, URL) with Field Encryption: module, **System Security > Field Encryption > Encryption Field Configurations** (table e.g. `kb_template_how_to`, single or multiple module method), then set **Encrypted context** on the roles allowed to see it ([[Field Encryption - Modules, Encrypted Fields and Access]]). To hide part of a field instead, use blocks.

## Knowledge blocks

- Plugin `com.snc.knowledge_blocks` (`admin`; activates Knowledge Management Advanced and has demo data). Core UI only (ServiceNow AI Platform), not wiki-type articles; files attached to a block are not shown, but images and text are.
- Per base: **Enable blocks** on the knowledge base (`knowledge_admin` or `knowledge_manager`; add the field to the form if missing). To turn it off later, delete all blocks in that base first.
- Contributors create blocks and insert them; a reader sees a block if they pass the base's and the block's user criteria. Preview an article by user or date.
- Use case from the docs: one holiday-calendar article with one block per location instead of one article per location.
- Custom search or article viewers must call the knowledge blocks API to render them.
- Works with or without article versioning.

### Working with blocks

- **Knowledge > Knowledge Blocks > Create New** (contribute access): number (prefix KBB, e.g. KBB0000101), knowledge base, category, ownership group (if that feature is on), **Can read** / **Cannot read** criteria, **Valid to** (after it the block disappears from articles and its words stop matching searches), short description, text, version (with versioning), article type (always HTML), workflow (Draft, Review, Scheduled for publish, Published, Pending retirement, Retired, Outdated). **Publish** follows the base's publish flow (instant or approval).
- Reading rules: contribute access to the base shows every block; a Cannot read match hides the block whatever Can read says; someone who can read the article but not a block sees the article without it.
- Insert: in an HTML field of the article (any template, several fields allowed) click **Add Blocks**, search (results 6 to 25, `glide.knowman.add_blocks.search_results`), insert, drag to rearrange (keyboard: right arrow selects the block, Ctrl+X / Ctrl+V). Only published blocks in the same base and language show up.
- **Preview Article with Blocks** related link: **View As** a user, and for published articles **View on date**.
- Retire: published block > **Retire** (retire flow applies). Docs say retire only when not used in any article; from Brazil the property `glide.knowman.allow_retire_bloc...` (name cut off) allows retiring a block that is in use, which then vanishes from the article. Delete only if no article, retired article or old version uses it.
- Editing a published block: Edit > **Checkout** (+0.01), Publish (next whole number, e.g. 2.02 → 3.0). Same in **Agent Workspace** (`agent_workspace_user` and `knowledge`; Lists > Knowledge Blocks; approval through the Approvals related list; block page shows read time at 200 words per minute, 500 characters for CJK, plus 12 s for the first image, 11 s the second and so on, 3 s each after the tenth).
- Custom search or viewer (server-side, global script includes): `new KBPortalServiceImpl().getResultData(request)` (from `com.snc.knowledge3`; request with keyword, language, variables such as `kb_knowledge_base`, context from `glide.knowman.sp.search_context`, resource, order, start/end, attachment, knowledge_fields) returns results that include block text the user may read; `new KBBlock().getArticleContent(kbRecord)` (from `com.snc.knowledge_blocks`) returns the article HTML with the readable blocks expanded. Check `GlidePluginManager().isActive('com.snc.knowledge_blocks')` first and fall back to the `text` field.

## Related

- [[Knowledge Bases and Categories]] · [[Knowledge Base Access and User Criteria]] · [[Knowledge Management Overview]]
