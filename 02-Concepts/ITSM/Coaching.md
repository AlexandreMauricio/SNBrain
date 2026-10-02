---
type: concept
tags: [concept, incident, users, roles, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Coaching" (pp. 774-808), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Coaching

**In one line:** Coaching watches task records for "coachable moments" (a **coaching opportunity** with a trigger condition), creates a **coaching assessment** for the person who did the work, and lets a coach (or an automatic **virtual coach**) rate it, assign training and award skills.

Plugin `com.sn_coaching` (ITSM Professional, activated by ServiceNow); store app *Coaching with Learning* (`sn_coach_lrn`) adds learning tasks, course items and libraries. Menu **Coaching**.

## Records

| Record | Table | Number | Content |
|---|---|---|---|
| Coaching opportunity | `sn_coaching_opportunity` | COP | where and when to assess |
| Coaching assessment | `sn_coaching_assessment` (extends [[task]]) | CAS | one evaluation of one trainee on one record |
| Virtual coaching | `sn_coaching_virtual_coach`; link `sn_coaching_opportunity_virtual_coach_m2m` | CVC | automatic completion of matching assessments |
| Training | `sn_coaching_recommendation` | | content (title, category, text); being replaced by course items (property `sn_coaching.recommended_learning_deprecated`) |
| Assigned training | `sn_coaching_assessment_recommended_learning`, `sn_coaching_opportunity_recommended_learning` | | |

## Roles

| Role | Can | Contains |
|---|---|---|
| `sn_coaching.trainee` | read own assessments, write their work notes, take the trainee survey | `skill_user`, `survey_reader`, `pa_viewer` |
| `sn_coaching.coach` | create and write assessments of own coach group, assign training and virtual coaches; cannot create opportunities | trainee, `pa_viewer`, `sn_lc.catalog_manager` |
| `sn_coaching.admin` | everything | coach, `survey_admin`, `sn_cim_improvement_requester`, `sn_lc.learning_admin` |
| `sn_lc.catalog_group_manager` | manage learning libraries by group | `sn_lc.task_creator`, `sn_lc.content_writer` |

## Coaching opportunity form

**Coaching > Coaching Opportunities** (or **Continual Improvement > Administration > Guided Setup**).

| Field | Meaning |
|---|---|
| **Table** | source table (any task table; others need a business rule, see below) |
| **Trainee** | the user field on that table that names the trainee, for example **Assigned to** |
| **Trainee group** | limit to members of these groups |
| **Coach group**, or **Specify coach user** + **Coach** | who assesses (a group, or a user field such as the assignment group manager) |
| **Trigger** | the condition, usually a "changes" event (for example *Assigned to changes*) |
| Snapshot Settings: **Snapshot fields**, or **Advanced** + **Snapshot script** | field values copied into the assessment at trigger time (script may use `{number}` style placeholders) |
| Frequency: **Random sample (%)** | share of triggering events that create an assessment |
| **Users who should be coached on every opportunity** | exempt from sampling (new hires); shown when the sample is below 100 |
| **Assessment duration** | after it, the assessment closes as Closed Incomplete (scheduled job *Close assessments after expiration*; deactivate it to stop auto-closure) |
| **Prevent duplicate assessment** + **Within time period** | one assessment per trainee and opportunity in that period |
| Surveys: **Survey taken by Coach**, **Survey taken by Trainee** | offered when the assessment is Resolved |
| Related KPIs: **Improvement KPI**, **Strategic objective** | link to [[Continual Improvement Management]] |
| Related lists | assigned trainings, virtual coach, *Skills Awarded on Assessment Completion* (skill + level) |

Typical triggers: incident first response, categorisation, reassignment, proposed solution; problem statement, known error, workaround, root cause; change implementation description, risk and impact analysis, approval, post-implementation review.

### Virtual coach

**Coaching > Virtual Coach > All**: **Table**, **Course Items**, **Condition** (or **Advanced** script), **Autofill fields** (for example State = Resolved). When an assessment created by the opportunity matches, it is closed complete automatically, the course items and skills are assigned and the surveys sent. It cannot be attached to a manually created assessment.

## Coaching assessment

States: Open, Work in Progress, Resolved (coaching given; training may still be pending), Closed Complete, Closed Incomplete (due date passed).

- Created by an opportunity (the coach group is notified) or manually with **Create Coaching Assessment** on a task (the UI action must be configured and the table returned by `getCreateAssessmentUITables` in extension point `sn_coaching.CoachingExtensionPoint`). Manual assessments have no surveys.
- Coach sets **Coach**, **Due date**, work notes (dialogue with the trainee), reviews the **Snapshot**, sets **Assessment rating** (Excellent, Good, Average, Poor, Unacceptable) and **Follow up Needed** (Recognize, Needs Additional Coaching, Needs Outside Training, Referral to Manager, Create Virtual Coach, No Follow Up), adds course items and a **Summary**, then sets Resolved.
- **Start Survey**: the coach's survey score (business rule *Calculate coaching survey score*) fills **Trainee Rating** (1-10), which is converted into the assessment rating; the trainee's survey fills **Coach rating**.
- Buttons: **Complete Assessment**, **Reopen Assessment** (coach or trainee, back to Work in Progress), **Submit feedback**.
- Skills are awarded when the assessment completes, from the opportunity, the assessment (*Skills Awarded by Assessment*) and completed course items; *All Awarded Skills* shows the source.

Surveys: create in Survey Designer with source table `sn_coaching_assessment` and owner Coaching Admin; add a question bank under **Coaching > Administration > Coaching Surveys**.

## Dashboards

- **Coaching Dashboard** (coach): active assessments, follow-up needed, survey results, resolved by virtual coach, trainee performance, KPIs addressed, opportunities of the last 6 months.
- **Trainee Dashboard**: active assessments, coaching history, survey results, assessment details.

## Non-task tables

Copy business rule *Evaluate coaching opportunity on tasks* (the troubleshooting section calls it *Coaching Opportunity creator for Task*) and adapt it to the table; without it, creating an opportunity on a non-task table gives an error. Server-side business rule.

## Properties

| Property | Default | Meaning |
|---|---|---|
| `glide.ui.sn_coaching_assessment_activity.fields` | assigned to, CI, state, impact, priority, opened by, work notes, comments, attachments... | fields in the assessment activity stream |
| `sn_coaching.kb_article_duration` | 5 | days to read an assigned knowledge article (becomes the due date) |
| `sn_coaching.exclude_weekends_on_training_due_date` | true | |
| `sn_coach.lrn.exclude_weekends_on_learning_task_due_date` | true | |

## Troubleshooting

- No assessment created: trainee not in the trainee group; **Prevent duplicate assessment** blocked it; sampling below 100% and the user not in the always-coached list.
- To change ACLs or the assigned-training lists: extension points `CoachingExtensionPoint`, `CoachingACLExtensionPoint`.
- Domain separation: Basic; all Coaching tables carry the domain.

## Related

- [[Continual Improvement Management]] · [[Benchmarks]]
