---
type: concept
tags: [concept, flows, automation, workspace, portal, roles, access-control]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Playbooks (read 2026-10-08 through the docs site; the published PDF does not contain these pages): Embed a playbook in ServiceNow mobile, Reflow for playbook components, Apply Reflow to playbook components, Playbook record generator, Playbooks patterns, Nested Playbooks (create a nestable child playbook, create a parent playbook), Configure a Wizard layout playbook, Configure a Guided Decision Playbook, Configure guest user access to playbooks, Running Playbook Experience, Add an activity to a playbook, Testing support for playbooks (configure, run), Restart a playbook, Cancel a playbook, Open full lists within playbook, Using activity stream within a playbook, Playbooks system properties, Playbooks roles, Keyboard navigation in playbook diagram view. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/playbook-patterns.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Playbook Patterns and Runtime Use

**In one line:** four recipes that need matching choices in Workflow Studio and UI Builder (nested, wizard, guided decision, guest access), and what an agent does with a running playbook.

Basics: [[Playbooks Overview and Components]]. Page design: [[Playbook Experience Design for Workspace, Portal and Mobile]]. Activities: [[Playbook Activities Reference]].

## Nested playbooks

A child playbook reused inside parents: smaller, reusable, faster to load in the designer.

- The child must be **Standalone** (execution type) with *Allow this playbook to be nest-able in another playbook* (ticked automatically), have at least one runtime permission set with **Trigger on-demand** (Start node > **Runtime Permissions > Add a Permission Set**), and be **activated** to appear in the picker.
- The child needs the same runtime permissions as the parent.
- In the parent (record driven): stage > **+** > **Add a playbook** > pick the child > **Label**, **Description**, **Schedule**; additional options **Display order**, **Start with delay**, **Restart rules**.
- Optional activities can only be inserted in the parent, never inside the child.
- Restart: not for single activities or stages of the child. When the parent restarts, the *Launch Nested Playbook* activity's rule applies: *Skip on restart* (child keeps running), *Run always* (child cancelled and launched again), *Skip on first run* (launched only on a restart).
- Cancelling the parent cancels the child; a child can also be cancelled alone (UI or API).

## Wizard layout

One activity at a time with numbered steps and back / forward controls. For strictly ordered processes; with branching prefer a guided decision playbook.

1. Have an activated playbook whose activity order is the step order.
2. UI Builder > an experience > a page > **Add content > Components >** *Playbook Horizontal Wizard* bundle.
3. On the **Playbook Wizard** component set **Playbook**; adjust step titles and descriptions.
4. Check navigation and that completion rules block moving on. **Preview**, **Save**, **Publish**.

Roles: `playbook.admin`, `pd_author` or `playbook.write`, plus `ui_builder_admin` or admin.

## Guided decision playbook

Questions, decisions and the activities of the chosen branch shown as one continuous flow; earlier answers fold into an accordion; no stage or activity pickers.

1. Workflow Studio > **New > Playbook**, **Type** = *Guided Decision*. *Standalone* if it should be nestable (a record-driven playbook cannot be nested).
2. It is a **single-stage** playbook: questionnaire activities, at least one **decision**, guidance activities at the end of each branch.
3. **Activate**. Any later edit saves but deactivates: activate again.
4. UI Builder page (Standard record template or from scratch; there is no matching page template) > add the *Playbook Guided Layout* bundle > default configuration (values from URL parameters; the page URL changes) or manual.
5. On the **Playbook Custom Layout Controller**: standalone = **Playbook to launch**; record-driven = bind parent table and record to `props.table` and `props.record`, and bind the controller's sysId to `-1` (without it the playbook never starts).
6. **Preview** in UI Builder: the designer's **Test** does not support this layout. **Save**, **Publish**.

## Guest (public) access

Lets people without a login run a playbook from a public URL.

| Step | Detail |
|---|---|
| Public table (admin, beforehand) | registered in `sys_public`, role `public` applied, create ACLs |
| Playbook | *Standard*, **Record driven**, **Parent table** = the public table, tick **Allow this playbook to be publicly accessible and embedded on public pages**. Must be chosen at creation; standalone playbooks cannot be public |
| Trigger | record based, *When record is created*; **Activate** |
| Audience | **Now Experience Framework > Building Blocks > Audiences > New**, with role `public` |
| Page | UI Builder page whose variant has that audience |
| Route ACL | **System Security > Access Control (ACL) > New**: **Type** `ux_route`, **Name** = the page path with slashes as dots (`now/myapp/test-form` > `now.myapp.test-form`), requires role `public` |
| Test | open the URL in a private browser window and submit |

