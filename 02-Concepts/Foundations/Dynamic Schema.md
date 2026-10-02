---
type: concept
tags: [concept, data-integrity, fields, schema, glide-api]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Dynamic Schema" (pp. 856-875, 902-903), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Dynamic Schema

**In one line:** instead of adding a column for every possible property, a **dynamic attribute store** field holds name-value pairs per record, optionally governed by attribute definitions, categories and choice sets in a **dynamic namespace**.

## Elements

| Element | What it is |
|---|---|
| **Dynamic attribute store** | a field type (**Dynamic Attribute Store**) holding one or more attributes and values for the record |
| **Dynamic attribute** | a name-value pair. Either defined formally (with a type) or **transient** (just written into the store, treated as a string) |
| **Dynamic category** | a container of attributes. A child category inherits its parent's attributes |
| **Dynamic namespace** | a scoped collection of attributes and categories. One is created automatically per store field, named `<table_name>/<store_column_name>`; several store fields can share one |
| **Dynamic choice set** | a fixed list of values for a String attribute. Not tied to a namespace, so reusable. Choices can be limited to a namespace, category or attribute, and **overridden** (relabelled or hidden) per namespace |

Creating a store field also adds a **dynamic category reference field** to the table, with the store field dependent on it.

## Two ways to use it

1. **Transient**: create the store field and start writing attributes. Quick, but values are strings (sorting and comparison are textual), there are no categories and no choice sets.
2. **Defined**: create dynamic attribute records in the namespace (**All > Dynamic Schema > Dynamic Namespaces**, role `dynamic_schema_writer`) with **Type** (String, integer, date, Reference...), put them in categories, attach choice sets.

Defining or retyping an attribute later **does not change stored data**, only how it is interpreted. Data invalid for the new type is treated as nil ("dog" in an integer attribute counts as 0 in queries).

## Reading and writing

On the form the store field takes JSON:

```text
{ "screen_size": "75", "screen_type": "OLED" }
```

In scripts, address an attribute as `<store_field>-><attribute>`:

```javascript
var gr = new GlideRecord('u_example_products');
gr.setValue('u_specs->screen_size', '75');
gr.setValue('u_specs->screen_type', 'OLED');
gr.insert();

var q = new GlideRecord('u_example_products');
q.addQuery('u_specs->screen_type', 'OLED');
q.query();
```

Supporting APIs: GlideRecord (`getDynamicAttributeValue`, `setDynamicAttributeValue`, `setDynamicAttributeValues`, display-value variants, `addQuery`, `orderBy`), GlideAggregate (`groupBy`, `addAggregate`, `addHaving`, `orderByAggregate`), `GlideDynamicAttributeStore`, `GlideElementDynamicAttributeStore`, `GlideDynamicNamespace`.

Dynamic attributes can also be used in the condition builder of workspace lists.

## Setup steps

1. **System Definition > Tables**, open the table, **Columns > New**, **Type** = Dynamic Attribute Store, give a label. Role admin.
2. (Optional) in the namespace, add **Dynamic Attributes**, **Dynamic Categories** (with **Parent**), and **Dynamic Category Members** linking attributes to categories.
3. (Optional) **Dynamic Schema > Dynamic Choice Sets**, add choices, and select the set on a String attribute.
4. To share a namespace between store fields, edit the store column's **Attributes**: `dynamic_namespace=<namespace name>`, then delete the auto-created namespace that is no longer used.

Writing attributes needs only write access to the table.

## Related

- [[Field Types Reference]] · [[Field Administration]]
