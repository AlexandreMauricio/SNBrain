---
type: reference
tags: [reference, admin, schema, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Service Administration > Assessments and Surveys > Installed with Assessments and Surveys, Quick start tests for Assessments and Surveys, Survey roles, Quiz roles, Assessment roles, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/r_InstalledWithAssessments.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Assessments and Surveys Tables, Roles and Plugins

Reference for the shared **assessment engine** behind [[Surveys Overview and Survey Designer]], [[Assessments]] and [[Quizzes]]. From the Brazil docs; not tested. Demo data ships with it (Vendor Performance adds vendor demo data).

## Tables

| Label | Name | Assessments | Surveys |
|---|---|---|---|
| Assessment Metric Type | `asmt_metric_type` | metric types (also quizzes, attestations) | survey definitions |
| Assessable Record | `asmt_assessable_record` | records to evaluate | system use only |
| Metric Category | `asmt_metric_category` | categories | survey categories |
| Assessment Metric | `asmt_metric` | metrics | questions |
| Assessment Metric Definition | `asmt_metric_definition` | answer options | answer options |
| Assessment Metric Template / Template Definition | `asmt_template` / `asmt_template_definition` | metric templates | question templates |
| Assessment Category User | `asmt_m2m_category_user` | category users | survey users (linked to all categories) |
| Assessment Stakeholders | `asmt_m2m_stakeholder` | stakeholders | not used |
| Category Assessable Records | `asmt_m2m_category_assessment` | category ↔ assessable record | |
| Assessment Group | `asmt_assessment` | one generation run | |
| Assessment Instance | `asmt_assessment_instance` | questionnaire per user | survey instance |
| Assessment Instance Question | `asmt_assessment_instance_question` | one question on one instance | |
| Metric Result | `asmt_metric_result` | metric results | responses |
| Assessment Category Result | `asmt_category_result` | category results | |
| Trigger Condition | `asmt_condition` | assessment triggers | survey triggers |
| Signature | `asmt_signature` | assessments and GRC attestations | surveys |
| Decision Matrix / X / Y category | `asmt_decision_matrix`, `asmt_m2m_xcategory_matrix`, `asmt_m2m_ycategory_matrix` | decision matrixes | |
| Bubble Chart | `asmt_bubble_chart` | bubble charts | |

Also met: `asmt_nps_result` (NPS by year, quarter, month), `asmt_assessment_stat` (sent / completed stats), legacy `survey_master`, `survey_question_new`, `question_choice`, `survey_instance`, `survey_response`.

## Properties

**Assessments > Administration > Assessment Properties** or **Survey > Administration > Properties**.

| Property | Meaning |
|---|---|
| `sn_portal_surveys.sp_survey.email_redirection` | email links open the portal view (Yes) |
| `com.snc.assessment.signature_authentication` | full-name signatures need credentials |
| `com.snc.assessment.collect.stats` | metric type sys_ids whose recent sent / completed stats go to `asmt_assessment_stat` |
| `css.assessment.question.header.background.color` (#767676), `css.assessment.caption.background.color` (#eee), `css.assessment.caption.font.color` (#ffffff) | colours; only without Next Experience |
| `sn_portal_surveys.sp_survey.show_progress_bar` | portal progress bar (not with pagination None) |
| `show_lang_picker_for_publicsurveys` | language picker on public surveys |
| `com.snc.assessment.decision_matrix_filter_max_entries` | 1000 |

## Roles

| Role | Notes |
|---|---|
| `assessment_admin` | all Assessments modules and quizzes; contained by `itil_admin` and `survey_admin` |
| `survey_admin` | contains `survey_reader`, `assessment_admin` |
| `survey_reader` | read surveys and results |
| `survey_creator` | create and assign own surveys, assessments, quizzes (shipped group *Survey Creators*) |
| `itil` | read assessable records |

See also [[Base System Roles]].

## Scripts and business rules

- Script includes (server-side, global): `AssessmentUtils` (core), `AssessmentUtilsAJAX` (scorecards), `MigrateSurveyToAssessment`, `SurveyUtils`, `RatingUtilsAJAX` (reserved). API used for on-demand generation: **AssessmentCreation**.
- Notable business rules: *Create Business Rule on Remote table* (generates *Auto business rule for Assessments* that creates assessable records, and *Auto deletion rule for Assessments* that blocks deleting source records with results); *Create Scheduled Job* / *Remove Scheduled Job*; *Generate assessment trigger condition*; *Publish Survey*; *Notify assessment user* (starts the notification workflow); *Create actual results*; *Evaluate filters*, *Update records that match filter*; domain rules forcing assessable records, categories, metrics and M2M records into the type's domain; *Verify min/max* (Checkbox and Yes/No forced to 0-1); *Verify value* (values ≥ 0 and unique).
- Many client scripts drive the forms (hide or show Min / Max, Not Applicable, scheduled job, metric definitions; *Validate Probability* 1-100; *Conditionally Set Type for Surveys* sets group Type *survey*).

## Quick start ATF tests

Plugin `com.glide.automated_testing_impl.Survey`. Tests: Survey basic platform test, dynamic validation, clone action, question bank flow, survey creator flow; Assessment assign to assessor, create as survey creator, scale and template support, basic flow. In Brazil the card buttons were removed: replace the step *Click the Take Survey button* with *Click the Survey card* ([[ATF Quick Start Tests by Application]]).

## Related

- [[Survey Distribution, Triggers and Channels]] · [[Survey Results, Scorecards and Sentiment Analysis]]
