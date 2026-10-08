---
type: concept
tags: [concept, platform, ai, security, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Agentic development on the ServiceNow AI Platform > Agentic development (read 2026-10-08 through the docs site; whole section): Agentic development on the ServiceNow AI Platform, Exploring agentic development, Who should use this guide, What is agentic development, Governance for agentic development, Tool comparison for agentic development, Workflow for agentic development, General guidelines, Onboarding, Agentic development (Develop), Environments, Agentic development with Build Agent (overview, get started, Build Agent and platform tools, Autonomous Engineer, custom in-app agents / workflows / skills, limitations, refinement in ServiceNow Studio, refinement in the ServiceNow IDE), Agentic app creation with Otto for Creator, Agentic development with Otto for App Engine, Testing agentically developed apps, Agentic development and deployment, Reference, ServiceNow Otto skills developer-oriented list, Example prompts. https://www.servicenow.com/docs/r/application-development/vibe-coding-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Agentic Development Overview, Tool Comparison and Governance

**In one line:** "agentic development" (the docs also say "vibe coding") means building an application by describing it to an AI in conversation; this section of the guide is an overview that points to the products, compares them, and lists the governance expected around AI-generated work.

From the Brazil docs. Most of the section repeats the product pages; the detail is in [[Build Agent]], [[Build Agent Usage, Checkpoints and Reference]], [[Autonomous Engineer and Test Agent]] and [[Otto for Creator and Otto for App Engine]]. Only what is new is kept here.

## Two ends of a spectrum

| Approach | Means |
|---|---|
| Autonomous generation | give a goal, let the AI generate, test and deploy without reading the code: fastest |
| Collaborative | the AI proposes, the developer reviews, refines and owns the code: supportable |

The docs' advice for Build Agent sits at the second end: use it only if you understand and can support what it generates, know the platform, and take part in the process.

Why do it on the platform instead of a generic AI tool: the agent already sees the instance's data model, ACLs, business rules and flows, so output fits the instance; results are ordinary scoped applications under the usual controls (ACLs, scope, update sets). A separately built front end can still sit on platform data.

## Tool comparison

| Tool | Best for | Skill | Output | Limits |
|---|---|---|---|---|
| **Build Agent** in ServiceNow Studio | whole applications, metadata-driven, with previews and diffs; guided, batch or one-shot modes | beginner to intermediate | tables, flows, experiences | best for new applications under about 20 tables; little cross-product integration; no complex custom code generation in Studio |
| **Build Agent** in the ServiceNow IDE | hardening generated applications, complex business rules and script includes | advanced | code files, deployed live | needs developer expertise |
| **Otto for Creator** skills | one catalog item at a time with variables and fulfilment; also app, flow, playbook, UI generation | intermediate | catalog items, record producers, order guides | not whole applications |
| **ServiceNow SDK** | local work in VS Code with Fluent and the command line, CI/CD | advanced | applications | less metadata coverage than Studio |

Studio or IDE after generation: Studio for reviewing tables, ACLs, roles and cross-scope edits visually; IDE for file-centred, code-heavy changes and pairing with the SDK and Git. IDE advice: fix structure (tables, relationships, ACLs) before polishing scripts; prefer declarative configuration (UI policies, flows) to code; write ATF tests for the critical paths before broad changes; tighten any over-permissive ACL left by scaffolding.

## Usual sequence

1. Describe the goal with roles, data needs and success criteria.
2. The agent produces a plan (for large, well-defined work, Autonomous Engineer replaces this step).
3. It generates the components.
4. It tests and repairs.
5. Refine by further prompts.
6. Run ATF.
7. Deploy from a sandbox or sub-production instance.

Other advice: say which application you mean when switching between two; keep prompts that worked; develop in a Developer Sandbox, a PDI or another non-production instance.

## Governance expected

Checklist from the docs:

- idea approved in [[App Engine Management Center]];
- ACLs and roles applied;
- code reviewed and optimised;
- ATF tests run and passed;
- release pipeline validated ([[AEMC Pipelines and Deployments]]);
- documentation generated;
- compliance and audit logs updated.

**Review by a person before deployment** whenever the application touches sensitive tables, personal or regulated data; contains scripts, business rules or external integrations; creates or changes roles, ACLs or cross-scope privileges; or has not been tested against the organisation's own data and configuration.

| Tool | Role in governance |
|---|---|
| App Engine Management Center | intake approval, collaborators, lifecycle checkpoints |
| AI Control Tower | registers generated applications and agents as AI assets: lifecycle, risk classification, evaluation scores; with AI Risk and Compliance, assessment against frameworks such as the NIST AI RMF and the EU AI Act |
| ServiceNow Vault (Vault Console) | finds and protects sensitive data |
| Machine Identity Console | governs API connections and authenticates AI agents |
| ReleaseOps | update set automation, pipelines |
| ATF | functional and regression tests |
| Developer Sandboxes | isolated copies of a non-production instance's metadata for parallel work, with Git or update sets, created on demand |

## Discrepancies inside the docs

- **Who can use it:** the product pages say only `admin`; this section's feature table also names `now.assist.creator` and `admin or delegated_developer` for some capabilities. Treat `admin` as the requirement unless tested.
- **Free allowance:** here "25 calls per month" on a customer instance (Zurich or later) and "10 per month" on a PDI; the Build Agent pages say 100 interactions per 30 days for the trial and 25 per 30 days on a PDI. Check the instance.

## Otto skills, developer-oriented list

The docs list the generative skills by area, as a map of manual work the platform now automates (the full list is under the AI documentation).

| Area | Skills |
|---|---|
| Applications and artifacts | app generation, catalog item generation, experience generation, mobile card generation, create a demand, story generation, target generation, write planning item |
| Flows and automation | flow generation (also from images), flow recommendations, flow summarization, playbook generation (also from images), playbook recommendations, spoke generation, event handler generation, RPA bot generation, LEAP installer |
| Code | Code Assist generation, edit, autocomplete, summarization; client script summarization; hide Code Assist API definition; new column data generation |
| Testing, quality, risk | test generation, change request risk explanation, risk assessment summarization, risk event summarization, security incident quality assessment, approval recommendation |
| Summarising | app summary, complete record generation, document summarization, docs summarization, doc generation, work notes analysis, sidebar discussion summarization, chat summarization, email recommendation, resolution notes generation, release notes generation |
| Cases and incidents | incident summarization, incident assist, incident sentiment analysis, case summarization, suggested steps, chat reply recommendation, activity response generation, work order task summarization, government case summarization |
| Knowledge | KB generation, knowledge content recommendation, article optimization, potential knowledge gaps |
| Analytics | analytics exploration and its summarization, query generation, insight generation, follow-up generation, hidden insight generation, dashboard and visualization export, data visualization generation |
| CMDB and architecture | CI summarization, manage duplicate CIs, service mapping candidates, diagram change analysis, business application insights, register a business application, register a digital integration |
| Security and compliance | correlation insights, post-incident analysis, common control objective creation, control objective impact analyzer, regulatory alert summarization, vulnerable item deduplication, suggest vulnerability solutions |
| Finance and procurement | invoice case summarization, invoice data extraction, purchase order, procurement case, supplier and negotiation summarization |

ITSM ones in detail: [[Otto for ITSM Skills and Agentic Workflows]].

## Related

- [[Build Agent]] · [[Autonomous Engineer and Test Agent]] · [[Otto for Creator and Otto for App Engine]] · [[Application Development Tools and Lifecycle]] · [[Personal Developer Instances]]
