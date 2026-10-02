---
type: concept
tags: [concept, task, roles, admin, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Time Card Management" (pp. 544-572), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Time cards and time sheets

**In one line:** Time Card Management lets task assignees record time against any task (projects, incidents, problems, changes); a **time card** is the time on one task for one week, a **time sheet** groups a user's time cards for that week, and a **time sheet policy** sets the rules and approvers.

## Setup

- Plugin **Time Card Management** (`com.snc.time_card`); also activated by PPM Standard (`com.snc.financial_planning_pmo`). It brings a Performance Analytics content pack, which needs a PA licence to use.
- Roles: `timecard_user` (log time), `timecard_approver` (approve; included in `project_manager` and `resource_manager`), `timecard_admin` (policies, approve by exception, edit others' Pending or Rejected cards).
- Domain separation: supported at data-only / basic level.

## States (same list for time cards and time sheets)

Pending, Submitted, Approved, Processed, Rejected, Recalled.

- After approval, the after business rule *Create expense from approved time card* creates an expense line for the task and sets **Processed**. A sheet that stays Approved had no task attached.
- Rejecting a sheet rejects its Submitted cards. One Rejected card makes the whole sheet Rejected. All cards approved makes the sheet Approved.
- One time sheet per user per week; creating a time card creates the sheet if missing.

## Time sheet policy (Time Sheets > Administration > Time Sheet Policies)

| Field | Default | Effect |
|---|---|---|
| Allow blank time cards | off | blank cards can be submitted |
| Auto create time card on planned task update | off | card created when a time card user assigned to the task updates it (not in a pending state) |
| Auto fill time card with time worked entries | off | **Time worked** on the task fills (or creates) the card |
| Auto create time cards every week | on | the scheduled job generates cards for the policy's users |
| Update actual hours and cost in resource plan/reports | off | approved hours update the resource plan |
| Allow recall / Recall period allowed (days) | on / 30 | recall after approval |
| Week starts on | Sunday | first day of the sheet |
| Maximum hours per day / per week | 24 / 40 | `-1` removes the limit (and allows negative corrections per day) |
| Non-project time approver | | Auto, User Manager, None (then `timecard_admin` approves) |
| Project time approver | | Auto, Project Manager, User Manager, Both, None |
| Allow multiple rate types / Default rate type | off | shows **Rate type** on the card |
| Default Policy | | the one policy applied to users with no other policy; cannot be deleted while default |

A user has one policy (assign through the policy's **Users** related list). With **Both**, a card stays Submitted until both approve; one rejection clears the approvals.

## Creating time cards

- Manually: Time Sheet Portal (**Add to Time Sheet** on a task card), the sheet's **Time Cards** related list, or the related links **Generate Time Cards** (project tasks in progress or planned that week) and **Copy from previous time sheet**.
- Automatically: the two policy options above, or the scheduled job **Auto Generate Time Cards** (**System Definition > Scheduled Jobs**, off by default). Its script sets `runFor` (`TimeCardConstants.CURRENT_WEEK`, `NEXT_WEEK`, `LAST_WEEK`), `includeGroups` and `excludeGroups`, then calls `new TimeCardGenerator().generateFromConfig(runFor, includeGroups, excludeGroups)`.
- Automatic creation does not work from the mobile interface.
- The **Time worked** field is not on the Project Task, Incident, Problem and Change forms by default; add it to the form.

## Where it lives in the data

- `time_card`: the time card. Audit its **State** field to see who submitted and approved.
- `time_card_daily`: day-by-day hours, written when a card is approved; use it for reports by day or month.
- [[task]]: **Time worked** (`time_worked`).
- Labour cost on approval: the project's rate model, else the labour rate card, else the property `com.snc.time_card.default_rate`.

## Australia changes

Time cards and the Time Sheet Portal support **resource assignments**: a card can name the resource assignment, and approved hours feed planned-versus-actual in Project Workspace and Resource Management Workspace.

## Gotchas

- A user with only `timecard_user` can be chosen in **Assigned to** on a project task and gets read-only access to it. To prevent that, override the reference qualifier on that field.
- The Time Sheet Portal is not designed for mobile devices.
- Duplicate cards (same short description, state, task, category, rate type, resource plan, project time category) can be merged, unless Processed, Approved or Recalled.

## Related

- [[planned_task]] · [[task]]
