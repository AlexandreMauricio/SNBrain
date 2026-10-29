---
type: concept
tags: [concept, admin, notifications, portal]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Service Administration > Assessments and Surveys > Surveys (Survey trigger conditions, Configure a trigger condition, Trigger condition example, Survey distribution, Email notifications for surveys, Send survey invitations, Define / add a recipients list, Embed a survey within the Outlook email client, Enable localization for a survey, Survey URLs and subtopics, Create a survey module, Share surveys, Export / Import, Use update sets for surveys and assessments, Configure a survey in the Connect chat support, Outlook Actionable Messages and subtopics, Surveys in Service Portal and the Now Mobile app, Surveys in ITSM Virtual Agent; Trigger Condition form, Recipients List form), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/c_SurveyDistribution.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Survey Distribution, Triggers and Channels

**In one line:** surveys reach people by **invitation** (survey users, recipients lists, Assign Survey), by **trigger condition** (a record meets a condition, e.g. incident closed), by **URL** or **module**, and are answered on the platform, Service Portal, Now Mobile, Outlook, Virtual Agent or Connect chat.

From the Brazil docs; not tested. Building surveys: [[Surveys Overview and Survey Designer]].

## Invitations

- Survey must be Active, Published and have a question. **Send Invitations** = an instance for every survey user and recipients list member (once per person); **Assign Survey** = pick users (not saved as survey users). More than one instance per user is possible.
- Email: shipped notification **Survey Invitation** (event fired by the engine; edit in **System Notification > Email > Notifications**). The general URL plus the automatic email can double up: clear **Send to event creator** on Survey Invitation to stop the second mail.
- **Recipients lists** (**Survey > Administration > Recipients Lists**, `admin`, `survey_admin`, `survey_creator`): Type (Contacts, Internal Users ...), State (New, In Progress, Complete), Setup **Upload File** (Excel template with sys_id and email; validated on Submit) or **Dynamic Condition** (condition builder on Table + User Field, or script); **Refresh Recipient List**. Add to a survey from the Survey Recipients Lists related list or the designer's Availability tab.

## Trigger conditions

**Survey > Administration > Trigger Conditions** (`admin`, `survey_admin`, `survey_creator`), stored in `asmt_condition`; a generated business rule watches the table.

| Field | Meaning |
|---|---|
| Assessment | the survey |
| Table | only tables in the current application scope |
| User field | any field (dot-walk allowed) pointing to `sys_user`, e.g. Caller |
| Repeat interval | minimum time before the same user gets it again (ignored for anonymous surveys) |
| Trigger randomly + Probability (%) | send only a share of the time |
| Related Field 1-4 | reference fields copied to the instance for reporting (not Number; use `trigger_id`) |
| Condition | e.g. [State] [is] [Closed] |

The instance also stores the triggering record as **Task**, so reports can dot-walk (e.g. assignment group) via **Task Assessment Details**. Keep the survey's Schedule period at No Limit; do not list survey users; make it public if users should not need to log in. Legacy *survey conditions* must be deactivated and recreated as trigger conditions.

## URLs and modules

- **General URL** (**View Survey URL**, only when Active; works once published; **Email** button for published public surveys): opens the user's earliest Ready / In progress instance or creates one. **Instance URL** (**View Instance URL** on an instance in Ready to take or In progress): only the assigned user.
- Completed instance + period restriction not expired → error; unpublished or inactive survey → error. Restricted surveys reject other users (test it with a user who is not a survey user).
- **Module**: Link type **Assessment** (not *Survey*, which is legacy) + the survey ([[Application Menus and Modules]]).

## Channels

- **Service Portal**: widget **My Assessments and Surveys** on the home page (instance options Max records 5, Title). Progress bar (`sn_portal_surveys.sp_survey.show_progress_bar`), autosave per page, resume later, Show more for long details, N/A listed last. Email links can open the portal view (`sn_portal_surveys.sp_survey.email_redirection`). Brazil shows cards instead of items.
- **Now Mobile**: applet *My Assessments and Surveys*; push notification when assigned (needs `glide.sg.universal_links.enabled` = true; not for triggered surveys); pagination always by question.
- **One Click survey**: no intro page, no Submit / Cancel (not on mobile). **Kiosk survey** = one-click with one Image Scale, Choice, Likert, Numeric Scale or Yes/No question; submits on click. URI parameters through `createAssessment()`: `sysparm_refresh_interval`, `sysparm_trigger_table`, `sysparm_trigger_id`, `sysparm_kiosk=true` (needs both trigger parameters). Public surveys cannot have a signature or attachment questions.
- **Outlook Actionable Messages** (plugin `sn_ms_oam`, role `oam_admin`): add `${mail_script:include_survey_actionable}` to the Survey Invitation message, tick **Send notifications** and **Outlook Actionable Message**, Assign Survey. Limits: sender must be `@service-now.com` or a registered provider (`sn_ms_oam.outlookactionable.originator`), SPF / DKIM must pass, no Attachment, Reference, Ranking, dependent questions or signature; Image Scale only as the single question; Date/Time only in Outlook web. The same plugin formats approval emails: **Actionable Messages > OAM Definition** (*OAM Request Approval*, *OAM RITM Approval*, *OAM Change Approval*; **Advanced OAM** for script edits) ([[Classic Approvals]]).
- **ITSM Virtual Agent**: **Chat Survey** flag; topic *Provide Virtual Agent Feedback* with the Survey topic block; one category only, types Boolean, Check box, Choice, Date, Date/Time, Image scale, Number, Numeric scale, Percentage, Scale, String; instance trigger = the `interaction` record ([[ITSM Virtual Agent Topics and Setup]]).
- **Connect Support** (`com.glide.connect.support`): **Connect Support > Support Administration > Chat Survey**: Survey, Type Connect, Chat queue, Active; offered when the agent ends the chat.
- **Localization** (public surveys only): property `show_lang_picker_for_publicsurveys`, then enter translated text per language; translations through Localization Framework in [[Survey Results, Scorecards and Sentiment Analysis]].

## Moving surveys between instances

**Export Assessment** (context menu; `admin`, `survey_reader`, `survey_admin`) gives one XML with `asmt_metric_type`, `asmt_template`, `asmt_template_definition`, `asmt_metric_definition`, `sys_trigger` jobs, `asmt_metric_category`, `asmt_metric`, `asmt_m2m_category_user`, `asmt_condition` (no results); import with Import XML. Update sets capture the same tables (preferred) ([[Update Sets]]).

## Example

A `survey_admin` creates a trigger condition for *Example Satisfaction Survey* on Incident, User field Caller, Repeat interval 30 days, Related Field 1 Assigned to, condition State is Resolved, Trigger randomly 50%.

## Related

- [[Email Notifications]] · [[Events and the Event Queue]] · [[Service Catalog in Employee Center, Service Portal and Mobile]]
