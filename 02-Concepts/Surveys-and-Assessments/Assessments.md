---
type: concept
tags: [concept, admin, reporting, scripting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Service Administration > Assessments and Surveys > Assessments (landing, Using assessments, Assessment administrator tasks, Configure an assessment, Assessment generation, Assessment groups, View an assessment metric category, Metric categories and assessable record associations, Assessment metrics and metric definitions, Metric types and assessable records, Delete a metric type, Export / Import, Signatures, Question bank, Copy, Metric templates, Category users and stakeholders, On-demand assessments and API, Scheduled assessments, Schedule types, Publish a metric type, Clean up assessment data, Assessment instances, Trigger conditions, Manager notifications and notification workflow, Metric results, Assessment results and calculation, Overview dashboard, Bubble charts, Scorecards and their views, Decision matrixes, Take an assessment, Assessments in Service Portal and Now Mobile; Assessments reference: data types, Assessment Metric form, Metric Category form, Assessment Metric form for a category, Trigger Condition form, Domain separation), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/r_Assessments.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Assessments

**In one line:** assessments score **records** (vendors, projects, demands, groups ...) rather than collect opinions: a **metric type** picks the records (**assessable records**), **metric categories** group **metrics** that are either questions to people or **scripts** that query data, and results show on **scorecards**, **decision matrixes** and **bubble charts**.

From the Brazil docs; not tested. Same engine and tables as [[Surveys Overview and Survey Designer]]. The plugin is on by default. Edit only in the metric type's own application scope.

## Terms

| Term | Meaning |
|---|---|
| Metric type (`asmt_metric_type`) | the set of records to evaluate (table + condition), schedule type, scale factor |
| Assessable record (`asmt_assessable_record`) | links one source record (e.g. a company) to a type; a record can be assessable in several types |
| Metric category (`asmt_metric_category`) | a theme (e.g. support rating), with weight and filter |
| Metric (`asmt_metric`) | one trait: a question (method *Assessment*) or a script (method *Script*) |
| Category user (`asmt_m2m_category_user`) | person who knows a category (scheduled assessments only) |
| Stakeholder (`asmt_m2m_stakeholder`) | category user linked to a specific assessable record |
| Assessment group (`asmt_assessment`) | container for instances and results of one generation run (cannot be deleted while it has data) |
| Assessment instance (`asmt_assessment_instance`) | one questionnaire for one user |
| Scorecard, decision matrix (`asmt_decision_matrix`), bubble chart | result views |

Roles: `assessment_admin` (set up; often needs extra roles to read the source table, e.g. `vendor_manager` for `core_company`), `itil` (read assessable records), `admin` (everything; only admins set generation schedules). No role needed to take one.

## Set up (`admin`, `survey_creator` or `assessment_admin`)

1. **Assessments > Metric Definition > Types** > New. Key fields: Name, **Assessment duration** (default 14 days), **Live feed**, **Notify manager if overdue**, **Assessment manager**, **Scoring type** (attestations: Percent or All or nothing), **Scale factor** (best score, usually 10; read-only once saved), portal pagination, **Roles** (extra read access to results), Signature, Return URL, **State** (Draft / Published), **Schedule type** (On demand / Scheduled), Scheduled job, **Evaluation method** (Assessment, Attestation, Survey), Allow retake, Active, Introduction, End note, Send notifications.
   - **Condition** tab: **Table**, **Condition**, **Enforce condition** (when ticked, **Generate Assessable Records** deletes records that no longer match; otherwise they stay).
   - **Decision Matrix** tab: **Filter field**, Filter condition, Default matrix filter.
   - **Assessors** tab: a **User field** of the table; generating assessable records then creates one per unique user (on demand: each assessor rates all records; scheduled: each assessor rates their own).
2. **Generate Assessable Records** (related link; again after every condition change). A generated business rule adds new matching records later.
3. **Categories** (Metric Categories related list or **Metric Definition > Categories**): Name, Type, **Create stakeholders** (all category users become stakeholders of all records; use with care), **Weight** (default 10; use one 1-10 scale for categories and metrics), Filter (auto-associates matching assessable records; manual links stay; source changes are not re-evaluated; to include everything copy the type condition or use [Sys ID] [is not empty]), Roles, Details.
4. **Metrics** (from the category's Assessment Metrics list): Method *Assessment* (all types except Duration; options *Default answer from field* and *Default answer from script* with **Ask question** always or only if empty) or *Script* (Duration, Number, Percentage); Weight (default 10), Order (default 100), Active, Mandatory, Allow not applicable, Question, Depends on / Displayed when, Data type, Randomize, Template, **Dependent plugin** (script runs only if that plugin is active), Scale definition (default High), Min / Max, Script. Choice and Likert need metric definitions (reorder with the hidden **Order** column, not Value).
5. **Publish** (only from Draft with at least one metric; no way back), then assign: **Assign Assessment** / **Assign to Assessors** (on demand) or **Generate Assessments** (scheduled; not *Generate Assessable Records*).

Changes to metrics and templates show up in open questionnaires and results, even saved ones.

### Scripted metrics

Server-side script on the metric (only `assessment_admin` may edit it now, not survey creators; scope of the metric type). Variables: input `primary` (sys_id of the record assessed); outputs `actual_result`, `scaled_result` (between Min and Max) and `string_result`. Example from the docs: count CIs for the vendor and map ranges to scaled values 0-5. Results are produced at generation time.

## On demand vs scheduled

- **On demand**: type active and published, a category with an assessable record and a metric. From an assessable record (questions for its categories) or from the type (questions for all records). API **AssessmentCreation** (sys_ids of an assessable record of an on-demand type with non-scripted metrics, and users) from any script. Best for testing first.
- **Scheduled**: a scheduled job *<type> Assessment Creation* per type; runs only when executed unless an admin sets **Trigger type** (e.g. Interval 30 days or Day in Month). Needs category users and stakeholders. Instances combine every record and category the user is a stakeholder for.
- Stakeholders: **Assessments > Advanced > Create Stakeholders** (list helper, many to many, scheduled types only), **Assessment Stakeholders** list (one to one; never mix types), or the assessable record's **Category users** list.
- **Trigger conditions** (**Assessments > Admin > Trigger Conditions**): like survey triggers but the type must be **On demand** and the condition needs an **Assessable Record Field** (a reference on the table pointing to the assessed records, e.g. Vendor on incident).
- Vendor Performance: **Vendor Performance > Admin > Generate Assessments**. Demand Management ships the type *Demand* with categories Size, Strategic Alignment, Risk, ROI, Cost (`it_pps_admin`).

## Notifications

*Notify assessment user* (assignment; no second instance while one is pending), *Remind assessment user* (at half the time), *Notify manager assessment is overdue* (per type **Notify if overdue**; user needs a Manager). Sent by the legacy workflow **Notify assessment user** ([[Classic Workflow Overview]]). **Cancel Expired Assessments** runs every 30 days.

## Results

- Metric results first (scripts at once, questions on submit; one per user per question per record), normalised, then category results (weighted average). Excluded: Not Applicable, unanswered non-checkbox, Date / Date/Time / String (values −1). Attachments move to the metric result. Normalisation formula: [[Survey Results, Scorecards and Sentiment Analysis]].
- **Assessments > Overview** dashboard: assessable records by type, instances by group, by state, answered / unanswered questions by user, average rating by type, category ratings, metrics by data type, stakeholders per category, top rated items, metrics by type.
- **Scorecard** (**View Scorecard** related link; add it to other tables by copying the UI action *View Scorecard* with **Insert and Stay** and changing only the Table): Averages (vs all records in the filter, trailing 12 months), Categories (all history, 3 or 12 months), Category Metrics, **Head to Head Compare** (overall rating = sum of normalised category values / number of assessment groups), History (3 years or 4 quarters), Live Feed.
- **Decision matrix** (**Assessments > Admin > Decision Matrixes**): type, X and Y axes (one or more categories each, weighted), quadrant labels and colours, one default per type; filter limited by `com.snc.assessment.decision_matrix_filter_max_entries` (1000); trailing 12 months.
- **Bubble chart** (**Assessments > Admin > Bubble Charts**): X, Y and Z (bubble size, the most important) categories, quadrant labels and colours, one default per type; last 12 months.

## Housekeeping

- **Remove Old Assessment Data** job (admin, manual by default): deletes instance questions, instances and metric results over a year old; schedule weekly or monthly.
- Deleting a type: first delete results, instances (questions then instances) and groups; the type deletion removes its job, business rule, categories, users, stakeholders, metrics, definitions and matrixes. Deleting an assessable record removes its stakeholders; deleting the source record needs its results deleted first.
- Export / import XML (types, assessable records, categories, metrics, definitions, users, stakeholders, matrixes `asmt_decision_matrix`, `asmt_m2m_xcategory_matrix`, `asmt_m2m_ycategory_matrix`), or update sets. **Copy** keeps structure, not users, instances or triggers.
- Signatures: **Assessments > Metric Definition > Signatures** (Checkbox, Full name, Assertion only).
- Domain separation: **Standard**.

## Example

An `assessment_admin` creates metric type *Example Vendors* on `core_company` with condition Vendor is true, schedule On demand, one category *Example Support* with a Likert question and a scripted Number metric counting open incidents (scale Low), publishes it, then uses **Assign Assessment** to send it to *Test User*.

## Related

- [[Quizzes]] · [[Assessments and Surveys Tables, Roles and Plugins]] · [[Change Risk Calculation and Assessment]] (risk assessments use the same engine) · [[Coaching]]
