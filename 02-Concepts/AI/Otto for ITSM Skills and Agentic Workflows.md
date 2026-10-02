---
type: concept
tags: [concept, ai, incident, change]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ServiceNow Otto for IT Service Management (ITSM)" (pp. 14-222), read 2026-10-02 at overview depth: the exploring and configuring topics and the list of agentic workflows were read; per-skill customisation procedures (pp. 49-86) and step-by-step usage (pp. 151-206) were not transcribed
sn-release: Australia
verified:
updated: 2026-10-02
---

# Otto for ITSM: generative AI skills and agentic workflows

**In one line:** ServiceNow Otto for ITSM (application `sn_itsm_gen_ai`; the Australia guide's name for what earlier releases document as Now Assist for ITSM, and parts of the text still say Now Assist) adds generative AI skills on incidents, changes, requests and chats, plus AI agents grouped in agentic workflows.

## Skills

| Skill | Works on | Output |
|---|---|---|
| Chat summarization | interaction / Virtual Agent chat | summary at hand-off or end of chat |
| Sidebar discussion summarization | Sidebar conversation | summary, can be posted to work notes |
| Incident summarization | active incident: short description, description, work notes, comments, email | issue, actions taken, resolution |
| Incident assist (Otto panel) | incident | answers on the caller's assets and recent incidents, on-call experts, similar resolved incidents |
| Resolution notes generation | incident | draft **Resolution notes** |
| Knowledge generation | resolved or closed incident | draft article (needs `com.snc.incident.knowledge`) |
| Change request summarization | active change: descriptions, plans, risk, CI, state, conflict status... | objective, plan, risk |
| Change request risk explanation | change with a Risk value | why the risk is what it is (uses similar changes, incidents they caused, the matched risk condition) |
| Change risk assessment answer generation | risk assessment questionnaire | suggested answers |
| Chat reply and email response recommendation | chat, email | suggested reply |
| Major incident email content | major incident communication | draft |
| Request Management summarization and response | REQ / RITM / SCTASK | summary, reply |
| Release notes generation | Digital Product Release | release notes |
| In-form and portal deflection, sentiment analysis, suggested steps | | |

Available in Core UI (from Vancouver Patch 2) and Service Operations Workspace (from 6.0.0), there through the Otto panel.

## Setting up

Role admin. Install `sn_itsm_gen_ai`, then **Admin > AI Admin Hub > AI Skills**, workflow group **Technology**: per skill **Activate skill**, choose inputs or triggers, choose where it is displayed, **Activate**. Model providers: Now LLM Service (being prepared for deprecation; no longer the default from September 2026), Azure OpenAI, Google Gemini, Anthropic Claude on AWS; allowed providers are set in AI Control Tower. Skills are customised by cloning them in the skill builder (role `sn_skill_builder.admin`).

## Access

Skills and agents run under the user's ACLs, and **role masking** limits what the model output can use to the data of the role in play. Most usage needs itil.

## Agentic workflows named in the guide

| Area | Workflows |
|---|---|
| Incident | Triage and categorize ITSM incidents; Investigate and resolve ITSM incidents; Incident assist; Generate post incident reviews; Who is On Call; Notify users with Twilio; Manage Microsoft 365 group members |
| Change | Generate change request plans; assess conflicts for a change request; change quality assessment (against policy documents or similar changes); schedule a change; suggest configuration items; create outages; create standard change request; create standard change template proposal |
| SLA | explain SLA |
| Also | Voice, Virtual Agent and Digital End-User Experience agents (boot time, Zoom call issues) |

Workflows can be triggered automatically or manually; AI agents have supervised and autonomous execution modes.

## Cautions stated by the vendor

Output may be inaccurate: keep a human in the loop. Data leaves the instance for a central environment and possibly a third-party cloud. Some features are unavailable in regulated or in-country data centres. Inputs and outputs are collected for model improvement unless you opt out.

## Dashboards

*Insights and Opportunities for Incident* and *ITSM Virtual Agent Analytics*.

## Related

- [[Incident Management Overview and Lifecycle]] · [[Change Risk Calculation and Assessment]] · [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]] · [[Email Agentic Workflow and Notification Agent]]
