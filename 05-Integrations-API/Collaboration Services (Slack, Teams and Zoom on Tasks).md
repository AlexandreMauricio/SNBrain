---
type: concept
tags: [concept, integrations, incident, notifications]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Collaboration services" (pp. 809-821), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Collaboration services: Slack, Teams and Zoom on tasks

**In one line:** the Collaboration services application (`sn_tcm_collab_hook`) lets agents open a Slack channel, Teams chat or Zoom Team Chat from a task record, import the conversation back into the record, and use those tools as channels in communication plans.

In Service Operations Workspace the same capability is delivered through `com.snc.uib.collaboration` (see [[Service Operations Workspace Admin Center and Process Setup]]); this note is the classic-UI and Slack side.

## What it needs

| Tool | Requires |
|---|---|
| Slack | *Slack Spoke for ServiceNow IntegrationHub* (`com.sn.slack.ahv2`, 1.3+) and an IntegrationHub licence; a custom Slack app that issues OAuth 2.0 tokens (use `<CLIENT_ID>` / `<CLIENT_SECRET>` placeholders in notes), with interactivity, shortcuts and slash commands configured |
| Microsoft Teams | *ServiceNow for Microsoft Teams* (ITSM or HR integration app) |
| Zoom | *ServiceNow for Zoom* |

Tables (installed with Task Communications Management, `com.snc.task_communication_management`): `comm_channel_def_slack` (extends `comm_channel_definition`), `comm_channel_slack` (extends `comm_channel`), `comm_plan_collab_data`.

## Slack on a task

- Property `sn_tcm_collab_hook.slack_on_task`: comma-separated task tables where the Slack features show; default `incident` (add `problem`, `change_request`...).
- **Create Slack Channel** (related link on an active incident): participants (users or groups; duplicates removed), **Channel name**, **Channel topic**, a message, **Private channel**. Participants get an invitation with **Join Channel** / **Skip**.
- **View Slack Channels** (related link, or add *View Slack Channels* as a form section): **View channel**, **Join channel** (public only), **Import messages**. Channels are **archived** when the incident becomes inactive.
- **Import messages**: search (optionally in reply threads), filter by sender or date, import as **Additional comments** or **Work notes**, optionally with attachments. Roles `sn_incident_write`, itil or admin; you must be a member of a private channel and your instance email must match your Slack account. Needs Collaboration Services 3.04+ and Slack app 1.4+.
- **Slack icon next to Caller, Assignment group, Assigned to**: run fix script *Add Slack Field Decorator* (shipped in the update set *Fix script to add Slack field decorators*; edit the table and fields in it first; server-side fix script, global). The icon opens a direct message, or the group's channel.
- A group's channel is registered in **Slack > Slack Channel Cache** (role `sn_slack_ah_v2.slack_admin`): **Channel Name**, **Channel ID**, **Channel Link** (`slack://channel?team=<TEAM_ID>&id=<CHANNEL_ID>`), **Document ID** = the group (`sys_user_group`), **Is Archived**, **Is Private**. Prefer public channels: a private one breaks the link for non-members.

### Slash commands

Users need `sn_incident_write`, itil or admin.

| Command | Does |
|---|---|
| `/now help` | lists the commands |
| `/now create incident` | creates an incident from the prompts |
| `/now list incidents` | active incidents assigned to you |
| `/now oncall [group name]` | current shifts and on-call members (itil or admin) |
| `/now comment [text]`, `/now note [text]` | only in a channel tied to an incident: adds a comment / work note |
| `/now assigntome`, `/now assign [@slack_user]` | only in such a channel: assigns the incident |

## Slack in communication plans

- **Incident > Communication Plan Definitions** > plan > communication task definition > related link **Add Channel - Slack**.
- Sending from the major incident workbench (**Communicate > Compose**) is **one-way**: recipients cannot reply to the sender through it, and they must be employees whose Slack email is their organisation email.
- Subflows: *TCM Slack - Create Channel*, *Add Users to Channel*, *Send Message*, *Remove User From Channel*, *Archive Channel*.
- Collaborative communication task (workbench **Collaborate > Add**, role `major_incident_manager`): plan, task description, **Channel** = Slack chat, **Frequency**, **Due in (Minutes)**, recipients; then **Initiate** creates the channel (**View channel**, **Import messages**).

See [[Incident Communications Management]] and [[Major Incident Management]].

## Teams and Zoom

Start a chat from a task; import message history (Teams: manually or automatically); individual notifications and collaboration in incident and major incident communication plans. Employee Center can also be shown inside Zoom.

## Related

- [[Working Records in Service Operations Workspace]] · [[On-Call Scheduling]]