Roles specific to this: `playbook.write.public_access` (edit public playbooks; others see them read-only, delegated developers included), `playbook.content_author.public_access` (set the public access field of an activity definition), `playbook.automation_runner` (the restricted identity the automations of a public playbook run as). In Service Portal the Portal Playbook widget must also be set for public access.

## Record generator

A playbook needs a record to run on. The **record generator** puts a *new record form* as the first step of a chosen process definition: on submit the user lands on the new record with the process already running (if none started by trigger, the one shown is started). A workspace or UI Builder page can show it instead of the standard new-record form. Configurable: the activity's name, the form view, the process definition shown, and optionally the declarative action that submits.

## Reflow and mobile

- **Reflow**: playbook components switch to compact mode around 200% browser zoom (pages zoom to 400%). Rules live in UX Auto Reflow Rules (`sys_ux_auto_reflow_rule`), one per standalone and custom layout component, toggling `compactMode` under 640 px page width. Standalone component: nothing more. Custom layout: on the *Playbook Custom Layout* controller set `stagePickerVisible` to true, add the **Compact Mode Changed** event handler to the component, and optionally script the **Default displayed pane** of *Resizable panes*.
- **Mobile**: after creating the Mobile Web screen (URL with `web_controller_spinner=on`), go to **Mobile app configs > Mobile Agent > Edit in original scope** and select the **Launcher screen** component to place the screen. The docs end the procedure there.

## Working a playbook (agents)

Shown in a record's side panel or related items. A header per playbook on the record; stages under it with progress and a check mark when complete; activity cards (first one of a stage expanded) with status, SLA timer, form, checklist, attachments. Activities done by AI agents show what was done.

| Action | How | Needs |
|---|---|---|
| Add an optional activity | action menu > **Add Activity** > **+ Add activity here** > pick > **Done** | the author must have defined optional activities; never as first activity of a stage nor between two finished ones |
| Restart | context menu of the playbook (**Restart playbook**), a stage (**Restart stage**) or a card (**Restart**) | restart enabled by the author; role `pd_restarter` (or the agent's access). A playbook that is Complete, Error or Cancelled cannot be restarted; a stage or activity must be Complete or in Error. Later restartable steps may have to be redone |
| Cancel | playbook header ellipsis > **Cancel Playbook** > reason | the cancel action added to the experience; role `pd_cancel`. Some started activities cannot be cancelled |
| Open a list fully | **Open List** icon on a list card | opens a tab |
| Comments and work notes | **View activity** / **View History** on a card | activity stream of the parent or associated record |

## Automated tests

Playbook pages can be tested with the Automated Test Framework (admin or `atf_test_admin`): a test with step **Configurable Workspace > Open Workspace Page** (the playbook URL, for example `/now/<workspace>/record/<table>/-1`), then **Configurable Workspace > Test Page** steps on the playbook components (`now-playbook-experience-connected` or `sn-playbook-card` for the standalone component; `sn-playbook-card`, `now-playbook-activity-picker`, `now-playbook-activity-viewer`, `now-playbook-stage-picker` for custom layouts), for example the action *[Stacked Selector]: Gets the playbook title by index* with index 0. Test execution must be enabled once. A 600-second timeout can be the browser throttling a background tab.

## Properties

| Property | Controls |
|---|---|
| `com.glide.event_manager.process_automation.claim_limit` | Process Automation events handled per transaction |
| `sn_agent_workspace.default_view_editable_tables` | table views (comma-separated) a workspace may render inside a playbook card |

Everyone needs `snc_internal`; without it triggers can fail validation. Playbook roles do not open Workflow Studio by themselves (`playbook.designer_access` carries `sn_workflow_studio.workflow_studio_read` and `sn_diagram_builder.db_read`). Role table: [[Playbooks Administration, Roles and Access]].

Diagram view by keyboard: arrows move between start node, connectors, stages and activities; Enter opens or edits; Esc leaves; Tab reaches **Triggers** and form fields; Enter on a connector's **+** adds a stage, activity, parallel path or decision.

## Related

- [[Playbook Experience Design for Workspace, Portal and Mobile]] · [[Playbook Activities Reference]] · [[Playbook Activities, Decisions and Variants]] · [[Agentic Playbooks]] · [[Create and Test a Playbook]]
