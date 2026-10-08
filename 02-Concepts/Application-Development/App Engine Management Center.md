---
type: concept
tags: [concept, platform, admin, roles, service-catalog, instance-admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Governing app development (read 2026-10-08 through the docs site): Governing app development, App Engine Management Center, Exploring the App Engine Management Center, AEMC user interface, App Readiness and Compliance Report, Get help with AEMC, Configuring AEMC, Configure the App Engine Management Center, Test AEMC functionality on a non-production instance, Configure Application Intake (configuration tasks, activate the Apply for Citizen Development catalog item, customize the App Intake form, manage user groups), Using AEMC, Managing app development (manage requests: intake, app requests from Creator Studio, collaboration; filter and search), Manage custom apps, Managing developers. https://www.servicenow.com/docs/r/application-development/app-engine-management-center/app-engine-management-center.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# App Engine Management Center

**In one line:** AEMC is the administrator's console for custom application development: it takes in requests to build, hands out development rights, shows every custom application and developer, and moves applications through the deployment pipeline.

From the Brazil docs. Deployment side: [[AEMC Pipelines and Deployments]]. Tools being governed: [[Application Development Tools and Lifecycle]].

## Governance it is meant to carry

| Kind | Decides | Who |
|---|---|---|
| Strategic | which applications get built, how success is measured, who may build | sponsors, business leadership, CIO, programme managers |
| Technical | development practices, who tests and deploys, training | platform architects and owners, security and compliance |
| Portfolio | intake process, support and maintenance duties, when to retire an application | portfolio and service owners, QA |

## Where and who

**All > App Engine > Administration > App Engine Management Center**, used from the **production** instance, installed on every instance of the pipeline. Role: App Engine admin (`sn_app_eng_notify.app_engine_admin`); setup needs admin. Since version 29.2.1 there is a free platform tier (Store) and a paid tier with more features. AI: regenerate release notes (licence-dependent).

| Page | Shows |
|---|---|
| **Overview** | counts of intake, app, collaboration and deployment requests; developer and application metrics; releases in progress, upcoming, completed; active deployment requests per pipeline stage |
| **Requests** | every request type by approval status: Intake, App, Collaboration, Deployment requests (ReleaseOps), Deployment requests - Legacy (App Engine pipelines) |
| **Pipelines** | open deployment requests per instance and pipeline |
| **Release management** | ReleaseOps releases and their deployment requests (since 28.2.1) |
| **Custom apps** | lifecycle charts (90-day trends) and the list of all custom applications |
| **Developers** | totals, active developers, by department; per developer their applications and requests |
| **Developer Sandboxes** | assign sandbox licences to instances |

Filter icon > *Advanced view* builds conditions; *Saved filters* on Requests and Release management can be shared. The search box takes request numbers with `*` wildcards.

## Flow of work

1. A would-be developer submits an idea (**intake request**).
2. An App Engine admin approves it and grants a development group.
3. The developer builds in Creator Studio, App Engine Studio or ServiceNow Studio, inviting collaborators (**collaboration requests**).
4. The developer submits the application: a **deployment request**.
5. Admins approve it stage by stage, read the test results, and finally approve production.

## Setup (guided setup, on production)

**App Engine > Administration > Guided Setup** runs two guided setups: *Application Intake* (optional) and *Pipelines and Deployments* (required for a pipeline; or choose ReleaseOps, or a standalone environment: [[AEMC Pipelines and Deployments]]).

Application Intake (needs App Engine Studio installed):

| Task | Detail |
|---|---|
| Activate the catalog item | *Apply for Citizen Development*: tick **Active** |
| Shape the form | its shipped variables are read-only: **copy** the catalog item, deactivate the original, edit the copy in Catalog Builder (questions, order, dynamic behaviour such as show a follow-up question on a given answer, deactivate a question) |
| App Engine Admin group | add the people who approve; the group's email receives the notifications |
| Development environment records | one environment of type Development per development instance users can be provisioned to |
| Groups offered at approval | table User Groups Permission Types (`sn_app_intake_permission_type`): **Active** per group |

To try AEMC without touching production: run the pipeline setup between two non-production instances and mark one of them as type Production (the type is not verified), then correct it.

## Handling requests

| Request | From | Admin does |
|---|---|---|
| **Intake** | the catalog item | check **Development instance** (the user must exist there, or be created by hand); **Permission type**: *Select group(s)* (App Engine Studio Users, App Engine Studio User Limited, Creator Studio Users, Creator Studio Restricted Users), *I will manually provision user*, or *Do not give requestor permissions*; approve or reject. Approval adds the user to the group and mails a link; a rejected request cannot be edited, only resubmitted |
| **App** | users with `sn_creator_studio_restricted_user` asking to create an application in Creator Studio | approve or reject |
| **Collaboration** | a developer inviting someone | approve or reject. Auto-approved when the invitee already has the AES User role, already has an application in Creator Studio, or is already a delegated developer. Needs Pipelines and Deployments set up on production, otherwise the request stays on the originating instance. The collaborator gets what the collaboration descriptor allows ([[Application Administration and Collaboration Descriptors]]) |

## Custom apps page

One row per application; an empty **Published Version** means it has never reached production. Per application:

| Tab | Content |
|---|---|
| **Compliance check** | the App Readiness and Compliance Report |
| **App usage** | this month's user count, record inserts and updates in production; links to Usage Insights (active users, sessions, page views) |
| **Subscription monitoring** | roles in the application and who holds them, with licence implications; only shown when the application is mapped to an App Engine subscription (only a system admin can change the mapping). Clicking a user shows a role inheritance map |
| **Deployment history** | each deployment, when, what changed, who approved |
| **Collaborators** | who may change it and with which permissions (stored on the development instance) |

**Open in App Engine Studio** opens the application itself.

### App Readiness and Compliance Report

A dashboard built from instance scan results ([[Instance Scan]]): an overall **readiness score** and categories Manageability, Security, User Experience, Upgradeability, Performance, plus a count of checks that failed to run. **Run new report** refreshes it. The checks live in **Instance Scan > Suites > Best Practices - Parent** and can be changed.

## Developers page

Lists everyone with the AES Users, AES User Limited, Creator Studio Users or Creator Studio Restricted Users role, or delegated development on the development environment. To make someone disappear from it, revoke all of those (and admin) or deactivate the account on the development instance.

## Related

- [[AEMC Pipelines and Deployments]] · [[Application Administration and Collaboration Descriptors]] · [[Application Development Tools and Lifecycle]] · [[Instance Scan]] · [[Subscription Management]]
