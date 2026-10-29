---
type: concept
tags: [concept, forms-lists, roles, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > Response templates (landing with roles, Activate, Components installed with response templates, Create a response template), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/response-templates-templated-snippets.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Response Templates

**In one line:** reusable canned messages (formerly **templated snippets**, plugin **Templated Responses** `com.sn_templated_snip`, scope prefix `sn_templated_snip`) tied to a task-extending table (or **Interaction** `interaction` for chat), with field variables and conditions, that agents copy into case or task fields or call in Agent Chat with `/shortname`.

From the Brazil docs; not tested. Not the same as **form templates** that prefill fields ([[Form Templates]]) nor the email client's response templates on `sys_email` ([[Email Client]]). Available only on existing records.

## Activation

`admin`: **System Applications > All Available Applications > All** > *Templated Responses* > Install (with demo data). Also activates **Scoped Application Restricted Caller Access** (`com.glide.scope.access.restricted_caller`). Agent Chat (`com.glide.interaction.awa`) activates it automatically. With domain separation and delegated admin, install from the global domain.

## Roles

| Role | Can | Contains |
|---|---|---|
| `sn_templated_snip.template_snippet_admin` | scoped administration | (page cut off) |
| `sn_templated_snip.template_snippet_writer` | create, read, update, delete templates | ? |
| `sn_templated_snip.template_snippet_reader` | read and use templates | none |

- `admin` inherits the admin role by default. To stop that: remove it from **Contained Role** (`sys_user_role_contains`), or **sys_store_app_list.do** > *Templated Snippets* > Related Links > remove from the role contained by admin.
- Property `sn_templated_snip.min_admin_count` (default 2) blocks removing the last response template admins.
- Shipped mappings: HRSD (HR administrator → admin, HR manager → writer, HR case writer → reader); CSM (`sn_customerservice_manager` → writer, `sn_customerservice_agent` → reader, sees templates for all their groups).

## Tables

| Label | Name |
|---|---|
| Response Template | `sn_templated_snip_note_template` |
| M2M Response Template to Channel | `m2m_response_template_to_channel` |
| Response Template Channel | `sn_templated_snip_channel` |
| Note Template for Table | `sn_m2m_note_template_for_table` |

## Create or modify (`sn_templated_snip.template_snippet_writer`)

**System Definition > Response template configuration** > New:

- **Name**; **Short Name** (chat shortcut, e.g. `gm` → type `/gm` in an Agent Workspace chat).
- **Table**: extension of Task (`task`), or Interaction for chat. Custom COE tables cannot get the **Copy to Clipboard** UI action (copy and paste still works).
- **Conditions** (depend on the table; for chat: [Type] [is] [Chat]); **Application**; **Group visibility** (empty = all groups).
- **Template body**: plain text only (no rich text); variables from the table's fields (e.g. Subject person on `sn_hr_core_case`), plus `${current_user}` and `${Date}` or the **Insert Current User** / **Insert Current Date** buttons.
- Submit; then the **Channels** related list: the template appears only in the channels added (empty = no channel), so chat, email and form can get different texts.

## Example

A writer creates *Example Escalation Reply* on an HR case table with condition HR service = *Example Service*, body "Hello ${subject_person}, your request has been escalated" (variable inserted from the list), channel *Form*; a case writer with the reader role copies it into the case comments.

## Related

- [[Service Operations Workspace for ITSM]] (writer role in SOW) · [[Incident Management Overview and Lifecycle]] · [[Base System Roles]]
