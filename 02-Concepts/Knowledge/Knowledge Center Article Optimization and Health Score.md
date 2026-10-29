---
type: concept
tags: [concept, knowledge, ai, scripting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > Knowledge Center (Knowledge Center Article Optimization, Knowledge Health Score, Article health score, Health score configuration, Enable system properties for Knowledge Center, Configure Article Optimization jobs, Configure custom script based scans for Article Optimization, Enable article health score calculation, Configure knowledge health score, Configure stale and expiring articles notification settings, View article optimization analysis, Article optimization with article length scan, Review and optimize articles with Article Optimization, Article Optimization with Reading Ease scan, Auto-fix article optimization findings, Merge and publish potential duplicate articles, Review stale and expiring articles, View the Knowledge Health Score dashboard, Review and fix article health scores), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-center-article-optimization.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Center Article Optimization and Health Score

**In one line:** **Article Optimization (AO)** runs scheduled and on-save **scans** (script-based or Otto-based) over articles and shows findings as cards; scan results roll up into an **article health score** (0-100), then a knowledge base score and an instance score; some findings can be **auto-fixed** and duplicate groups **auto-merged**, with a revert window.

From the Brazil docs; not tested. Home and editor: [[Knowledge Center]]. AI skill setup: [[Otto in Knowledge Management]].

## Properties

| Property | Meaning |
|---|---|
| `sn_km_center.ao_auto_update.enabled` | auto-fix of eligible multiple-H1 and title relevancy findings (active by default) |
| `sn_km_gen_ai.auto_merge.enabled` | auto-merge of potential duplicates; off = old duplicate view. The merge page spells it `sn_km_gen_ai.auto_merge.enable` (unconfirmed variants) |
| `sn_km_gen_ai.auto_merge.revert_ttl_days` | revert window for auto-merged and auto-updated content (properties page). The auto-fix page names `sn_km_gen_ai.ai_operation.revert_ttl_days`, default 5 days (unconfirmed variants) |
| `sn_km_gen_ai.auto_merge.confidence_threshold` | minimum confidence (%) for automatic merge; lower goes to manual review |
| `sn_km_center.kb_health_score.enabled` | calculate article health scores (UI: **Knowledge > Administration > Properties** > Knowledge Center Properties > *Enable Article Health Score calculation*) |
| `sn_km_center.reading_ease.minimum_score` | reading ease below which AO flags an article (the scan page says 60) |
| `sn_km_center.stale_article_threshold_days` | days after publishing / last update before "stale" (30-365; default 365 per the review page) |
| `sn_km_center.expiring_article_threshold_days` | days before Valid to for "expiring" (5-365; default appears to be 30, cut off on the page) |

Stale / expiring thresholds can also be set from **Knowledge Center > Configurations > Knowledge management properties** > Article Optimization Properties (`knowledge_admin`); they apply only when the script-based AO jobs next run.

## Jobs and scans

- **Jobs** (**Knowledge > Knowledge Center > Lists > Article Optimization > Jobs**, table `sysauto_kb_assist_job`): Query table (Knowledge or another article table), Query conditions, Run schedule with Time zone and Time (stagger jobs to avoid load), related list **Article Assist Scans**. Copy with **Insert and stay**.
- **Scans** (**... > Article Optimization > Scans**, table `kb_assist_scan_definition`):
  - **Run type**: *On change* (runs on each article save, still needs to be in a job) or *Always* (on the job schedule).
  - **Execution type**: *Script Based* (Script field; copy an existing scan, as the result format is fixed) or *Now Assist skill* (pick the prompt by name, check with Preview which version is active; **Process Inputs** and **Process Outputs** scripts send data to the Now LLM Service and build the finding record shown on the card). AI scans need an Otto subscription; without it only script scans run. Scripts run server-side; scope presumably `sn_km_center` (not stated).
- Script scans include heading tags, image alt attributes, bad links, stale / expiring, **article length** (non-AI: under 300 words = too short for SEO; over 10,000 = too long for AI Search indexing; the page says 10,000 AI tokens in one place and 10,000 words in another, unconfirmed); the length card is information only and disappears once fixed and saved.
- **Reading Ease** scan (Otto prompt): Flesch-Kincaid reading ease below 60 → card *Article too complex for audience* with up to three rewrites (shorter sentences, active voice): **Update** / **Ignore** each or **Review all** / **Ignore all**; saving re-runs the scan.
- Card actions in the editor or the AO view (**Insights > Article optimization > View top issues**): **Ignore**, **Review**, **Checkout** (new version), suggested fixes (e.g. *Add alt attribute*, Otto subscribers only), then Save and Publish.
- **Stale / expiring / expired**: stale = not updated for the threshold; expiring = near Valid to; expired = past Valid to (retire or delete). Act by Checkout and update, extend **Valid to**, or **Retire** / **Delete** (roles `knowledge_manager`, `knowledge_admin` or `knowledge`).

## Auto-fix

`knowledge_manager` or `knowledge_admin`; needs the AO skill, `sn_km_center.ao_auto_update.enabled`, and the per-base flag **Enable automatic updating and publishing of articles from AO findings**. Only **Multiple H1 tags** (scripted fix) and **Title relevancy** (AI with confidence score) support it (another line says the AI image alt tag scan too, by confidence; unconfirmed). Dashboard **View top issues** > base > summary cards (issues, articles with issues, ready to auto-fix, needing review) > scan card > **Auto-fix** (all, selected or one) or **Ignore articles**. Each fix creates a new version and publishes it through the base's publish flow. **History** tab: revert within the window (5 days by default) back to the previous version; not possible if you republished it by hand.

## Merge and publish duplicates

`knowledge_manager` or `knowledge_admin`; skills **Identify duplicate articles** and **Merge (duplicate) articles**; per-base flag **Enable automatic merging and publishing of duplicate articles**. For each AI **topic** an LLM gives a recommendation (new article or update one), a confidence score and a rationale.

| Status | When | Action |
|---|---|---|
| Ready for (to) publish | confidence above threshold, flag on | **Merge & publish** in bulk |
| Ready to merge | above threshold, flag off | **Review draft**, publish by hand |
| Needs review | low confidence, blocks or media, or articles from different bases | merge by hand (score may show 0) |

**Dismiss** (confirm Ignore) removes the topic; it can come back on a later run. Reverting restores updated articles and deletes a newly created one. Manual merge rules (from the Otto merge page): 2-5 articles, same topic, Draft / In Review / Published, English only, same scope, no knowledge blocks. On publish, source drafts expire (Valid to = publish date) and published sources are retired, and also replaced when `glide.knowman.enable_article_replacement_on_retire` is true; source owners are notified; sources show as *Merged to new* and the new article lists **Source Articles**.

## Health score

Needs `sn_km_center.kb_health_score.enabled` and the **Article Optimization Recommendations** skill.

- **Article health score** = 80% **Article Optimization score** + 20% **Duplicate score** (default ratio, configurable).
- AO score = weighted sum of seven parameters, each scored 0-100: **Image alt tags**, **Multiple H1 tags**, **Bad links** (e.g. 6 good of 10 links → 60), **Stale and expiring**, **Article length**, **Title relevancy**, **Article readability**. The page's example weights include 0.14 for alt tags and 0.15 for H1 (the rest of the weight column is cut off) and totals 74.1; with a duplicate score of 50 the article scores 0.8 × 74.1 + 0.2 × 50 ≈ 69.
- **Knowledge base health** = average of its articles; **aggregated score** (gauge on the Knowledge Center home) = average of the bases. Improving one article raises both.
- **Knowledge Base health view** (**View Knowledge Base Health**): filter by base; **Needs Attention** (gauge plus "top six" issue cards, one per parameter, although seven parameters exist; and a duplicates card with **Review Duplicates**); list of bases (owner, score); list of articles (views, score). Saving an article re-runs all scans and updates the score.
- **Health score configuration** (`knowledge_admin`, `knowledge_manager`; **Knowledge Center > Configurations > Health score configuration > Configuration steps**): Overview, Default configuration (read-only weights and linked bases), Custom configuration: **Clone configuration** (source, name, description, **Link KBs**), set article and base weights so each level sums to 100% (red total otherwise), Save.

## Example

A knowledge manager for **Example Knowledge Base** lowers `sn_km_center.stale_article_threshold_days` to 180, links the base to a cloned health configuration *Example Health Weights* giving Bad links more weight, then uses **Auto-fix** on Multiple H1 tags findings and reverts one run from History within five days.

## Related

- [[Knowledge Feedback, Ownership Groups and Article Quality]] (AQI, the older quality checklist) · [[Knowledge Workflows and Article Lifecycle]] · [[Knowledge Management Properties Reference]]
