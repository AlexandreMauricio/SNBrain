---
type: concept
tags: [concept, knowledge, roles, automation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Exploring > Knowledge-Centered Service configuration, Article quality index, Ownership groups, Automating feedback management to improve content, Knowledge subscriptions; Configuring > Activate Knowledge Management KCS Capabilities, Enable actionable knowledge feedback (Create field mapping from an HR case to a knowledge article, Add a property, Create a UI action), Enable creating an article from a customer service case, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/enable-ownership-group.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Feedback, Ownership Groups and Article Quality

**In one line:** the content-health tools of KM: **ownership groups** take over an article from one person, **actionable feedback** turns flags, "not helpful" and low ratings into **feedback tasks** (`kb_feedback_task`), the **Article Quality Index** scores articles against a checklist, and the **KCS** plugin adds Knowledge-Centered Service roles and states, including creating articles straight from incidents and cases.

From the Brazil docs; not tested. All need Knowledge Management Advanced ([[Knowledge Management Overview]]).

## Ownership groups

- `glide.knowman.ownership_group.enabled` (default false). Once used, avoid turning it off; if you must, reassign their articles, close approvals sent to them and resolve their feedback tasks first.
- An ownership group (members plus a manager) approves, runs AQI checks and handles feedback for its articles. Members get contribute access to those articles even without contribute access to the base; non-members who are not the author cannot contribute even if the base allows them.
- `glide.knowman.ownership_group.override` (default false): true keeps contribute access for the author or reviser after publishing (otherwise they lose it).
- `glide.knowman.ownership_group.allow_self_approval` (default true): false stops members approving their own articles.
- When creating an article from an ITSM Agent Workspace incident, the Knowledge form may need the ownership group field added.

### Managing ownership groups

- Create: `knowledge_domain_expert` or `knowledge_admin`, **Knowledge > Ownership Groups > Manage Group**, Request Type **Create Ownership Group** (or **Edit Ownership Group**): name, **Group email** (used for article activity and AQI mails; empty = each member's email), description, manager, members, **Order Now** → a knowledge admin approves.
- Edit: `knowledge_group_manager` adds or removes members without approval but cannot change the manager (only knowledge admins can).
- From an existing group: Type = *Knowledge*, manager with `knowledge_group_manager`, group role `knowledge_group_member`.

## Actionable feedback

- Needs the Knowledge Portal plugin; works in the Knowledge Portal and Agent Workspace (other portals through the **Knowledge Article View** page route map, active by default since New York), **not** in KM v3.
- Properties (*Actionable Feedback Properties* section of Knowledge properties): task when **flagged** (default Yes), when marked **not helpful**, when **rated at or below** a value 1-5 (0 = off), and only when feedback details are given. Saying **No** to "Helpful?" opens a reason pop-up (Other asks for details).
- Assignment: the ownership group manager if the article has a group (they or members can reassign), else the author or reviser. Assignees update the article, write a new one, ask for more feedback or reassign. Knowledge-gap tasks from [[Knowledge Demand Insights and Predictive Intelligence]] use the same table.

### Working a feedback task

**Knowledge > Feedback Management > My Assigned Tasks** (managers: All Open Tasks, then reassign; members assign themselves). Reason and Description come from the feedback form. States: **Work in progress** (edit or create an article), **Awaiting information** (Additional Comments email the submitter; Work notes stay internal), **Resolved** with **Resolution Code** (Updated article, Created article, Updated search configuration, No action, Others) and notes; the submitter gets a portal link to accept or reject; **Closed** (no acceptance needed; accepted resolutions close too). **Knowledge Feedback Task Metrics** related list shows time per state (base owner, `knowledge_manager`, `knowledge_admin`, `admin`). Retiring an article does not close its feedback tasks. Now Mobile: ratings of 1-3 stars create a task.

### Feedback types and channels

- Feedback task types: **User feedback** (not helpful or low rating), **Internal feedback** (flagged), **Knowledge gap** (Demand Insights), **Knowledge gap - manual** (raised from a case or incident), **Unsuccessful search** (from the Unsuccessful Searches report in Self-Service Analytics for Customer Service), **Other** (default for old records on upgrade).
- Workspace lists: **Knowledge > My Tasks - Feedback** and **My Tasks - Flagged**; from a task you can **Edit Article** or create a new one.
- **Flag Article**: opens a box for suggested changes; stored in Knowledge Feedback (`kb_feedback`), not in `live_message`; flagged comments are hidden from the article page and visible to `admin`, `knowledge_admin`, `knowledge_manager` (and the author). **Disable suggesting** on the base hides Flag Article; **Disable rating** and **Disable mark as helpful** hide those controls. Helpful? Yes/No stays available even after answering.
- Comments use Live Feed when `glide.knowman.use_live_feed` is on. Managers review all feedback under **Knowledge > Feedback**.
- Self-approval property name differs between pages: `glide.knowman.ownership_group.allow_self_approval` (ownership groups page) and `glide.knowman.ownership_group.enable_self_approval` (article create/edit pages). Unconfirmed which exists.

## Article Quality Index (AQI)

`knowledge_admin` builds a **checklist** of weighted true/false questions and sets it on the knowledge base (**Checklist** field). Reviewers with `knowledge_coach` and `knowledge_domain_expert` (page wording: "and"; unconfirmed whether both are needed) answer it per article; score = sum of weights answered true. Average shown on the **Content Quality** tab of the Knowledge Management dashboard.

### AQI in practice

- **Knowledge > Article Quality Index > AQI checklists > New**: questions with Order and **Weight**; weights must total exactly **100** before the checklist can be put on a base (one checklist per base, reusable across bases). Pass score default **70** (Article Quality Index properties).
- Editing an assigned checklist: remove it from the base first (not possible while reviews are pending). Deleting questions (`admin`; checklist detached, no review in progress) keeps old scores but blanks the question text.
- Review (`knowledge_domain_expert`, `knowledge_coach`, `knowledge_admin` or `admin`; states allowed by `glide.knowman.aqi.article_workflow_states`): on a published article **Perform AQI** / **Continue AQI**, set true answers in **Article Checklist Answers**, **Submit** (score in **AQI score**, latest in **Latest AQI**; email to author, later versions also creator, and ownership group) or **Update** to finish later (**Knowledge > My Pending AQI Checklists**; done ones in **My Completed AQI Checklists**; everyone's in All Pending / All Completed).
- Delete reviews: submitted ones by `admin` / knowledge admin; unsubmitted by knowledge admin or the reviewer.

## KCS

ServiceNow KM is **KCS v6 verified**. Plugin **Knowledge Management KCS Capabilities** (`com.snc.knowledge_kcs_capabilities`) enables KCS roles and KCS article states. The **KCS Article** template (`kb_template_kcs_article`: Issue, Environment, Cause, Resolution) is the usual target when creating knowledge from a task.

### KCS states and roles

KCS roles include `kcs_candidate`, `kcs_contributor`, `kcs_publisher` (plus `knowledge_coach`). **Confidence** (editable by `knowledge_coach`, `knowledge_admin`, `kcs_contributor`, `kcs_publisher`): Draft / Review / Scheduled for publish → *Work in Progress*; Published (and Pending retirement, Outdated) → *Validated* if published by coach, contributor or publisher, else *Not Validated*; Retired → *Archived*; articles older than the plugin → *None*. **Governance** (experience based or compliance based; editable by anyone with contribute access) marks who may manage regulated articles.

### Article from an incident (custom build, global)

Same pattern as the HR case below: KCS Article template active; `csm_table_map` **Incident KCS Article** (Incident → KCS Article; Sys ID → Source Task, Resolution notes → Resolution; optional advanced script copying the first comment into `kb_issue`); system property `enable_kcs_incident` = true; UI action **Create Knowledge** on Incident (action name `create_knowledge`, client + form button, condition on the property, `CSMTableMapUtil.findMapByName("incident_kcs_article")` and `KBKnowledge().canCreate()`, server part redirects to the map's target URL). There is also a ready **Incident KCS Article** template route described with Agent Workspace article creation.

### Article from a customer service case

`sn_customerservice.customer_admin` or `admin`. Mapping **Case KCS Article** in **CSM Table Map** (`csm_table_map`): source `sn_customerservice_case`, target `kb_template_kcs_article`, four basic field mappings; optional **Advanced Field Mapping** script (overrides basic mappings for the same field, otherwise adds to them) and a **Condition** (or advanced condition) for the **Create Knowledge** button. Users need contribute access to at least one active base. Change the scripts too if you change the target table.

### Article from an HR case (custom build, scope Human Resources: Core)

1. Activate the KCS Article template.
2. `csm_table_map` record **HR Case KCS Article**: source HR Case, target KCS Article; basic mappings Sys ID → Source Task, Short description, Close notes → Resolution, (description) → Cause; optional advanced script (the doc sample copies the last comment into Issue; note it declares `now_GR` but then uses `gr`, so it needs fixing before use).
3. System property `sn_hr_core.enable_kcs_hr` (true|false) = true (the form shows the name as `enable_kcs_hr` inside the HR scope).
4. UI action **Create Knowledge** on HR Case: action name `create_knowledge`, Client, List v3 Compatible, Form button, onclick `createKnowledgeClient()`, condition checks the property, `CSMTableMapUtil.findMapByName('sn_hr_core.hr_case_kcs_article')` and `KBKnowledge().canCreate()`; the client part blocks unsaved forms then resubmits, the server part (`gsftSubmit` pattern) saves the case and redirects to the map's target URL with `m2m_kb_task` link parameters. Client and server UI action, HR scope.

## Example

Ownership group **Example KB Owners** on article *Example VPN Guide*; rating threshold 2 → a 1-star rating creates a feedback task for the group manager *Test Manager*.

## Related

- [[Knowledge Bases and Categories]] · [[Knowledge Base Access and User Criteria]] · [[Knowledge Workflows and Article Lifecycle]]
