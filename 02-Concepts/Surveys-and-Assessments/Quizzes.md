---
type: concept
tags: [concept, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Service Administration > Assessments and Surveys > Quizzes (landing, Using quizzes, Set up and administer quizzes, Data types for quizzes, Activate the quiz designer, View quiz reports, Quiz designer, Create a quiz and subtopics, Configure a scored question, Configure a quiz, Select a quiz recipient, Publish, Copy, Edit, Enable a quiz retake, View a quiz result, scorecards, View an assessment category result, Modify the weight of a category, Take a quiz, View a quiz instance, Question bank for quizzes, Create quizzes with forms and subtopics; Quizzes reference), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/c_Quizzes.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Quizzes

**In one line:** knowledge tests on the assessment engine: a quiz (a metric type in Quiz view) has weighted **categories**, each sent to its own **category users**, with **scored** questions that have a **correct answer** (0% or 100% each); the overall score is the weighted share of correct answers.

From the Brazil docs; not tested. Shares tables and screens with [[Surveys Overview and Survey Designer]] and [[Assessments]].

## Roles and setup

- `assessment_admin` (contained by `itil_admin` and `survey_admin`) administers quizzes; `admin` alone changes survey notifications, creates survey modules and imports surveys. No role to take a quiz (log in; it must be assigned).
- The **Quiz Designer** is a plugin to activate (**System Applications > All Available Applications > All**; its ID is not given on the page). From the global domain when domain separation and delegated admin are on.
- Steps: optional templates > quiz (**Quizzes > Quiz Designer**, or forms under **Quizzes > Quizzes** / **Quiz Management**) > categories (one default with the quiz name; weight default 10) > users per category > questions > answers and scoring > publish (emails recipients and their managers; card in **My Assessments & Surveys**).

## Questions

- Data types as in surveys: Attachment, Boolean, Choice, Date, Date/Time, Number (1-10), Percentage, Scale, Image Scale, Numeric scale (1-5), String, Template, Reference (no reference qualifiers). Multiple correct answers allowed for Choice, Scale, Image Scale, Numeric scale and Template.
- Scorable types: Checkbox, Choice, Duration, Likert Scale, Numeric Scale, Template, Yes/No. Unscored questions (opinions, dates) do not count.
- **Scored** must be set on the Assessment Metric form, not in the designer: **Quizzes > Quizzes** > quiz > Metric Categories > category > Assessment Metrics > question > **Scored** + **Correct answer**. Only scored questions show in results and scorecards; a category needs scored questions to have results.
- Dependent questions may hang off any scored question in the same category.

## Configuration

Active, Description, Introduction, **Owners** (`survey_creator`, `survey_admin` or `assessment_admin` users), Signature, Return URL or End note, **Duration** (default 14 days), **Manager** (told when submissions are overdue), **Notify manager if overdue**. Show Benchmarks link as for surveys. **Allow retake**: **Assessments > Metric Definition > Types**, remove the *Evaluation method = Assessment* filter, open the quiz, tick it (results wait until the duration ends).

Editing after publishing: new questions only for later quizzes; changed or deleted questions apply at once to unsubmitted quizzes. Copy keeps structure but not users, instances or triggers.

## Notifications

Recipient: assigned, half the time gone, overdue. Recipient's manager: overdue. Quiz manager: overdue quiz they manage.

## Results

- **Quizzes > Quiz Results** (`asmt_metric_result`), **Quizzes > Category Results** (`asmt_category_result`), **View Scorecard** (Category Results, Question Results, Average Ratings, History; only scored questions; percentage questions use 20% report ranges, see **Reports > Administration > Report Ranges**).
- Category result **Rating** = sum of normalised metric values / number of instances (docs example 8.86); category **Normalized value** = rating × category weight / sum of the weights of all categories the record has results for (example 7.81 × 9/37 ≈ 1.9). Skipped metrics shift weight to the others.
- **Quizzes > Overview** (`assessment_admin` or `admin`): quizzes by state, questions per quiz and by data type, correct and incorrect answers by user and in total.
- **Quizzes > Quiz Instances** to check or reassign; question bank at **Quizzes > Question Bank**.

## Example

An `assessment_admin` builds *Example Security Quiz* with categories *Basics* (all staff, weight 10) and *Advanced* (team leads only, weight 5), marks each Yes/No question as Scored with its correct answer, sets Duration 7 days and Notify manager if overdue, and publishes it.

## Related

- [[Assessments and Surveys Tables, Roles and Plugins]] · [[Workforce Optimization Learning, Skills and Reference]]
