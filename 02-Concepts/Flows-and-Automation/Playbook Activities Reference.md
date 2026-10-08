---
type: reference
tags: [reference, flows, automation, workspace, email, integrations]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Playbooks > Playbooks reference (read 2026-10-08 through the docs site; the published PDF does not contain these pages): Playbook statuses and activation states, Process executions, Activity executions, Create Task, Instruction, User Form, Placeholder, Interactive activities (Adobe Acrobat Sign, Advanced Instruction, Checklist Task from Template, Checklist Task, Collect User Data, Create Record, Create Child Case, Create Child Task, Docusign, Guided Decision, Invoke PaCE, Microsoft Teams, Request Multi-Level Approval, Request Ad Hoc Approval, Request Manager Approval, Send Email, Show Knowledge Article, Show List of Records, Slack, Two Step Instruction, Update Record, View Approval Requests, Wait For Condition), Non-Interactive activities (Automated Create Record, Automated Send Email, Automated Update Record, Autocompleting User Form, Look Up Records, Make a Decision-First Match). https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/process-automation-designer-reference.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Playbook Activities Reference

**What it is:** the shipped playbook activities with their specific inputs and outputs, plus the run-time records and states. How activities are defined, laid out and sequenced: [[Playbook Activities, Decisions and Variants]]. Playbooks themselves: [[Playbooks Overview and Components]].

*Common activities* can be added by admin, `playbook.admin` or `pd_author`. Store activities need their application (and, for third-party ones, the matching spoke).

## Inputs every activity has

| Input | Meaning |
|---|---|
| **Label**, **Description** | card title and help text |
| **Run condition** | must hold for the activity (or stage) to run; can use data of earlier activities. False = Skipped |
| **Start Rule** (Schedule) | stage: *When process starts* / *After specific stages*. Activity: *When stage starts* / *After specific activities* (older pages word it Immediately / With previous / After previous) |
| **Start with delay** | wait before running |
| **Wait for user input** | pause until the user completes or skips. Editable only with `playbook.admin`; on by default for interactive activities |

Shown with **Show additional options** on many activities: **Assignment Group** / **Assigned To** (who may act; by default whoever is assigned on the parent record), **Display Order**, **Restart rules** (*Skip on restart* / *Run always* / *Skip on first run*), **Experience Status Table** and **Experience Status Record** (the flow data record whose state mirrors the card), **Icon**, **Title**, **Tagline**, **Footer**, pending-state title and description, **Show Attachments**, **Attachments read only**, **Show SLA**, **Show Checklist**.

## Interactive activities

They become cards the user must act on; the playbook waits. Because a waiting card blocks everything scheduled after it, put non-interactive activities first where possible.

| Activity | Specific inputs | Outputs |
|---|---|---|
| **Instruction** | **Message** | Record |
| **Advanced Instruction** | **Title**, **Description**, Tagline, Footer | Record (task) |
| **Two Step Instruction** | **Initial Message** (In Progress), **Completed Message**, **Skipped Message** | Record |
| **User Form** | **Associated table**, **Associated record**, **Form View** (default view when empty; many views are not supported in workspace), **Form Fields** (must also be on the view), **Record fields**, **Attachment source** | Table, Record |
| **Create Record** | **Table**, **Create Record View**, **Template Fields** | Table, Create Record View, Record Created (sys_id) |
| **Update Record** | **Table**, **Record**, **Fields**; *Fields to show after update* | Table, Record |
| **Create Task** | **Short Description**, **Assigned To**; advanced: **Task Table**, field values, *Fields to show after creation*, **Wait for Task completion** | Table, Record |
| **Checklist Task** | **Checklist Owner**, **Checklist Items**, **Checklist Name**, **Task** (optional), **Can Skip** with *Skip Assignment Group* / *Skip Assigned To*, Show SLA | Checklist Task |
| **Checklist Task from Template** | **Checklist Template** (`checklist_template`; create the checklist and a template for the task table first), the rest as above | Checklist Task |
| **Send Email** | **To**, **Cc** (users, or pills), **Subject**, **Body** (HTML with pills), Tagline, Footer; advanced: To / Cc / Bcc address strings, **Target Record**, Table. The user reviews before sending | Automated, Record, Email |
| **Show Knowledge Article** | **Title**, **Knowledge Article** (`kb_knowledge`) | Record |
| **Show List of Records** | **Table**, **Fields to show**, **Conditions** | Record, Fields |
| **View Approval Requests** | **Table**, **Conditions**; Order by, Sort Type, Max Results | |
| **Request Manager Approval** | **Table name**, **Record**, **Approver**, **Due date**, **Comments** | the approval record |
| **Request Multi-Level Approval** | **Assigned to** (the person whose first- and second-level managers approve), **Due date**, **Comments**, **Table**, **Record** | approval states |
| **Request Ad Hoc Approval** | **Approver**, **Approver group**, **Table**, **Record** | approval records and states |
| **Wait For Condition** | **Record**, **Table**, **Conditions**; **Enable timeout**, **Duration**, **Schedule** (on timeout the activity is Skipped) | none |
| **Guided Decision** | **Decision Tree** (`ga_decision_tree`), **Task**. Needs App Engine or Customer Service Management | none |
| **Create Child Case**, **Create Child Task** (Store) | **Parent**, **Assignment Group**, **Assigned To**, **Short Description**, **Description**, **Priority**, *Collect data from user* | the child record |
| **Collect User Data** | **User form for data collection** (a data definition; answers go to `sys_flow_data`). Out of the picker since 26.1: use **Questionnaire** | Record (flow data) |
| **Placeholder** | **Edit** (pick the activity that replaces it). Produces nothing and does not advance a playbook | none |

