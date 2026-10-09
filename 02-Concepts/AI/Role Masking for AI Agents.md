---
type: concept
tags: [concept, ai, security, roles, access-control, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Identity (chapter read in full 2026-10-08) - Role masking for AI agents, Agent Access Role Configuration (Configure role masking for an AI agent). https://www.servicenow.com/docs/r/platform-security/identity/role-masking.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Role Masking for AI Agents

**In one line:** role masking makes an AI agent, agentic workflow or skill run with only those of the triggering user's roles that are also on an approved list, instead of with everything that user can do.

From the Brazil docs. Agents and workflows: [[Otto for ITSM Skills and Agentic Workflows]], [[Otto for ITSM Agentic Workflows and AI Agents Reference]]. Roles in general: [[Role Management]].

## The rule

Effective roles of the agent = (roles of the invoking user) ∩ (roles in the role mask).

- An agent acts on behalf of the user who triggered it: it runs tools, queries and updates records. Unmasked, it carries all of that user's session roles.
- The mask can only narrow. A role in the list that the user lacks is not granted.
- Purpose: a smaller blast radius for prompt-driven mistakes or misuse, and behaviour that is easier to audit.

## Dynamic user or AI user

| The component runs as | Roles available | Masking |
|---|---|---|
| **Dynamic user** (the invoking user) | that user's roles | can be masked |
| **AI user** (a dedicated account) | all roles of the AI user, whoever triggers it: a way to give the agent **more** than the user has | cannot be masked |

## Configuring

Needs Now Assist for Platform 10.0.2-SS or later and role `sn_aia.admin`. No menu module is given: open `sys_agent_access_configuration_list.do`.

**Agent Access Role Configuration > New**: **Name**, **Description**, **Agent Table** (the table holding the agent record), **Agent**, **Action** = *Limit To Roles*, then add roles in the embedded **Agent access roles** list, one row per role.

- Each row is a record in Agent Access Role Mapping (`sys_agent_access_role_mapping`). Older configurations with a delimited **Role List** (`role_list`) keep working; new ones use rows.
- One record per role lets several business units share an agent: the agent ships with a minimal set and each unit adds or removes its own roles without touching the others'.
- Takes effect the next time the agent runs.

## Related

- [[Otto for ITSM Skills and Agentic Workflows]] · [[Agentic AI Security and Governance]] · [[Role Management]] · [[Hardening Settings - Access Control]]
