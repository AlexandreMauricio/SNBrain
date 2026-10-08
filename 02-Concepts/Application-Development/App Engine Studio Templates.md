---
type: reference
tags: [reference, platform, roles, admin, flows, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > App Engine Studio > Build > Create your app (read 2026-10-08 through the docs site): Create your app, Create your app using an application template, Available templates (Document Approval, Emergency Alert, Event Registration, Expense Pre-Approval, Inventory Tracker, Performance Review, Service Request Management, Team Contacts, Time Off), Build a custom template (from an existing application, from scratch, template creation errors, permissions to publish, publish), Update custom template contents and properties, Manage template activation, App template sharing, Create your application from scratch, Prepare your app for approval; and Reference > Supported features and metadata in custom templates is NOT included here (see App Engine Studio Building Reference). The per-template lists of forms, flows and notifications are condensed to counts and the main items. https://www.servicenow.com/docs/r/application-development/app-engine-studio/template-library.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# App Engine Studio Templates

**What it is:** an application template pre-builds the four parts of an App Engine Studio application (tables, experiences, flows and notifications, roles); this note lists the shipped templates and how custom ones are made, shared and published.

From the Brazil docs. Context: [[App Engine Studio Overview, Setup and Roles]].

## Using one

**App Engine Studio > Templates** tab > hover > **Use template** > name, description, logo > **Continue** > **Go to app home**; then edit what was created. Needs admin or `sn_app_eng_studio.user` (the limited group sees no templates). Each shipped template is a separate Store application to install first. Table and role names take the new application's scope: `x_<company code>_<app>_...`.

## Shipped templates

| Template | Purpose | Tables | Roles | Experiences and automation (main items) |
|---|---|---|---|---|
| **Document Approval** | upload documents and route them for approval, per document category | Document Approval, Document Approval Category, Document Approver | submitter (own records), approver, admin | workspace, portal, mobile; *Master Flow* looks up the flow attached to the category and runs it; *Single Stage Approval* (manager) |
| **Emergency Alert** | alerts, employee self-reports, work-from-home or time-off requests during an emergency | Emergency Alert, Self Report, Status Report Request, Work Status Request Task | emergency alert admin, manager, employee | workspace, portal, many forms; about 15 record flows and 15 emails; creates a knowledge article per alert |
| **Event Registration** | publish events, register attendees, waitlist at capacity | Event, Event Location, Attendee | organizer, attendee, admin, public | workspace, portal, organizer mobile; confirmation, waitlist, on-hold, change and cancellation flows and emails; expiry flow |
| **Expense Pre-Approval** | planned expenses through manager then budget reviewer approval | Budget definition, Expense request, Expense line item | employee, manager, budget reviewer | record producer, manager and budget workspaces, mobile; *Budget Approval Process*, budget calculation flows, SLA warning; levels adjustable through decision tables |
| **Inventory Tracker** | stock of consumables, loaners, discontinued items; requests and reorder alerts | Inventory Control, Inventory Request, Stock Location | employee, inventory manager, admin, public | workspace, portal, mobile; about 20 record flows and 30 emails (submitted, approved, denied, checked out, returned, overdue, out of stock) |
| **Performance Review** | scheduled self and manager evaluations | Performance Review | employee, manager (team), HR/admin | workspace, portal, mobile; *Main Flow* runs daily and uses dates held in system properties to create records, remind, and close the period |
| **Service Request Management** | generic request / approve / fulfil service desk | **Primary** (extends Task; extend it for each new service), Example Request, Fulfiller Task | requestor, approver, fulfiller, fulfiller's manager, app admin | record producers, fulfiller / approver / manager workspaces; flows *Assignment Process*, *Approval Process*, *Fulfillment Process*; decision tables *Approver Decision* and *Fulfiller Decision* give the default approver and fulfiller per service |
| **Team Contacts** | employee directory with favourites, notes and reminders | Relationship Contact, Relationship Notes, Reminder | employee, manager, admin | mobile, portal; reminder flow and notifications |
| **Time Off** | time-off requests with manager approval | Time Off Request | employee (own), manager, admin, public | workspace, portal, mobile, dashboard; notification flows; a daily flow counts down remaining days |

## Custom templates

Roles: `app_template_author` creates and edits; `app_template_admin` activates and shares; admin does both ([[App Engine Studio Overview, Setup and Roles]]). A custom template is itself a scoped application in `sys_app`.

| Action | How |
|---|---|
| From an existing application | **Templates > Create new template > Existing app** > pick it > name, description, SVG logo > sharing. The application is scanned first (see errors below) |
| From scratch | **Create new template > Start from scratch** > name, logo, sharing > **Go to template dashboard** and add data, experiences, logic, security > **Save** |
| Edit | template > More actions > **Edit Template** (contents), **Edit Properties** (name, description, logo, sharing, *Details page*: only templates made from scratch have an editable details page), **Delete template** |
| Activate / deactivate | **App Engine > Templates > App Templates** > record > **Active** (`app_template_admin`) |
| Share | same record > related list *Template Sharing Permissions* > **New**: Global, User Group or User. The recipient still needs `sn_app_eng_studio.user`. Removing a user's share does nothing if a group share still covers them |
| Publish | template > **Properties** > tick *Activate this template* > **Publish template** > version, release notes, target: own application repository or the Store. Needs the publish permissions below |

Seen without any share record: instance admins and template admins see all templates; authors see those in scopes they may edit; active or not.

Publish permissions: per template, **App Templates** list > add column **Package** > open the package > *Manage Collaborators* > descriptor **Customize** > tick *Publish To App Repo* and *Publish To App Store*. For all owners: **App Engine > Collaboration > Descriptors > Owner** > add both permission sets ([[Application Administration and Collaboration Descriptors]]).

### Creation errors

Scanning an existing application gives one of three outcomes: everything supported; some items skipped (the template is still created without them); some items **denied** (creation stops until they are removed). **View all errors** opens Scan Failure (`sys_app_scan_failure`).

| Error | Meaning |
|---|---|
| `Unsupported_table` | a record class with no allow rule: remove the records |
| `Denied_table` | a record class explicitly denied |
| `Scripted_record` | a scripted rule failed for a record: for example the application has tables extending `sys_metadata`, has application administration turned on, or its template is being run right now |
| `Scripted_app` | a scripted rule evaluated once for the whole application |

Which record types are allowed, skipped or denied: [[App Engine Studio Building Reference]].

## From scratch, and before approval

**Create app** > name, description, logo > roles (admin and user are offered; at least one role needs read) > **Go to app dashboard**; a banner offers to open it in ServiceNow Studio; a *Guidance* toggle shows hints. Before submitting, the *Edit application properties* icon renames, re-describes, changes the image, or deletes (needs the delete permission).

## Related

- [[App Engine Studio Overview, Setup and Roles]] · [[App Engine Studio Building Reference]] · [[Decision Tables]] · [[Clone Options and States]]
