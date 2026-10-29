---
type: concept
tags: [concept, admin, forms-lists]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Service Administration > Assessments and Surveys > Surveys (landing and version comparison, Use surveys, Survey questionnaires, Take a survey, Survey administration, Survey designer, Survey designer elements, Configure a survey in the survey designer, Survey categories, Create a question in the survey designer, Survey question data types, Create custom metric type, Edit a survey, Configure category weights, View a survey instance, Survey users and groups, Copy, Publish, Customize the appearance, Survey definitions, Modify a survey definition, Schedule periods, Survey questions, Survey question template, Question bank, Answer options, Order of questions; Surveys reference: roles, key terms, Survey Designer Configuration form, Properties form, Custom Metric form, Survey Instance form, Survey Question form), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/r_SurveyManagementLandingPage.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Surveys Overview and Survey Designer

**In one line:** surveys are built on the **assessment engine**: a **survey definition** (`asmt_metric_type`) holds **categories** (`asmt_metric_category`) of **questions** (`asmt_metric`); each copy sent to a person is a **survey instance** (`asmt_assessment_instance`) and each answer a **metric result** (`asmt_metric_result`).

From the Brazil docs; not tested. Sending surveys: [[Survey Distribution, Triggers and Channels]]. Results: [[Survey Results, Scorecards and Sentiment Analysis]]. Scoring records instead of asking people: [[Assessments]].

## Versions

**Surveys** (current) and **Legacy Surveys** (old `survey_master` tables, documented only on the old wiki). Surveys adds portal support, retakes, question templates, categories and category reports, deactivation without deletion, conditional questions, scheduled sending, colours, anonymous responses, scorecards, drafts, one-page design, restricted users, trigger conditions, emails, frequency limits, intro and end notes, modules, **public surveys** (no login) and update set tracking. Migration: [[Survey Results, Scorecards and Sentiment Analysis]]. Because the tables are shared, survey screens show assessment labels.

## Roles

| Role | Can | Contains |
|---|---|---|
| `survey_admin` | create and administer surveys, distribution, users | `survey_reader`, `assessment_admin` |
| `survey_reader` | view surveys, responses, groups, scorecards, reports | |
| `survey_creator` | create surveys (and assessments, quizzes), assign them; sees, copies and publishes only surveys they own | |
| none | take an assigned survey (must be logged in, unless public) | |

Adding a user to the shipped group **Survey Creators** gives `survey_creator`. Users with `assessment_admin` can **Show all** in the queue to see others' instances.

## Taking a survey

**Self-Service > My Assessments & Surveys**: cards (name, state, due date) > answer (red asterisk = required; **Not Applicable** if offered) > **Save** (resume later; invalid answers block saving) or **Submit** (final). Users without access to the trigger record still take it but do not see the record number.

## Survey designer (`survey_admin`, `survey_creator`, `admin`)

**Survey > Survey Designer**. Left panel: **Controls** (drag a data type onto the canvas), **Questions** and **Categories** (the question bank). Header tabs: **Design**, **Configuration**, **Availability**. Menu: Save, Preview, Publish, Save and Publish, New Survey, Load Survey, Copy Survey.

