---
type: concept
tags: [concept, service-catalog, portal, workspace]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Integrating Service Catalog, topics "Integrating Service Catalog", "Service Catalog in Employee Center portal" and its children, "Service Catalog in Service Portal" and its children, "Service Catalog in mobile", "Fulfiller experience in Mobile Agent", "Request experience in Now Mobile" and its children, "Configure Now Mobile properties", "Service Catalog configuration for Universal Request", "Standard ticket page for a requested item", "Define filters for My Requests", "Sample ATF tests for Service Catalog in Service Portal", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/integrating-service-catalog.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Service Catalog in Employee Center, Service Portal and mobile

**In one line:** requesters normally order through Employee Center (recommended) or Service Portal widgets and the Now Mobile app; approvers and fulfillers also act from the mobile agent app.

## Employee Center

- Plugins `sn_ex_sp` (Employee Center) and `sn_ect` (Employee Experience Taxonomy). Items appear only when associated with a **taxonomy topic**: on the item, related list **Assigned Topics** > **Add** (e.g. IT > Hardware > Computers), or from Content Taxonomy. Default IT topics: Hardware, Software, Network, Browse IT. Clone the taxonomy to change it.
- Search in Employee Center finds only items tied to a topic.
- Cart and wish list are off by default: **Service Portal > Portals** > Employee Center > **Main menu** options `enable_cart` and `enable_wishlist` = true (catalog wish list must be enabled too).
- Requester actions: request an item (**SC Catalog Item** widget: quantity, attachments, Order Now, delivery info, special instructions), order guides (Describe Needs, Choose Options with include toggles, Summary, Edit Options), cart (bundles, Save as Draft), drafts in My Requests > Drafts.

## Service Portal

- New instances: catalog landing page by default; upgrades need plugin **Service Portal - Service Catalog v2** (`com.glideapp.servicecatalog.portal`). The docs advise moving to Employee Center.
- Landing page: search across configured catalogs (only items with a catalog and category; filters show primary category and catalog), **Browse by Categories**, **Requests and Approvals** (from My Request Filter), **My Saved Bundles**, **My Recent Items** (viewed or requested), **Popular Items**.
- Breadcrumbs follow the item's primary category when opened from search, the browsed category otherwise.
- Record producer submit label: widget option `"record_producer_label": {"value": "Request"}`. Requested For defaults: options `requested_for_id` and `requested_for_display`. Order Status page options: show columns, RITM number or item name, **Allow Cloning**.
- `glide.sc.portal.use_cart_v2_header` puts the Cart V2 widget (`sc-shopping-cart-v2`) in the header.
- Per item **Portal Settings**: **Request method** (Order / Request / Submit), **Hide 'Add to Cart'**, **Hide 'Save as draft'**, **Hide Quantity**, **Hide Delivery time**, **Hide 'Add to Wish List'**, **Hide Attachment**, **Mandatory Attachment**, **Hide on Service Portal**. For upgraded items that used No cart / No quantity, run script include **CatalogPortalSettingsMigration**.

## My Requests filters

**Catalog Administration > My Request Filter** (table `request_filter`, now extending Filter `sys_filter`; old **Short Description** / **Table Name** fields became **Title** / **Table**): **Applies to** Desktop, Service Portal, both, or Mobile; **Filter**; for portals **Portal page**, **Primary field to display**, up to three **Secondary fields** (no image fields; for `sc_request` the RITM name or item count is shown instead). Feeds Self-Service > My Requests, the portal My Requests widget and the Now Mobile applet (defaults *Incident Mobile* and *Service Catalog Request Mobile*; include only open records).

## Standard ticket page

Configure the standard ticket page for RITMs in portals; optional **Summarize** button (skill *ServiceNow Otto in Standard Ticket Page*, shown only when summary fields are configured).

## Now Mobile (requesters)

- Plugin `com.glide.mobile-employee`. **For Me**: My To-Dos (approvals), My Requests. **Services**: Recent Services, Popular Services (10 in 12 months), Browse Services (items of a category with subcategories appear under *Others*).
- Catalogs: **Now Mobile App > Catalogs** (portal catalogs `m2m_sp_portal_catalog`, portal Employee Center); none = all catalogs. Catalog-level browsing: swap the **Browse Services** applet section for **Browse Catalog**.
- Not requestable on mobile: content items, wizards, standard change templates; anything hidden on Service Portal. Not shown in record views: HTML, Custom, Custom with Label, UI Page variables; MRVS shows a "not viewable" message. Only non-scripted onLoad catalog UI policies (visibility only) apply in record views; empty variables are hidden.
- Extras: barcode scan into Single-line text (`barcode=true`), quick actions (function of type URL like `/mesp?id=sc_cat_item&sys_id=<item>` with condition `new sn_sc.CatItem('<sys_id>').canView() && ...isVisibleServicePortal()`), Siri shortcuts, push notifications, cart (`glide.sc.cart.enabled` = true; off by default), record producer button label (instance of widget `widget-sc-cat-item-v2` for the Now Mobile app).
- Properties: `glide.sc.mobile.category.order_by` (Title or Order), `glide.sc.mobile.include_desktop_only_items`, `glide.sc.mobile.item_class_not_supported` (e.g. `sc_cat_item_content,sc_cat_item_producer`), `glide.sc.mobile.unsupported_discover` (discoverable with a message, or hidden; ignored with AI Search), `glide.sc.mobile.primary_color` (ignored in Next Experience).

## Mobile Agent (approvers)

Plugin ITSM Mobile Experience (`com.sn_itsm_mobile`); roles business_stakeholder or approver_user. **My Approvals**: approve or reject (reason required) requests and RITMs; completed approvals list. No ordering. See [[ITSM Mobile Agent]].

## Universal Request

Per item or producer: **UR certified/enabled item** and **Requires Additional Review** (plugin `com.snc.universal_request`). For all at once create boolean properties `sn_uni_req.enable_ur_all_cat_items` and `sn_uni_req.enable_ur_all_rec_prod_items`; RITM or the producer's table must be registered as a Universal Request service. See [[Request Management Data Model and Process]].

## ATF samples

Plugin **Service Catalog - ATF Tests** (`com.glideapp.servicecatalog.atf.test`) with demo data: suite of Service Portal tests (MRVS ordering, order guide, cart checkout, record producer, variables on RITM and task, approvals, multiple catalogs, bundles, My Recent Items, regex, Requested For flows). See [[Automated Test Framework Overview]].

## Related

- [[Catalogs, Categories and the Catalog Home Page]] · [[Cart, Checkout and Cart Layouts]] · [[Conversational Catalog Requests and Virtual Agent]]
