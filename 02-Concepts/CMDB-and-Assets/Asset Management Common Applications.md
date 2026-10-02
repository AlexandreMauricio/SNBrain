---
type: concept
tags: [concept, assets, cmdb]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Asset Management common applications" (pp. 292-510), read 2026-10-02 at summary depth. Only the overview, Contract Management components and life cycle, Procurement roles and flows, and Product Catalog were read in detail; the two ITSM Software Asset Management plugin sections (pp. 293-395) and the purchase order / receiving procedures (pp. 451-484) were skimmed
sn-release: Australia
verified:
updated: 2026-10-02
---

# Asset Management common applications

**In one line:** asset management tracks the financial and contractual life of property, CMDB tracks what is running; the ITSM guide covers the supporting applications that asset management relies on.

| Application | Role |
|---|---|
| Base Asset Management | asset repository and life cycle (Core UI in limited support since Washington DC; workspaces are the future) |
| ITSM Software Asset Management | basic entitlements and counters, through the legacy SAM plugin or SAM Foundation; not the separately licensed SAM Professional |
| Contract Management | contracts, renewals, terms, covered assets and users |
| Procurement | purchase orders, sourcing of catalog requests, receiving |
| Product Catalog | models and catalog items: [[Models, Model Categories and the Product Catalog]] |
| Expense Line | costs: [[Expense Lines and Allocations]] |

## Contract Management

Active by default. Menu **Contract**. Role `contract_manager` (contains `financial_mgmt_user`).

| Table | Content |
|---|---|
| `ast_contract` | Contract (children include `ast_service` service contract, leases, licences) |
| `clm_m2m_contract_asset` | Assets Covered |
| `clm_m2m_contract_user` | Users Covered |
| `clm_terms_and_conditions`, `clm_m2m_contract_and_terms` | terms and conditions |
| `clm_contract_history` | copy kept when dates or terms change |
| `clm_condition_checker`, `clm_condition_check` | condition check definitions |
| `fm_contract_rate_card` | rate card for expense lines |

**State**: Draft, Active, Expired, Canceled. **Substate**: Awaiting Review, Under Review, Approved, Rejected, Renewal Approved / Rejected / in process, Renewed, Extension Approved / Rejected, None. Both are read-only; after Draft the date, renewal and financial fields lock.

Nightly job **Contract Compliance Checks**: approved contracts become Active on their start date, approved renewals are applied, Active contracts past their end date become Expired, and condition checks run (property `contract_compliance_check_job.enable_override` lets a child-table check override the parent's).

**Renew** (new term, optional cost adjustment by amount or percentage) and **Extend** (new end date) are offered on Active or Expired contracts with substate None or Rejected and go through approval. Expense lines are generated only for Active or Expired contracts.

Domain separation: data only; the jobs and flows do not respect domains.

## Procurement

Plugin `com.snc.procurement`. Roles `procurement_user` (contains `financial_mgmt_user`, `model_manager`), `procurement_admin`.

| Table | Content |
|---|---|
| `proc_po`, `proc_po_item` | purchase order and lines; status Requested, Ordered, Received, Canceled (lines also Pending Delivery) |
| `proc_rec_slip`, `proc_rec_slip_item` | receiving slips |
| `alm_transfer_order`, `alm_transfer_order_line` | transfer between stockrooms |

Flows: *Service Catalog Request* (items over 1,000 need approval), *Source Request* and *Procurement Process Flow - Hardware* (a catalog task asks the procurement manager to **source** the requested item, from stock by transfer order or from a vendor by purchase order). Receiving a line into a stockroom creates the assets.

## ITSM Software Asset Management (skimmed)

Tables seen: `alm_license` (software entitlement), `alm_entitlement`, `alm_entitlement_user`, `alm_entitlement_asset` (allocations), `ast_license_software_instance`. Software counters compare installations against rights owned.

## Related

- [[Service Portfolio Management]] · [[Companies and Normalization Data Services]]
