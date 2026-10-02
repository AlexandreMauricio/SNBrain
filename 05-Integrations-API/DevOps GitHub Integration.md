---
type: concept
tags: [concept, change, integrations, api, automation, security]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > "GitHub integration with DevOps Change Velocity" (pp. 987-1029), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps GitHub Integration

**In one line:** connecting GitHub or GitHub Enterprise to DevOps Change Velocity for plans (issues), code (repositories) and orchestration (Actions workflows), including change control from a workflow.

Common onboarding pattern: [[DevOps Change Velocity Setup and Onboarding]].

## Which tool type and URL

| Offering | Tool integration | URL |
|---|---|---|
| GitHub | GitHub | `https://api.github.com` |
| GitHub Enterprise Cloud | GitHub | `https://api.github.com` (not the `github.com/enterprises/...` web address: that gives "Tool cannot be created because the tool URL is invalid") |
| GitHub Enterprise Server (self-hosted) | GitHub Enterprise | `https://<your host>` |

## Rules

- Organization repositories need base permission Read to discover and Admin to configure; with *No permission* nothing is discovered, even public repositories, and the owner may limit which repositories are offered.
- **One repository must not be configured under two tools** on the same instance (events are then attached to a random tool). To move it: delete the webhooks, untrack, then configure under the other tool.
- Commits of forked repositories cannot be imported (the REST API does not return them).
- There is no plan object in GitHub: each repository yields a plan. Historical import of plans is not supported. Issue updates synchronised: title, assignees, transfer (marked transferred in the old repository, opened in the new), delete (work item kept, state set to deleted).
- Upgrading customers: after plans are discovered, property `sn_devops.track.github.issues` reconfigures all configured repositories so the issues webhook is created.
- The scheduled pipeline discovery covers tracked repositories only unless property `sn_devops.discover.tracked_repos_only` = false.
- Webhooks created: `push` (commits, branches, tags), `workflow_job` (pipeline data), `issues` (work items). Manual: repository **Settings > Webhooks**, **Payload URL** = the webhook URL, **Secret** = the secret token.

## Authentication methods

| Method | Custom actions | Secrets in workflows | Deployment gates (environments) |
|---|---|---|---|
| Basic (username + classic personal access token; minimum scopes `repo`, `admin:repo_hook`, `user:email`) | yes | | no |
| OAuth 2.0, Authorization Code (user-level repositories only) | yes | yes | no |
| OAuth 2.0, GitHub App with JWT | yes | yes | **yes** |

Both OAuth grants also work through a MID Server. With JWT, **one GitHub App = one organization = one tool**.

Connection and credential aliases `DevOpsAlias1` to `DevOpsAlias10` are used automatically; for more than 10 OAuth tools an admin creates more aliases in scope `sn_devops` (or frees one by inactivating its HTTP connection).

### GitHub App with JWT (role `oauth_admin`)

