---
type: concept
tags: [concept, platform, ai, admin, security, integrations, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Agentic development on the ServiceNow AI Platform (read 2026-10-08 through the docs site): Agentic development on the ServiceNow AI Platform (chapter page), Build Agent, Exploring Build Agent, Build Agent use cases, Autonomous Engineer in Build Agent, Build Agent workflow, Build Agent and Autonomous Engineer chat panel, Supported models and versions, Tutorial for Build Agent in ServiceNow Studio, General guidelines for Build Agent, Build Agent tools, MCP connections and Build Agent, Build Agent governance, Build Agent limitations, Build Agent configuration, Install Build Agent, Build Agent plugins, Connect Build Agent to a supported MCP server, Configure custom skills and rules, Configure auto test prompting and UI tests, Configure web search. https://www.servicenow.com/docs/r/application-development/build-agent.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Build Agent

**In one line:** an AI agent inside ServiceNow Studio and the ServiceNow IDE that turns a plain-language request into application metadata (tables, logic, UI, tests), shows a plan for approval, and tracks what it changed in update sets.

From the Brazil docs. Day-to-day use, checkpoints, deployment and reference lists: [[Build Agent Usage, Checkpoints and Reference]]. The docs call "ServiceNow Otto" the new AI experience brand; parts of the text still say Now Assist for the same assets (see [[Otto for ITSM Skills and Agentic Workflows]]).

## Where it sits

| Product | For |
|---|---|
| **Build Agent** | building and changing applications by conversation ("agentic development", "vibe coding"); development and test stages |
| **Otto for Creator** | generative skills for developers (app, flow, UI generation) on non-production instances; contains the premium Build Agent |
| **Otto for App Engine** | AI skills, agents and agentic workflows that the application's **users** use at runtime; built with AI Skill Kit and AI Agent Studio |
| **Autonomous Engineer** | separate Store application for large jobs: interviews you, writes a plan of work items, builds them in parallel in the background. Installing it installs Build Agent, not the reverse |
| **Test Agent** | writes and runs ATF tests for what Build Agent built and analyses failures |

## Facts

- **Only `admin` can use it** at present.
- Works on scoped **and** global applications, including base tables such as Incident (`incident`).
- Generates **ServiceNow Fluent** (the platform's code language; `.now.ts` files) and can use React for custom UI. It only creates metadata Fluent supports: anything else needs exact instructions or is done by hand on the platform.
- Enabled by default for "create with AI" in Studio; turn it off in Studio preferences to use the older app generation skill instead.
- Usable in any supported language, on PDIs and in Developer Sandboxes.
- Availability is restricted for some regions, in-country SKUs and regulated markets. Build Agent v2 (Australia Patch 0, Zurich Patch 8 and later) depends on off-instance services and is **not available in GCC, NSC or FedRAMP** environments; they stay on v1 (on-platform). Autonomous Engineer and Test Agent share the restriction.
- ServiceNow collects inputs, outputs and edits to improve its models unless the customer opts out.

### Editions and prompt counting

| Edition | Plugins | Allowance |
|---|---|---|
| **Build Agent (Trial)**, installed on every instance | `sn_glider`, `sn_build_agent` | 100 interactions per 30 days free; then wait for the reset or buy |
| **Premium** | `sn_now_creator` (Otto for Creator), which contains `sn_build_agent_pro` | by entitlement |
| PDI | | 25 prompts per instance per 30-day cycle |

Every message you send counts, including answers to its clarifying questions; **approving a plan does not**. Draft long prompts in a text editor first.

Install premium (admin): buy *ServiceNow Otto for Creator* in the Store > **System Applications > All Available Applications > All** > install > **AI Admin Hub > Skills** > tab *Creator* > **Turn on**. Instances on Australia Patch 5 or Zurich Patch 12 and later upgrade Build Agent automatically when a new version is published.

Models listed for Brazil: Azure OpenAI 5.4, 5.5 and GPT 5.6 Sol, Google Gemini 3.5 Flash, Gemini 2.5 Pro, Claude Opus 4.6, 4.8 and 5.0. The version is picked in the chat panel; the provider is changed in AI Admin Hub.

## Studio or IDE

| | ServiceNow Studio | ServiceNow IDE |
|---|---|---|
| Suits | admins, low-code builders, analysts | developers who want TypeScript and Fluent |
| Style | metadata-first: guided steps, previews, diffs | code-first: generates whole applications, approve edits, then build and deploy |
| UI produced | forms, lists, workspaces, catalog items | React UI pages |
| Deployment | update sets; Studio package and install | SDK build, deploy, install |
| Source control | update sets, linked repositories | Git with branches |
| Local work | no | yes, VS Code with `@servicenow/now-sdk` |

Needs ServiceNow SDK 4.0 or later. Checkpoints and rollback work in both.

## Chat panel

Studio home page centre = new conversation; **Conversations** icon in the Navigator = existing ones. Icons: new chat, chats, **checkpoints**. A selector switches between *Build Agent* and *Autonomous Engineer*. Right-clicking an artifact on the platform > **Configure** opens it in Studio ready for a conversation. A conversation begun in Otto elsewhere can be **handed off**: Studio opens Build Agent with an editable summary pre-filled (nothing runs until you send it) and the full transcript attached.

## Usual sequence

1. Check settings (MCP servers, tests, web search).
2. Describe what to create or change.
3. It proposes a plan; adjust by prompting, then **Approve plan**.
4. It writes the metadata; review diffs, the change log and checkpoints.
5. Ask for ATF tests and run them; failures are triaged automatically.
6. Build, verify in the file navigator, deploy (update set or Git).

## Tools it can call

| Tool | Does |
|---|---|
| Planning | step-by-step plan, refined by feedback |
| Semantic metadata search | finds existing files and applications by meaning; used on its own initiative to avoid duplicates, or on request |
| Code search | exact text or regex across workspace files |
| Table schema inspector | every field of a table: name, type, mandatory, reference target |
| Open app | finds an application not built in Studio / IDE / SDK, converts it to Fluent and adds it to the workspace |
| Run query | queries a table (for example the top five records) |
| Run script | generates and runs a **server-side** script on the instance; shows script, intent and scope and **waits for approval**; runs in the scope of the application being built (an unresolvable scope name fails, it never falls back to global) |
| Rollback script | undoes a run-script operation of the current session, with the same approval |
| UI validation | checks generated UI through Playwright on ATF Cloud Runner (needs the ATF Test Generator and Cloud Runner application) |
| Web search, web fetch | public web, or a URL you give; off until **Enable web search** is on |

## Settings (chat panel > Settings icon, admin)

| Tab | Setting |
|---|---|
| General | **Sync ATF tests with app** (generate tests on creation and keep them in step); **Run UI ATF tests** (needs the previous one; off by default because slow); **Enable web search** |
| MCP | **Enable MCP servers**, then pick the server and **Allow** once; expand a server to see its tools |
| Skills / Rules | custom instructions (below) |

### Custom skills and rules

Records in the Build Agent Instruction table. A **rule** is loaded into every session automatically (naming conventions, "search before creating"); a **skill** is guidance called on demand (for example a read-only security review). Fields: **Name** (100 characters), **Type**, **Applies To** (*Instance* = all sessions, highest precedence; *Application* = sessions in that scope; *Me*), **Active**, **Description**, **Instructions for Build Agent** (plain text, up to 65,000 characters). Entitlement-dependent. In the IDE only, Markdown grounding files in the project (for example `BUILD_AGENT_RULES.md`) do a similar job per project.

### MCP connections

MCP (Model Context Protocol) lets the agent use tools of external systems. Supported: Atlassian Rovo, AWS DevOps, Box, Docusign, Figma, Linear, Miro, Prisma Postgres, Zoom, Zoom Chat, Zoom Docs, Zoom Whiteboard (each Zoom one needs its own Zoom app). Needs Connect Hub. Chain: admin adds the server as a Workflow Data Fabric connection > admin approves it as an AI asset in **AI Control Tower** > the user authenticates in **Personal Integrations** > the user enables it in Build Agent settings. Figma additionally needs an allowlist request to support; it supplies components, styles and variables as data instead of screenshots. MCP settings apply to Build Agent, not Autonomous Engineer.

## Governance built in

- Generates ACLs and roles, checks generated scripts for vulnerabilities, optimises code; can also create Security Attributes (attribute-based access), Security Data Filters (row-level restriction) and cross-scope privilege records ([[Application Access Settings and Cross-Scope Privileges]]).
- When creating agents and skills it asks which user or role they run as and who may use them. Generated agents are registered as AI assets in AI Control Tower, which flags agents with elevated permissions, access errors, or 90 days of inactivity with live permissions.
- Applications still pass through [[App Engine Management Center]] and its deployment checks.

## Limits and advice

- Generated code needs human review (ACLs, security, conventions): keep peer review, instance scan and tests.
- Security is at application and API level by default; ask explicitly for record- and field-level rules.
- Be specific and use platform names ("reference to `sys_user`", not "a field for who ordered"); one detailed prompt beats several vague ones; let it interview you; build one feature per conversation; use Git.
- Good first uses with no risk: ask it to document an existing application, explain a rule, draw a Mermaid diagram of the tables, audit ACLs.

## Related

- [[Build Agent Usage, Checkpoints and Reference]] · [[Application Development Tools and Lifecycle]] · [[App Engine Management Center]] · [[Personal Developer Instances]]
