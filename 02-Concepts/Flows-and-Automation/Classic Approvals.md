---
type: concept
tags: [concept, automation, workflow, service-catalog, change, security, email]
status: documented
source: ServiceNow docs, Australia, Build workflows > Classic approvals (read 2026-10-08 through the docs site; whole chapter): Classic approvals, Approval engines, Set up an approval engine, Approval rules, Set automatic approval rules, Gating approvals (via an approval rule, based on the item being ordered), Process approvals, Approve with a process guide, Schematic of a hypothetical approval process, Approval summarizer formatter, Summarizers (change, create), Approval with e-signature (activate, de-activate, select an approval table, local database, SSO with SAML 2.0, installed components), Approval status, Generate an approval using approval rules / the approvers related list / Workflow flows, Multiple approvers, Receive notifications, Embed an approval request within the Outlook email client, Dynamic approval forms, Scripts and engines execution order. https://www.servicenow.com/docs/r/australia/build-workflows/approvals/r_Approvals.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Classic Approvals

**In one line:** an approval is a record in Approval (`sysapproval_approver`) linking one approver to the record being approved; the *classic* ways to create those records (approval rules, item approvers, execution plan approval tasks, process guides) are legacy, replaced by the **Ask for Approval** flow action ([[Flow Core Actions Reference]]).

The docs spell the table once as `sysapprover_approver` and once as `sys_approval_approver`; the name used everywhere else, and by the flow action page, is `sysapproval_approver`.

## The approval record

| Field | Meaning |
|---|---|
| **Approver** | the user who must decide |
| **State** | Not Yet Requested (no notification yet), Requested, Approved, Rejected. The flow action adds Cancelled, No Longer Required, Skipped |
| **Approving** | document ID of the record under approval, on any table |
| **Comments** | journal |
| **Approval Summarizer** | formatter showing the key fields of the approved record |
| **Flow** | set when a flow created the approval; not to be used in business logic |

Everyone's approvals: **Self-Service > My Approvals** with the filter removed (admin).

## How the task's approval value is derived

On the approved task (for example a change request), **Approval** (`approval`) follows its approvers:

- any approver rejected: **Rejected**, immediately;
- all approved: **Approved**;
- none, or all Not Yet Requested: **Not Requested**;
- otherwise **Requested**.

So with several classic approvers **everyone** must approve. "Any one of" and similar rules need a flow (or the legacy workflow).

## Approval engines

Each task table uses one engine: **System Properties > Approval Engines** (stored as properties `glide.approval_engine.<table_name>`).

| Option | Meaning |
|---|---|
| **Approval Rules** | rules evaluated for the table; matching rules create approvers |
| **Process Guides** | sequenced approval steps. Deprecated |
| **Turn off Engines** | neither. Set, and read-only, when a workflow manages the table's approvals |

When a flow or workflow handles approvals for a table, the engines should be off for that table: two mechanisms create conflicting approvals, and leaving engines on costs performance.

## Approval rules

**System Policy > Rules > Approvals** (admin).

| Field | Meaning |
|---|---|
| **Name**, **Table**, **Active** | for catalog approvals the table is usually Request (`sc_request`) |
| **Run Rule Before** | run before the record is saved. Needed for **Set State** to work |
| **User**, **Group** | approvers (either may be empty) |
| **Set State** | approval value put on the task when the rule applies: *Requested* starts the process and its notifications; *Approved* auto-approves |
| **Condition** | when the rule applies |
| **Script** | returns the approver, for example `current.requested_for.manager` (server-side, on the task record) |

- Every matching rule adds its approvers; the same person is never added twice.
- Without Set State the task stays *Not Yet Requested* and nobody is notified until something sets Requested.
- An approver added by a rule starts as Requested; one added by hand through the **Approvers** related list (**Edit**) starts as Not Yet Requested.

## Catalog approvals (legacy model)

