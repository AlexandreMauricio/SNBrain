---
type: concept
tags: [concept, change, integrations, api, security, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > SonarQube, Split.io, Veracode and Checkmarx integrations, user-created integrations, tool mappings and test tool integration (pp. 1181-1228 and 1236-1244), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Quality, Security and Other Tool Integrations

**In one line:** bringing code quality (SonarQube), security scans (Veracode, Checkmarx), feature flags (Split) and test results into DevOps Change Velocity so they can feed change policies, plus how to integrate a tool that has no shipped connector.

Pattern: [[DevOps Change Velocity Setup and Onboarding]].

## SonarQube / SonarCloud (software quality)

- Scans run in GitHub Actions, Jenkins or Azure DevOps pipelines. Overall and new-code metrics are captured. Results show on the change (Software Quality Results) and the task execution, and can be used in policies.
- Connect with URL (no trailing slash), username and token.
- Admin token: project-level access. **Non-admin token**: set DevOps property *DevOps Non-Admin Software Quality Summary Flag* = Yes; the user needs Browse (GitHub, GitLab, Azure DevOps) or Execute Analysis (Jenkins) on the projects, and the branch must already exist in SonarQube (branch analysis needs Developer or Enterprise edition, or SonarCloud).
- Tool-side: [[DevOps Azure DevOps Integration]] (Sonar Registration tasks), [[DevOps GitHub Integration]] (`servicenow-devops-sonar`), [[DevOps Jenkins Integration]] (plugin).

## Veracode and Checkmarx (security)

Plugins: DevOps Vulnerability Integrations (`sn_devops_vul_ints`) plus Vulnerability Response Integration with Veracode (`sn_vul_veracode`), Checkmarx One Vulnerability Integration (`x_chec3_chexone`) or Checkmarx CxSAST Vulnerability Integration (`x_chec3_cxsast`). Installing them adds `sn_vul.app_sec_manager` (and `sn_vul_veracode.configure_integration`) to `sn_devops.tool_owner`.

| Tool | Connection | Tool-side permission |
|---|---|---|
| Veracode | **API id**, **API key** | API roles *Upload and Scan* and *Results* |
| Checkmarx SAST | **Server URL**, API id, API key | role that can read Project and Scan Results |
| Checkmarx One | **Access Control Base URL**, **API Base URL**, **Tenant**, **Client Id**, **Client Secret** | roles `create-scan` and `manage-project`; SAST scans only, not SCA |

With more than one security tool instance, the playbook asks which orchestration tool to associate (one security tool instance per orchestration tool or pipeline); association can also be done from the security tool's *Orchestration tools* tab or the orchestration tool's or pipeline's *Security tools* tab. With a single instance, pipelines are associated automatically on their first run.

### The pipeline step

`securityResultAttributes` JSON:

| Scanner | Attributes |
|---|---|
| `Veracode` | `applicationName` (required), `buildVersion` (optional: scan name) |
| `Checkmarx SAST` | `projectId` (required) |
| `Checkmarx One` | `projectName` or `projectId` (required), `scanId` (optional) |
| all | `securityToolId` (optional: sys_id of the security tool; overrides the association) |

| Orchestration tool | How |
|---|---|
| Azure DevOps | task *ServiceNow DevOps Build / Release Security Results*; always required |
| GitHub Actions | action `ServiceNow/servicenow-devops-security-result`; always required |
| Jenkins | `snDevOpsSecurityResult securityResultAttributes: '{...}'`. Not needed when the pipeline already has a Veracode scan step with `waitForScan: true`, or a Checkmarx One step (`checkmarxASTScanner`). Checkmarx SAST always needs it |
| GitLab, Harness | Docker image: `sndevopscli create securityScan -p '{"pipelineInfo":{...},"securityResultAttributes":{...}}'` (Harness: only this way) |

### Where results are stored

| Table | Columns |
|---|---|
| Application Vulnerability Scan Summary (`sn_vul_app_vul_scan_summary`) | **Source**, **Detected Flaw Count**, last scan date and rating overall and per static, dynamic and interactive scan |
| Application Vulnerability Scan Summary Details (`sn_vul_app_vul_scan_summary_details`) | **Category name**, **Severity**, **Count** |

Shipped policy behaviour: action *Fetch Risk Sonar Security and Incident data* in subflow *DevOps Gather Change Policy Data* of the *DevOps Default Change Request* flow; a Veracode or Checkmarx severity of HIGH or VERY HIGH **auto-rejects** the change. Customise by editing that action's script against the details table.

## Split.io (feature flags)

Change approval for feature flag and segment changes. Classic onboarding only; needs the integration user.

1. In Split: **Admin Settings > Integrations**, add *ServiceNow DevOps* (generates the token used as the tool password); in the workspace environment set **Change permissions** = *Require approvals for changes > Restrict who can approve* = that integration.
2. Tool record: URL `https://api.split.io`, username, token. **Discover** workspaces, environments, segments and feature flags; **Configure** creates the webhook.
3. A change in Split creates an inbound event (Requested, Approved, Rejected, Withdrawn), a **Feature Flag Request** (**DevOps > Feature Flag > Feature Flag Requests**) and a change request; the decision calls Split's callback URL so the flag update proceeds or not.

## User-created integrations

For planning, coding or test tools without a connector.

| Who | Does |
|---|---|
| Integration developer | a **tool integration** record (defines the source tool); a Workflow Studio **subflow** that transforms the tool's payload; a **tool capability mapping** (integration ↔ capability); an **integration capability** record (the action, with subflow and **Timeout**) |
| DevOps admin | the tool record (field **Tool** = the tool integration); configures webhook and credentials in the source tool |

Actions: **Connect** (subflow updates the connection state), **Discover** (creates an import request whose **Detail** and **Status** report items discovered, updated, failed), **Import** (no historical import for custom tools), **Lookup** (artifact tools), **Notification** (webhook: raw payload → standard JSON; with no subflow the original payload is copied as is, useful when the tool already sends the standard payload). Endpoint: DevOps API `POST /devops/tool/{capability}`.

### Inbound events

An inbound event (`sn_devops_inbound_event`) is the staging record of a notification; one in state Error can be retried.

| Error | Cause / action |
|---|---|
| Missing required fields | transformed payload does not match the standard payload |
| Repository not marked for tracking | track the repository |
| Subflow has not been published within application scope | publish the subflow |
| Timeout exception | subflow ran longer than the integration capability's **Timeout** / property `com.glide.hub.flow_api.default_execution_time` |
| Did not find a matching subflow | check the integration setup |
| Payload does not match the expected capability | the payload's capability differs from the mapping |

No inbound event is created at all when the tool id is missing from the URL or matches no tool.

### Shipped mappings

Capabilities: Plan (Agile Development 2.0, Azure DevOps, Jira, Rally), Code (Azure DevOps, Bitbucket, GitHub, GitHub Enterprise, GitLab), Orchestration (Azure DevOps, Jenkins, GitLab), Test (Azure DevOps, Jenkins). Each mapping has integration capabilities for Connect, Discover, Import and Notification as applicable (Rally also Validate).

## Test results

| Category | Test types |
|---|---|
| Unit | JUnit (default; property `sn_devops.default_test_type`), NUnit, XUnit, Unit test |
| Functional | Integration, Regression, Smoke, System, User Acceptance |
| Performance | Load |

- Jenkins and GitLab: JUnit format only. Azure DevOps, GitHub and GitHub Enterprise: JUnit, NUnit, XUnit, Unit test.
- Selenium tests published with TestNG are reported by the Jenkins plugin. Other tools (for example JMeter) can be handled with a custom subflow or the DevOps API.
- **Test type mappings** (**DevOps > Integrations > Test Type Mappings**) tie a test type and the tested entity to a tool so results are categorised correctly.

## Related

- [[DevOps Change Velocity Setup and Onboarding]] · [[DevOps Planning, Code, Artifact and Deployment Tool Integrations]] · [[Change Approval Policies]]
