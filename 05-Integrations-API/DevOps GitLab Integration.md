---
type: concept
tags: [concept, change, integrations, api, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > "GitLab integration with DevOps Change Velocity" (pp. 1029-1054), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps GitLab Integration

**In one line:** connecting GitLab (on-premises 13.x and later, or cloud) to DevOps Change Velocity for plans (issues), code (repositories) and orchestration (basic pipelines; multi-project pipelines are not supported).

Common onboarding pattern: [[DevOps Change Velocity Setup and Onboarding]].

## Key points

- A pipeline must have run to completion once before change control is enabled.
- **Pipeline reruns are not supported.**
- A manual job that is cancelled or times out leaves its change open until the approval is finished by hand.
- Discovery uses a project search filter and returns the first 100 results: *Owned by me* (recommended), *Currently member of*, or a text search; widen it to find more. What is found also depends on the credential's access.
- A milestone becomes a release version. Repositories or pipelines created after discovery must be tracked by hand.
- Tests: JUnit report format only.
- Upgrading to 5.0.0: reconfigure the tool to receive issue events.

## Authentication

- **Basic**: username + personal access token with scope `api` and read/write on groups, projects, container registry and package registry.
- **OAuth 2.0 (Authorization Code)**, role `oauth_admin`:
  1. GitLab **Edit Profile > Applications**: redirect URI `https://<instance>.service-now.com/oauth_redirect.do`, scope `api`.
  2. Instance **System OAuth > Application Registry > New > Connect to a third party OAuth Provider**: client id = GitLab Application ID, client secret (`<CLIENT_SECRET>`), **OAuth API script** = `OAuthDevOpsGitLabHandler`, URLs `https://gitlab.com/oauth/authorize` and `https://gitlab.com/oauth/token` (own host on-premises); check the `api` scope in OAuth Entity Scopes.
  3. **Connections & Credentials > Credentials > New > OAuth 2.0 Credentials**, then **Get OAuth Token**. The user doing this needs GitLab Maintainer (project webhooks) or Owner (group webhooks) so webhooks can be configured automatically.

## Webhooks

| Capability | Trigger events |
|---|---|
| Code | Push events, Tag push events, Comments, Merge request events |
| Orchestration | Job events, Pipeline events |
| Planning | Issues events, Confidential issues events |

Manual: **Project > Settings > Webhooks**, one webhook per capability with the capability-specific URL and the **Secret Token** (needs Maintainer or higher).

## Modelling

**Orchestration pipeline** = `<Group>/<Subgroup>/<Project>` (or just the project). Steps are created on the first run, or by hand with **Orchestration stage** = the GitLab job name (case-sensitive).

## Change control

Two ways:

1. **ServiceNow Docker image** (`servicenowdocker/sndevops:<version>`) with the CLI, for example a job whose script runs `sndevopscli create change -p '{"changeStepDetails":{"timeout":3600,"interval":100},"attributes":{...},"autoCloseChange":true}'`. This is the way that supports **parallel jobs** (`needs:`).
2. **Manual jobs**: enable change control on the step in DevOps and give the GitLab job `when: manual` and `allow_failure: false`.

| Manual job | Change control on the step | Change approved | Result |
|---|---|---|---|
| yes | yes | yes | the job is run automatically |
| yes | yes | no | the job is rejected / failed |
| yes | no | | waits for someone in the GitLab UI (GitLab default) |
| no | yes | | no change request is created |

- With `when: manual`, every earlier stage must have completed successfully or no change is created.
- `allow_failure: true` lets the pipeline continue after a rejection.
- Anyone with the right GitLab role can unblock the pipeline whatever the change says.
- Parallel jobs are shown sequentially, in queue order.

## Merge (pull) requests

Tracked by default (DevOps property *Enable to track GitLab pull (merge) requests...*). Create, update, close, reopen and merge are captured, plus comments (latest only; edits and deletes are not). At most 100 commits are shown. Emails default to `<user_name>@noreply.gitlab.com`.

To block a merge until the change is approved:

1. Use the Docker image for the change step.
2. GitLab **Settings > Merge requests** (13.x: **Settings > General > Merge requests**): select *Pipelines must succeed*.
3. In the `.yml`, restrict the pipeline or the job with `rules: - if: $CI_PIPELINE_SOURCE == 'merge_request_event'`.

The merge request data is linked to the change and can be used in the approval policy.

## Bulk commits

Plugin `com.glide.hub.action_type.datastream`; `com.snc.process_flow.reporting.level` = Off. The push webhook carries at most 20 commits: with 20 or more, the original inbound event is marked ignored and new events of 19 commits each are created. Up to 10,000 commits per push.

## Related

- [[DevOps Change Velocity Setup and Onboarding]] · [[DevOps GitHub Integration]] · [[DevOps Jenkins Integration]]
