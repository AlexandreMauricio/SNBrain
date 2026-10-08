---
type: concept
tags: [concept, security, data-management, forms-lists, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy (chapter read in full 2026-10-08) - Real time protection, Real time protection policies, User sensitive data logs, Alert data patterns, Attachment quarantine policies, Attachment scan findings. https://www.servicenow.com/docs/r/platform-security/data-privacy-classic/real-time-protection.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Real Time Protection - Alerts, Blocking and Attachment Quarantine

**In one line:** real time protection checks what a user types into a chosen field, or uploads as an attachment, against sensitive data patterns and then warns the user, blocks the save, or quarantines the file.

From the Brazil docs. Part of [[Data Privacy Overview]]. Menu: **All > System Security > Data privacy > Real time protection**. Role `data_privacy_admin` (attachment pages: plus `admin`).

- Enforced only for **interactive user sessions**: not for background scripts, integrations or instance data replication.
- A policy on a parent table's column applies to the child tables: a policy on the **Description** (`description`) of Task (`task`) covers incident.

## Alert data patterns (create these first)

**Alert data patterns > Create new**: a name and up to **10** data patterns. A reusable group; some come with the base system.

## Real time protection policies

**Real time protection policies > Create new policy**:

| Field | Notes |
|---|---|
| **Policy name** | |
| **Table**, **Column** | one table and one column per policy |
| **Action** | **Alert** (warn only) or **Alert and block** (warn and prevent the save) |
| **Alert data pattern** | the group to detect |
| **Display message** | what the user reads when blocked |
| **Active** | |

Under each policy: **View details**, and **View logs**: the top 100 activity logs of the last month with table, column, data pattern, user and action (Alert or Block).

A default alerting policy on task work notes and comments is active from installation: see [[Data Privacy Overview]].

## Attachment quarantine

**Attachment quarantine policies > Create new policy**: name, **Active**, **Add table** (several allowed), the data patterns to look for, **Save**, **Confirm**. A matching attachment is quarantined and the user sees an *Attachment Quarantined* message with the scan result and how to ask for release.

**Attachment findings** list policy, source table, record, attachment, data pattern and status:

| Status | Meaning | Download |
|---|---|---|
| Pending | not scanned yet, or the scan failed while `dp.pii.document.download.allowed` is false | no |
| Available | scanned, nothing found | yes |
| Available conditionally | scan failed while `dp.pii.document.download.allowed` is true | yes, unscanned |
| Quarantined | sensitive data found | no, until an administrator releases it |

- A background job rescans Pending and Available attachments once; if that fails the file cannot be downloaded.
- A quarantined file's name may still look clickable; the download is refused with a message.
- Release: tick the attachments > **Mark as available** > confirm.

Malware scanning of attachments is a different feature: [[Antivirus Scanning]].

## Related

- [[Data Privacy Overview]] · [[Data Discovery - Patterns, Policies, Jobs and Findings]] · [[Data Privacy Channel Policies - AI Prompts, Inbound Email and Virtual Agent]] · [[Antivirus Scanning]]
