---
type: concept
tags: [concept, assets, cmdb, flows]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Asset Management common applications > Contract Management" (pp. 396-443), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Contract Management

**In one line:** a contract (`ast_contract`) records an agreement with a vendor, the assets, users and CIs it covers, its terms, its money (rate cards and expense lines) and an approval and renewal life cycle driven by a nightly job.

Active by default (`com.snc.contract_management`). Menu **Contract**. Role `contract_manager` (contains `financial_mgmt_user`); also `contract_system_admin`, and workspace roles for Hardware, Enterprise and Software Asset workspaces.

## Contract form

| Area | Fields |
|---|---|
| Header | **Contract model** (Lease, Maintenance, Warranty, Service Contract, Software License, Subscription, Purchase Agreement, NDA, Insurance...), **Vendor**, **Contract number** (the vendor's), **Parent contract**, **Start date**, **End date** (empty = open-ended), **State**, **Substate**, **Contract administrator**, **Approver** (users with `contract_manager`), **Business owner**, **Agreement type** (Enterprise, SaaS, Subscription; software and maintenance), **Commitment** and **Discount** (purchase agreements; 0 to 99), **Process non-contractual SLAs** (service contracts) |
| Financial | **Invoice payment terms**, **Payment schedule**, **Payment amount**, **Applicable taxes**, **Effective tax rate**, **Tax cost**, **Total cost** (sum of rate cards if any), **Vendor account**, **PO Number**, **Cost center**, **Has rate card** |
| Renewal | **Automatically renew**, **Options** (duration), **Renewal start / end date**, **Cost adjustment type** (Fixed, Manual, CPI), **Cost adjustment amount** or **percentage** (not both; negative = decrease) |
| Related lists | Assets Covered (`clm_m2m_contract_asset`, with **Date added / removed**), Users Covered (`clm_m2m_contract_user`), CIs Covered, Terms and Conditions, Contract Rate Cards, Expense Lines, Contract History, Approval History |

A contract with rate cards cannot have its form fields edited.

## Life cycle

| State | Substate | How |
|---|---|---|
| Draft | Awaiting Review | created; editable |
| Draft | Under Review | **Submit for Review** with an **Approver** (the approver cannot be changed while under review) |
| Draft | Approved / Rejected | approver decides in **Contract > My Approvals** (rejection needs a comment) |
| Active | (empty) | start date reached and approved (immediately, if the start date is past) |
| Expired | empty, or Awaiting Review / Renewal Approved while a renewal is pending | end date reached |
| Canceled | | **Cancel Contract** on an Active contract: condition checkers and rate cards become inactive |

Other substates: Renewal Rejected, Renewal in process, Renewed, Extension Approved, Extension Rejected. State and Substate are read-only on the form.

Actions on an Active contract: **Adjust** (start, end, payment amount; asset end dates follow), **Renew** (same record updated; needs substate None or Rejected), **Extend**, **Cancel Contract**.

### The nightly job

**Contract Compliance Checks** (script include `ConditionChecks`) runs the **condition check definitions** (**Contract > Administration > Condition Check Definitions**; tables `clm_condition_checker`, `clm_condition_check`): each definition names a **Table**, a **Condition field** to set (typically State or **Expiration level**), an **Event name**, and ordered **Conditions** (the first true one sets the value). It activates approved contracts on their start date, applies approved renewals, expires contracts past their end date, and sets expiration levels. Property `contract_compliance_check_job.enable_override` (true): a check on a child table (for example Lease) overrides the same check on the parent.

Expiry reminders: event `contract.expiration` emails the **Contract administrator** 90, 60 and 30 days before, and on the day.

## Terms and conditions

Records in `clm_terms_and_conditions` (**Contract > Contracts > Terms & Conditions**), added to a contract with an **Order** only while it is Draft / Awaiting Review (or a rejected substate); **Build Terms and Conditions** assembles them into the contract's text. Read-only once sent for approval.

## Money

- **Contract rate card** (`fm_contract_rate_card`, needs Cost Management): **Start date** / **End date** inside the contract's dates, **Interval** (Monthly, Quarterly, Annually), **Base cost**, tax, **Distribute cost**:

| Distribute cost | Expense lines |
|---|---|
| Allocate and distribute cost per asset | base cost split evenly per covered asset |
| Allocate and distribute cost based on value | split in proportion to each asset's **Cost** or **Residual Cost** |
| Allocate and distribute cost per user | split evenly per covered user |
| Allocate cost to contract | one line on the contract |

Only assets and users already on the contract can be put on its rate card. Job **Process FM Costs** generates the expense lines daily from **Next process**; only for Active or Expired contracts. See [[Expense Lines and Allocations]].
- Business rules keep **Tax cost**, **Total cost**, lifetime cost and cost per asset in step.

## Contract renewal workflow (newer, task-based)

Needs SAM Professional, Hardware Asset Management or Enterprise Asset Management, and property `sn_contract_enable_renewal_flow` (true on new instances). For Software License, Subscription, Maintenance and Warranty contracts. **Renew** creates a **Contract Renewal Request** with a **request line** per contract (parent and chosen children) and tasks:

1. Contract selection (only when there are child contracts: **Renewal Decision** Yes/No each)
2. Build renewal (creates **draft** contracts; child dates must fall inside the parent's)
3. Asset selection (valid assets are carried over; set **Renewal cost**)
4. Software assets selection (entitlements; perpetual types carry over)
5. Terms and conditions
6. Rate cards (not carried over; optional)
7. Renewal confirmation
8. Renewal approval (draft → Approved, or Renewal rejected)
9. Renewal purchase order (needs Procurement; **Order** then **Receive** publishes draft entitlements)

When the new contract becomes active the old one is Expired with substate **Renewed** and a contract history record links them. Cancelling a request, line or task cancels the drafts and clears the old contract's substate; closed tasks cannot be edited.

## Reports

Active Contracts by Cost Per Unit / Lifetime Cost / Monthly Cost / Yearly Cost / Vendor, All Contracts by State, Contract Expenditure by Type / Vendor, Contract Pipeline Report, Expiring Contracts (90 days). **Contract > Overview**.

## Notes

- **Contract History** (`clm_contract_history`) stores a copy whenever dates or terms change.
- Subscription contracts are readable by every authenticated user (for the *My Assets* report).
- Domain separation: data only; the job, renewals and approvals do not respect domains (the renewal workflow does).
- With Now Assist in Contract Management (`sn_cm_gen_ai`), **Initiate contract extraction** reads obligations and metadata from the document.

## Related

- [[Asset Management Common Applications]] · [[SLA Definitions and Task SLAs]] (service contracts)
