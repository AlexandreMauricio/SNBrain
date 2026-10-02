---
type: meta
tags: [meta]
status: documented
source: own
updated: 2026-10-01
---

# Index: Tables

One note per table, named with the exact table name. Overviews spanning a family of tables go here too.

<!-- One line per note: [[Note Name]] - short description -->
- [[task]] - Task: base class of all work records, common fields and features (documented)
- [[planned_task]] - Planned Task: duration, effort, cost and rollup fields for projects and releases (documented)
- [[reminder]] - Reminder: timed reminders against a task date field (documented)
- [[sys_db_object]] - Tables: one record per table (documented, column names not given)
- [[sys_dictionary]] - Dictionary Entries: one row per table and per column (documented)
- [[sys_documentation]] - Field Labels, the language file (documented)
- [[sys_storage_alias]] - Storage Column Aliases: logical field to physical column mapping (documented)
- [[sys_auto_flush]] - Auto Flush: table cleanup rules (documented, column names not given)
- [[sys_user]] - User: login, identity type, active and locked out flags (documented, few column names given)
- [[sys_user_group]] - Group: manager, type, parent, email options (documented, column names not given)
- [[sys_email]] - Email: every message sent or received, types and states (documented, column names not given)
- [[sysevent]]: event log and queue
- [[incident]] - Incident: caller, category, resolution, parent incident, major incident fields, state values (documented, some column names unconfirmed)
- [[incident_task]] - Incident Task: work under an incident, closure cascade (documented)
- [[problem]] - Problem: resolution code, workaround, cause and fix notes, state values 101-107 (documented, some column names unconfirmed)
- [[problem_task]] - Problem Task: root cause analysis and general tasks, state values 151-157 (documented)
- [[change_request]] - Change Request: type, risk, planning and CAB fields, conflict status, state values -5 to 4 (documented, some column names unconfirmed)
- [[change_task]] - Change Task: task types, on hold, how tasks follow the change (documented)
- [[task_sla]] - Task SLA: stage, breach time, actual and business timings; related SLA tables (documented, most column names unconfirmed)
