---
type: concept
tags: [concept, ai, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Enable AI Experiences (2,035 topics; Implementing AI read in part, including roles table start and product tiers; landing pages of AI Admin Center, AI Admin Hub, AI Skill Kit, Generative AI Controller, large language models, AI Lens, Predictive Intelligence, MCP Client), read at overview depth 2026-10-30. Remaining pages not read. Docs site API, map UBGwc5glUUjVANqQeiJeZA.
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# AI Platform Map, Roles and Product Tiers

**In one line:** which AI tool does what, which role administers it, and how the three product tiers divide AI features.

From the Brazil docs; not tested. Availability depends on licence and tier, so check your instance. Security is in [[Agentic AI Security and Governance]]. The docs mix **Now Assist** and **ServiceNow Otto** for the same products.

## Layers

AI policy sits at the base, then data and search, then generative skills and agentic AI, with the conversational layer on top. Poor data weakens everything above it.

## Tools

| Tool | Does | Admin role |
|---|---|---|
| **AI Admin Hub** | activates skills, sets preferences, AI Guardian guardrails | `sn_nowassist_admin.nsa_admin` |
| **AI Admin Center** (was Now Assist Center) | sets up and tracks AI solutions | `sn_na_center.nac_admin` |
| **AI Skill Kit** | custom prompts and skills | `sn_skill_builder.admin` |
| **AI Agent Studio** | AI agents and workflows; see [[AI Agent Studio, Agentic Workflows and AI Control Tower]] | `sn_aia.admin` |
| **Generative AI Controller** | connects third-party LLMs, governs and logs requests | `admin` on the pages sampled |
| **AI Control Tower** | governance and value | see the linked note |
| **AI Data Kit** | datasets | `sn_data_kit.admin` |
| **Knowledge Graph** | schemas of nodes and relationships | `kg_admin` |
| **AI Search** | see [[AI Search Overview]] | `ais_admin` |
| **External Content Connectors** | external search content | `sn_ext_conn.xcc_admin` |
| **AI Lens** | scans and extracts data with generative AI | `lens_admin`, `lens_user` |
| **Predictive Intelligence** | trains machine learning models | `ml_admin` |
| **MCP Client** | uses external MCP tools in AI Agent Studio | `sn_mcp_client.admin` |
| **MCP Server Console** | exposes the instance to MCP clients; see [[ITSM MCP Server]] | not read |

**`admin` does not automatically grant these roles** per the docs (they say `sys_admin`). Assign them directly.

AI Admin Center: the Lux interface replaces the Next Experience workspace, which is being prepared for deprecation in the November store release.

Unconfirmed variants: AI steward is `sn_ai_governance_ai_steward` on one page, `sn_ai_governance.ai_steward` on others. Analytics admin `sn_na_analytics.admin` is named both AI Analytics Admin and Now Assist Analytics Admin.

## Product tiers

| Tier | Gives |
|---|---|
| **Foundation** | AI skills, routine AI agents |
| **Advanced** | agentic workflows |
| **Prime** | autonomous AI workforce, building new agents |

The rollout is separate from your upgrade; ask the account team.

## LLMs

Every skill and agent uses an LLM. Options include Now LLM Service, Azure OpenAI and Google Gemini; the list changes, see the docs. LLMs are probabilistic, so identical prompts can differ. Long term stable models serve regulated industries.

## Predictive Intelligence

From Brazil, classification, clustering and similarity models use **Workflow solutions**, which are pre-trained, so new solutions need no word corpus. Compare [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]].

## Example

For a pilot, give *Test User* `sn_nowassist_admin.nsa_admin`, activate one summarisation skill in AI Admin Hub on *Example Test Instance*, then test on an incident.

## Related

- [[AI Agent Studio, Agentic Workflows and AI Control Tower]] · [[Agentic AI Security and Governance]] · [[Role Masking for AI Agents]] · [[Virtual Agent Overview and Assistant Designer]]
