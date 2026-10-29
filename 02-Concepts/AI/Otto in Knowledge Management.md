---
type: concept
tags: [concept, ai, knowledge]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > ServiceNow Otto in Knowledge Management (landing, Explore, Configure, Configure the KB generation skill, Configure skill for context menu, Configure custom prompts for knowledge article templates, Guidelines for creating prompts, Configure skill to identify duplicate articles, Configure Article Optimization skill and prompts, Activate the Article Optimization skill, Configure custom AI-based scans for Article Optimization, Configure skills for potential gaps, Configure AI skills for merging articles, Enable multilingual service, Enable article optimization recommendations; Use, Generate a knowledge article from the Otto panel, Generate knowledge article in classic environment, Generate article with multi-language, Edit article with context menu, Generate and edit articles in the Knowledge Center article editor, Identify and review articles, Merge duplicate articles), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/now-assist-in-knowledge-management/now-assist-knowledge-management.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Otto in Knowledge Management

**In one line:** generative AI skills for knowledge: **KB generation** (draft an article from a case, incident or HR case), **knowledge content recommendation** (Elaborate / Shorten context menu), **identify duplicate articles**, **merge duplicate articles**, **Article Optimization** (AO) recommendations and **knowledge gaps identification**; set up in **AI Admin**.

From the Brazil docs; not tested. The Brazil pages call it **ServiceNow Otto in Knowledge Management**; the URLs still say *now-assist* (same feature, older name Now Assist). Data goes to a central ServiceNow AI environment and inputs / outputs may be collected to improve the product (per the page); review AI output before publishing. Knowledge Center features using these skills: [[Knowledge Center]], [[Knowledge Center Article Optimization and Health Score]].

## Prerequisites

Store apps **ServiceNow Otto for Knowledge Management** and **Knowledge Capabilities in UI Builder** (latest), plus the product Otto app (Otto for CSM, ITSM, HRSD, FSM). To reach articles created with TinyMCE from Knowledge Center, the KB generation skill must be enabled.

## Configure (AI Admin)

The docs give several menu paths for the same console: **AI Admin > AI Skills**, **AI Admin > AI Features > Platform**, **Admin Center > AI Admin > AI Skills > Platform**, **AI Admin Hub > AI Skills > Platform > Knowledge** (unconfirmed which is current; likely renames).

