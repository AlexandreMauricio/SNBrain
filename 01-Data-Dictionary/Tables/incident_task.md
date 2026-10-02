---
type: table
tags: [table, incident, task, schema]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topics "Create an incident task", "Synchronization between an incident and its incident tasks" (pp. 2472-2473), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# incident_task

**Label:** Incident Task
**Extends:** [[task]]
**Purpose:** a piece of work under an incident, used to ask another assignment group for help without reassigning the incident.

## Own columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Incident | `incident` | reference [[incident]] | the parent |

Everything else used on the form is inherited: **Number**, **Configuration item**, **State**, **Priority**, **Assignment group**, **Assigned to** (cleared when the group changes), **Short description**, **Description**, **Work notes**, **Work notes list**.

## Behaviour

- Created from the **Incident Tasks** related list or the form context menu **Create Incident Task**.
- A closed incident task is read-only.
- With property `com.snc.incident.incident_task.closure` = true: closing the incident sets open tasks to **Closed Incomplete**; cancelling the incident sets them to **Closed Skipped**.
- Role `sn_incident_task_assigned_user` gives the assignee read/write on their task.
- Domain separated.

## Used in

- [[Incident Management Overview and Lifecycle]]
