---
type: concept
tags: [concept, automation, ai, roles, release-specific]
status: documented
source: ServiceNow docs, Australia, Build workflows > Intelligent approvals (read 2026-10-08 through the docs site; whole chapter): Intelligent approvals, Explore intelligent approvals, Configure intelligent approvals, Build intelligent approvals, Create an intelligent approval, Publish an intelligent approval, Update source document, Deactivate intelligent approval, Create an allowlist configuration, Intelligent approvals reference, Intelligent approval system properties. https://www.servicenow.com/docs/r/australia/build-workflows/intelligent-approvals.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Intelligent Approvals

**In one line:** upload an approval policy as a PDF; generative AI derives when it applies and how to judge a request, then at run time approves or rejects the clear cases itself and leaves the rest to the existing human approval.

Human approvals and the approval record: [[Classic Approvals]]. Flow-based approvals: [[Flow Core Actions Reference]].

## Run-time behaviour

An intelligent approval must be **published** (active). For each request matching its trigger conditions it returns:

| Outcome | What the system does |
|---|---|
| Auto-approve / Auto-reject | creates an Approval (`sysapproval_approver`) record in state Approved or Rejected, with a comment explaining the decision; sets related approvals still waiting for a person to **No Longer Required** |
| Can't decide | nothing is decided: the existing approval process routes it to people, with work notes on the parent record and the approval saying AI tried |

- It does not replace the existing approval flow; it runs beside it. A flow with the same trigger still creates human approvals. **Potential overlapping approvals** (three-dot menu) lists conflicts with other intelligent approvals: either extend the existing one and leave the new one in draft, or deactivate the existing one.
- Every decision is an approval record, so it is auditable.
- Decisions rest only on the policy text; the docs ask for continued human oversight.

## Requirements

- An AI entitlement (the feature depends on the licence tier; availability varies by region and data centre).
- Plugin *Intelligent Approvals* (`com.glide.intelligent_approvals`), which turns on the **Approver Agent**.
- AI Platform Core components: NextWave framework, AIX framework (home page), Document Intelligence.

## Roles

| Role | Can | Contains |
|---|---|---|
| `sn_iap.policy_admin` | everything, including deleting; allowlist configurations | `sn_iap.policy_manager` |
| `sn_iap.policy_manager` | home page, create and manage intelligent approvals, execution details | `sn_iap.policy_reader`, `taas_api_write` |
| `sn_iap.policy_reader` | read-only | `taas_api_read` |
| `sn_iap.policy_runtime` | run-time policy evaluation skills | `sn_iap.policy_reader` |

**Allowlist**: by default a policy manager can target any table. With property `sn_iap.enable_allowlist` = true (add it; default false), **Intelligent Approvals > Allowlist Configurations** records (description, **Role**, **Table Name**, active, condition) demand an extra role, typically `sn_iap.policy_admin`, to create intelligent approvals on a given table.

## Building one

**All > Intelligent Approvals > Intelligent Approvals Home** (shows totals: decisions, auto approved, auto rejected, undecided; lists by state).

1. **Create new** > upload the policy (PDF, 10 MB at most) > **Create intelligent approval**.
2. Review scope and trigger: tab **Suggested options** (the AI's description of the record types and start conditions) or **Define my own** (describe record types, field values and start conditions in text). **Next**.
3. Read **Overview** and **Test results**: a high share of approved / rejected means the policy is clear; a high share of *Can't decide* means the document needs work.
4. **Suggested improvements**: a downloadable PDF of things to add, change or remove in the policy. Edit the policy outside the instance.
5. Three-dot menu > **Upload new source document** regenerates everything from the revised PDF. Repeat until the results are acceptable.
6. Check **Potential overlapping approvals**.
7. **Publish**. **Deactivate** (three-dot menu) stops it; past decisions stay.

Troubleshooting from the docs: generation fails without access to both the feature and the target records; an approval that never starts usually has wrong start conditions (use *Define my own*); too many *Can't decide* means improving the policy text.

## Related

- [[Classic Approvals]] · [[Flow Core Actions Reference]] · [[Change Approval Policies]]
