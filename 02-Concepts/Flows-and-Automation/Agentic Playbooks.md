---
type: concept
tags: [concept, flows, automation, ai, roles]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Agentic Playbooks (read 2026-10-08 through the docs site; whole chapter): Agentic Playbooks, Exploring Agentic Playbooks, Configuring Agentic Playbooks, Using Agentic Playbooks, Agentic Playbooks reference, Agentic Playbooks user roles, Guidelines for writing AI agent instructions. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/agentic-playbooks.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Agentic Playbooks

**In one line:** an ordinary playbook in which some activities are performed by AI agents: the agents gather data and fill the activity's form, and either wait for a person to approve (*Collaborative*) or complete the activity and move on (*Autonomous*).

Playbooks themselves: [[Playbooks Overview and Components]]. The activity settings (child agents, autonomous support, the separate *Use an AI agent* activity) are in [[Playbook Activities, Decisions and Variants]].

## What runs behind it

The agentic workflow **Playbook Activity Assist**, with two shipped agents:

| Agent | Does | Tools |
|---|---|---|
| **Playbook data gathering agent** | finds the data an objective needs and chooses how | Knowledge Graph text-to-result query (a custom graph schema is possible), knowledge article retrieval, AI Search over the most relevant tables, list a record's attachments, summarise attachments (PDFs, images), web search |
| **Playbook activity context agent** | reads the activity's form fields, fills what it can, asks for what is missing, keeps a summary | the playbook slot filling script (loads the activity's schema, saves the answer back to the activity context) |

Custom agents can be added per activity; keep to five or six.

## Configuring an activity (author)

Roles: admin, `playbook.admin`, `pd_author` or `playbook.write` (no extra author role). In Workflow Studio open the playbook > the activity's side panel > **AI Agents** tab.

| Setting | Meaning |
|---|---|
| Mode | **Collaborative**: agents fill values, a person reviews and approves. **Autonomous**: agents update the record, complete the activity and advance the playbook. **No AI Agents** |
| **Run as** | the user who triggered the playbook, or the user who completed the previous activity |
| **AI Agents** | optional custom agents |
| **AI Agent Instructions** | what to do, in plain language |

When an autonomous agent cannot finish, what it gathered is saved and the activity completes only if the data satisfies a wait condition of the playbook. Test thoroughly, with **View progress** open, before relying on autonomous mode.

### Writing instructions

- One operation per step (count, highest, lowest spelled out separately).
- Exact column names, and only columns the Knowledge Graph can query; give an example of the value wanted when the agent returns the wrong thing (a number like `INC0000081` rather than a sys_id).
- Meaningful names for activities, tables and nodes, especially with a custom Knowledge Graph.
- Mark what must not be skipped with words such as *Mandatory*, *Required*, *Important*.
- The word **Query** steers the data gathering agent to the Knowledge Graph rather than AI Search.
- Test and revise.

## Running one (agent user)

Roles: `playbook.agent_user` (the standalone playbook agents) and `playbook.agentic_workflow_user` (the Playbook Activity Assist workflow, its agent roles and `now_assist_panel_user`). They come with the Now Assist for Platform AI agents skill and count for subscriptions.

- An activity handled by agents shows a Now Assist status on its card; **View progress** opens the Now Assist panel with what the agents did; **How** summarises how a value was derived.
- In collaborative mode correct or complete the suggested values, then complete the activity.
- Typical flow from the docs: on saving a contract renewal record the playbook starts, agents compute a discount percentage for review, then draft the email to the customer for the user to send.

Output must be reviewed: agents can return incomplete data when gathering fails.

## Related

- [[Playbook Activities, Decisions and Variants]] · [[Playbooks Overview and Components]] · [[Playbooks Administration, Roles and Access]] · [[Flow Core Actions Reference]]