| Skill | Setup |
|---|---|
| **KB generation** | pick the product app, feature *Knowledge*, **Activate skill**; read-only inputs: Input Table (e.g. case for CSM), Input Fields, **Default Knowledge Base for NAP** (where the panel drafts); availability always or by conditions; display **In-product** (forms and workspaces) and/or **Otto panel**, each with roles; Activate. Skill inputs per product: [[Otto for ITSM Skill Inputs, Triggers and Customization]] |
| **Knowledge content recommendation** (context menu) | Platform > Knowledge feature > View details > Active skills > Edit > enable **In-product** > Done |
| **Identify duplicate articles** (`knowledge_admin` and `knowledge_manager`) | Activate > **Switch scope**: Table (read-only), Fields to compare (or **Configure custom template**), Filter (article ID, base version, base ...), **Duplicates generation frequency** (*Run once* runs immediately; others run soon after activation then on schedule; reset the skill after changing frequency) > Save and continue > Done |
| **Merge duplicate articles** | Platform > Knowledge > toggle on |
| **Knowledge gaps identification** (ITSM), (CSM), (HR) | Platform > Knowledge > activate each; recommendations then appear on the Knowledge Center home |
| **Article Optimization Recommendations** | AI Skills > Platform > Knowledge > toggle (also needed for health scores) |
| Multilingual | **AI Admin > Settings > Multilingual service**: **Native Translation** (model's own languages) and **Dynamic Translation** (extra languages); Edit per provider |

### Custom prompts per article template (KB generation)

Roles `sn_skill_builder.admin`, `sn_nowassist_admin.nsa_admin`. Form check first: the article form needs the **Knowledge Gen AI Message** field and a second Otto field (name cut off) in its view; customised forms must add them (Configure Form Layout on `kb_knowledge`, then clear cache with `cache.do`).

1. **AI Skill Kit > Home** > ServiceNow skills > *KB generation* for the workflow (ITSM, CSM ...) > **Clone** (prompts can only be changed on the clone) > Open Cloned Skill.
2. Prompts > Add: name, provider, provider API; write, save and **evaluate** the prompt.
3. Settings > **Usage conditions**: `prompt_type` = `single` or `multi`, `source_table` = the task table, `target_table` = the template table. **Finalize prompt** after checking the JSON output map.
4. Repeat for every template, single and multi-KB; **Publish**; then in AI Admin (**Link to NAA**) **Activate skill**.

Prompt guideline from the docs: header (purpose), input data (e.g. `{{short_description}}`, `{{description}}`, `{{activities}}`, `{{close_notes}}`), rules (no real names, emails, phone numbers or machine names; only content from the task; "N/A" when unsure), then a JSON output whose keys match the template fields, e.g. `kb_introduction` (Problem, Severity), `kb_instructions` (Steps To Resolve), `short_description` (Title). Multi-KB prompts combine child articles (`{{intermediateKBGenerator.output}}`) into one parent article.

### Custom Article Optimization skill and AI scans

1. Skill Kit: **Create Skill**, Role restriction *Nobody*, prompt from library (reference) or from scratch (editing existing custom skills may make AO scans unreliable); at least one **Skill input** (default datatype Record, table Knowledge `kb_knowledge`); Go to summary > Finish; edit prompts; Deployment settings > **Publish**.
2. In `sys_generative_ai_config` find the prompts, set the AI Admin location (AO sits under Platform > Knowledge) and **Feature name** = skill name; related list **Generative AI Prompt Configs** > New: Name `optimization_prompt`, Value = prompt name from the Output format section.
3. Activate from the AI Admin list (Platform > Knowledge > skill name).
4. Use it in an AO scan with Execution type *Now Assist skill* ([[Knowledge Center Article Optimization and Health Score]]).

## Use

- **Otto panel**: open an assigned case or incident > sparkle icon > *Generate Article* (or type a task number without opening it) > **View KB article** > edit, publish, rate the output. HRSD: only on the HR case table (`sn_hr_core_case`).
- **Classic environment, from a task** (author or agent): UI action on the record > *Use AI to draft this article?* > **Yes, draft with Otto** > pick up to five more similar tasks > article opens in a new tab with an ID. Only standard and KCS templates here. Needs the skill displayed In-product with table, fields and conditions set.
- **Classic, as author**: **Lists > Knowledge > All articles > New** > base and template > Yes, draft with Otto > search up to five task types / tasks > *Use selected tasks...*. The banner "drafted by ServiceNow Otto" disappears after Save or Publish. Generation cannot be stopped once started. The article links to the parent task and the selected tasks.
- **Other language**: from a task documented in another language > **Create Knowledge** > base and **Article language** (choices depend on the base's language packages and admin settings).
- **Context menu**: select text in a form field > Otto icon > **Elaborate** or **Shorten** > **Insert**. Supported tags: p, br, ol / ul / li, h1-h6, strong / em / s, a. Unsupported (error): media (img, video, audio, picture, source, iframe, embed, object), table, details, summary, knowledge blocks.
- **Knowledge Center editor**: Actions > Create an article > base > template > Next > instruction (e.g. "Generate an article for password reset") > review / **Regenerate**. Instruction block must not contain img, video, audio, canvas, svg, iframe, script, input, button.
- **Duplicates list**: **Knowledge > Articles > Duplicate Articles** > expand topics > **Unmark as Duplicate** (may regroup on the next run). Works on new, published, draft and in-review articles; not on non-English articles.
- **Merge**: Potential duplicates card > View all > select articles > base > template; rules and effects in [[Knowledge Center Article Optimization and Health Score]].

## Example

An admin clones *KB generation* for ITSM as *Example KB Generation*, adds a single-KB prompt for the template *Example How-To* (`source_table` incident, `target_table` the template table), publishes and activates it; an agent then opens an incident assigned to them and uses **Yes, draft with Otto**.

## Related

- [[Otto for ITSM Skills and Agentic Workflows]] · [[Knowledge Article Templates and Knowledge Blocks]] · [[Knowledge Feedback, Ownership Groups and Article Quality]] · [[Now Assist in Document Management]]
