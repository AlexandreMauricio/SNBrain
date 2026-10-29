---
type: reference
tags: [reference, service-catalog, forms-lists]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Reference, topics "Catalog Item form", "Record Producer form", "Order guide form", "Define a content item", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/catalog-item-form.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Catalog item, record producer and order guide forms

Navigation: **All > Service Catalog > Catalog Definition > Maintain Items** (`sc_cat_item`), **Record Producers** (`sc_cat_item_producer`), **Order Guides** (`sc_cat_item_guide`). Column names are not given by the docs; only labels are recorded here (see [[sc_cat_item]] for the few known names). Concepts: [[Service Catalog Overview, Item Types and Roles]]. Grouped and paraphrased.

## Catalog Item form

| Section | Field | Notes |
|---|---|---|
| main | **Name**, **Catalogs**, **Category** | category selectable after catalogs; portal search finds only items with a category; Employee Center needs a topic |
| main | **Model** | product model, for items published from models |
| main | **Active** | inactive items are hidden even inside order guides |
| main | **Owner**, **Secondary owner** | owner edits; secondary owner = user criteria of extra editors (set by catalog admin or owner) |
| main | **Fulfillment automation level** | Unspecified, Manual, Semi-automated, Fully automated (reporting) |
| main | **Access Type** | Restricted (default) or Delegated: see [[Delegated Requests and Requests from Other Records]] |
| main | **Template** | Catalog Builder template it came from |
| main | **Preview Link**, **Ordered Item Link**, **Hide on Service Portal**, **Availability** | Availability: Desktop and Classic Mobile, Desktop Only, Classic Mobile Only |
| Item Details | **Short Description**, **Description**, **Meta** | Meta = search keywords |
| Process Engine | **Flow**, **Workflow**, **Execution plan** | only one |
| Picture | **Icon** (27x27), **Picture** | default icon `images/service_catalog/generic_small.gif` |
| Pricing | **Price**, **Recurring Price**, **Recurring Price Frequency**, **Omit Price in Cart** | [[Catalog Pricing]] |
| Portal Settings | **Request method**, **Hide 'Add to Cart'**, **Hide 'Save as draft'**, **Hide Quantity**, **Hide Delivery time**, **Hide 'Add to Wish List'**, **Hide Attachment**, **Mandatory Attachment** | Request = no delivery info; Submit = no confirmation either; guides inherit some from items |
| Universal Request Config | **UR certified/enabled item**, **Requires Additional Review** | with `com.snc.universal_request` |
| added by form layout | **Expand help for all questions**, **No Quantity**, **No Cart**, **No search** (hidden from portal browse and search, still browsable in Core UI), **Order**, **Domain**, **Domain Path**, **Use cart layout**, **Omit price in cart**, **No order**, **No order now**, **No proceed checkout**, **Cart**, **Delivery Plan Script**, **Make the item non-conversational in VA**, **Use NLU for conversational requests** | |
| Related Links | **Item Diagnostic**, **Edit checked out item in advanced view**, **Copy**, **Try It** | |
| Related Lists | Variables, Variable Sets, Approved By Group, Approved By, Categories, Catalogs, Catalog Data Lookup Definitions, Catalog UI Policies, Catalog Client Scripts, Related Items, Related Articles, Service Fulfillment Steps, Assigned Topics (with `sn_ect`), Available For, Not Available For | |

## Record Producer form

Same idea, with: **Table name** (target), **Post insert script**, **Accessibility** (**Catalogs**, **Category**, **View** (CMS), **Roles**, **Availability**, **Can cancel**), **What it will contain** (**Short description**, **Description**, **Meta**, **Hide on Service Portal**, **Redirect To**, **Script**), **Icon**, **Picture**, Classic Mobile pictures, **Generated Record Data > Template**, **Portal Settings** (**Hide Attachment**, **Hide 'Save as Draft'**, **Mandatory Attachment**), Universal Request config (the produced task becomes the universal request's primary task). Wizard prerequisites **Save options** and **Allow edit** are added by form layout. See [[Record Producers]].

## Order guide form

**Name**, **Active**, **Category**, **Two step** (not in Service Portal), **Icon** (16x16), **Cascade variables**, **Ordered Item Link**, **Roles**, **Short description**, **Description** (first page), **Meta**, **Hide on Service Portal**, **Picture**, **Order to cart** (only with Two step; not Service Portal), **Script** (`guide.add()` / `guide.remove()`), Portal Settings **Request method**, **Hide 'Add to Cart'**, **Show Include Toggle** (default on for new guides). Button **Generate sequence**. Related lists Rule base, Variables, Variable Sets. See [[Order Guides]].

## Content item form

**Name**, **Category**, **Icon**, **Roles**, **Active**, **Content type** (KB Article, Catalog Content, External Content), **Target** (Within Catalog, New Window/Tab), **URL**, **KB article**, **Short description**, **Description**, **Picture** (catalog content only), **Meta**, **Hide on Service Portal**.

## Related

- [[Catalog Variables and Variable Types]] (variable form) · [[Create a Catalog Item with Variables]]
