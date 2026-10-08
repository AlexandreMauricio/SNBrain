---
type: concept
tags: [concept, platform, admin, change, security, instance-admin, integrations, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Governing app development > App Engine Management Center (read 2026-10-08 through the docs site): Deployment process in AEMC, Pipelines and Deployments workflow version 24.1.2, Deployment requests in AEMC, Testing applications in AEMC, Migrating App Engine pipelines to ReleaseOps, Configure ReleaseOps in AEMC (guided setup, system property, trust profile setup), Configure Pipelines and Deployments (configuration tasks, environment credentials, OAuth credentials: API endpoints, third-party provider records, pipeline credentials; pipeline environments, pipeline, controller instance, ATF and instance scan suites, ATF properties, Change Management integration and its properties), Migration tasks (system property, state mapping, custom conditions), Configure a standalone environment, Managing deployments (manage, schedule, update, cancel, Deployment Request form). https://www.servicenow.com/docs/r/application-development/app-engine-management-center/deployment-process-aemc.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# AEMC Pipelines and Deployments

**In one line:** a *pipeline* is the ordered list of instances an application travels (development > test > production); a developer's **Submit** creates a *deployment request* on the controller instance, and an App Engine admin approves it from stage to stage.

From the Brazil docs. Console and intake: [[App Engine Management Center]].

## Three ways to deploy from AEMC

| Option | What it is |
|---|---|
| **Pipelines and Deployments** (App Engine pipeline, "legacy") | flows on the controller instance move the application through the **application repository** |
| **ReleaseOps** (integrated since AEMC 28.2.1) | releases, update sets, assessment and release playbooks. From ServiceNow Studio 28.1.2 developers can start a ReleaseOps deployment from update sets directly |
| **Standalone environment** | no pipeline yet: set the controller on development (and test), add the admin group on production; add a pipeline later |

An application is deployed either through the application repository or through update sets; an application that used update sets can be converted once to the repository.

## Setting up a pipeline

Guided setup: **App Engine > Pipelines and Deployments > Guided Setup**. Tasks run on different instances, in this order.

| On | Task |
|---|---|
| Production | credentials for each instance; environment records; the pipeline; App Engine Admin group; extra scan suites; Change Management integration |
| Test | credential for production; controller instance; ATF properties; ATF suite; instance scan suite |
| Other non-production | credential for production; controller instance |

### Credentials

Use a **functional account**: not a person, no periodic password reset, held by the administrator, admin on every instance of the pipeline.

- Basic: **Connections & Credentials > Connection & Credential Aliases > New**, **Type** = Credential, scope Global; then in its *Credentials* list **New > Basic Auth Credentials** (name, order, user name, password, credential alias). On production create one per instance; on each non-production instance create one pointing at production. The password goes only into the credential record.
- OAuth 2.0 (stricter), three passes, scope Global:
  1. On each instance, **System OAuth > Application Registry > New > Create an OAuth API endpoint for external clients**: production gets one whose **Redirect URLs** list every instance as `https://<instance>.service-now.com/oauth_redirect.do`; each other instance gets one listing production and itself.
  2. On production, **New > Connect to a third party OAuth Provider** once per instance (itself included): **Client ID** `<CLIENT_ID>` and **Client Secret** `<CLIENT_SECRET>` copied from that instance's endpoint record, **Default Grant type** = Authorization code, **Authorization URL** `.../oauth_auth.do`, **Token URL** `.../oauth_token.do`. On each non-production instance, one such record for production.
  3. Credential aliases as above but **OAuth 2.0 Credentials** with the matching **OAuth Entity Profile**; open the record and **Get OAuth Token** > **Allow**.

### Environments, pipeline, controller

- **Environments** (`Pipelines and Deployments > Environments`, admin only for the credential field): **Name**, **Instance Type** (Sandbox, Development, Testing, Staging, Production), **Instance URL**, **Instance ID** (filled by **Validate**), **Instance credential**, **Is Controller?**.
- **Pipelines**: **Name**, **Pipeline Type** (usually Application Deployment), **Source Environment** (development), **Active**; then *Pipeline Environments Order* lists the remaining environments in deployment order. Any number of environments and pipelines.
- **Controller**: one instance, normally production, holds the flows, all request and approval records, and tells the others where the application goes next.

### Tests run on the way

Arriving on an environment of type **Testing**, two things run automatically:

| Job | Detail |
|---|---|
| *Application Deployment Test Suite* (ATF) | a single test, *Log*; needs properties `sn_atf.runner.enabled` and `sn_atf.schedule.enabled` = true on the test instance (otherwise only the scan runs, with a warning) |
| *Scoped App Definitions* instance scan | checks the application's tables that extend Task |

More suites: on production, **Pipelines and Deployments > Scan Suites** (**Populate default suites** the first time) > **New**: **Suite** (an ATF or scan suite existing on the test instance), **Error severity**, **Instance Type** = Testing. Results: the request's **Deployment Environment Results** tab (ATF results, instance scan results, raw JSON) and its activity stream. If production is cloned over test, preserve the two ATF properties with a clone data preserver ([[Clone Options and States]]).

### Change Management

Property `sn_deploy_pipeline.change_management.enabled` = true makes the production step create a change request and deploy inside its window. Optional, each a sys_id in a property:

| Property | Default |
|---|---|
| `sn_deploy_pipeline.change_management.default.model` | Normal change model |
| `sn_deploy_pipeline.change_management.default.template` | the template used to create the change |
| `sn_deploy_pipeline.change_management.config_ci_creation_subflow` | subflow *Create CMDB CI if not present* (copy it into the Deployment Pipeline scope to change it) |

## What happens to a request (workflow 24.1.2)

1. **Submit** in the studio: the payload is validated, the application manifest read from `sys_app`, a deployment request created on the controller, the requester mailed, and the application **published to the application repository**.
2. Publication errors of severity *Error* wait for an approval; otherwise the next environment is looked up. None left = closed, requester told it is published.
3. Otherwise **Target environment** is set and an approval waits. Rejected = closed, with the reason mailed.
4. Approved for **Testing**: install there if absent, run the scan and ATF suites, write results, back to step 2.
5. Approved for **Production** with Change Management: **Approve & Create Change Request** creates the change from the template; the application is registered as a CI if needed and added as affected CI. The flow waits for state *Implement* (states other than Assess / Authorize / Implement close the request as not approved), creates a change task, waits for the planned start, deploys, closes task and request.
6. Approved for any other environment: install there.

Without Change Management the button is **Approve & Deploy app**; at the production step **Deploy app** offers *Deploy* now or *Schedule for later* (runs within 15 minutes of the chosen time; interval set by scheduled job *Scheduled Deployments*). A scheduled date can be changed on the **Scheduled Deployments** tab; **Cancel deployment** cancels the whole request.

| State | Meaning |
|---|---|
| New, In Review | submitted; awaiting review |
| Closed - Published | deployed to production |
| Closed - Rejected | rejected on an approval; the reason is mailed to the requester |
| Closed - Failed | a pipeline flow failed |
| Canceled | |

Form: number, assignment group and assignee, **Release notes**, app name / version / sys_id / development URL, requester details, originating environment, pipeline, current environment, comments (include the manifest and test results), work notes.

## ReleaseOps

Setup from AEMC guided setup: card *Set up ReleaseOps and Multi-Instance Management* > start a configuration (continues in the ReleaseOps guided setup) > tick **Enable ReleaseOps** in AEMC properties > **Run Setup** in the AEMC banner, which builds *Trust Profile for App Engine Management Center* (check **Multi-Instance Management > Application Trust Profiles**: every pipeline instance listed).

Pure ReleaseOps, scheduled release:

1. A release manager creates a **release** tied to a pipeline.
2. Developers complete update sets and promote them; they join a deployment request targeted at the release.
3. The developer sets the request to **Ready to Assess**: the *assessment playbook* runs ATF suites and instance scans.
4. Failures become deployment tasks, signed off by a tester or sent back.
5. The request becomes **Ready for Deployment**; on the release date the *release playbook* carries all such requests to production.

A ReleaseOps deployment request shows its release, update sets, tasks, the ATF suites run with results, and the instance scan suites.

### Migrating an App Engine pipeline

Keeps Submit and the repository, but lets ReleaseOps orchestrate; useful to evaluate it, or for App Engine Studio and Creator Studio where ReleaseOps is not native.

1. Install and configure ReleaseOps (ecosystem, multi-instance management) on every instance.
2. Property `sn_deploy_pipeline.migrate_releaseops` = true on production (default false).
3. Custom ReleaseOps states: map them under **Pipelines and Deployments > ReleaseOps State Mapping** (do not remap the end states Canceled, Completed, Failed).
4. To migrate only some deployments, add rows to decision table *Deployment Migration to ReleaseOps* ([[Decision Tables]]).

Afterwards each Submit creates both requests; open the ReleaseOps one and attach it to a release or mark it on-demand; the admin's approval in the App Engine pipeline hands over; an update set with install instructions is attached; the two stay in sync.

## Related

- [[App Engine Management Center]] · [[Change Approval Policies]] · [[Instance Scan]] · [[Clone Options and States]] · [[Application Scope and Namespace Identifiers]] · [[ReleaseOps]] · [[Update Sets]] · [[Application Repository, Publishing and Administering Apps]]
