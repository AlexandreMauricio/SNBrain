---
type: concept
tags: [concept, platform, ai, update-sets, admin, domain-separation, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Agentic development (read 2026-10-08 through the docs site; both sections whole). Autonomous Engineer - Autonomous Engineer, Exploring Autonomous Engineer, Agent packs, Autonomous Engineer chat panel, Using the dashboard, Resilience, Supported models, Supported tools, Playbooks in Autonomous Engineer, View changes in the change log, Configure Autonomous Engineer, Install Autonomous Engineer, Using Autonomous Engineer, Use Autonomous Engineer to implement an application, Manage work items during execution, Update sets and Autonomous Engineer, Test what you built, Deploying what you built, Reference, Domain separation support, Supported metadata, Supported file types, Plan and work item states. Test Agent - Test Agent, Exploring Test Agent, Test Agent access, Author, execute and troubleshoot tests and test suites, ATF test generation in Build Agent, Enable ATF test generation in Build Agent, UI Test Script in ATF, Create a UI Test Script in Build Agent, Test Agent references, Test Agent guidelines. https://www.servicenow.com/docs/r/application-development/autonomous-engineer.html and https://www.servicenow.com/docs/r/application-development/test-agent-landing-page.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Autonomous Engineer and Test Agent

**In one line:** two companions of [[Build Agent]]: **Autonomous Engineer** takes a whole set of requirements, plans it as work items and builds them in parallel; **Test Agent** writes, runs and repairs ATF tests for what was built.

From the Brazil docs. Both need `admin`; neither is available in regulated environments (see [[Build Agent]]). Tools, models, supported metadata, file types and domain behaviour are the same lists as Build Agent's ([[Build Agent Usage, Checkpoints and Reference]]).

## Autonomous Engineer

Separate Store application (entitlement). Installing it installs Build Agent. Install: Store > **System Applications > All Available Applications > All** > install > **AI Admin Hub > Skills** > *Creator* tab > Autonomous Engineer > **Turn on**. Works in ServiceNow Studio only, on PDIs and sandboxes too. MCP settings do not apply to it.

### Two phases

**Planning**

1. In the Studio chat panel switch the mode selector to **Autonomous Engineer**.
2. Give requirements: a prompt, or a file (for example a CSV of user stories).
3. It interviews you and searches the instance for existing tables, roles, fields, catalog items so it does not duplicate them; it writes a **brief** to approve.
4. It produces a **plan** of **work items** in user-story form (description, acceptance criteria, test criteria), grouped in sections and ordered by a dependency graph. **Show work items**; edit in chat or through *more options > Open record*.
5. Steps it cannot do (activating plugins, for example) are listed for you to do first.

**Execution**

6. **Execute plan**. One background agent per work item, isolated, all in parallel.
7. Each agent builds the metadata, has Test Agent generate and run ATF tests, and retries on failure several times.
8. At **Needs validation** open the item, read the artifacts and test results, **Mark as complete**; or edit it and ask for a retry; or ask to roll back that one item (others are untouched).
9. When all are complete a single **batch update set** for the plan is produced: export it for UAT or production.

### Dashboard

| Tab | Content |
|---|---|
| **Overview** | plan title, status, last update; **Pre-flight verification** (plugins to install with a link each; manual work items with instructions; collapses when cleared; absent if nothing is needed); **Milestones** (sub-plans with item counts, drill down, breadcrumb back) |
| **Work items** | every item with its state, updated live; items needing attention are highlighted. Per item: artifacts, test results, a **Log** tab with the background agent's own conversation, its own update set when complete |

The chat panel stays in the context of the open plan: ask about progress or answer the agents' questions. Earlier plans, and other users' plans: *Plans* view in the navigator.

| Plan state | Meaning |
|---|---|
| Standby | not started; items are Draft |
| In progress | being worked |
| In review | all built, awaiting your review |
| Completed | reviewed, ready to deploy |
| Cancelled | |

| Work item state | Meaning |
|---|---|
| Draft | generated, not queued |
| Ready | approved, waiting for dependencies before queueing |
| Queued | waiting for a background agent |
| Waiting | dependencies unmet |
| In progress | being built |
| Needs validation | built and tested; your review needed |
| Complete | approved by you; in the plan's update set |
| Blocked (user input) | the agent needs an answer; notice in chat |
| Blocked (error) | error it cannot fix; inspect, then ask for a retry |
| Cancelled | not executed, not in the update set |

### Agent packs

Bundles of domain knowledge, tools and skills loaded by the background agents; each includes Test Agent abilities for its product. In Brazil Patch 0: the **Planning** pack (parses requirements, interviews, applies best practice, writes the plan) and the **Platform development** pack (tables, roles and configuration patterns for custom applications). Product packs apply only to the work items that target that product.

### Resilience

A scheduled job watches active work items: an agent silent beyond a configurable threshold is cancelled and its item retried with a new agent; jobs interrupted by an instance restart are resubmitted; long-running jobs that still show activity are left alone.

### Update sets

Same scheme as Build Agent (per-checkpoint `<application> build agent install N`, `manual edit N`), plus one update set per completed work item and the batch one per plan. Found on Studio's **Deployment** tab. Deployment is by update set, optionally packaged through the application repository.

## Test Agent

Installed with Build Agent. Running tests needs the Store application **ATF Test Generator and Cloud Runner** and a configured cloud user. Generated tests are ordinary ATF tests in the application's scope (the docs name the table both `sys_atf_tests` and `sys_atf_test`; the second is the usual name, check), reusable in scheduled regression runs.

### Use

In the IDE or Studio chat (**+** for a new chat), prompt to:

- write a test or suite ("Write an ATF test in the global scope to validate that all mandatory fields on the Incident form are completed before submission");
- run one by name or sys_id: it builds and installs the latest code, then runs in the background;
- triage a failure by test name or result sys_id: it finds the failing step and root cause, offers fixes, applies the chosen one, re-runs, and summarises.

On the ATF test and suite lists, **Create with Otto** jumps to the IDE (needs Build Agent).

### Automatic generation after a build

Chat **Settings > General**, both off by default:

| Setting | Effect |
|---|---|
| **Sync ATF tests with app** | after each build and install Build Agent asks "Generate automated tests for this application?" (Yes / No / Remind me later); on Yes it generates, validates and runs the server-side tests, and keeps them in step with later edits |
| **Run UI ATF tests** | also runs client-side UI tests (slower); needs the first setting |

### UI Test Script

An ATF step type holding test code for custom UI, written with a subset of Testing Library syntax. Describe the test in chat ("fill the profile form with name and email, then select Submit"), review selectors and assertions, refine by feedback, then package it as a single step or beside other steps. Runs in the client test runner; the step passes or fails as a whole, with per-line pass/fail marks inside the code. Troubleshooting is manual: logs and screenshots, then ask for changes. Also creatable from the standard ATF forms.

### Coverage

Supported metadata includes UI actions, UI policies and their actions, client scripts, UI scripts, data policies, forms, sections, views, lists, list controls, related lists, UI pages, macros, formatters, messages, styles, themes, context menus, roles, application menus and modules, portal widgets, instances and themes, ACLs and ACL roles, business rules, script includes, email notifications, reports, catalog UI policies and actions, templates, several mobile (`sys_sg_*`) and workspace (`sys_aw_*`) records, data filtration, and ATF tests, steps and step configurations themselves.

**Not supported:** flows, configurable workspace steps, custom UI test steps, custom test steps.

Scopes global, custom and Store; unit, functional and UI tests and suites; execution on Cloud Runner.

## Related

- [[Build Agent]] · [[Build Agent Usage, Checkpoints and Reference]] · [[Application Development Tools and Lifecycle]]
