---
type: concept
tags: [concept, change, integrations, api, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > Argo CD, Jira, Rally, Agile Development 2.0, Bitbucket, JFrog (including AppTrust) and Harness integrations (pp. 1094-1181 and 1228-1236), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Planning, Code, Artifact and Deployment Tool Integrations

**In one line:** the smaller DevOps Change Velocity connectors: Jira, Rally and Agile Development 2.0 (planning), Bitbucket (code), JFrog (artifacts, AppTrust), Argo CD and Harness (deployment and orchestration).

All follow the pattern in [[DevOps Change Velocity Setup and Onboarding]].

## Jira (planning)

- Jira Server (Basic Auth or API key) and Jira Cloud (Basic Auth or **OAuth 2.0 with 3LO**). The Jira user needs Jira Administrators permission.
- With 3LO the tool URL is `https://api.atlassian.com/ex/jira/<Cloud-ID>`.
- Projects become **Plans**. Jira Cloud discovery pages 50 projects at a time (constant in script include `DevOpsCommonConstants`). Discovered project and version data is not updated in real time.
- Webhooks: with basic authentication one per project; with OAuth on the integration app (configuring manually as well can create a duplicate). Manual: **System > WebHooks > Create a WebHook**, URL = webhook URL with the token appended as `ni.nolog.token=<token>`.
- Do not change a project key in Jira: names only refresh when the object is next updated.

OAuth 3LO (roles `sn_devops.admin`, `credential_admin`, `sn_jira_spoke.jira_admin`): installed records *DevOps Jira Cloud OAuth Application* (registry), *DevOps Jira Cloud OAuth Profile* (default entity profile) and *DevOps Jira Cloud OAuth Scope*. Create an **OAuth 2.0 Credentials** record on that profile, then **Get OAuth Token** and accept in Atlassian. Each credential needs its own entity profile: for a second Jira connection create another profile (not default, same provider, same scope record).

## Rally (planning)

- Install the Rally application from the Store. Object types by default: `HierarchicalRequirement`, `Defect`, `Feature`. State mapping uses Rally's *ScheduleState* and can be changed in the script include *Rally state mapping helper*. The formatted id becomes the work item's native id (used to link commits).
- Basic Auth (API key) or OAuth 2.0: in Rally **My Settings > Access > OAuth Clients > Create** with callback `https://<instance>.service-now.com/oauth_redirect.do`; in the Application Registry **OAuth API script** `OAuthDevOpsRallyHandler`, grant Authorization Code, URLs `https://rally1.rallydev.com/login/oauth2/auth` and `.../token`, scope `alm`; then a credential record and **Get OAuth Token**.
- Manual webhook endpoint: `<instance>/api/sn_devops/v2/devops/tool/plan?toolId=<toolId>&ni.nolog.token=<token>`.
- Needs the integration user to be set up.

## Agile Development 2.0 (planning)

Needs the Agile Development 2.0 plugin. No URL or credentials: connect, then **Discover** finds Products as plans. Import fills Work Items (stories, defects), Plan Versions (releases) and Features (epics).

## Bitbucket (code)

Repositories, commits, branches and pull requests. Bitbucket Server: URL and global admin credentials (MID Server for on-premises). Bitbucket Cloud credential types:

| Type | Needs |
|---|---|
| Basic Auth | account email + API token with scopes `read:account`, `read:project:bitbucket`, `read:pullrequest:bitbucket`, `read:repository:bitbucket`, `read:webhook:bitbucket`, `write:webhook:bitbucket`. Discovers repositories of all workspaces |
| Access Token | token with Account, Projects, Pull requests read, plus the **Workspace ID** |
| OAuth 2.0 Authorization Code | OAuth consumer (**Workspace settings > OAuth consumers**) with Account read, Projects read, Webhooks read and write, Pull requests read; *This is a private consumer* **not** selected; callback `https://<instance>/oauth_redirect.do`. Registry URLs `https://bitbucket.org/site/oauth2/authorize` and `.../access_token`. Discovers all workspaces (Bitbucket limitation) |
| OAuth 2.0 Client Credentials | consumer with *private consumer* **selected**; client id = **Key**, client secret = **Secret**; can be created in the playbook |

Manual webhook triggers: Repository Push; Pull request Created, Updated, Approved, Approval removed, Changes Request created / removed, Merged, Declined, Comment created / updated / deleted / resolved / reopened.

## JFrog (artifacts)

- Tracks artifacts published by Jenkins, GitHub Actions, Azure DevOps (not release pipelines) and GitLab pipelines. No discover, configure or historical import for the classic integration.
- Credentials: Basic Auth (needs the *Administer Platform* role in JFrog) or **Bearer Token** (needs Store plugin `x_snc_jfrog`).
- **Build info must be published** with the artifacts and contain the URL and modules.
- **Associate pipeline steps with the JFrog tool** (a step belongs to one artifact tool): from the orchestration tool's Pipelines tab (**Associate artifact tool**), the pipeline's *Steps with artifact association* tab, the step's *Artifact tool* tab, or the JFrog tool's *Associated steps* tab.
- Tool-side setup: Azure DevOps uses the JFrog Artifactory extension with tasks *Artifactory Generic Upload* (**Collect build info**, build number = build id) and *Artifactory Publish Build Info*; GitHub uses the JFrog CLI (`jf rt u`, then `jf rt bp`); GitLab uses the CLI with CI/CD variables `JFROG_URL`, `JFROG_USER`, `JFROG_PASSWORD`.

### JFrog AppTrust

AppTrust applications promote versions through lifecycle stages; a promotion can be put under change control.

1. Connect the JFrog tool with a bearer token (permission check: read on artifact repositories, projects and builds). Projects are discovered.
2. Tool record > **Projects** > a project > **Business Applications > Associate**: creates an AppTrust application with the business application's name and configures the webhook. **Auto configure with new token** re-configures all configured projects.
3. In JFrog enable change request creation for a stage (AppTrust Integrations page). On promotion a change is created with evidence; when approved, the approval goes back and JFrog promotes the version.
4. Policy: add change approval policies to the model used; flow action *JFrog Fetch evidences* attaches the evidence.
5. Digital signature verification: generate a key in the Key Management Framework module `x_snc_jfrog.signing_key` (role `sn_kmf.cryptographic_manager`) and take the public key from JFrog **Administration > Security > Keys Management**.

## Argo CD (deployment)

Plugin `sn_devops_argocd`. Closes the change according to the Argo CD sync result:

1. The CI pipeline creates the change (must be in Implement).
2. The config repository commit carries the tag `sn_devops_change-<change number>`.
3. The app is synced in Argo CD; a notification creates an inbound event; the change is closed with close code, close notes and work notes from the sync status.

Connect with URL and a user token (user capability `apiKey`). The webhook is manual: in ConfigMap `argocd-notifications-cm` define `service.webhook.sn_devops_argocd` (the orchestration webhook URL), a template `app-sync-succeeded` posting sync status, repository, revision, commit author, message and tags, start and finish times, triggers `on-sync-succeeded` and `on-sync-status-unknown`, and subscribe the app with annotation `notifications.argoproj.io/subscribe.on-sync-succeeded.sn_devops_argocd`.

## Harness (orchestration)

Workspace only. Credentials: access token + **Account Identifier**. Webhooks are manual: URL `.../tool/orchestration?toolId=<toolId>&ni.nolog.token=<secret token>&projectId=<account identifier>`; in the Harness pipeline **Notify > + Notifications**, events Pipeline End, Stage Failed, Stage Success, Stage Start, Step Failed, channel Webhook. Change and security steps use the generic Docker image (`servicenowdocker/sndevops`) with `sndevopscli`.

## Related

- [[DevOps Change Velocity Setup and Onboarding]] · [[DevOps Quality, Security and Other Tool Integrations]] · [[DevOps Jenkins Integration]]
