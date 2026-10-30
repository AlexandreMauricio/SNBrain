---
type: concept
tags: [concept, automation, roles, schema, domain-separation, ai, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > RPA Hub (Explore, Getting started, Configure, properties, Reference: components, domain separation, AI limits, glossary start), RPA Desktop Design Studio (Explore), read at overview depth 2026-10-30. Design Studio components (427 topics), plugin methods, Unattended Robot and Attended Robot pages listed, not read. https://www.servicenow.com/docs/r/integrate-applications/create-integrations-applications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# RPA Hub

**In one line:** central control for software robots on Windows machines: build automations in a desktop studio, publish packages, then deploy, schedule and monitor robots from the instance.

From the Brazil docs; not tested. Application `sn_rpa_fdn` from the Store, installed by `admin`, with demo data. Domain separation: Basic. Measured from [[Automation Center]].

## Applications

| Application | Role |
|---|---|
| **RPA Hub** | on the instance; deploys, monitors and manages robots |
| **RPA Desktop Design Studio** | Windows; drag components onto a Design surface, publish packages |
| **Unattended Robot** | Windows or VDI; runs with no person |
| **Unattended Robot Login Agent** | unlocks or logs in the robot machine |
| **Attended Robot** | runs beside a person, started from their desktop or a form |

Interface translation covers the instance only, not these desktop clients. Multi-tenancy gives logical partitions for customers, each with its own access, robots, licences and logs.

## Concepts

- **Bot process:** the sequence of steps a robot follows; one bot process configuration maps to one bot process.
- **Package**, **package version:** the published files.
- **Work queue**, **work item:** data waiting for robots.
- **Process job:** one run; **process schedule:** planned runs.
- **Robot pool**, **credential group**, **robot license distribution** (only one per domain; can be edited but not deleted).
- **Attended configuration:** starts an attended process from a form, with mapped fields.
- **RPA Hub Workspace:** **All > Robotic Process Automation > RPA Hub Workspace**. Properties: **Administration > Properties**.

Robots hear about changes through an AMB channel; packages move through the Attachment Framework REST APIs. RPA roles need read access to `cmdb_rel_ci`.

Security: mTLS or basic authentication for robot machines, code signing for packages (client certificates or exported Active Directory certificates).

## Roles

| Role | Can |
|---|---|
| `sn_rpa_fdn.rpa_admin` | application setup and properties |
| `sn_rpa_fdn.rpa_release_manager` | data, schedules, configuration |
| `sn_rpa_fdn.rpa_developer` | build, test, publish packages |
| `sn_rpa_fdn.rpa_business_user` | work items, credentials, reports |
| `sn_rpa_fdn.rpa_support_user` | first-level troubleshooting |
| `sn_rpa_fdn.rpa_assisted_user` | run attended automations |
| `sn_rpa_fdn.rpa_robot` | service account of the unattended robot |
| `sn_rpa_fdn.rpa_elevated_privileges` | with another RPA role, read sensitive logs |
| `sn_rpa_fdn.rpa_user` | qualifier needed to reach RPA Hub |

Admin, developer and release manager roles also bring `fd_read` or `itil`, and most roles include `cmdb_read`.

## Tables

| Table | Holds |
|---|---|
| `cmdb_ci_rpa_process` | bot process, extends Base Bot Process |
| `cmdb_ci_rpa_robot` | robot, extends Base Robot |
| `sn_rpa_fdn_bot_process_config` | bot process settings |
| `sn_rpa_fdn_package`, `sn_rpa_fdn_package_version` | packages |
| `sn_rpa_fdn_process_job`, `sn_rpa_fdn_execution_log`, `sn_rpa_fdn_automation_log` | runs and logs |
| `sn_rpa_fdn_schedule` | schedules |
| `sn_rpa_fdn_work_queue`, `sn_rpa_fdn_work_queue_item` | queues and items |
| `sn_rpa_fdn_credentials_set`, `sn_rpa_fdn_application_credentials`, `sn_rpa_fdn_credential_group` | credentials |
| `sn_rpa_fdn_external_credential_vault` | external vault |
| `sn_rpa_fdn_attended_configuration`, `sn_rpa_fdn_field_parameter_mapping` | attended start from a form |
| `sn_rpa_fdn_license_distribution` | licences |
| `sn_rpa_fdn_alert`, `sn_rpa_fdn_alert_rule` | alerts |

[[Automation Center]] names `cmdb_ci_base_rpa_robot` and `cmdb_ci_base_rpa_process`, presumably the base classes here. Unconfirmed.

Daily purge jobs: *RPA: Purge Process Jobs*, *Purge Work Items*, *Purge Alert Rule Triggers*, *Purge Alerts*.

## Selected properties

| Property | Meaning |
|---|---|
| `sn_rpa_fdn.instance_authentication` | mTLS or Basic |
| `sn_rpa_fdn.code_signing_required` | default No; validated by the robots |
| `sn_rpa_fdn.enable_code_quality_check` | compliance rule checks |
| `sn_rpa_fdn.allow_rda_robot_auto_assignment` | auto-assign attended robots |
| `sn_rpa_fdn.process.job_purge_days` | job log retention |

## AI

**ServiceNow Otto for RPA Hub** (also written **Now Assist for RPA Hub**): skill **RPA bot generation** builds automations, activities and logic from text, inside Design Studio, with a preview. Needs AI Search. Limits on the page still refer to the *Yokohama* release: only some components are generated, and methods missing from the loaded plugin version appear as unknown components.

## Example

A developer publishes package *Example Invoice Entry*, a release manager creates bot process *Example Invoice Bot* and schedule *Example Nightly Run*, and unattended robot *Example Robot 01* takes items from work queue *Example Invoices*.

## Related

- [[Automation Center]] · [[Task Mining]] · [[Process Mining]] · [[Workflow Studio Overview]]
