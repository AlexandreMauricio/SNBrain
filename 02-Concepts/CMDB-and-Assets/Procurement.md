---
type: concept
tags: [concept, assets, request, service-catalog, integrations]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Asset Management common applications > Procurement" (pp. 443-485), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Procurement

**In one line:** Procurement turns approved catalog requests into assets: a sourcing task decides, per requested item, whether to consume local stock, transfer from another stockroom or buy from a vendor with a purchase order, and receiving the order creates the assets.

Plugin `com.snc.procurement`. Menu **Procurement**. Roles `procurement_user` (contains `financial_mgmt_user`, `model_manager`), `procurement_admin`, `procurement_system_admin`; stock handling needs `inventory_user` / `inventory_admin`.

## From request to sourcing

- A catalog request (REQ) has one requested item (RITM) per item ordered; see [[Request Management Data Model and Process]].
- Flow *Service Catalog Request*: requests over 1,000 (base currency) need approval. Edit the flow to change the threshold.
- After approval (or at creation if none is needed) a **catalog task** *Source Request Items* is created for items **that have a model**; items without a model, and bundles, cannot be sourced.
- On the task, **Source Request** opens the sourcing page (it needs the task's **Parent** and **Request** fields; tasks created by a flow must set Parent). Per item:

| Choice | Result |
|---|---|
| **Consume** | reserve stock from the requester's local stockroom or one that serves the location (subflow *Asset Local Stock*); an asset task assigns the asset (state In stock, substate Reserved); consumables can **Consume and Close** |
| **Transfer** / **Add Transfer Order** | transfer order from a **Source stockroom** to a **Destination stockroom**; optionally through distribution channels (Hardware Asset Workspace). Property `glide.asset.procurement.sourcing.local_stock_transfer` adds the local stockroom to the choices |
| **Purchase** | purchase order: **Vendor**, **Quantity**, **Destination Stockroom**; **Consolidate PO** adds the line to an open Requested PO for the same request and vendor |
| **Add assignments** (software) | assign rights from a licence to a user or device |

When every item is sourced, **Sourced** is ticked on the request. Cancelling the request cancels unreceived purchase orders, procurement tasks and unshipped transfer lines (lines In Transit or Delivered stay).

## Purchase orders

| Table | Label |
|---|---|
| `proc_po` | Purchase Order |
| `proc_po_item` | Purchase order line items |
| `proc_rec_slip` | Receiving Slip |
| `proc_rec_slip_item` | Receiving Slip Line |

**Purchase order**: **Vendor**, **Ship to** (stockroom), **Bill to**, **Due by**, **Terms** (Credit, Net 30 days, Net 90 days), **Shipping** and **Ship rate**, **Total cost** (lines + shipping), **Initial request**, **Requested by**, **Expected delivery**, **Contract**, **Department**, **Budget number**.

**Line item**: **Product Model**, **Product Catalog**, **Part number**, **Request line** (the RITM), **Ordered / Received / Remaining quantity**, **List price**, **Cost** (from the vendor catalog item's vendor price), **Total cost**; for software **Metric group**, **License metric**, **Rights per license pack**, **Number of packs**.

| Status | When |
|---|---|
| Requested | created |
| Ordered | **Order** (no more lines can be added) |
| Pending Delivery | assets pre-created with **Create hardware assets prior to delivery** (reserved for the requester) |
| Received | **Receive**: only when every line is received |
| Canceled | **Cancel** from Requested, Ordered or Pending Delivery; pre-created assets are deleted. A canceled PO or line can be re-ordered with **Order** |

Status is read-only. Expected delivery dates on the PO and its lines stay consistent: a line cannot be later than its PO; a later line date pushes the PO date.

## Receiving

**Receive** on an Ordered or Pending Delivery PO: tick the lines, adjust **Receiving Stockroom**, **Receiving Quantity** (over- or under-receipt allowed) and **Unit Cost**; **Reserve** / **Reserved for**; **Capture asset tags** (asset tag, serial number, MAC address; at least one field required by the CI class identification rules). Each receipt creates a receiving slip; a PO with a slip becomes read-only.

- Hardware: one asset per unit, state In stock, substate Reserved or Available. **Reserved for** becomes **Assigned to** when the asset goes In use.
- Software: one asset per licence unless rights are split.
- **Consumables** are merged into an existing consumable record that matches on model, location, model category, stockroom, status, substatus, parent, function, assigned to and domain; quantities and cost are added (50 received + 20 in stock = one record of 70). They are not tracked individually and do not show on the PO.
- The hardware CI created is written back to the catalog task and requested item (business rule *Update Request Item CI*).

## External procurement integration (Coupa)

Store app *Asset Management - Procurement Integration* (with SAM Enterprise and the Coupa spoke): a published **Procurement Integration Profile** (`itam_procurement_integration_profile`; one active per domain) with a connection and credential alias (`sn_coupa_spoke.Coupa_OAuth`, OAuth with `<CLIENT_ID>` / `<CLIENT_SECRET>` and a long list of `core.*` scopes). **Order** on a software-only PO then creates a requisition in Coupa; job *ITAM - Sync Coupa purchase orders* (daily) pulls status and receipts, creates receiving slips and **entitlements**, or *entitlement import errors* on mismatch. Reference data must match on both sides: requester email, vendor/supplier, currency codes, catalog item names. One-way: requisitions created in Coupa are not imported. With Sourcing and Procurement Operations installed, **Purchase** hands over to its Shopping Hub instead.

## Notes

- Create assignment groups for the sourcing tasks before using the application.
- If Field Service Management is active, its flow processes transfer orders.
- Domain separation: Standard with exceptions; work in the right domain when creating POs.

## Related

- [[Asset Management Common Applications]] · [[Models, Model Categories and the Product Catalog]] · [[Contract Management]]
