---
type: concept
tags: [concept, ai, incident, automation, workspace]
status: documented
source: ServiceNow Australia IT Service Management PDF, "L1 IT Service Desk AI Specialist" (pp. 2862-2883), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# L1 IT Service Desk AI Specialist

**In one line:** an "autonomous worker" (an AI specialist, part of ServiceNow's Autonomous Workforce) that is added to an assignment group like a team member: incidents routed to it are classified, investigated against knowledge and history, answered in the activity stream, resolved, or handed to a human when it is not confident.

Obtained through the account manager. Needs *IT Service Management for AI Agent Collection* (`sn_itsm_aia`) 5.1 and Service Operations Workspace (SOW) for ITSM 8.4. Domain separation: not supported.

## Roles

| Role | For |
|---|---|
| `sn_itsm_common.sn_service_desk_agent` | agents: see the specialist's work on records in the workspace |
| `sn_itsm_common.sn_service_desk_manager` (guide also writes `sn_sow_itsm_common.sn_service_desk_manager`) | contains the agent role and `sn_aia.worker_manager`; onboards and configures the specialist, sees team analytics |
| `sn_aia.worker_manager` | activate, onboard and set up a specialist from the SOW landing page or AI Agent Studio |

The manager role is given in **SOW Admin Center > Configuration > Initial setup > Service desk manager role** (tabs *Service Desk Managers* / *All available groups and users*). On upgrade a fix script gives it to managers of groups or users that have the service desk agent role, and to managers of groups in the *Service Desk Group Inclusion* user criteria.

## Execution modes

Set per specialist, in the *Investigate and resolve* task; no global switch.

| Mode | Behaviour |
|---|---|
| **Autonomous** (default) | triages, searches knowledge, past incidents, known errors and catalog items, may ask the requester questions, posts the solution and moves the incident to *Solution Proposed*, which proceeds to Resolved without requester confirmation |
| **Supervised** | same research, but a human fulfiller must accept the proposed solution before it is posted; if rejected it investigates again |

If the requester does not answer after the configured number of contacts (default 3) the incident is rerouted to a human. The specialist talks only through the incident's activity stream; it sends no email itself, but existing notifications on comments and state changes still fire.

## Setup (SOW home page card *L1 Service Desk AI Specialist*)

**Activate** > confirm assignment groups, role, language > **Add to team**. **View details** opens the guided setup with tabs Profile, Tasks, Test, then Performance and Activity.

**Profile**: first and last name, title, department, user ID, description, assignment groups (remove your group to stop it taking your tickets), roles (these bound the data it can reach).

**Tasks**:

| Section | Settings |
|---|---|
| Classify and assign | **Table**; **Fields to predict** when empty: Category, Subcategory, Service, Service offering, Configuration item; **Similar records search profile** (AI Search); **Override existing field values with predictions** |
| Triage and diagnose | fields to use; **Use attachment content**; map specialist states to record states (for example Awaiting info → On Hold); **Default routing decision**; routing criteria *Attempt resolution for* and *Reassign for* |
| Investigate and resolve | **Knowledge sources** (at least one AI Search profile; a table source is searchable only if the specialist's roles can read it); **Automatically create KFT records** (knowledge feedback task when a proposed solution cited no article); **Research depth** Low / Medium / High; **Pre resolution condition** (encoded query that must hold before it resolves); **Execution mode**; **Auto-submit catalog requests** (items without required variables; otherwise it returns the link); **Flag high-risk resolution steps** (elevated access, backend or irreversible actions go to an agent, not the requester) |
| Response formatting | inbound channels (activity stream); outbound channels (activity stream, email, portal, phone; HTML or plain); **Internal communication when confidence is low** (logs the solution as a work note instead); response templates for *Follow up*, *Propose a solution*, *Reassign to human* |
| Reassign | **Maximum number of interactions before escalation**; **Reassign on follow-up question**; **Stuck monitor filter**; where to reassign (group or person); **Cross-group reassignment** (Off / Recommend only: posts a recommendation and unassigns itself, never changes the group) with a confidence threshold 0-1 |

**Test**: pick a recommended open incident and **Run**. Tests are not simulations: the record is really changed.

Deactivate: card menu > **Deactivate**, or remove your assignment group.

## Monitoring

- **Performance > Overview**: durable auto-resolve rate (resolved without reassignment and not reopened), coverage rate (share of assigned incidents attempted), routing journey (closed in eligible groups → assigned to the specialist → attempted), outcomes (resolved, reassigned, reopened), mean time to resolution and to first response, reassignment reasons (low confidence, failed execution, time-out) over time, follow-up rate.
- **Quality**: each handled incident gets an automated quality assessment linked to a coaching opportunity ([[Coaching]]): scores per opportunity, tier distribution, metric trends.
- **Detailed**: outcomes, reassignment reasons and exchanges per service; similarity between proposed and final resolution (AI judge score).
- **Value and feedback**: sentiment, adoption coverage, thumbs up / down.
- **KB article**: articles used, cited, retrieved only, unused; usage frequency and reopen rate per article.
- **Activity**: every record it worked on, with execution state and reason.

## Related capability and property

- *Incident service and category prediction* (providers Now LLM Service, Claude on AWS, Gemini, Azure OpenAI) predicts Category, Subcategory, Service, Service Offering and Configuration Item from the descriptions.
- Property `sn_itsm_aia.glide.ui.autoresolve.time`: days after which incidents On Hold with reason *Awaiting caller* are resolved automatically (default 2; 0 disables).

## Related

- [[Otto for ITSM Agentic Workflows and AI Agents Reference]] · [[Service Operations Workspace for ITSM]] · [[Incident Management Overview and Lifecycle]]
