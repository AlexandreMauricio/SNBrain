---
type: concept
tags: [concept, task, incident, problem, change, knowledge, ui-action, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Creating many-to-many task relations" (pp. 540-544), read 2026-10-01. The guide warns its script examples are illustrative and may not work on all instances
sn-release: Australia
verified:
updated: 2026-10-01
---

# Many-to-many task relations

**In one line:** beyond parent/child, the Many to Many Task Relations plugin records *what kind* of relationship two tasks have (caused by, solved by, related to), and links tasks to knowledge articles.

## How it works

- Plugin **Many to Many Task Relations** (`com.snc.task_relations`). Included with Planned Task, Field Service Management, Project Management and Governance, Risk, and Compliance; can also be requested alone (**System Applications > All Available Applications > All**, **Request plugin**).
- Adds the **Task Relationships** application:

| Module | Holds |
|---|---|
| Relationship Types | the possible relationship types between tasks |
| Relationships | the actual relationships between tasks |
| Knowledge Relation Types | types of relationship between articles and tasks |
| Knowledge Relationships | actual article-to-task relationships |

- Each type has a **Parent descriptor** and a **Child descriptor**; the name is `Parent::Child`. Default types: Solution is documented in::Documenting solution for, Caused by::Causes, Contains::Task of, Documenting Solution for::Solution is documented in, Investigated by::Investigates, Permanent correction for::Permanently corrected by, Related to::Related to, Requesting::Requested by, Solved by::Solves.
- On a type, the related list **Task Relationship Allowed** says which parent and child **tables** may use it, with optional scripts that auto-create the other task.
- **Mark as Solution**: shown in the knowledge pop-up when searching the knowledge base from a task. It creates a row in Task / KB Relationships (`task_rel_kb`). Disable by deactivating the `solution_button` UI macro.

## Where it lives in the data

- `task_rel_task`: one row per task-to-task relationship. Fields used in the guide's scripts: `parent`, `child`, `type`.
- `task_rel_kb`: task to knowledge article.

## Creating a relationship from a UI action

The guide's pattern (a UI action on Change Request that logs an incident caused by the change):

```javascript
// server-side UI action on change_request; names are placeholders
var inc = new GlideRecord('incident');
inc.short_description = current.short_description;
inc.insert();

var rel = new GlideRecord('task_rel_task');
rel.initialize();
rel.child = current.sys_id;      // the change
rel.parent = inc.sys_id;         // the new incident
rel.type.setDisplayValue('Caused by::Causes');
rel.insert();

gs.addInfoMessage('Incident ' + inc.number + ' created');
action.setRedirectURL(current);
```

The same shape is used for "cause a problem" (from a change) and "fix a problem" (a change created from a problem).

## How to define a type

1. **All > Task Relationships > Relationship Types**, **New**.
2. Fill **Parent Descriptor** and **Child Descriptor** (e.g. *Caused By* and *Causes*) and save; **Name** fills itself.
3. In **Task Relationship Allowed**, add the parent and child tables. Role: admin.

## Related

- [[task]] · [[Create a Many-to-Many Relationship]] (the generic platform feature)
