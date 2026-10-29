---
type: table
tags: [table, schema, knowledge]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management (Create a knowledge article, Article versioning changes, I18N, Components installed with Knowledge Management Core, Knowledge article templates, Knowledge blocks), read 2026-10-29. Column names marked ? are not stated on those pages. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/create-knowledge-article.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# kb_knowledge

**Label:** Knowledge
**What it stores:** knowledge articles; each version and each translation is its own record.
**Extends:** none stated (not a task table)
**Extended by:** every article template table (`kb_template_faq`, `kb_template_how_to`, `kb_template_what_is`, `kb_template_kcs_article`, custom ones) and `kb_knowledge_block`
**Scope:** global

## Key columns

| Label | Name | Type | Reference / choice | Meaning | Confidence |
|---|---|---|---|---|---|
| Number | `number` | string | | KB number, not unique-indexed; shared by all versions | documented |
| Knowledge Base | `kb_knowledge_base` | reference | [[kb_knowledge_base]] | one base per article | documented |
| Category | `kb_category` | reference | `kb_category` | | documented |
| Short description | `short_description` | string | | title | documented |
| Article body | `text` | HTML | | standard template body | documented |
| Wiki | `wiki` | wiki | | body for wiki articles | documented (from `glide.knowman.text.check_can_read`) |
| Workflow | `workflow_state` | choice | | see below | documented (name from KM pages, e.g. subscription property values) |
| Valid to | `valid_to` | date | | expiry | documented (minor edit default) |
| Meta | `meta` | string | | SEO keywords | unverified (name inferred) |
| Source | `source` | reference | task | task it was created from | documented (HR case mapping script) |
| Language, Parent | `language`, `parent`? | choice / reference | | translations | ? |
| Version, Display number, Base Version, Revised by | `version`?, ?, ?, ? | | | versioning fields | ? |
| Ownership Group, Confidence, Governance, Article type, Attachment link, Display attachments, Scheduled publish date, Can Read, Cannot Read, View count (`sys_view_count`) | ? | | | feature fields | label documented, name ? |

## Choice values (Workflow)

`draft` = Draft, `review` = Review, `published` = Published, `outdated` = Outdated (value must stay `outdated`), plus Scheduled for publish, Pending retirement, Retired (values not stated). Brazil docs; not seen in an instance.

## Relations

- Related articles `kb_2_kb`, catalog items `kb_2_sc`, products `m2m_kb_ci`, tasks `m2m_kb_task`, keywords `kb_knowledge_keyword`, feedback `kb_feedback`, `kb_feedback_task`, use `kb_use`, versions `kb_version`, translations `kb_translation_task`.

## Useful queries

```text
workflow_state=published^valid_to>javascript:gs.daysAgoStart(0)
```
List filter (reads only): published and not expired.

See [[Knowledge Management Roles, Tables and Plugins]], [[Create and Edit Knowledge Articles]].
