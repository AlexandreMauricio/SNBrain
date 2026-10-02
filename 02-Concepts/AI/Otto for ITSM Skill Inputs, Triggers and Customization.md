---
type: reference
tags: [reference, ai, incident, change, request, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ServiceNow Otto for IT Service Management (ITSM)", topics "Supporting information", "Configure ServiceNow Otto for ITSM", "Skill inputs and triggers", "Configure Otto for Virtual Agent in ITSM", "ITSM Virtual Agent pre-built LLM topics", "Customize a ... skill" (incident summarization, resolution notes, activity response, change summarization, change risk explanation, risk assessment answer generator, Request Management skills) (pp. 14-87), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Otto for ITSM: skill inputs, triggers and customization

**What it is:** per generative AI skill of ServiceNow Otto for ITSM (`sn_itsm_gen_ai`), the data it reads, what triggers it and what an admin can change. Overview of the product: [[Otto for ITSM Skills and Agentic Workflows]]. The guide mixes the names "Otto" and "Now Assist" and the menu paths **Admin > AI Admin Hub > AI Skills**, **ServiceNow Otto Admin** and **Now Assist Admin**; they are the same console.

## Activation pattern

**AI Admin Hub > AI Skills > Technology > ITSM** → feature card **View details** → **Activate skill** → guided steps: inputs or triggers → display (**In-product** on forms and workspaces, and/or **Otto panel**, each with the roles allowed) → **Activate**. Role admin; editing prompts needs `sn_skill_builder.admin` (AI Skill Kit). Domain separation is supported. The Otto panel needs Next Experience.

To customise: **Make a copy** of an active skill (only the summarization skills and Change risk explanation can be copied; the others show read-only inputs), then walk the steps *General details, Choose input data, Customize the prompt, Define availability, Define access, Select display, Review and activate*.

Interfaces: Service Operations Workspace gets everything (from version 6.0.0); Core UI gets incident summarization, the Otto panel and incident assist (from Vancouver Patch 2).

## Skills

| Skill | Reads | Trigger / notes |
|---|---|---|
| Incident summarization | `incident`: short description, description, work notes, additional comments, email | **Summarize**; optional trigger *Assign modal* (opens on save when the assignee or group changes). Input templates per state: New, WIP, Resolved, Closed. Sections: Issue (always), Key Actions Taken (WIP on), Resolution (Resolved on), optional Affected CIs and Impacted Services, Service Level Agreement, Child Incidents (dropped with a "too much information" message past the token limit). Extra data sources: related table, activity email, activity attachment (PNG, JPEG, PDF, DOCX through Document Intelligence; only attachments added after activation; not on child incidents) |
| Resolution notes generation | incident short description, work notes, additional comments | automatic when conditions are met, or *User triggered*. Otto context menu config: target field (default **Close notes**), refine actions Shorten / Elaborate, **Insert** |
| Incident activity response recommendation | short description, priority, state, work notes, comments (read-only) | Otto context menu in the activity stream. Work notes: *Summarize actions*, *Post response*; additional comments: *Follow up*, *Post response*, *Acknowledge task*. Configured under **AI Experiences > Otto context menu > Configurations** |
| Knowledge article generation | incident description, resolution notes, work notes, comments | **Create Knowledge** on Resolved or Closed. Other states: property `com.snc.incident.create_knowledge.multistate.enable` with the state numbers (1 New, 2 In Progress, 3 On Hold, 6 Resolved, 7 Closed, 8 Canceled) and a matching availability condition |
| Incident assist | | Otto panel topics: similar resolved incidents, on-call experts, caller's assets, caller's recent incidents |
| Incident sentiment analysis | short description, description, priority, state, created, additional comments, task SLA | output: sentiment (Positive, Neutral, Negative), trend (Improving, Declining, Stable), reasoning; refreshed by scheduled job *Sentiment analysis scheduled job (incident)* |
| Suggested steps generation | incidents clustered on short description; closed in the last 6 months by default | being deprecated from Australia, replaced by LEAP (`sn_itom_leap`). Needs about 2,000 records to cluster (**Launch clustering**); not domain separated |
| Major incident email content recommendation | incident fields and activities, business impact, resolution notes, `task_sla` (target, stage, time left, breached, pause), optionally `sys_cs_collab_message` payload (must be added by hand) | generative variables in the communication email templates |
| Chat summarization | chat transcript | triggers: Virtual Agent to live agent hand-off, `/summarize` quick action, chat wrap-up (fills **Chat Summary**), short description at chat end, task creation (pre-fills short description and description). Property *Bulleted list* |
| Chat reply recommendation | chat | user triggered; icon config with preset and refine actions (Shorten, Elaborate) |
| Sidebar discussion summarization | Sidebar conversation | `/summarize`; bulleted list option |
| Change request summarization | `change_request`: descriptions, notes, risk, impact, justification, the four plans, close code and notes, CI, service, service offering, state, conflict status, type; related: Change Risk Details, Conflict, Applied Change Policy, Impacted CIs, Affected CIs | templates per state group: Assess, Authorize & Scheduled, Implement & Review, Closed. Sections Objective, Plan, Risk, Affected CIs, Impacted services; Close notes and Incidents caused by change when Closed. After adding a custom change state, add the *GenAI Summary Card* to that state's **Change > Workspace Configuration > Overview Container** (scope Change Management for Service Operations Workspace) |
| Change request risk explanation | short description, risk, implementation plan, description, backout plan, assignment group, model type; Change Risk Details; similar past changes (needs AI Search; search source *Change Requests*) and the incidents they caused; the risk condition met | toggle **Use similar changes as a data source**. An output saying risk is not calculated means the prompt had nothing to work with |
| Change risk assessment answer generator | change fields listed in property `sn_itsm_gen_ai.com.snc.asmt_answer_generator.change_request_fields`; **AI Risk Data Sources**; dynamic risk attributes on the change | active by default. **Generate Answers** in the *Generate Risk Assessment Using Otto* dialog (Core UI: related link **Risk Assessment**; workspace 9.2+: **Assess Risk**) |
| Request / requested item / catalog task summarization | `sc_request`, `sc_req_item`, `sc_task` fields (number, descriptions, dates, comments, notes, priority, approval, state, requested for, price, item, stage...) | copyable. Default access itil |
| Request / requested item / catalog task activity response generation | description, priority, work notes, comments, updated | not copyable, inputs read-only |
| Release notes generation | artifacts in a Digital Product Release scope | release in the readiness phase |

### AI Risk Data Sources

**Change > Change Administration > AI Risk Data Sources** (role `sn_change_manager`). Shipped: related affected CIs, impacted services, impacted business applications, service offerings, active change tasks, outages. A source is either *Change Request Related Records* (**Related Table**, **Change Reference Field**, **Expand Reference Field** for many-to-many rows) or *Knowledge Articles* (policies and standards selected by condition, for example published articles only); **Max Records** up to 100; **Source Condition** trims the prompt and its token cost; **Active**.

## Access

- Skills run with the user's ACLs; **role masking** then limits what the model output may use to the data of the role in play.
- Script include `NowAssistitsmGenAIUtilsSNC` (client-callable, server-side) backs several skills; its ACL requires itil or `sn_incident_read`.
- Model providers: Now LLM Service (being deprecated; no longer default from the September 2026 release), Azure OpenAI, Google Gemini, Anthropic Claude on AWS; allowed providers in AI Control Tower, per-skill choice in AI Admin Hub.

## Virtual Agent

Role `sn_nowassist_admin.nsa_admin`. Turn on the assistant skills *Multi-Turn Catalog Ordering*, *Q&A Genius Results*, *Topics*. Conversational catalog ordering fills several variables from one sentence; reference, lookup select box, lookup multiple choice, Requested For, attachment and multiple choice with more than 10 choices are asked for but not understood from free text. Mask sensitive data with Sensitive Data Handler. The generative Virtual Agent replaces the older ITSM Virtual Agent.

Pre-built LLM topics are read-only templates (suffix *(Template)*): duplicate in **Conversational Interfaces > Virtual Agent > Designer** (Topic actions > **Duplicate**), set the properties, **Publish**.

| Group | Topics |
|---|---|
| Core | Check Ticket and Support Status (HR cases need a restricted caller access record for script include `ITSMTopicsHelper`), Show Pending Approvals, Check IT Ticket Status, Open IT Ticket (finds similar open tickets first), Escalate IT Ticket (deprecated; raises urgency one level with a justification), Service Disruptions, device health (needs DEX), Explain change risk |
| Password | Change Password (logged in), Reset Password, Unlock Account; plugins `com.glideapp.password_reset`, `com.snc.password_reset.virtual_agent`; the process must have **Enabled on Virtual Agent**; verifications: personal data, Google Authenticator, SMS code, email code, security questions (no custom ones) |
| Actionable notifications (activate in Workflow Studio) | requested item: view / add comment, details for approver or requester; incident: add comment, close, mark unresolved, resolve; approvals: approve, reject, show details |

## Related

- [[Otto for ITSM Skills and Agentic Workflows]] · [[Change Risk Calculation and Assessment]] · [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]]