- **Categories**: at least one (created with the survey's name); more give collapsible sections and category scores; a category needs scored questions to have results. Weight per category default 10 (add **Weight** to the Survey Category form).
- **Questions**: gear icon > Properties: Name, Question, data type, Active, **Mandatory** (not for dependent or check-box Boolean), **Allow Additional Information** (extra label field; portal only), Boolean option (check box or Yes/No), String option, Min / Max, **Allow not applicable** (excluded from results), **Randomize answers**, **Positive indicator** / **Scale definition** (High = bigger is better, Low = smaller is better), **Source Field** (inserts `${param}` in the label, filled from the trigger record; do not translate it), sentiment flag (String only), Details, Choices (two or more, unique values). **Dependency** tab: show only when a Boolean, Choice, Scale or Template question has given answers (no recursion).
- Editing after distribution: new questions only on later instances; changed questions apply at once to open instances; deleted questions disappear from queues. Only in the survey's own application scope. Change **Sample metric** last.

### Question data types

| Type | Scored | Notes |
|---|---|---|
| Attachment | no | files cannot change after submit |
| Boolean (Checkbox, Yes/No) | yes | needs scale definition |
| Choice, Likert Scale | yes | answer options = **metric definitions** (`asmt_metric_definition`): Display + numeric Value (order and score; unique) |
| Date, Date/Time, String | no | String options: single line, single line wide, multiline; field validation Email, IP, Phone (E.164), URL |
| Number, Percentage | yes | Min / Max (Number default 1-10) |
| Numeric Scale | yes | default 1-5, radio buttons |
| Template | yes | reusable scale (`asmt_template`, values in `asmt_template_definition`); keep question Min / Max equal to the template's smallest and largest Value (not updated automatically) |
| Reference | no | any table, no reference qualifiers (a Condition field filters) |
| Image Scale | yes | five emoji by default, own JPG / PNG / GIF (64x64), no N/A |
| Multiple Selection, Ranking | | ranking: each number once, may depend on a parent but not be a parent |

Shipped templates: Amount, Complexity, Frequency, Likert 5, Quality, Satisfaction, Size (five options each). Scored answers convert to 0-10.

**Custom metric type** (**Survey > Administration > Custom Metric Type**): Name, Application, Icon, Active, **Macro** (platform rendering; input with `datatype="custom"` and `name="${jvar_question_name}"`), **Widget** (portal rendering; `ng-model="page.fieldValue"`), Result type, Value parameters (e.g. 5 or 10 stars). Not shown on public surveys unless the widget is made public; changing macro or widget affects existing instances.

**Question bank** (**Survey > Question Bank**; demo data plugin `com.snc.question_bank_data`): reusable categories and metrics; **New Category from Bank**, **New Metric from Bank**, **Add to Question Bank**, or drag from the designer (a parent brings its dependants).

Ordering: designer-created questions get Order 101, 102 ...; hand-made ones default to 100 (they come first). A question with responses cannot be deleted until the responses are.

## Survey definition form (`asmt_metric_type`)

Name, Description, **Active** (off = no new instances and open ones cannot be completed), **Owners** (`survey_creator`, `survey_admin` or `assessment_admin` users), **Anonymize responses** (clears Assigned to on submit; Created by / Updated by remain visible to `survey_admin`), **State** (Draft / Published; no way back to Draft, deactivate instead), **Allow retake** (resubmit until the due date; results wait until then), **Scheduled job**, **Assessment duration** (default 14 days → due date), **Send notifications**, **Sample Metric**, **Signature** (Check box, Full name or Assertion only; `com.snc.assessment.signature_authentication` makes full-name signatures re-authenticate), **Schedule period**, skip introduction, **Pagination setting for Service Portal view** (Category default, Question, None), **One Click Survey**, **Source Table**, **Chat Survey** (needs `com.glide.cs`), **Outlook Actionable Message** (needs `sn_ms_oam`), **Allow Sentiment Analysis**, Introduction, End note (or a **Return URL** instead).

Related links: Enable / Remove Public Access, View Responses, View Scorecard, View Survey URL, Show Benchmarks (`bm_viewer`, opted in), Create Improvement Initiative (`com.sn_cim`, [[Continual Improvement Management]]), Retry Sentiment Analysis. Related lists: Trigger Condition, Survey Responses, Metric Categories, Survey Users (empty = anyone may take it), Assessment Instances, Improvement Initiatives, Survey Recipients Lists. The form also shows a weekly Response Trend and a Survey Summary chart.

### Schedule periods

Only Once, **No Limit** (default), Daily, Weekly, Monthly, Yearly. Recurring periods create a scheduled job that gives each survey user a new instance per period (if they have none incomplete) and set the instance **Expiration date**; until it passes the user gets no new instance, even after the period is changed. With **trigger conditions** keep No Limit.

## Users, publishing, appearance

- **Survey users** (Survey Users related list, category Users slushbucket, or designer **Availability** > *Specific users*, optionally *Survey groups only*); groups of Type *survey* appear under **Survey > Administration > User Groups** (`admin` or `user_admin`). Listing users does not create instances unless the schedule is recurring. Do not list users on triggered surveys.
- **Publish** (Survey > View Surveys > Publish, or designer): creates instances for survey users and emails them and their managers.
- **Copy**: copies questions, configuration, categories, metrics, domain rules, role-based categories (not assigned users).
- **Instances** (**Survey > Survey Instances**: Ready to take, In progress, Completed, Cancelled, All): Metric type, Due date (not enforced; the **Cancel Expired Assessments** script runs every 30 days and cancels expired instances still Ready to take or in progress), State, Assigned to (read-only once started), Domain, Expiration date; related list Assessment Instance Questions.
- **Colours**: **Survey > Administration > Properties** or **Assessments > Admin > Assessment Properties** (HTML names or `#hex`); some caption colours only without Next Experience; applies to all surveys and assessments.

## Example

A `survey_creator` builds *Example Satisfaction Survey* in the designer with one category, a Likert 5 template question (scale High) and a dependent String question shown when the answer is Disagree, sets Schedule period No Limit, and publishes it.

## Related

- [[Assessments]] · [[Quizzes]] · [[Assessments and Surveys Tables, Roles and Plugins]]
