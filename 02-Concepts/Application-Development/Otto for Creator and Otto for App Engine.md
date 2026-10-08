---
type: concept
tags: [concept, platform, ai, roles, workspace, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Agentic development (read 2026-10-08 through the docs site; both sections whole). ServiceNow Otto for App Engine - landing page, Exploring, AI capabilities for enhancing custom applications, Custom app record summarization skill, Tools included, Choosing the right AI capability, Configuring, Installing, Activate the custom app record summarization skill, Configure the custom app record summarization skill, Using, Summarize a record in-product, Summarize a record through chat. ServiceNow Otto for Creator - landing page, Exploring, Configuring, Install, now.assist.creator role, Using generative AI (Process Mining, RPA bot generation, UI generation: exploring, Experience Generation, UI Builder Agent, client script summarization, data binding generation, event handler generation, module generation, general guidelines, install, grant UI Builder admin role, configure UI Builder Agent, the six use procedures and six use cases, roles, roles and permissions matrix, formula operator synonyms), Using agentic AI, ATF troubleshooting agent (explore, install, troubleshoot test failures, design considerations). https://www.servicenow.com/docs/r/application-development/now-assist-for-creator/now-assist-for-creator-landing.html and https://www.servicenow.com/docs/r/application-development/now-assist-for-app-engine/add-ai-to-custom-apps-with-now-assist-for-app-engine-enterprise.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Otto for Creator and Otto for App Engine

**In one line:** **Otto for Creator** is AI that helps the *developer* build (generate apps, flows, code, UI, tests); **Otto for App Engine** is AI that the finished application's *users* work with (skills, agents, record summaries).

From the Brazil docs. Both are separate subscriptions from the Store, in three licence tiers (Foundation, Advanced, Prime); output must be reviewed; data leaves the instance for a central ServiceNow environment and possibly a third-party cloud; usage is collected unless opted out. Parts of the UI and docs still say Now Assist. Build Agent, the largest piece of Otto for Creator: [[Build Agent]].

## Otto for Creator (`sn_now_creator`)

Install (admin; Next Experience must be on): Store > **Request App** > **System Applications > All Available Applications** > install > turn on each capability. Skills are switched on in **AI Admin Hub > Skills > Creator** (the Code Assist skills are on by default); agents and agentic workflows in **AI Agent Studio**. Model provider per skill: Now LLM Service, Azure OpenAI, Google Gemini or Anthropic Claude on AWS (choices offered are set in AI Control Tower).

Roles: since version 28.4.3 most capabilities no longer need `now.assist.creator`; each needs the role of the tool it lives in (`catalog_builder_editor`, `flow_designer`, `ui_builder_admin`, `now_assist_panel_user` for app generation in Studio).

| Capability | Where |
|---|---|
| App summary generation | ServiceNow Studio |
| Build Agent | Studio, ServiceNow IDE |
| Code generation, edit, autocomplete, summarization | IDE and script fields |
| Catalog item generation | Catalog Builder |
| Flow generation, recommendations, summarization | Workflow Studio |
| Playbook generation (text, image or knowledge article), recommendations, summarization | Workflow Studio |
| UI generation, UI Builder agent | UI Builder |
| Theme generation (from an image) | Theme Builder |
| Mobile card generation; widget generation and update | mobile and portal builders |
| RPA bot generation | RPA Desktop Design Studio |
| Process Mining (why work gets reassigned, from work notes) | Process Mining |
| Release lifecycle documentation agent (release notes, update set descriptions) | Core UI, ReleaseOps, [[App Engine Management Center]] |
| ATF troubleshooting agent | ATF |

### UI generation (`sn_ui_generation`, Zurich or later)

Everything here needs **`ui_builder_admin`** (contains `ui_interaction_admin`, `canvas_user`, `workspace_admin`); module generation also works with `workspace_admin`; only `admin` grants the role and manages the properties.

| Feature | What it does |
|---|---|
| **Experience Generation** | UI Builder > **Create > Experience > AI-Generated experience**. Describe name, table, navigation style, chart ("Create a tabbed experience called 'Change Request Tracker' with a pie chart grouped by state") > **Generate preview**: a read-only preview shows name, navigation, chart parameters, the table found and sample rows > **Save and edit experience** or reword and **Regenerate preview**. Creates three linked pages: landing (count and chart), filtered list, record. Missing details get defaults; the experience is marked as AI-generated |
| **UI Builder Agent** | chat in the Otto panel of the page editor: answers how-to questions from the docs, explains how the current page is built ("are client scripts used on my page?"), and changes it (layout, add a button with a link, styling). Works only inside UI Builder |
| **Client script summarization** | in *Edit client script*, panel **Explain this code**: a summary and a code walk-through; **Explain again** after edits |
| **Data binding generation** | in the *Bind data* dialog, describe the binding ("if the page is bare show 'Simplified View', otherwise 'Standard View'") and get the formula (for example an `IF(...)`, `CONCAT`, `WHERE_GT`, `LEN`) or a data pill; **Accept and Edit** > **Apply**. Understands synonyms: count / how many = LEN, add up = SUM, join = CONCAT, between dates = DATEDIFF, and so on (70+ operators under *Browse operators*) |
| **Event handler generation** | on a component event, describe the action ("open record page in a new tab with table and sys_id from the event payload"). Supported handlers: Open page or URL, Open or close modal dialog, Viewport load requested. Binds parameters from the event payload or state |
| **Module generation** | **All > Create menu** > title > **Generate multiple modules at once**: one prompt creates list, single record, new record, URL, script, dashboard and folder modules; **Accept and Edit** each |

Setting up the UI Builder Agent (four parts): install Otto for Creator, UI Generation and Conversational Studio (`sn_convo_studio`) > **AI Agent Studio > Overview** > *UI Builder Agent* card > step through the wizard unchanged (it runs as the calling user, approved role `ui_builder_admin`) and tick *This AI agent is active* > **AI Admin Hub > Experiences** > turn on the Otto panel > in Assistant Designer edit *Otto Panel - Platform (default)*: add display experience *Unified Navigation app shell*, save, **Activate**. AI Search must be requested first (**AI Search > AI Search Status > Request AI Search**, about 15 minutes).

Prompt advice: name the experience, the navigation style, the chart type and the grouping field; a vague prompt ("track incidents") gives a generic result.

### ATF troubleshooting agent

Needs Build Agent and the *ATF Test Generator and Cloud Runner* application; default model provider Anthropic Claude on AWS. User needs an ATF role (`atf_test_admin`, `atf_test_designer`, `atf_ws_designer` or admin) **plus** `atf_triager` and `now_assist_panel_user`. `atf_triager` gives read on test and step results, any `sys_metadata`, and syslog, and write on `sn_atf_assist_triage_output`.

Use: run a test > **Go to Result** (or open a failed step result) > **Triage with Otto**: Studio or the IDE opens with a pre-filled prompt; the agent finds the failing step and cause, proposes fixes, applies the chosen one and re-runs. Same supported and unsupported metadata as Test Agent ([[Autonomous Engineer and Test Agent]]): not flows, workspace steps, or custom steps.

## Otto for App Engine

Install from the Store (admin). Brings the tools to put AI inside a custom application:

| Tool | For |
|---|---|
| AI Skill Kit | building custom skills (model, inputs, prompt, tools) |
| AI Agent Studio | building AI agents and agentic workflows |
| AI Data Kit | data sets to test and evaluate them |
| AI Control Tower | governing the assets |

### Three kinds of capability

| Capability | Is | Choose when |
|---|---|---|
| **Skill** | one defined generative task: input (usually a record), prompt, output. Called from the Otto panel, a UI action, a flow action or Virtual Agent | the task is specific and predictable (summarise, classify); most human control; easiest first step |
| **AI agent** | instructions plus role, steps, tools (skills, data), trigger, and where it shows (Otto panel or Virtual Agent) | the task needs some reasoning and several tools, and can run with less supervision |
| **Agentic workflow** | several agents towards one outcome, coordinated by an orchestrator | an end-to-end, knowledge-heavy process; the docs suggest low-risk ones such as routine approvals |

Shipped ("Platform") skills and agents were built for shipped use cases: to use one in a custom application it must be duplicated and reworked, so building a custom one is usually quicker. A custom skill goes: create > prompt > test > evaluate > publish > an Otto admin activates it (a data steward may have to approve) > use.

### Custom app record summarization skill (version 28.2.4 and later)

A template skill that summarises records of custom tables, global or scoped.

1. Activate: **AI Admin Hub > Skills > App Engine** > card > **Activate skill** (admin or `sn_generative_ai.nsa_admin`).
2. Configure (card > actions > **Edit**): pick the application > **Base input table** > the fields to include, each with a **Field description** that says what it means and its format (this drives quality) > optional extra sources: related tables, relationships (with fields and descriptions), **emails** and **attachments** (fetched when present; attachments cost more usage).
3. Test on a real record with optional extra instructions (each test counts as usage).
4. Access: roles and conditions.
5. Display: **in-product** (a *Summarize* button on forms; an AI summary card component in workspaces), **Otto panel** ("summarize a record" then the number), or both. The display choice applies to every application using the skill.

Users can copy the summary, expand or collapse it, and rate it.

## Related

- [[Build Agent]] · [[Autonomous Engineer and Test Agent]] · [[Agentic Development Overview, Tool Comparison and Governance]] · [[Otto for ITSM Skills and Agentic Workflows]] · [[Subscription Management]]
