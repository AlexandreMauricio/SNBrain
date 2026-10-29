---
type: table
tags: [table, schema, service-catalog]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog (chapter read in full; column names only where a page states them), https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/catalog-item-form.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# sc_cat_item

**Label:** Catalog Item
**What it stores:** every orderable or browsable entry of the Service Catalog; the specialised item types are child tables.
**Extends:** `sys_metadata` (application file) according to general knowledge; the chapter only shows that items are indexed through the `sys_metadata` text index. Unconfirmed.
**Extended by:** `sc_cat_item_producer` (record producer), `sc_cat_item_guide` (order guide), `sc_cat_item_content` (content item), `sc_cat_item_wizard` (wizard launcher), `sc_cat_item_service`, `pc_hardware_cat_item`, `pc_software_cat_item`; `sc_cat_item_subscribe` (service offering) per the CSDM page. Not a complete list.
**Scope:** global

## Key columns

The docs give labels; names are given only where stated.

| Label | Name | Type | Reference / choice | Meaning | Confidence |
|---|---|---|---|---|---|
| Name | `name` | string | | item name; usable as checkout description via `glide.sc.ess.description` | documented |
| Short description | `short_description` | string | | default checkout description column | documented |
| Class | `sys_class_name` | class | | item type; class names drive the `glide.sc.item.*` lists | documented |
| Domain, Domain Path | `sys_domain`, `sys_domain_path` | | | added by the Service Catalog domain separation plugin | documented |
| Catalogs, Category | ? | | `sc_catalog`, `sc_category` | overridden by the Catalogs and Categories related lists | label documented, names unconfirmed |
| Active, Availability, Hide on Service Portal, Meta, Owner, Secondary owner, Access Type, Fulfillment automation level, Template, Flow, Workflow, Execution plan, Price, Recurring Price, Recurring Price Frequency, Omit Price in Cart, Request method, No search, Use cart layout, Checked out | ? | | | see [[Catalog Item, Record Producer and Order Guide Forms]] | labels documented, names unconfirmed |

## Relations

- Item to catalog and category: `sc_cat_item_catalog`, `sc_cat_item_category`.
- Variables: [[item_option_new]] (by item or through variable sets).
- Access: [[user_criteria]] through `sc_cat_item_user_criteria_mtom` and `sc_cat_item_user_criteria_no_mtom`.
- Ordered as `sc_cart_item`, then `sc_req_item` (field **Item**, name not stated) under `sc_request`: [[Request Management Data Model and Process]].
- Record producers: produced records logged in `sc_item_produced_record`.

## Useful queries

```text
sys_class_name=sc_cat_item_producer^active=true
```

```javascript
// Scripts - Background, read only: count active items by type
var ga = new GlideAggregate('sc_cat_item');
ga.addActiveQuery();
ga.addAggregate('COUNT');
ga.groupBy('sys_class_name');
ga.query();
while (ga.next()) {
    gs.info(ga.getValue('sys_class_name') + ': ' + ga.getAggregate('COUNT'));
}
```

## Gotchas

- Catalog Builder keeps a **draft copy** while a published item is checked out: two rows for one item; filter on the state when counting.
- Items in a domain-separated catalog are requestable only in their own domain.

## Related

- [[Service Catalog Overview, Item Types and Roles]] · [[Record Producers]] · [[Order Guides]] · [[Catalog Builder]]