| Kind | When | Created by |
|---|---|---|
| **Gating approval** | before anything starts: no notifications, no tasks until all are met | approval rules on the request; or per catalog item, related lists **Approved By Group** and **Approved By** |
| **Process approval** | inside fulfilment | an approval task in an execution plan (**Service Catalog > Execution Plans > New Approval**: name, order, SLA, delivery time, then the same two related lists) |

- Item-based approvers add to approval rules; duplicates are merged.
- Rejecting a process approval cancels that line item only, not the whole request.
- A **process guide** (**System Policy > Process Guides**, table Catalog task, with a condition) allows "any of / all of" and sequenced approvals on an execution task. Catalog tasks all exist from submission in state pending, so add `state=open` to the condition to wait for the task to start. A *Default* guide (sequence 10,000) reproduces the old behaviour. Deprecated along with the engine.

Current model: [[Request Management Data Model and Process]].

## Notifications

- Approvers are mailed when their approval becomes Requested (every member for a group). The mail carries mailto links to approve or reject; replying with `state:approved` or `state:rejected` in the body does the same. An inbound email action can accept a plain yes / no ([[Inbound Email Actions]]).
- The task's assignee is mailed when it is approved.
- **Outlook actionable messages**: plugin *Outlook Actionable Messages* (`com.sn_ms_oam`); add `${mail_script:include_approval_actionable}` to the notification message or its template (for example templates `request.itil.approve.role`, `change.itil.approve.role`). Only for mail sent from the instance's default address unless a provider ID is registered with Microsoft and put in `sn_ms_oam.outlookactionable.originator`; depends on SPF / DKIM validation; templates cannot be customised.

## Approval form summarizer

The summary at the bottom of an approval form is a formatter backed by a UI macro named `approval_summarizer_<table_name>` (**System UI > UI Macros**; Jelly), for example `approval_summarizer_change_request`, `approval_summarizer_sc_request`. To support a new table, create a macro with that name and add the formatter to the form (global scope only). Copy a macro's script before editing it.

On a multi-item request the summarizer shows **Reject** / **Accept** per requested item so an approver can drop items before approving the request. They must not be used after the request is approved: rejecting then cancels the item's workflow and leaves its stage inconsistent.

## Approval with e-signature

Plugin *Approval with e-Signature* (`com.glide.e_signature_approvals`; needs *Code Signing Signatures* `com.glide.code_signing.signatures`). Approving or rejecting requires re-entering credentials in an **Approver Authentication** dialog; a failed check leaves the approval unchanged. Validated for 21 CFR Part 11: the signer's name, the time and the meaning (approval or rejection) are kept in the approval's activity stream and audit history.

- Tables: **System Definition > E-Signature Registry** (table + **Enabled**). By default Change Request (`change_request`) and Standard Change Proposal (`std_change_proposal`); the plugin cannot be removed, so disable per table.
- Applies to list context menu, form UI actions and setting the state by hand.
- Credentials: local user records, or SAML 2.0 through Multi-Provider SSO. The IdP **must honour ForceAuthn**; on the identity provider record check **Force AuthnRequest** and fill the *eSignature Approval* tab (assertion consumer URL and index, AuthnRequest URL, dialog width 500 and height 300), then **Generate Metadata** and update the IdP (roles `sso_config_admin`, `business_rule_admin`, `script_include_admin`).
- Installs UI pages for the dialogs, client script *Authenticate Approver*, script includes *User* and *UserAuthentication*, and replaces the two shipped Approve UI actions on `sysapproval_approver`.

## Where the approval engine sits

Engines, including the approval engine, run between the *before* business rules of order below 1000 and those of 1000 and above; flows are triggered after the database write. Full sequence: [[Order of Execution for Rules, Engines and Notifications]].

## Related

- [[Flow Core Actions Reference]] · [[Intelligent Approvals]] · [[Change Approval Policies]] · [[Flow System Properties Reference]] · [[Business Rules]]
