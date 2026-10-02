---
type: approach
tags: [approach, task, incident, automation]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 527-530), read 2026-10-01. Comparison built from the guide's own statements; none of the options tested
sn-release: Australia
verified:
updated: 2026-10-01
---

# Auto-assigning tasks: ways to do it

**Problem:** set **Assigned to** and **Assignment group** on a task without a person choosing them.

## Options

### A. Assignment rule
- **How:** see [[Create an Assignment Rule]]
- **Pros:** simple condition builder; works on any task table; optional script.
- **Cons:** runs only on save; only when both fields are empty; never overwrites; only the first matching rule runs.
- **Status:** documented
- **Best when:** routing by a few conditions on first save.

### B. Data lookup rule
- **How:** see [[Create an Assignment Data Lookup Rule]]
- **Pros:** can run on form change, so the user sees the assignment before saving; can replace existing values; can set any field; maintained as rows of data.
- **Cons:** matching is by the lookup table's matcher fields rather than free conditions.
- **Status:** documented
- **Best when:** a matrix of category, subcategory, CI or location decides the team.

### C. Workflow or flow
- **How:** task activities in a workflow, or a flow in Workflow Studio.
- **Pros:** handles multi-step logic, e.g. assign only after a group approves.
- **Cons:** more to build and maintain; a default workflow runs before the record is saved, so the guide adds a short Timer activity first.
- **Status:** documented
- **Best when:** assignment is one step of a longer process.

## Recommendation

Start with **A** for plain routing and **B** when the routing is a lookup matrix or must show on the form before saving. Keep **C** for processes with approvals or several steps. A and B can coexist; after an assignment exists the other is ignored unless the lookup is set to replace values. Where they sit in the processing order: [[Order of Execution for Rules, Engines and Notifications]].
