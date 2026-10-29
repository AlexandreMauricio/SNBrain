---
type: reference
tags: [reference, knowledge, admin, scripting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Configuring > View knowledge logs (Search Log fields, View Log fields, View the source of a knowledge article search, Modify the data retention policy for View logs), Duplicate knowledge article numbers, Create a custom knowledge homepage, Use extension points for Knowledge Management, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/view-knowledge-logs.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Logs, Numbering and Extension Points

From the Brazil docs; not tested. Admin odds and ends for [[Knowledge Management Overview]].

## Logs (`knowledge_admin`, `knowledge_manager`)

| Log | Table | Holds |
|---|---|---|
| **Search Log** (Knowledge > Administration > Search Log) | Knowledge Searches `ts_query_kb` | search term, results count, user, sort order, **Final Search Term**, **Highest Click Rank** (lower = better), session; source: **Source Doc**, source table (e.g. `kb_knowledge`, `sp_portal`, `incident`, `sn_customerservice_case`, `kb_template_kcs_article`), **Source Type** (Portal, Classic, Workspace, Knowledge Classic, Other), Source URL. **Zing only, not AI Search** |
| **View Log** | Knowledge Use `kb_use` | created, article, user, **Used** (attached to a task), **Viewed**, Search Id (→ `ts_query_kb`), session, Times Viewed. Not filled for articles opened from global search |

Sources covered: Customer Service Portal, Service Portal, Now Mobile, Agent Workspace, KM v3.

Retention for `kb_use`: kept forever by default; enable its **Table Cleanup** (Auto Flush) record, default age 31,536,000 s (365 days), larger than `glide.knowman.view_age.days`. The page gives the menu as **Instance Scan > Table Cleanup** (the usage-metrics page says **System Maintenance > Table Cleanup**; unconfirmed which) and once calls the job "kb_user". Deleted rows disappear from Self-Service Analytics and KM dashboards. See [[Table Cleaner]].

## Article numbers

- **Number** on `kb_knowledge` starts at 10,000 (KB0010000); change in **System Definition > Number Maintenance** > Knowledge > **Number Counter**.
- The number is **not uniquely indexed**: importing articles (other instance, demo data) can create duplicates, and links like `kb_view.do?sysparm_article=KB0000033` then open either one at random. Avoid demo data in production, check numbers before import, add a before-insert business rule on `kb_knowledge` rejecting used numbers, or raise the counter above the highest number. (A unique index on Number also makes the KM Advanced installer fail; see [[Knowledge Management Overview]].)

## Custom KM v3 homepage module

Legacy v3 homepage (prefer the portal): module with link type **URL (from Arguments)** and arguments `$knowledge.do#/search?sysparm_kb=<kb sys_id>&sysparm_category=<category sys_id>&sysparm_order=<view_count|last_modified|relevancy>` (category must belong to that base; unknown values fall back to defaults).

## Extension points

- **UI extension points** (System Extension Points > UI Extension Points > Create Implementation; one implementation per scenario): `KMArticleViewHeader`, `KMArticleViewFooter` (header and footer on KM v3 `kb_view.do`), `KMFeedbackNotification` (email template when an article is commented; needs Knowledge Management Advanced).
- **Scripted extension point** `global.KMFeedbackObject` with base implementation `KMFeedbackObjectBaseImpl` (server-side, global): the feedback object used in that email; add fields there.

## Related

- [[Knowledge Portal and Search]] · [[Knowledge Base Access and User Criteria]]
