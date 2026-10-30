---
type: concept
tags: [concept, ai, roles, workspace, task, release-specific]
status: documented
source: ServiceNow Brazil docs, Conversational Interfaces > Manage people and work > Advanced Work Assignment (105 topics; Explore overview, roles, table names), Agent Chat (31), Sidebar (28), Proactive Triggers (17), Conversational Interfaces Console (17), landing and section overviews, read 2026-10-30. Step pages, Omnichannel Callback and the Diagnostic Tool not read. https://www.servicenow.com/docs/r/conversational-interfaces/advanced-work-assignment/awa-roles-1.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Advanced Work Assignment and Live Agent Tools

**In one line:** Advanced Work Assignment (AWA) pushes work to qualified agents by availability, capacity and skills, instead of agents picking from a queue; Agent Chat and Sidebar are the tools they use to talk to requesters and each other.

From the Brazil docs; not tested. Compare [[Workforce Optimization for ITSM]].

## How AWA works

1. A request through any channel creates a task or interaction: a **work item**.
2. A **service channel** routes it to a **queue**, by need or type.
3. **Assignment rules** with availability, capacity and optionally skills choose the agent in the queue's groups.
4. The item appears in the agent's **inbox** in the workspace.

**Capacity** is the number of items assigned at once per channel. **Presence states** set availability; **reject reasons** record refusals. **Wrap up** records closing details and codes. **Group queue priorities** decide which queues a limited group serves first. **External routing** lets a third-party system complete assignment.

**Start:** **Advanced Work Assignment > Home**. Installing plugins from there needs `admin`, not `awa_admin`.

## Roles and tables

| Role | Can |
|---|---|
| `awa_admin` | configure and manage AWA |
| `awa_manager` | monitor agent performance across channels |
| `awa_agent` | handle work; assign with `workspace_agent` |
| `awa_integration_user` | use AWA integration APIs |

Tables: `awa_service_channel`, `awa_queue`, `awa_assignment_rule`, `awa_work_item`, `awa_presence_state`, `awa_reject_reason`, `awa_inbox_layout`, `awa_work_item_rejection`, `awa_queue_item_sorting`.

The docs mention `sys_admin` for the home page install; that name is unconfirmed.

## Agent Chat

Live agents chat with end users in the workspace. Agents go Available or Away to open or close the inbox; managers monitor and assist. Works with [[Virtual Agent Overview and Assistant Designer|Virtual Agent]] handoff.

## Sidebar

Real-time collaboration between agents, standalone or linked to a task or interaction record from a workspace.

## Proactive Triggers

Store application, included for Virtual Agent chat widget and Agent Chat customers. Rules show rich text pop-ups to chosen users based on real-time data.

## Conversational Interfaces Console

The home-page experience for setting up these interfaces, including **Chat Settings**.

## Example

Create service channel *Example Incident Channel*, queue *Example Network Queue* for group *Example Group*, and give *Test User* `awa_agent` and `workspace_agent`. A new matching incident appears in their inbox once they are Available.

## Related

- [[Virtual Agent Overview and Assistant Designer]] · [[Service Operations Workspace for ITSM]] · [[Working Records in Service Operations Workspace]]
