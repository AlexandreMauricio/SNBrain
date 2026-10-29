---
type: concept
tags: [concept, service-catalog, request, users]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Delegated request experience", "Configure the default behavior to request items for other users", "Requested for" (variable), "Create a catalog request from another flow", "Configure a parent mapping for a request", "Service Catalog parameters", "Fulfillers can request catalog items for others", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/delegated-request-exp.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Delegated requests and requests from other records

**In one line:** the **Requested For** variable lets a user order for someone else (or for up to 50 people at once in Service Portal); separately, a fulfiller can start a request from an incident or other record and keep it linked to it.

## Requested For variable and field

- Add a **Requested For** variable (type *Requested for*, users from `sys_user` only) to the item or a variable set; one per item; not in an MRVS. Default = the logged-in user.
- On submit its value is copied to **Requested for** on the RITM (`sc_req_item`). Add that field to the RITM form if missing. Later edits of the variable and the field do **not** sync. Form views, lists and notifications are not updated to show the RITM field by default.
- Request (`sc_request`) **Requested for**: the common user when all items share one, otherwise the logged-in user or the cart's default.
- My Requests shows the RITM to its Requested For user when that differs from the REQ's; otherwise it shows REQs.
- Record producers: the value goes to the target field set in **Map to field**.
- Not supported with **two-step checkout**.

### Who may order for others

- `glide.sc.req_for.roles`: roles allowed to change Requested For (blank = see next property). Without the right, users order only in their own name.
- `glide.sc.req_for.roles.default`: `allow` (default when missing, empty or any value other than `deny`) or `deny`. New (zBoot) instances ship it as `deny`; upgraded ones may add it. Admins can always order for others.

### Access Type on the item

**Restricted** (default): only for users who themselves have access to the item. **Delegated**: allowed for users without access. Only matters when the item has a Requested For variable. In order guides a restricted item the target user cannot see is dropped; a delegated one stays.

### Several people at once

On the Requested For variable: **Enable also request for** and optional **Roles to use also request for** (blank = anyone with item access). Service Portal shows **Also request for** (up to 50 users): one cart item per user, one REQ, one RITM per user. Not in Now Mobile, workspaces, record producers or order guides; not in cart or wish list views; not scriptable with `g_form`; hidden when the variable is read-only.

### Defaults through parameters

Core UI: `sysparm_requested_for=<user sys_id>` in the URL. Service Portal catalog item widget options: `"requested_for_id"` and `"requested_for_display"` (value set after the form loads).

## Requests from another record

- From an incident (or another table) use **Create Request** in the form's additional actions; the catalog opens, and items, order guides or record producers can be ordered. Role itil. Requests appear in the parent's **Requests** tab; producer records in a related tab. The caller becomes Requested For (two-step lets the fulfiller change it); with delegated requests the caller fills the Requested For variable. No wish list and no saving of record producers in this flow.
- Needs a **Request Parent Mapping** (**Catalog Administration > Request Parent Mapping**): **Parent table**, **Request Parent** (field on the request), **Parent requestor** (user field on the parent). *Incident request* exists by default.
- Needs `glide.sc.use_cart_layouts` = true, otherwise the request is not linked.
- URL parameters: `sysparm_parent_sys_id`, `sysparm_parent_table`, `sysparm_view` (Core UI catalog view), `sysparm_processing_hint=setfield:request.parent=<sys_id>` (overrides the mapping). Record producers read the parent with `RP.getParameterValue('sysparm_parent_sys_id')` and `('sysparm_parent_table')` in their script.
- In a domain-separated instance only items from the parent record's domain or global can be ordered, and records are created in the parent's domain.
- Otto chat lets fulfillers do the same conversationally from an incident or case: requester prefilled from the parent, questions rephrased, request linked back.

## Discrepancy

[[Create an Incident Record Producer]] uses `RP.getParameterValue('sysparm_req_parent')` with `LinkRecordProducerToIncident` (Australia ITSM guide). This chapter names `sysparm_parent_sys_id` / `sysparm_parent_table`. Both kept; which one a given release sends is unconfirmed.

## Related

- [[Request Management Data Model and Process]] (Create Request from workspaces) · [[Cart, Checkout and Cart Layouts]] (cloning) · [[Order Guides]] · [[User Criteria and Catalog Access]]
