---
type: concept
tags: [concept, admin, reporting, ai]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Service Administration > Assessments and Surveys > Surveys (Survey responses and results, View results for all surveys / one survey, View a survey scorecard and its views, Export scorecard as image, Request / Edit translations for surveys, Survey responses in a database view, View survey reports, Sentiment analysis for surveys and subtopics, Legacy survey migration and subtopics; Surveys reference: Survey Overview dashboard, Metric Result form, Normalized value for an assessment, Domain separation in Surveys), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/c_SurveyResults.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Survey Results, Scorecards and Sentiment Analysis

**In one line:** each answer is a **Metric Result** (`asmt_metric_result`), rolled up into **category results** (`asmt_category_result`) and shown on **scorecards**; text answers can be scored for sentiment by an external API.

From the Brazil docs; not tested. Building and sending: [[Surveys Overview and Survey Designer]], [[Survey Distribution, Triggers and Channels]].

## Where results are

- **Survey > Survey Responses** (`survey_admin` or `survey_reader`; not *Legacy Surveys > Survey Responses*), or a definition's **View Responses** (grouped by metric = question).
- Category results: **Assessments > Results > Category results**, filter [Type.Evaluation method] [is] [Survey].
- **Survey > Overview** dashboard (`survey_admin`, `survey_reader`, `admin`): customer satisfaction by assignment group (90-day average), service desk survey questions over 60 / 90 days, surveys by metric type and state.
- **View Responses in Rows** (database view, one row per instance, columns = questions; Export from the context menu): only up to five active metrics, at least one response and at most 100 K responses; ranking and multiple choice give several rows; changes to the survey fire `survey.results_view.updated` ([[Database Views]]).

## Metric Result fields

Assessment group (all instances created in one go), Metric, Data type, Method (always Assessment), Source (survey definition), Assigned to, Instance, **Actual value** (Checkbox and Yes/No 0 or 1; Choice / Likert / Template = the option Value; Date, Date/Time, String = -1, not scored), **Normalized value**, String value.

**Normalized value** = (input − min) / (max − min) × (metric weight × bias / sum of metric weights in the category) × scale factor, inverted (1 − value) when the scale definition is Low. Bias = total metric weight / valid metric weight (skipped and scripted metrics excluded). String, Date, Date/Time, Reference, Attachment and Ranking are left out. Docs example: (3 − 1) / (6 − 1) × (10 / 50) × 10 = 0.8. Multiple selection uses per-choice normalisation inputs. Risk assessments use weighted value = metric weight × actual value.

## Scorecards

**View Scorecard** (only when results exist; recalculated on view): **Question Results** (pie for scored types, list for String, Attachment, Date, Date/Time, Reference ...), **Category Results** (stacked bars by respondent count), **Average Ratings** (weighted average per question), **History** (trailing 12 months vs the three previous years, or the current vs four previous quarters; red = worse, green = better), **Sentiment Analysis Results**. Export as PNG or JPEG (`admin` or `survey_admin`).

**NPS** on Template questions: 9-10 promoter, 7-8 passive, 0-6 detractor; NPS = % promoters − % detractors; stored per year, quarter and month in `asmt_nps_result`.

For meaningful scores set the **Scale definition** right (e.g. options Good = 1, Neutral = 3, Bad = 5 need scale Low for Good to score best).

## Sentiment analysis

- Plugin **Sentiment Analysis** (`com.snc.sentiment_analysis`); per survey **Allow Sentiment Analysis**, per String question the sentiment flag; responses go to a third-party service. Results: **Survey > Question Sentiment Results** (green positive, red negative, blue neutral). Labels: −1 to 0 negative, 0 neutral, 0 to 1 positive.
- Connector (`admin`, scope *Sentiment Analysis*): **Sentiment Analysis > Sentiment Connector Configurations** (placeholders for Google, IBM Watson, MS Azure): Name, Active, **Credential Alias** (`sys_alias_list`: connection URL and API key or basic credentials from the vendor), Default, Script. Timeout property `sn_nlp_sentiment.glide.sentiment.transaction.timeout` (ms).
- Azure text analytics v2 is deprecated; with v3 the score = 1 × positive + 0.5 × neutral + 0.01 × negative. The page says this ranges from −1 to 1, although with confidences summing to 1 it can only lie between 0.01 and 1 (unconfirmed; how labels then map is unclear).
- **Retry Sentiment Analysis** on a definition or instance resends instances without results.

## Translation

**Request Translations** (list action, `localization_requestor`) creates Localization Framework requested items; **Edit Translations** (`localization_editor`, plugin `com.glide.localization_framework.installer`): manual, machine translation, export / import files, **Publish Translations** ([[Localization Framework, Workspace and Dynamic Translation]]).

## Legacy survey migration

- Legacy plugins (inactive, on request): `com.snc.bestpractice.task_survey`, `com.glideapp.survey`, `com.snc.assessment`, `com.glideapp.survey_wizard`. Legacy modules exist only on upgraded instances. Survey wizards cannot be migrated.
- **Survey > Legacy Surveys > Masters** > **Migrate to New Survey Management** (consider lifting the transaction quota for big surveys). Mapping: `survey_master` → `asmt_metric_type` (+ assessable record and category), `survey_question_new` → `asmt_metric`, `question_choice` → `asmt_metric_definition`, `survey_instance` → `asmt_assessment` + `asmt_assessment_instance`, `survey_response` → `asmt_assessment_instance_question` + `asmt_metric_result` (+ category result). Originals stay.
- After migrating: people who took it become survey users (remove them to open it to all), deactivate legacy survey conditions and create trigger conditions, check scale definitions (choice values are set 1, 2, 3 by legacy Order, so "Excellent" may become the worst score). Types not migrated: Break, HTML, Label, List Collector, Lookup types, Macro, UI Page (mapping partly cut off on the page).

## Domain separation (Basic)

`survey_admin` creates surveys in their domain (global admins in any). Users take surveys in their domain and global (global users: any). A user can assign a domain's survey only to users of that domain or global. Trigger conditions (`asmt_condition` has no domain path) are visible across domains. See [[Domain Separation Support Levels by Application]].

## Related

- [[Assessments]] · [[Assessments and Surveys Tables, Roles and Plugins]] · [[Benchmarks]]
