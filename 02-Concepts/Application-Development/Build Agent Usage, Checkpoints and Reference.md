---
type: reference
tags: [reference, platform, ai, update-sets, domain-separation, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Agentic development > Build Agent > Use and Reference (read 2026-10-08 through the docs site): Use Build Agent, Accessing Build Agent in ServiceNow Studio, Create an application using Build Agent default mode, Edit an existing application, Creating or updating an app file, Agentic workflows, agents and skills, Create agentic workflows, agents and skills, Revert app changes, Test what you built with Build Agent, Document an application, Checkpoints and conversation change log, Update sets and Build Agent, Deploying what you built with Build Agent, Issues and solutions in Build Agent, Build Agent reference, Supported metadata in Build Agent, Example prompts, Supported file types for Build Agent, Domain separation and Build Agent. https://www.servicenow.com/docs/r/application-development/use-build-agent.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Build Agent Usage, Checkpoints and Reference

**In one line:** how a Build Agent conversation becomes checkpoints and update sets, how the result is deployed, what goes wrong, and the lists of what it can create and accept.

From the Brazil docs. What Build Agent is, editions, tools, settings: [[Build Agent]]. All procedures need `admin` and start at **All > App Development > ServiceNow Studio**.

## Tasks

| Task | In the chat |
|---|---|
| Create an application | describe it (or *Create an app* from the list), attach diagrams or wireframes if useful > review the plan > **Approve plan**. Code files can be previewed before approval; real metadata exists only after build and install. UI can be previewed in a Studio tab and changed by pointing at it ("make this button purple") |
| Edit an application | new conversation > *Update an app* > pick it > describe > review in the change log > **Review all edits** > **Approve plan**. Applications not made in Studio / IDE / SDK are converted to Fluent first (open app tool) |
| Add or change one file | *Create a file* / *Update a file*; it asks for the application name or scope |
| Document | "Document this app" writes a README (tables, sample data, UI) into the file explorer; check it |
| Revert | checkpoints icon > choose > **Restore**: reverts application **and** conversation |

### Agents, skills and agentic workflows inside an application

Entitlement-dependent. It follows four phases: **Assess** (is the data model ready), **Analyze** (use cases from tables, roles, flows), **Design** (architecture with a quick win), **Build** (artifacts limited to the application's data model, roles and ACLs). An application with real data, roles and automation gives more specific results. Ask "analyze my application and suggest where an agent or skill would help" if unsure.

| For | Tool types it can attach |
|---|---|
| Skills | flow action*, Otto skill, inline script, explicit script, subflow*, web search |
| Agents | catalog item, conversational topic, flow action, Otto skill, record operations, script, search retrieval (matched to an existing search profile), subflow, web search |

\* only flow actions and subflows already in the application's scope; a skill must be published before another skill can use it.

Afterwards: test each skill in AI Skill Kit, test the agent in AI Agent Studio, **activate its triggers by hand** (never automatic), deploy with the application's update set.

### Testing (Test Agent)

After each build step it offers to generate ATF tests; accept or decline. Tests are stored in the application's scope and can be scheduled. Failures get a root-cause analysis; safe fixes are applied or proposed, and tests re-run until green ("auto-heal"); stale tests are updated or removed. Covers functional tests, UI tests, list and related-list steps, and suites. Scopes: global, custom, Store. Running needs the *ATF Test Generator and Cloud Runner* application and a cloud user.

## Checkpoints, change log, update sets

- A **checkpoint** is created each time you approve a task plan. The **conversation change log** (a Studio tab) lists files changed per checkpoint, the plan and actions, a *Summary* across checkpoints, and offers restore.
- Each checkpoint's changes go into **one update set**, named `<application name> build agent install 1`, `2`, ... Checkpoint 0 is only a restore point (initial state). Checkpoint 1's update set is the parent of the rest; all are in the application scope, so they can be merged for transport.
- After each checkpoint a **manual edit** update set (`manual edit 1`, ...) catches changes you make yourself outside the agent; it is dropped if empty when the next checkpoint starts.
- When you say the task is finished and rollback is no longer needed, everything is consolidated into a single update set.
- Open them from the checkpoint's **Review** button, the *Current Changes List* page, or the **Deployment** tab of the Studio home page.

The docs page contradicts itself on checkpoint 0 (one line says it creates a global-scope update set, the next that it creates none).

## Deployment

Nothing reaches users until you deploy and install: in the IDE the work lives in source and build artifacts, in Studio in update sets.

| Route | Notes |
|---|---|
| Update set | wrap the application: Custom Applications list > open it and switch to its scope > publish to an update set with demo data > deployment request (ReleaseOps) or the normal update set process |
| Application repository | publish from Git or from update sets; then a ReleaseOps pipeline can carry it and run its ATF tests. Register and entitle the application first |
| Git | push scoped applications to your own repository for branching and CI/CD |
| SDK | build and install from a local machine or an external pipeline |

**For one application on one instance, application repository and update sets are mutually exclusive**: after one is used there, the other cannot be (KB0715422). Global applications can also go into the repository and source control. Governance on the way: [[AEMC Pipelines and Deployments]].

## Problems

First step always: paste the exact error into the chat. If a few attempts fail, start a new conversation naming the error.

| Symptom | Check or do |
|---|---|
| Panel not visible | plugins and `admin`; refresh or sign in again |
| Unresponsive | clear cache, other browser, status page |
| Scope or name conflict | already used on the instance: let it pick another |
| Error loop | revert by checkpoint or Git, fresh conversation |
| Changes missing after deploy | it deploys the **latest successful build**: read the build output. In the IDE run SDK build, then deploy and install |
| Empty UI page | paste the browser console errors |
| Context limit exceeded | new conversation, describe the application again: it reads the work already done |
| Out of prompts | wait for the 30-day reset or upgrade |
| Rate limit | wait a minute or two |
| Unsupported configuration | do that step on the platform |
| Missing dependencies (IDE) | `package.json`; `npm install` |
| Long prompt times out | session timeout. The docs name the property two ways (`glide.ui.session_timeout`, `glide.ui.sessiontimeout`): check `sys_properties`; 1440 suggested for labs |

## Supported metadata (ask it for anything not listed)

ATF tests · application menus and modules · assignment rules · business rules · choice lists · client scripts · conditions and queries · connection and credential aliases · custom AI agents · data policies · data import pipeline (data source, staging table, transform map; CSV, Excel, JSON, XML, JDBC, LDAP, REST; one-off or scheduled) · data lookup · dictionary overrides · event registry · flows · forms · inbound email actions · JavaScript modules (shared server code with import/export) · knowledge base access · LDAP server configurations · list controls · playbooks (attach an image, XML or description; includes runtime permissions, launchers, optional activities, outputs of nested playbooks) · record insertion (seed, demo and configuration records in any table) · REST messages and HTTP methods · scheduled jobs · script includes · scripted REST APIs · ACLs and roles · Service Catalog items, variables (including a default that follows another variable) and fulfilment flows · Service Portal pages and widgets · Otto skills · tables · transition conditions · UI actions · UI Builder components · UI pages · UI styles (`sys_ui_style`) · UI policies · views · user criteria · legacy workflows · workspaces.

## Files it accepts

| Kind | Extensions |
|---|---|
| Code | .js .ts .tsx .jsx .py .java .css .html .xml .json |
| Documents | .txt .md .csv .log |
| Images | .png .jpg .jpeg .gif .svg .webp |
| ServiceNow | .now.ts, update set .xml |

Up to 10 MB each. Uploads live only in that conversation and are **not** added to the application unless you ask ("add this script as a script include"); re-upload after a reload. Excel or PDF: convert to CSV or paste a screenshot. An update set XML is analysed and recreated in Fluent.

## Prompt patterns

| Goal | Pattern |
|---|---|
| Plan | "I want to build [idea]. Plan tables, fields, roles, business rules. Wait for my approval before creating files." |
| Extend base | "Add a field [field] to the incident table and a business rule that [logic]. Show the plan before applying." |
| Secure | "Only [role] can edit, others read-only. Show the ACL changes first." |
| Test | "Create ATF tests to validate [function]." |
| Document | "Summarise architecture, data model, roles and UI. Make no changes." |
| Diagram | "Generate a Mermaid ER diagram of this application." |
| Coach | "For [metadata type], give me an ideal prompt and the common pitfalls." |

State security, audit, testing and compliance needs in the first prompt. Field show / hide / mandatory rules come out as UI policies, without script.

## Domain separation

Supported. The agent does not configure domains (an administrator does, with plugin `com.glide.domain.msp_extensions`); it creates ordinary metadata that takes part:

- a table extending a domain-separated parent (`task`, `cmdb_ci`) inherits `sys_domain`: do not declare it again;
- its GlideRecord queries are filtered by domain; reference fields show only visible records;
- flows run in the domain of the triggering record; cross-domain flows need extra design;
- Fluent can set `sys_domain` and `sys_override` on records;
- global-scope metadata is visible to all domains; scoped applications isolate better.

## Related

- [[Build Agent]] · [[AEMC Pipelines and Deployments]] · [[Application Scope and Namespace Identifiers]] · [[Delegated Development and Deployment]]
