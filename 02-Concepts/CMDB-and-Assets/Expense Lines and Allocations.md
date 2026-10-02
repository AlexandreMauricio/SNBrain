---
type: concept
tags: [concept, assets, cmdb]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Expense Line" (pp. 2387-2395), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Expense lines and allocations

**In one line:** an expense line (`fm_expense_line`) is one point-in-time cost attached to any record through **Source ID**; allocation rules then split that cost to users, groups, departments or cost centres.

The Expense Line plugin is always active. Allocations and allocation rules need Cost Management.

## Where expense lines come from

| Source | How |
|---|---|
| New asset | business rule *Create Expense Line* on `alm_asset`, from the asset **Cost** (not for merged software licences); updated when **Cost** or **Quantity** change |
| CI rate cards | processed monthly, one line per CI |
| Distribution costs | processed monthly |
| Task rate cards | when tasks close |
| Manual | **Costs > Expense Lines > New** |
| Script / import | server-side `ExpenseLine` script include |

## Fields

**Date**, **Amount** (negative = credit), **Source ID** (document reference to any record; fills the specific source fields **Asset**, **Fixed asset**, **Contract**, **User**, **Configuration Item**, **Task**, **Cost center**), **Rate Card**, **State** (Pending, Processed), **Process date**, **Summary type** (Grow / Run / Transform Business), **Inherited** (child of another expense line).

## Allocation rules

**Costs > Administration > Expense Allocation Rules**: **Table**, **Allocation field** (dot-walk allowed, for example Caller > Department on Incident), **Percentage**, **Condition**, **Summary type**; or **Advanced** with a script (server-side) that queries targets and calls `allocation.createAllocation(targetGlideRecord, amount)` with `expense` (the line) and `rule` available. Job *Process Expense Allocation* generates the allocations.

Deleting an expense line deletes its allocations.

## Roles

`financial_mgmt_admin` (contains `financial_mgmt_user`). Domain separation: not supported.

## Related

- [[Asset Management Common Applications]]