1. GitHub **Developer Settings > GitHub Apps**: **Homepage URL** `https://<instance>.service-now.com`; **User authorization callback URL** `https://<instance>.service-now.com/oauth_redirect.do`; clear *Expire user authorization tokens*; webhook **Active** with URL `https://<instance>.service-now.com/api/sn_devops/v2/devops/tool/apps?toolId=<tool sys_id>` (can be filled in later with **Configure GitHub App > Auto configure with existing token** on the tool record).
2. Repository permissions: Actions, Checks, Contents, Environments, Metadata, Pull requests, Secrets = Read-only; **Deployments** and **Webhooks** = Read and write. Subscribe to event *Deployment protection rule*. Changing permissions later requires accepting them on the installed app.
3. Generate a private key; install the app on the account or organization (all or selected repositories).
4. Build a Java KeyStore from the private key: `openssl req -new -x509 -key <key>.pem -out <cert>.pem -days 1095`, then `openssl pkcs12 -export -in <cert>.pem -inkey <key>.pem -certfile <cert>.pem -out <file>.p12`, then `keytool -importkeystore -srckeystore <file>.p12 -srcstoretype pkcs12 -destkeystore <file>.jks -deststoretype JKS`.
5. Instance: **System Definition > Certificates > New** (**Type** Java Key Store, key store password, attach the `.jks`, **Validate Stores/Certificates**).
6. **System OAuth > JWT Keys > New** (signing keystore = that certificate, **Signing Algorithm** RSA 256, signing key password).
7. **System OAuth > JWT Providers > New** (signing configuration = the key); in Standard Claims set `iss` = the GitHub **App ID**; leave `aud` and `sub` empty.
8. **System OAuth > Application Registry > New > Connect to a third party OAuth Provider**: client id and secret (`<CLIENT_ID>`, `<CLIENT_SECRET>`), **OAuth API script** = `OAuthDevOpsGitHubJWTHandler`, **Default Grant type** = JWT Bearer, **Token URL** `https://api.github.com/app/installations/<installation_id>/access_tokens` (Enterprise Server: `https://<host>/api/v3/app/installations/<installation_id>/access_tokens`; the installation id is in the URL of the installed app's settings page). On the default OAuth entity profile set **JWT Provider**.
9. **Key Management > Module Access Policies**: the policy with crypto module `com_snc_platform_security_oauth_glideencrypter` and target script include `OAuthDevOpsGitHubJWTHandler` must have **Result** = Track.
10. **Connections & Credentials > Credentials > New > OAuth 2.0 Credentials** with that profile.

In the workspace playbook the same values can be entered directly (JKS certificate, signing key, App ID, client id and secret, token URL). Optional **GitHub app slug name** enables the permission check before connecting.

### GitHub App with Authorization Code

As above but: webhook **not** active; Application Registry **OAuth API script** = `OAuthDevOpsGitHubHandler`, grant type Authorization Code, URLs `https://github.com/login/oauth/authorize` and `https://github.com/login/oauth/access_token` (own host for on-premises); the credential record (roles admin, `credential_admin`) needs **Applies to** MID Servers and **Order**, then **Get OAuth Token**.

## GitHub Actions

Secrets to create in the repository or organization:

| Secret | Value |
|---|---|
| `SN_INSTANCE_URL` | `https://<instance>.service-now.com` |
| `SN_ORCHESTRATION_TOOL_ID` | sys_id of the GitHub tool record |
| `SN_DEVOPS_INTEGRATION_TOKEN` | the tool's secret token (**Copy token** on the tool record) |

Workflow rules: files in `.github/workflows` with `.yml` or `.yaml`; the workflow name equals the file name; every job has a unique display name, which must equal the stage name passed to the custom action; `workflow_dispatch` for manual runs.

What arrives: `workflow_job` notifications with status queued, in_progress (ignored) and completed. From queued and completed events, pipeline steps and orchestration tasks are created per job; each run becomes a pipeline execution with task and step executions.

### Custom actions (GitHub Marketplace; step level, `uses:`)

| Action | Does |
|---|---|
| `servicenow-devops-change` (Change Automation) | creates the change, sets Change control on the step, polls for the decision. Parameters named: `changeCreationTimeOut` + `abortOnChangeCreationFailure`, `timeout` + `abortOnChangeStepTimeout`, `deployment-gate`. With change receipt the workflow continues at once |
| Get Change / Update Change | read the change number; update the change |
| `servicenow-devops-register-artifact`, `servicenow-devops-register-package` | artifacts and packages (**DevOps > Artifact**) |
| `servicenow-devops-test-report` | unit test results (**DevOps > Test Results > Test Summaries**) |
| `servicenow-devops-sonar` | SonarQube results; secrets `SONAR_HOST_URL`, `SONAR_PROJECT_KEY`; needs the SonarQube tool record |
| Security Results | security scan results |

Docker images can be used instead of the Marketplace actions. The console shows the change number with status `pending_decision` while polling, then the same change details and policy decision lines as described in [[DevOps Azure DevOps Integration]].

### Deployment gates (JWT only)

1. Repository **Settings > Environments > New environment**; under **Deployment protection rules** select the installed GitHub App.
2. In the change job pass `deployment-gate: '{"environment":"<environment name>","jobName":"<deploy job name>"}'`; the deploy job depends on the change job.
3. The workflow run is paused and resumed from ServiceNow when the change reaches Implement. Pause and resume by callback works **only** with deployment gates.

### Reruns and limits

- A change is reused on rerun only if it is in Implement or post-implement; if it was already implemented before the failure the rerun is not stopped again.
- Composite workflows with the change step in the child: `job-name: '<parent-job-name> / <child-job-name>'` (spaces around the slash are mandatory).
- Change automation is **not supported for parallel jobs** (the webhook carries no sequence).
- Actions and environments need GitHub Enterprise Server 3.3 or later; environments for private repositories only in Enterprise Cloud.
- Only the latest scan results of a run can be pulled. The user who created the tool must be a reviewer to approve workflows for environments.

## Related

- [[DevOps Change Velocity Setup and Onboarding]] · [[DevOps Azure DevOps Integration]] · [[DevOps GitLab Integration]]
