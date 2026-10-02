---
type: concept
tags: [concept, incident, cmdb, task]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Task Outage" (pp. 3788-3791), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Task outages

**In one line:** an outage (`cmdb_ci_outage`) records the downtime of a CI; the many-to-many table `task_outage` links outages to the incidents, problems or changes that explain them.

Plugin Task-Outage Relationship (`com.snc.task_outage`; installed with [[Major Incident Management]]). Role `sn_task_outage_admin`.

## Creating

On an incident or problem (and change, on instances new since Jakarta): context menu **Create Outage**. Fields: **Configuration Item**, **Type**, **Begin**, **End**, **Duration**, **Task number**, **Short description**. Related links **Begin Outage Now** / **End Outage Now** stamp the current time. The task gets an **Outages** related list.

To link existing tasks to an outage, add the **Tasks** related list to the Outage form and use **Edit**.

## Extending to another task table

UI action **Create Outage** on Task (`task`); condition by default (server-side):

```javascript
current.getRecordClassName() == 'incident' || current.getRecordClassName() == 'problem'
```

Add `|| current.getRecordClassName() == '<table>'`.

## Notes

- Domain separation: Basic; the guide notes `cmdb_ci_outage` relationships are visible across domains.
- An unauthorized change with an outage of type Outage follows the full state path ([[Change Management Overview and Lifecycle]]).

## Related

- [[incident]] · [[Many-to-Many Task Relations]]
