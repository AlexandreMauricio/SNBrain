---
type: concept
tags: [concept, request, service-catalog, task]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Request Management" (pp. 3112-3125), read 2026-10-02; Brazil Platform Capabilities guide > Self-service > Service catalog requests (https://www.servicenow.com/docs/r/servicenow-platform/self-service/p_ServiceCatalogRequests.html), read 2026-10-29. The ITSM guide covers only the request side; catalog items, variables and flows are covered by the Service Catalog notes made from the Brazil docs chapter (read 2026-10-16), linked under Related Re-checked against the Brazil ITSM docs (final chapters), read 2026-10-30.
sn-release: Australia (Brazil for the submitted-requests section)
verified:
updated: 2026-10-30
---

# Request Management data model and process

**In one line:** ordering a catalog item creates a Request (`sc_request`, REQ) holding one Requested Item (`sc_req_item`, RITM) per item ordered, each fulfilled through Catalog Tasks (`sc_task`, SCTASK).

## Tables

| Table | Label | Role |
|---|---|---|
| `sc_cat_item` | Catalog Item | what can be ordered; the only trigger of the request process |
| `sc_cart` / `sc_cart_item` | Cart / Cart Item | the basket; a temporary cart is used for **Order Now** |
| `sc_request` | Request | the order |
| `sc_req_item` | Requested Item | one line of the order; **variables belong here only** (not to tables extending it) |
| `sc_task` | Catalog Task | fulfilment work |
| `sc_item_option` | Options | variable values |
| `sc_item_option_mtom` | Variable Ownership | links values to the requested item |

All three task tables extend [[task]].

## What happens on checkout

1. A cart exists (temporary for a direct order; the default cart otherwise; a two-step order guide uses the temporary cart, a three-step one the default cart).
2. The item and the entered variable values become a `sc_cart_item` with rows in `sc_item_option` and `sc_item_option_mtom`.
3. A `sc_request` and a `sc_req_item` are initialised in memory, the RITM is pointed at the request, the variable rows are re-pointed at the RITM.
4. The **RITM is committed first, then the request**. With several items, steps 2 to 4 repeat per item.

## Rules from the guide

- Do **not** use a record producer to insert into `sc_request`, `sc_req_item`, `sc_task` or their extensions.
- Do **not** write *before* business rules on `sc_request`, `sc_cart`, `sc_cart_item`.
- The base workflow attached to the request is demo data.

## Requests from other records

- From an incident or interaction in a workspace: UI action **Create Request** opens the catalog with `sysparm_parent_table` and `sysparm_parent_sys_id`; **Requested for** defaults to the caller. A mapping must exist in **Catalog Administration > Request Parent Mapping**. For record producers, read the two parameters with `RP.getParameterValue()` in the producer script (server-side).
- Workspace client script pattern (UI action, runs client-side in the workspace): submit the form, then `g_service_catalog.openCatalogItem('sc_cat_item', '-1', params)`.

## Universal Request integration

Plugin `com.snc.universal_request`, property `sn_uni_req.com.snc.ur.request_integration` = true. The RITM becomes the **primary ticket** of a universal request; **Create Request** and **Transfer** (with or without resolution, to a department) are available. Linking requires `glide.sc.use_cart_layouts` = true and **Use Cart Layout** on the item. Default state mapping (RITM → UR): Open, Work in Progress, Pending → In Progress; Closed Complete / Skipped / Incomplete → Closed.

Brazil addition: the property `sn_uni_req.transfer_type`, on the Universal Request properties page, sets how request transfers are handled (the transfer with or without resolution above). Roles named on the page: `itil`, a routing agent, `sn_request_write`, `sn_hr_core_case_writer`. Values not recorded.

## Roles and domain

Granular roles `sn_request_read`, `sn_request_write`, `sn_request_comment_write`: see [[ITSM Granular Roles]]. Domain separation: Standard; `sc_request`, `sc_req_item`, `sc_task` are domain separated.

## Working with submitted requests (Brazil Self-service pages)

From the Brazil Platform Capabilities guide > Self-service > Service catalog requests (read 2026-10-29, documented, not tested).

- **Add New Item** on a request (**Service Catalog > Open Records > Requests**): only `admin` or `catalog_admin`, and only while the request is *Pending Approval*; changing a request does not send it through approval again.
- **Delete items**: Requested Items related list > Actions > Delete; price and delivery date are recalculated. Any user may remove items from their own request before delivery (the page lists `admin` as the role, unconfirmed which applies).
- **Status**: **Self-Service > Requested Items** > number > **Stage** field and **Backordered** field (comments explain restock).
- **Create Incident / Create Change** from a requested item (`itil`): the admin must set **Active** = true on those UI actions for `sc_req_item`; the new record keeps a relationship to the item ([[UI Actions]]).
- `glide.vm.checkout_redirect` (*One-step checkout redirect*, **Cloud Management > Administration > Properties**): false = Order Status form after Order Now, true = *My Virtual Assets* portal (virtual machine requests). The Amazon EC2 catalog items described next to it are deprecated (KB0867184).

## Related

- [[Incident Management Overview and Lifecycle]] (Create Request from an incident) · [[Create an Incident Record Producer]]
- Catalog side (Brazil docs): [[Service Catalog Overview, Item Types and Roles]] · [[Catalog Variables and Variable Types]] · [[Cart, Checkout and Cart Layouts]] · [[Catalog Fulfilment - Flows, Workflows and Execution Plans]] · [[Delegated Requests and Requests from Other Records]] (Requested For, Request Parent Mapping, `sysparm_parent_*` parameters) · [[Order Guides]]
