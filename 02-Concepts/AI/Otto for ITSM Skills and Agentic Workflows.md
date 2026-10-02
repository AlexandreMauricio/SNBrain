---
type: concept
tags: [concept, ai, incident, change]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ServiceNow Otto for IT Service Management (ITSM)" (pp. 14-222), read in full 2026-10-02; this note is the overview and the usage side, detail is in the two linked reference notes
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

Workflows can be triggered automatically or manually; AI agents have supervised and autonomous execution modes. Per-workflow agents, triggers, roles and prerequisites: [[Otto for ITSM Agentic Workflows and AI Agents Reference]].

## Cautions stated by the vendor

Output may be inaccurate: keep a human in the loop. Data leaves the instance for a central environment and possibly a third-party cloud. Some features are unavailable in regulated or in-country data centres. Inputs and outputs are collected for model improvement unless you opt out.

## Using the skills (agent side)

Role itil unless stated. Several skills are **on by default on new installs** (chat, incident and change summarization, resolution notes, knowledge generation, chat reply, the DEX Zoom skill); upgrades keep their previous activation. Skills live in the global domain but only read data of the user's domain.

- **Summarize** (incident, change, request, requested item, catalog task): banner in Core UI, Overview or Details tab in the workspace; then **Share as Work notes**, copy, thumbs up / down (feedback is stored in the generative AI log, `sys_generative_ai_log`). Not offered on a change in New or Canceled.
- **Reassignment summary**: changing **Assigned to** or **Assignment group** opens the Assign dialog with a generated summary in **Work notes** (not shown if `glide.ui.advanced` is on and nothing changed).
- **Resolution notes**: **Resolve** fills **Resolution notes** automatically, or (user-triggered mode) click in the field and use the Otto icon, then **Refine** (Elaborate / Shorten) and **Insert**.
- **Create knowledge** on an incident without an article: pick knowledge base and template (*Incident-KCS article - HTML* or *Standard*; the picker page is skipped when `com.snc.incident.knowledge` is installed), then draft with AI. Several incidents can feed one article (workspace: type a short description and the top three similar incidents are used; Core UI: choose up to five); the article is attached to all of them. Needs AI Search, `sn_km_gen_ai` and `sn_km_uib`. Generation cannot be cancelled once started.
- **Chat**: summary at hand-off, `/summarize`, and at **End Chat** (fills **Short description** and **Chat Summary**; an incident created from the chat gets them too). Reply recommendation: Otto icon in the message box (empty box = suggestion, typed text = refine).
- **Email**: in the composer select six or more words, or put the cursor in a reply, and use the Otto icon; also template suggestions. Admin must activate the email response skill.
- **Major incident email**: **Communicate > Compose** on an email task, with the generative templates (*Ad hoc AI*, *Business user AI*, *End user AI*, *Technical AI*); role `major_incident_manager`.
- **Explain Risk** on a change with a calculated risk (uses the top five normalised risk assessment values).
- **Risk assessment answers** (roles `sn_change_write`, `change_manager`; Zurich patch 11 / Australia patch 4): **Generate Answers** pre-fills each Likert-scale question with an answer and a **Reasoning**; review, then submit; **Skip generation** for manual. Editing later opens the plain form; **Generate Answers** again replaces everything.
- **Activity stream response** (inactive by default): Otto icon in Work notes or Comments > Post response, Acknowledge task, Summarize actions taken, Follow up; **Refine** can also change tone.
- **Sentiment** field on the incident list and form (add it to the layout): value, trend and reasoning; a new comment shows a red dot and can be refreshed by hand.
- **Deflection on the portal**: record producer *Create Incident with ServiceNow Otto*. The description is classified as incident (troubleshooting from knowledge) or request (a catalog item matched to the user's hardware); the query is rephrased with the user's hardware and location from the knowledge graph when relevant ("my laptop is not working" becomes the model name), and the tone is acknowledged. **Solution found** ends without an incident (counted as deflected); **Proceed with incident creation** adds urgency and attachments.
- **Otto panel** (needs Next Experience): Chat Summarization, Sidebar Discussion Summarization, Summarize a record / change request, Explain change risk, Generate resolution notes, Generate Article, chat reply, add a comment or work note conversationally, and the agentic workflows.
- **DEX**: *Investigate* banners for Zoom call issues (root cause, evidence, correlations; date range at most 48 hours within 30 days; role `sn_dex.user`, recommendations need `sn_dex.ai_user` + itil + engineer or service desk role) and Windows boot time.
- **Release notes**: Digital Product Release Workspace > release > **Release notes > Generate** (role `sn_dpr_model.product_manager`; DPR 2.3+; readiness phase in progress or complete), then Save, Regenerate, Publish (read-only), Download PDF, Copy link.

## Dashboards

- **Insights and Opportunities for Incident** (workspace dashboard; roles `sn_sow_itsm_common.sn_service_desk_manager` or `incident_manager`): incident volume, SLA status, sentiment trend, *Incident trends* (AI-clustered categories; a row opens the trend view with an AI summary, average MTTR, breached incidents, reassignments, priority and category breakdowns, associated incidents), top departments, geography, channel, service criticality, CI classes, assignment groups by reassignment count.
- **ITSM Virtual Agent analytics** (from the IT Agent Dashboard picker, itil; or Assistant Designer > Analytics > Related Dashboards, with `virtual_agent_admin`): tabs *Chat analytics* (closed chats, daily chats and unique users, abandonment rate, by department and location; filters date, caller company, department, location, handled by, channel), *Topics* (top 10 topics, all topics with closed by virtual agent or live agent), *Customer satisfaction* (LLM-inferred CSAT 0-5 for virtual agent, live agent and all sessions; thumbs up / down counts), *Resources* (knowledge articles and catalog items referenced in successful deflections and in transfers to a live agent). Fed by scheduled data collection jobs.

## Related

- [[Otto for ITSM Skill Inputs, Triggers and Customization]] · [[Otto for ITSM Agentic Workflows and AI Agents Reference]] · [[Incident Management Overview and Lifecycle]] · [[Change Risk Calculation and Assessment]] · [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]] · [[Email Agentic Workflow and Notification Agent]]
