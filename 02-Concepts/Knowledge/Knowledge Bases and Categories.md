---
type: concept
tags: [concept, knowledge, admin, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Configuring > Knowledge Management setup guide for admins, Knowledge base setup guide for knowledge admins and managers, Create a knowledge base, Configuration tasks for knowledge managers (Add a knowledge article to featured content, Define a knowledge article category, Assign a knowledge base manager), Configure knowledge subscriptions, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/create-a-knowledgebase.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Bases and Categories

**In one line:** a **knowledge base** (`kb_knowledge_base`) groups articles with its own owner, managers, publish/retire flows, access criteria, templates, languages and a category tree (`kb_category`); split knowledge into several bases so each team manages its own.

From the Brazil docs; not tested. Access lists: [[Knowledge Base Access and User Criteria]]. Big picture: [[Knowledge Management Overview]].

## Planning (setup guides)

- Admin: agree with stakeholders (knowledge manager, knowledge admin, coach, domain expert, version author, creators and reviewers, community managers, line managers) on consumers, writers, publish/retire processes, special behaviour (e.g. attachments in search), translation; then assign roles, adjust flows and properties, activate languages. **Knowledge > Administration > Guided Setup** walks through it.
- Per base (`knowledge_admin`, `knowledge_manager` or `admin`; the setup page writes `knowledge_administrator`, unconfirmed variant): scoped or not, managers who approve, readers and contributors, categories and whether users may add them, whether users may create content.

## Knowledge base form (**Knowledge > Administration > Knowledge Bases > New**, `knowledge_admin` or `admin`)

| Field | Notes |
|---|---|
| Title, Description, Icon (about 54×54 px) | |
| **Article Validity** | days; article **Valid to** = created + validity; blank = 2100-01-01 |
| Disable commenting / suggesting / category editing / rating / mark as helpful | category editing off = only managers edit categories |
| **Enable blocks** | knowledge blocks ([[Knowledge Article Templates and Knowledge Blocks]]) |
| Checklist | Article Quality Index checklist |
| Application | scope, from the application picker |
| **Owner**, **Managers** | owner and managers get `knowledge_manager` automatically; removed from a user only when they manage no other base (not removed when the base goes inactive) |
| **Publish flow** / **Retire flow** | Instant Publish, Approval Publish, Instant Retire, Approval Retire. Older form: Publish workflow / Retire workflow (legacy Workflow, see [[Knowledge Workflows and Article Lifecycle]]) |
| Active | inactive = only `admin` and knowledge admins can create, search or view |
| Set default knowledge field values, Related products | |
| Auto-create translation tasks, Languages | only with translation management on; a language can be removed only if no article uses it |

Related lists: Knowledge (articles), **Can Read**, **Can Contribute** (and the Cannot lists), **Article Templates** (non-empty = only those templates allowed), **Featured Content**, **Knowledge Categories**.

## Categories

Each base has its own tree in **Knowledge Category** (`kb_category`); the path is stored in **Full category**. Base form > Knowledge Categories > New: Label, Value (used in scripts), Parent ID (top level), Active. Expand a category and New for children. Contributors may also add categories while editing an article. Inactive category: no new articles, existing ones untouched. Roles: `knowledge_admin`, `knowledge_manager` or contribute access.

## Featured content (pinning)

`knowledge_manager`, `knowledge_admin` or `admin`. Base > **Featured Content** > New: pick the article and one or more **Knowledge keywords** (single words). The **Featured content** section on the portal homepage shows articles carrying the keyword in `glide.knowman.default_keyword`; searching another keyword puts its articles at the top of results (not with AI Search). Not shown in global search or Virtual Agent.

## Subscriptions

Needs Knowledge Management Advanced (`com.snc.knowledge_advanced`, brings `com.snc.activity_subscriptions`). **Knowledge > Administration > Properties**, *KM Subscription Properties*: `glide.knowman.enable_km_subscription` (on/off), `glide.knowman.enable_km_subscription.roles` (roles allowed), `glide.knowman.enable_km_subscription.workflow_state` (article states, default includes Draft, Review?, Published; list cut off on the page). Owners are auto-subscribed to their bases, authors to their articles. Users choose notification preferences in System Settings.

## Example

Knowledge base **Example IT Knowledge**: owner *Test Manager*, managers *Example Group* lead, Approval Publish and Instant Retire flows, Article Validity 365, Can Read = *Example Employees* criteria, Can Contribute = *Example Service Desk* criteria, categories *Hardware > Laptops* and *Software*.

## Related

- [[Knowledge Base Access and User Criteria]] · [[Knowledge Portal and Search]] · [[Knowledge Workflows and Article Lifecycle]]
