---
type: concept
tags: [concept, knowledge, flows, workflow]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Reference > Knowledge Flow, Knowledge workflows, Knowledge article states, Knowledge article version numbers, Knowledge article version information, Validity of a knowledge article, Article versioning changes, Feedback on article versions; Creating and maintaining articles > Schedule a knowledge article for publishing, Recall an article, Approve an article, Retire a knowledge article, Republish a retired article; Exploring > Migration from workflow to flow, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/r_KnowledgeFlow.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Workflows and Article Lifecycle

**In one line:** each knowledge base names a **publish** and a **retire** process (Flow from Zurich, legacy Workflow before); they move articles through the **Workflow** states (`workflow_state` on `kb_knowledge`): Draft → Review → (Scheduled for publish) → Published → Pending retirement → Retired, with **Outdated** for superseded versions.

From the Brazil docs; not tested. Creating and editing: [[Create and Edit Knowledge Articles]]. Versions: [[Knowledge Article Versioning]].

## Default processes

| Flow / workflow | Behaviour |
|---|---|
| **Knowledge - Instant Publish** | publishes at once, or on the Scheduled publish date |
| **Knowledge - Approval Publish** | approval by base managers (or the ownership group when that feature is on); article sits in Review; reject → back to Draft; approve → Published (or Scheduled for publish) |
| **Knowledge - Instant Retire** | retires at once |
| **Knowledge - Approval Retire** | approval by managers / ownership group; article in Pending retirement; reject → stays Published |
| **Knowledge - Publish Knowledge**, **Knowledge - Retire Knowledge** | building blocks (actions in Flow, subflows in Workflow) for custom processes |

- Custom processes per base are allowed; change who approves by editing `getApprovers()` in the script include `KBWorkflow...` (name cut off on the page; server-side, global).
- **Zurich onward**: new customers must fill **Publish flow** and **Retire flow**; upgraded instances see both workflow and flow fields but cannot mix them for publish and retire. Approval records of knowledge flows cannot be deleted, only approved or rejected. See [[Flows, Subflows and Actions Overview and Architecture]] and [[Classic Workflow Overview]].
- Approval emails: `glide.knowman.enable_approval_notification` (on by default since New York; disable custom approval notifications before turning it on in older instances). Only active users get them. Notifications list: [[Knowledge Notifications and Subscriptions]].

## States

| State | Meaning |
|---|---|
| Draft | being written; versioned drafts editable only by the author/reviser with contribute access, base owner, `admin`, `knowledge_admin`, ownership group members |
| Review | waiting for approval; only listed approvers can change it (others **Recall** it) |
| Scheduled for publish | approved, waiting for the scheduled date |
| Published | live; earlier published versions become Outdated; with an ownership group only the base owner and group members can contribute |
| Pending retirement | retirement awaiting approval |
| Retired | hidden from search for external users and customers; base owners and managers can open but not search them (the retire page also says only admins and knowledge admins can view them; unconfirmed) |
| Outdated | a newer version was published, or the article passed its Valid to date; readers can still open it |

KCS adds a separate **Confidence** value per state ([[Knowledge Feedback, Ownership Groups and Article Quality]]).

## Actions

- **Schedule**: Scheduled publish date (needs KM Advanced and versioning; add the field to the form), then **Publish**. Instant flow → Scheduled for publish; approval flow → Review, then Scheduled for publish if approved before the date, or published immediately if approved after it. **Recall** cancels.
- **Recall** (Review or Scheduled → Draft, +0.01): author, knowledge admins, admins, and with ownership groups also the group manager and members; only the reviser of that version when it is a revision.
- **Approve**: base owner / manager (or ownership group), from the **Approvals** related list on the article (Requested → Approve) or in Agent Workspace (Approval form, State Approved). Version becomes the next whole number.
- **Retire**: knowledge admin, manager, latest publisher (not `kcs_candidate` or `kcs_contributor`); not while checked out; the number is never reused. Retiring a parent does **not** retire its translations. Optional **replacement article** (HTTP 301; without replacement 404; not in classic workspace). Admins can also **Delete** published articles.
- **Republish** (KM Advanced, `admin` or `knowledge_admin`; scoped bases need the scoped admin role): **Knowledge > Articles > Retired** > **Republish** → back to the last published version with no approval.

## Version numbers

Minor change +0.01, publish → next whole number. Example from the docs: create 0.01, update, submit 0.02, recall 0.03, resubmit 0.04, reject 0.05, resubmit 0.06, approve (Scheduled) 0.07, publish **1.0**; checkout 1.01 … publish **2.0** (1.0 becomes Outdated). Every state change increments except to and from Pending retirement, Retired and Outdated. The **Display number** shows e.g. `KB0010004 v1.02`; fields **Base Version** and **Revised By** are added. Portal URLs by number may need the version (`sys_id=KB0000005%20V1.0` in the docs' example).

Carried across versions: average rating, helpfulness percentage, view count and use count (each version adds to later ones, not earlier ones), comments (unless Live Feed, which shows current only). Checkout or Make this current resets **flagged** to false.

Version history on the article page: readers see the latest published and previous major versions; contributors also see draft and review versions; older versions show a "newer version available" banner.

## Validity

**Valid to** = created + base **Article Validity** days (blank → 2100-01-01). On new versions or moves: blank validity keeps the old date, else updated date + validity; a changed dictionary default wins. With versioning, changing Valid to needs checkout unless `valid_to` is a minor edit field. Expired articles leave search (or become Outdated per the states page). Monthly expiry email when enabled.

## Related

- [[Knowledge Bases and Categories]] · [[Knowledge Article Versioning]] · [[Classic Approvals]]