With a **Task** given to a checklist activity, the checklist also shows on that task and keeps its state across runs; without one, a private task is created per run.

Third-party interactive activities (Store, each through its spoke):

| Activity | Inputs |
|---|---|
| **Adobe Acrobat Sign** | **Group record** (connection and credential alias), **Attachment**, **Participants email**, **Email body** |
| **Docusign** | **Attachment**, **Email subject**, **Email body**, **Signatory** (a user), **DocuSign account** (`sn_docusign_spoke_accounts`) |
| **Microsoft Teams** | **Chat type** (channel or direct), **Message**, **Team ID**, **Channel name**, **To members** |
| **Slack** | **Channel/Member ID**, **Message**, **Blocks**, **Username**, **Icon** |
| **Invoke PaCE** (Policy as Code Engine) | **Service**, **Category**, **Policy tag**, **Document Ids**, **Data** (JSON), **Options**; outputs Root execution id, Response, Action Status, Don't Treat as Error |

## Non-interactive activities

Run to completion (or are skipped) with no input; their cards show collapsed and complete.

| Activity | Inputs | Outputs |
|---|---|---|
| **Automated Create Record** | **Table Name**, **Fields** | Table Name, Record |
| **Automated Update Record** | **Record**, **Table**, **Fields** | Table, Record |
| **Automated Send Email** | **To**, **Cc**, **Subject**, **Body**; advanced address strings, Bcc, **Target Record** | Record, Email |
| **Look Up Records** | **Table**, **Conditions**; Order by, Sort Type, Max Results | Records, Count |
| **Make a Decision - First Match** | the decision table; its inputs and outputs follow the table | first matching rule only. For all matches call the table from a subflow ([[Decision Tables]]) |
| **Autocompleting User Form** | **Completion Condition**: the form completes and saves when it is met | |

Automated record activities obey server-side rules (data policies, business rules, mandatory dictionary fields) and ignore UI policies. The docs page for *Make a Decision - First Match* lists Table Name and Fields as inputs, which looks copied from Automated Create Record: treat as unconfirmed.

## Status of the design

| Status | Meaning |
|---|---|
| **Draft** | inactive; edits save automatically |
| **Published** | active. Later edits are saved but not live until **Activate** is pressed again |

## Run-time records

**Process Automation > Process Automation Administration > Active Processes / Today's Executions**.

| Process execution (`sys_pd_context`) state | Meaning |
|---|---|
| Queued | triggered, not started |
| In Progress | at least one activity Ready or In Progress |
| Complete | every activity Complete or Skipped |
| Error | an activity is in Error (its automation plan failed) |
| Cancelled | cancelled by admin or `playbook.admin` |

Fields: **Name**, **Created**, **Input Record**, **State**. Its *Activity Executions* related list: **Label**, **Stage**, **State**, **Activity Type**, **Associated Record**, **Execution index**.

| Activity execution state | Meaning |
|---|---|
| Pending | waiting for earlier activities |
| Ready | about to start |
| In Progress | running |
| Complete | done |
| Skipped | skipped by a user, or its run condition was false |
| Error | the automation plan or the experience failed |
| Cancelled | the underlying action or subflow was cancelled (admin, `flow_designer`, `action_designer`) |

## Related

- [[Playbook Activities, Decisions and Variants]] · [[Playbook Patterns and Runtime Use]] · [[Playbooks Administration, Roles and Access]] · [[Agentic Playbooks]]
