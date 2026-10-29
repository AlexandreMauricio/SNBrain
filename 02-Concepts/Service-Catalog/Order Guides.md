---
type: concept
tags: [concept, service-catalog, request, scripting]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Order guides", "Create an order guide", "Configure a sequence to fulfill items in order guides", "Request an order guide", "Create an order guide rule to add a catalog item", "Create an order guide variable", "Create an item variable assignment", "Cascade an order guide variable", "Avoid enforcement of a mandatory field", "Run order guides automatically", "Order guide form", "Service Catalog properties", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_ServiceCatalogOrderGuides.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Order guides

**In one line:** an order guide (`sc_cat_item_guide`) asks a few questions once, then orders several catalog items in **one request**, chosen by rules and pre-filled from the answers.

## Ordering flow

1. **Describe Needs**: the guide's own variables.
2. **Choose Options**: the items picked by the rule base, each with its own variables (and attachments).
3. **Check Out**: review and **Submit Order**.

Tick **Two step** on the guide to skip Check Out (not applicable in Service Portal). The RITMs show the guide in their **Order Guide** field. In Service Portal each item can have an include toggle (**Show Include Toggle**); an excluded item ignores its mandatory fields.

## Rule base

Each rule (related list **Rule base**) has **If this condition is true** (conditions on Keywords, Requested By, Requested For or any guide variable) and **Include this item** (catalog item or record producer). Other rule options:

| Option | Effect |
|---|---|
| **Ignore Mandatory Evaluation** | user can continue without that item's mandatory fields (values then are not passed on) |
| **Use cart layout** | use the configured cart layout |
| **Show quantity** / **Quantity** | show and preset the item quantity in Choose Options (Service Portal, Now Mobile) |

The guide **Script** field can add or remove items outside the rules: `guide.add("<sys_id of item>")`, `guide.remove("<sys_id of item>")`.

## Passing answers down

- **Cascade variables** (guide check box): a guide variable passes its value to the item variable with the **same name**. Define shared variables once in a variable set and attach it to the guide and each item.
- **Item variable assignment** (on a rule, related list **Item Variable Assignments**): set an item variable to a fixed **Value** or to an **Order Guide Variable**.
- Precedence for an item variable: item variable assignment, then cascaded value, then the variable's default.
- **Requested For** always cascades by type, even without Cascade variables, and is read-only on the items. Attachment variables cascade as copies; the item's own attachment attributes are not enforced on the first cascaded copy.
- Hide the duplicated variables after Describe Needs: in Core UI an onLoad catalog client script comparing `current_item` and `sysparm_guide`; in Service Portal `if (g_service_catalog.isOrderGuide()) g_form.setDisplay('<variable>', false);`.
- Order guide variables carry **no price**, even through a variable set.
- MRVS data can be cascaded when Cascade variables is on.

## Mandatory fields and tabs

`glide.sc.guide.tab.validate` (default true) checks mandatory fields when switching item tabs in Choose Options; set false to check only on moving to the next step. `glide.sc.reset_cascade` and `glide.sc.reset_cascade_all` control resetting values when going back to Describe Needs (Core UI only).

## Sequenced fulfilment

Plugin **Order Guide Sequential Fulfillment** (`com.glideapp.servicecatalog.order_guide_sequencing`), roles admin or catalog_admin plus `playbook.admin`. On the guide, **Generate sequence** creates a Playbooks process: items land in Lane 1 in rule-base order; each activity has **When to start** (immediately, with or after previous), the **Order Guide Item**, an option to end without waiting for the task to close, and conditions on the previous activity's outputs (Generated Task Record, Record Id, Table). RITMs wait in Pending until their turn; record producer records are only created when reached. Limits: only the first 20 rule-base items are added automatically (add others with **Fulfill Order Guide**); items added by the guide script must be added by hand; guides whose rule base is only record producers are ignored; an activity repeated in a sequence runs once. See [[Playbooks Overview and Components]].

## Running a guide without a user (scriptable order guides)

Use from a server script (business rule, UI action) or the legacy workflow activity **Scriptable Order Guide**:

```javascript
// Server-side, global scope (for example Scripts - Background or a business rule)
var guide = new GlideRecord('sc_cat_item_guide');
if (guide.get('name', 'Example Onboarding Guide')) {
    var sog = new SNC.ScriptableOrderGuide(guide.getUniqueValue());
    var input = { opened_by: '<user sys_id>', requested_for: '<user sys_id>', department: '<department sys_id>' };
    if (sog.process(JSON.stringify(input))) {
        gs.info('Request created: ' + sog.getRequest().getUniqueValue());
    } else {
        gs.info('Failed: ' + sog.getMessage());
    }
}
```

- `process(json)`, `reprocess(failureGR)`, `getMessage()`, `getRequest()`, `getFailure()`. `opened_by` and `requested_for` are **mandatory** valid user sys_ids; other keys must match guide variable names used in rules.
- Order guide UI policies are not enforced and Choose Options cannot be answered, so rules must give sensible defaults.
- Failures go to Scriptable Order Guide Failures (`sc_script_order_guide_failure`), module **Catalog Administration > Scriptable Order Guide Failures**; fix and use **Reprocess**. Properties `glide.sc.sog.*` choose which errors create a failure record (empty payload, inactive guide, invalid sys_id, JSON parse error, missing parameters).
- In a workflow, success puts the request sys_id in the scratchpad as `sc_request`.
- The docs' own example declares `now_GR` but then uses `gr`, and uses `new JSON().encode()`; the snippet above is rewritten, not tested.

## Other rules

- Items excluded from guides: `glide.sc.item.order_guide_exclusion`. Inactive items in a guide are not shown; use **Visible on Guides** / **Visible elsewhere** to show an item only in a guide.
- Making a bundle from a cart that contains a guide loses the guide association.
- Many active rule bases slow loading (item diagnostic rule `checkOrderGuideRuleBaseCount`).

## Related

- [[Create an Order Guide]] · [[Catalog Item, Record Producer and Order Guide Forms]] · [[Variable Sets and Multi-Row Variable Sets]] · [[Delegated Requests and Requests from Other Records]]
