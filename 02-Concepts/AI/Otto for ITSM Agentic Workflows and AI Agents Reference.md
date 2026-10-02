---
type: reference
tags: [reference, ai, incident, change, sla, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ServiceNow Otto for IT Service Management (ITSM)", topic "Use agentic AI in ServiceNow Otto for ITSM" and all its subtopics (ITSM, Voice, Virtual Agent, Change Management, Incident Management and DEX agentic workflows and standalone AI agents) (pp. 87-151), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Otto for ITSM: agentic workflows and AI agents reference

**What it is:** each agentic workflow shipped with ServiceNow Otto for ITSM (`sn_itsm_gen_ai`; agents in scope `sn_itsm_aia`, *IT Service Management AI agent collection*), with its agents, trigger, roles and prerequisites. Skills are in [[Otto for ITSM Skill Inputs, Triggers and Customization]].

## Rules that apply to all of them

- Open and edit in **AI Agent Studio > Create and manage** (tab *Agentic workflows*). Shipped workflows and agents are **read-only**: **duplicate** to change them, and rewrite the instructions when you change a tool or agent.
- To run one automatically: duplicate, activate the workflow, activate every agent in it (**Status** / *This AI agent is active* on the availability screen), and activate a **trigger** (triggers must be unique per workflow). Manual use needs no trigger. Display in the Otto panel: **Select channels and status** (or *Select display*) > **Display**, plus the roles allowed.
- **Run as**: a dynamic user (for example *Assigned to*) or an **AI user**. A user record of identity type *AI agent* named *ITSM Worker AI Agent* is shipped; roles can be given to such users.
- Access is by role masking; if user access is "Users with specific roles", the security controls must include those roles.
- Azure OpenAI is the provider the guide recommends for ITSM agentic workflows.
- AI agent options stored in `sn_aia_agent_config`: **External discoverable** (third-party agents may call it; off by default), **Specialist enabled** (AI specialists may use it), long-term memory (property `sn_aia.ltm.enable_long_term_memory`, off by default).

## Incident

| Workflow | Agents | Trigger and conditions | Notes |
|---|---|---|---|
| Triage and categorize ITSM incidents | Categorize ITSM incident; Classify service and CI; Link major incident or problem | automatic: state New (or updated to In progress), **Assigned to** empty, priority 3, 4 or 5. Manual: In progress and assigned. The active trigger needs the sys_id of a user with itil | sets **Category**, **Subcategory** (from the short description), then **Service**, **Service offering**, **Configuration item**, then **Parent incident** (most similar major incident) or else **Problem**; writes work notes and comments. Needs `com.snc.incident.mim` for the major incident search; a duplicated workflow needs semantic indexing on the Problem table |
| Investigate and resolve ITSM incidents | ITSM incident resolution plan investigation | manual; **Run as** = Assigned to | AI Search returns the 10 most relevant catalog items (links written to work notes); similar resolved incidents and knowledge articles produce a resolution plan in work notes |
| Wrap-up and resolve incident | Incident resolution details; Incident knowledge article; Incident known error article | Otto panel | for incidents In progress, or Resolved with a code other than Known Error. Drafts resolution notes from work notes and comments, offers the resolution codes, records the duplicate if the code is Duplicate, attaches a known error article if the code is Known Error, resolves, then suggests knowledge articles to attach or drafts one ("Draft"). Needs the skills Resolution notes generation and KB generation active |
| Generate post incident reviews | Post-incident review | when a major incident with an assignee becomes Resolved, or manually with the number | validates major + resolved; reads the incident, child incidents, problems, changes (including caused-by), incident tasks; produces Executive Summary, Customer / Service Impact, Detailed Technical Summary, Action Items & Prevention; revises on feedback; on approval writes **Post Incident Report** on the record. Needs `com.snc.incident.mim` |
| Incident assist | Incident context; Additional incident context | loads with the incident in context when the Otto panel is opened on an incident; role itil | answers on status, SLA breach risk, related changes, outages, problems, CIs, child incidents; caller's hardware assets, recent incidents, similar resolved incidents (semantic search), on-call experts; 10 records at a time. Replaces the Incident assist **skill**, deprecated in Australia Patch 2 |
| Who is On Call | On Call Retrieval (not enabled by default) | manual | on-call members for a shift, group or period, with fuzzy matching and time zones. *Manage On Call Shifts* (On Call Shift Creator) creates shifts from a template or a description |
| Notify users with Twilio | Twilio SMS text | manual | needs the Twilio spoke (`sn_twilio_spoke`). Changing the role from itil also means changing the flow action ACLs `sn_itsm_aia.look_up_incoming_phone_numbers` and `sn_itsm_aia.send_sms` |
| Manage Microsoft 365 group members | Microsoft 365 group membership | manual, no trigger | needs the Microsoft Entra ID spoke. Approval: properties `sn_itsm_aia.office_365_group_member_approval.required` (true by default) and `sn_itsm_aia.office_365_group_member_approval.group_id` (sys_id of the approving group; members go in group *Office 365 Approval*). ACLs to change with the role: `sn_itsm_aia.look_up_group`, `sn_itsm_aia.look_up_user`, `sn_itsm_aia.manage_office_365_group_member` |

## Change

All manual (no trigger), used from the Otto panel with a prompt naming the change.

| Workflow / agent | Does | Roles and notes |
|---|---|---|
| Generate change request plans (Change request plans agent) | drafts implementation, backout and test plans, justification, risk and impact analysis from similar changes. The autonomous version resolves the applicable change policy (by **Model**, else **Type**) and fills only the fields named in the policy; with no policy it drafts all five | itil, `sn_change_write` |
| Assess conflicts for a change request (Change conflict assessor) | runs conflict detection and summarises per conflict type the affected CI, conflicting change and maintenance or blackout schedule | needs CI and planned dates; `sn_change_write` or itil |
| Assess quality of a change request (Change quality assessor) | rates short description, description, implementation, backout and test plans and justification as Excellent, Very good, Good, Fair, Poor, Very poor or Incomplete, against a **change policy document** if one applies, else against similar closed changes; suggests improvements; report in work notes | role `sn_itsm_aia.sn_aia_chg_quality` (in itil and `sn_change_write`). Turning on **Display** also activates the needed text index |
| Explain SLA | picks the most important SLA on a task (by default the one that will breach first), then answers on target, elapsed time, pauses and resumes, assignments and breach causes; incident, problem, case or change | role `sn_uxc_gen_ai.sn_aia_sla_explain` (in itil). See [[SLA Definitions and Task SLAs]] |
| Schedule a change (Schedule Change Request agent) | finds the earliest conflict-free slot on or after the planned start, within the next 90 days, respecting blackout and maintenance schedules | role `sn_itsm_aia.sn_aia_chg_schedule` |
| Suggest configuration items (Change CI suggestion agent) | proposes primary and affected CIs from the change text (refine by class, location, environment) and writes the chosen ones | itil, `sn_change_write`, `cmdb_read`. Latest version from Australia Patch 5 (app 17.1.2+) |
| Create outages for a change request (Change outage assistant) | creates the outage from the planned dates, attaches affected CIs, asks whether to link the impacted service | |
| Create standard change request (Standard change template recommender) | asks standard, normal or emergency; for standard recommends templates from past use and returns links; otherwise a link to create the change | `sn_change_write`, itil |
| Create standard change template proposal | lists similar changes, the user picks one and the content, a proposal record is created for approval | `change_manager`, itil |
| Create change request agent (autonomous) + Change template suggestion agent | **Create with otto** on the change list: the user describes the change in one message; the agent drafts it, picks model and template (LLM judgement, else semantic search over the assignment group's past changes ranked by frequency and relevance), shows a summary, creates the record | itil, `sn_change_write` (that role needs plugin `com.snc.itsm.roles.change_management`) |

### Change policy documents and quality scores

- Table **Change Policy Control**: description, **Change model** or **Change type**, and the policy document as attachment. On save, business rule *Ingest policy document* extracts the criteria into **Policies** and ticks **Active**. One active policy per scope; a new one deactivates the old; **Copy Policy** reuses one.
- Extraction prompts per field are in script include `ChangeQualityUtilSNC` (keys `justification`, `implementation_plan`, `backout_plan`, `test_plan`, `risk_impact_analysis`). To add custom fields override `POLICY_EXTRACTION_KEYS` in `ChangeQualityUtil` (server-side script include; a list of `name` + `description` entries, with a `u_custom_field` placeholder to copy).
- Versions of the two child agents (*using change policy documents*, *using similar changes*): **version 1 supervised** asks before setting each field (marked AI Generated) and before recording the score; **version 2 autonomous** records the rating and work note but sets no fields. Choose under **Define the specialty > View versions > Set as active**. The tools that set change fields always run supervised.
- Scores: table `ai_change_quality_score` (**Change Policy Control**, **Change Request**, **Explanation**, **Rating**, **Score** 0-100, **Per field score**); one record per change, overwritten on reassessment. Trend it in Platform Analytics (average score by month, grouped by assignment group or model).
- Cloning the workflow: run the semantic index for similar change requests by hand (business rule *[Chg Quality] Trigger semantic index* does not run for clones).

## Other channels

| Area | Content |
|---|---|
| Voice (`sn_itsm_voice_aia`) | agents *Create incidents with voice*, *Manage tickets with voice* (status, escalate, comment), *Password reset with voice* (emails the article, texts the link or reads the URL); demo "primers": request a catalog item (submits software items, emails a link for others), troubleshoot Outlook from knowledge, submit an account unlock item. Knowledge search needs an AI Search profile and a search retrieval tool on the agent |
| Virtual Agent | platform *Request Status* agent (view and update tickets from Virtual Agent, the Otto panel or Teams); *DEMO Password reset agent* (inactive; enable under **Select channels and status**, assistant *ServiceNow Otto in Virtual Agent (default)*; uses the *ESC Portal Default Search Profile*) |
| Digital End-User Experience | *DEX issue diagnosis and resolution*: agents *DEX diagnosis* (root cause from device health data of the 24 hours before the incident, events, similar incidents; Zoom diagnostics) and *DEX resolution plan* (remedial actions, self-help, past resolutions, knowledge; stamps work notes on approval). Roles `sn_dex.service_desk_user` or `sn_dex.engineer`, plus itil. The incident must be under a month old with exactly one DEX-monitored device as CI or affected CI; the prompt must contain "diagnose and resolve" |

## Related

- [[Otto for ITSM Skills and Agentic Workflows]] · [[Change Conflict Detection and Maintenance Schedules]] · [[Major Incident Management]] · [[On-Call Scheduling]]
