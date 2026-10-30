---
type: concept
tags: [concept, ai, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Enable AI Experiences > AI agents and agentic workflows > AI Agent Studio (77 topics) and Agentic workflows (13), Establishing AI governance > AI Control Tower (295), section overviews, read 2026-10-30. AI agents library (602), AI Agent Studio (legacy) (134), AI Control Tower (legacy) (158), Autonomous Workforce and AI Desktop Actions not read. Docs site API, map UBGwc5glUUjVANqQeiJeZA.
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# AI Agent Studio, Agentic Workflows and AI Control Tower

**In one line:** AI Agent Studio builds agents and the workflows that coordinate them; AI Control Tower inventories and governs AI across the organisation.

From the Brazil docs; not tested. Depends on tier: see [[AI Platform Map, Roles and Product Tiers]]. Security: [[Agentic AI Security and Governance]], [[Role Masking for AI Agents]].

## Terms

- **AI agent:** follows instructions toward a goal using configured **tools**, with an LLM suggesting the next action.
- **Agentic workflow:** one or more agents working to an outcome, adapting steps as they go. Suits routine but variable work such as investigation and remediation.

## AI Agent Studio

Role `sn_aia.admin`. AI agents must be installed first.

1. **Create** an agent or workflow. Keep record and knowledge data current, because agents depend on it.
2. **Select channels and access:** includes creating a UI action so the workflow can run from a form.
3. **Test** manually, or with **test scenarios** (existing tables need at least 10 records), then **evaluate**.

**Testing traps:**

- If you lack the roles to pass the ACLs of the asset and its tools, the test will not run.
- Silent failures with no values may mean an access error: the workflow is reachable but its agent is not.
- The test dialog does not offer record numbers, so pick a real record first.

**External agents:** on other platforms, connected only through the **A2A protocol**, and they need an ACL generated. They run independently of the instance.

Progress shows in dedicated spaces in Core UI and workspaces, where users answer follow-up questions.

## AI Control Tower

| Area | Does |
|---|---|
| **Plan** | priorities, goals, costs |
| **Discover and manage** | inventory of AI assets |
| **Govern** | risk, compliance, security, privacy through the life cycle |
| **Monitor** | scores a sample of live interactions, because quality can degrade after deployment |
| **Measure** | productivity value, costs, net return |
| **Activity Center** | action items and recommendations |

Roles: `sn_ai_asset_mgmt.ai_asset_owner` (some widgets limit to owned assets), `sn_ai_governance.ai_steward`, `sn_grc_ai_gov.ai_risk_and_compliance_manager`, `sn_grc_ai_gov.ai_risk_and_compliance_admin`.

**Legacy:** the guide keeps separate *legacy* sections for AI Control Tower and AI Agent Studio. Migration: KB3144679. Upgrade AI Risk and Compliance sequentially, not skipping releases, per [[Brazil Release Changes from Australia]].

## Example

Agent *Example Triage Agent* uses a record lookup tool and an update tool. Workflow *Example Triage Flow* runs from a UI action on *Incident* (`incident`). Test on a chosen incident as *Test User*, then record it as an asset in AI Control Tower.

## Related

- [[AI Platform Map, Roles and Product Tiers]] · [[Otto for ITSM Agentic Workflows and AI Agents Reference]] · [[L1 IT Service Desk AI Specialist]] · [[Automation Center]]
