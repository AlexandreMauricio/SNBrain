---
type: reference
tags: [reference, incident, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topics "Incident Management properties", "Refresh impacted services and CIs for incident", "Email notification redirection" (pp. 2427-2433, 2444-2445, 2484-2485), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Incident properties reference

**Where:** Incident > Administration > Incident Properties (major incident ones: Incident > Administration > Major Incident Properties). Role admin or `incident_manager`.

## Closure and reopen

| Property | Default | Effect |
|---|---|---|
| `glide.ui.autoclose.time` | (days) | days after which Resolved incidents are closed; 0 disables |
| `com.snc.incident.autoclose.basedon.resolved_at` | true on new instances | count the days from **Resolved**; false = from **Updated** |
| `com.snc.incident.incident_task.closure` | true on new instances | close open incident tasks when the incident is closed or canceled |
| `com.snc.incident.incident_alert.closure` | false | close open communication plans with the incident |
| `com.snc.iam.incident_alert_task.closure` | false | close communication tasks with their plan |
| `com.snc.incident.clone_fields_on_reopen` | list | fields copied into the new incident when a closed one is "reopened" by email |

## Copy and child incidents

| Property | Effect |
|---|---|
| `com.snc.incident.copy.enable` | show **Copy Incident** |
| `com.snc.incident.create.child.enable` | show **Create Child Incident** |
| `com.snc.incident.copy.attach` | copy attachments too |
| `com.snc.incident.copy.attributes` | fields copied |
| `com.snc.incident.copy.related_lists` | related lists copied (only `task_ci`, `task_cmdb_ci_service`, `task_service_offering`, `task_cmdb_ci_business_app`) |
| `com.snc.incident.copy.rl.task_ci.attributes`, `com.snc.incident.copy.rl.task_cmdb_ci_services.attributes` | columns copied from those lists |

## Form and activity

| Property | Effect |
|---|---|
| `glide.ui.incident_activity.fields` | fields shown in the activity formatter |
| `glide.ui.incident_activity.style.comments` / `.work_notes` | styling |
| `com.snc.incident.communicate_prb_workaround_to_inc_worknotes` | a problem's shared workaround/fix goes to work notes instead of customer-visible comments |
| `com.snc.incident.create_from_interaction.save` | incident created from an interaction is saved immediately (true on new Australia instances) |
| `com.snc.incident.create_from_interaction.copy_attachments` | copy the interaction's attachments |
| `com.snc.problem.create_from_incident.attributes` | fields copied to a problem created from an incident |
| `com.snc.incident.ci_assignment_group.field_name`, `com.snc.incident.service_offering_assignment_group.field_name` | (add) which CI / offering field fills **Assignment group** |

## Impacted services

| Property | Effect |
|---|---|
| `com.snc.incident.refresh_impacted.include_affected_cis` | populate Impacted Services from Affected CIs |
| `com.snc.incident.refresh_impacted.event` | run the refresh in the background by event |
| `com.snc.incident.populate_business_application` | fill the Business Applications related list |
| `com.snc.incident.populate_service_offering` | fill the Service Offerings related list |
| `com.snc.incident.refresh_impacted_services.message.show` | show the "refresh initiated" message |

## Major incident (plugin `com.snc.incident.mim`)

| Property | Effect |
|---|---|
| `sn_major_inc_mgmt.com.snc.incident.mim.major_incident_creation` | *Create new* (a new parent major incident, the candidate becomes its child) or *Promote* (the candidate itself becomes the major incident) |
| `sn_major_inc_mgmt.major_incident_management_group` | sys_id of the group that receives major incidents |
| `sn_major_inc_mgmt.com.snc.major_incident.create.copy.attributes` | fields copied from the child when a new major incident is created |
| `sn_major_inc_mgmt.com.snc.incident.mim.compose_email_on_iatasks` | communication task types with **Compose Email** on the workbench |
| `sn_major_inc_mgmt.pir_export_pdf_ui_page` | custom UI page for the post incident report |
| `sn_comm_management.default_email_recipient_field` | recipients go in BCC by default |
| `sn_major_inc_mgmt.notify_webrtc_number` | Notify number used by **Start a call** |

## Links in notifications

`sow_email_notification_redirect` (all tables) or `sow_email_notification_redirect.incident` (add; overrides for incident) = true: record links in emails open in Service Operations Workspace for users with `sn_sow.sow_user`. Major incidents: `sn_major_inc_mgmt.sow_email_notification_redirect.mim`.

## Related

- [[Incident Management Overview and Lifecycle]] · [[Major Incident Management]] · [[System Properties]]
