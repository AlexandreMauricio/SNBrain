---
type: reference
tags: [reference, service-catalog, scripting, glide-api]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Server API reference, pages CartJS - Scoped, CatItem - Scoped, UserCriteria - Scoped; Client API reference > g_service_catalog - Client; read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA). CatCategory, CatalogSearch, other sn_sc classes and return-value examples not read.
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# Service Catalog Scripting APIs (CartJS, CatItem, UserCriteria, g_service_catalog)

**In one line:** order items, change catalog items and user criteria by server script, and read the parent form from inside a multi-row variable set.

From the Brazil docs, not tested. Variables in scripts: [[Scripting with Catalog Variables]].

## CartJS (`sn_sc`, server)

Needs the **Service Catalog Scoped API** plugin (`com.glideapp.servicecatalog.scoped.api`), on by default.

| Method | Does |
|---|---|
| `new sn_sc.CartJS([cartName])` | the user's cart, or a named one |
| `orderNow(request)` | orders one item. With two-step checkout it puts the item in the cart and returns the cart; otherwise it returns the new request |
| `addToCart(request)`, `updateItem(request, cartItemId)`, `empty()` | build the cart |
| `checkoutCart()`, `submitOrder(request)` | check out |
| `setRequestedFor(user)`, `setDeliveryAddress()`, `setSpecialInstructions()` and the matching getters | cart details |
| `getCartItems()`, `getCartDetails()`, `getCartID()`, `canViewRF()` | read |

`request` keys: `sysparm_id` (item sys_id, required), `sysparm_quantity` (default 1), `sysparm_requested_for` (default the session user), `delivery_address`, `special_instructions`, `variables`. The docs type `variables` as an Array of `var_name` and `var_value`, so check the format on a real call before relying on it.

## CatItem (`sn_sc`, server)

- `create()`, `update()`, `read()`, `deleteRecord()`, `setAttributes()`, `setCatalogs()`, `setCategories()`, `setTableName()`, `setImage()`.
- `availableForUserCriteria(action, ids)`, `notAvailableForUserCriteria(action, ids)`.
- Checks: `canViewInDomain()`, `canViewOnSearch(isMobile)`, `isVisibleServicePortal()`, `isDelegationAllowed(user)`, `getInvalidDelegatedUsers(users)`.
- `submitProducer({sysparm_id: '<record producer sys_id>', variables: {...}})` creates a record through a record producer (`sc_cat_item_producer`). See [[Record Producers]].

## UserCriteria (`sn_uc`, server)

Needs the **User Criteria Scoped API** plugin (`com.glideapp.user_criteria.scoped.api`). It creates, edits and deletes **User Criteria** (`user_criteria`) records: `create()`, `update()`, `read()`, `deleteRecord()`, `setName()`, `setUsers()`, `setGroups()`, `setRoles()`, `setCompanies()`, `setDepartments()`, `setLocations()`, `setMatchAll()`, `setAdvanced()`, `setScript()`, `setActive()`.

It has **no** method to check whether a user matches criteria. The team notes' `SNC.UserCriteriaLoader` ([[Service Catalog Overview, Item Types and Roles]]) is not on any API reference page read.

## g_service_catalog (client)

`g_service_catalog.parent.getValue('<variable>')` reads a variable of the parent catalog item form from a client script on a multi-row variable set while its modal is open. It works in Service Portal, Core UI, workspaces and Now Mobile. It is called on `parent`.

## Example

```javascript
// Server side, for example a scripted REST resource, scoped application
var cart = new sn_sc.CartJS();
var result = cart.orderNow({
    sysparm_id: '<catalog item sys_id>',
    sysparm_quantity: '1',
    sysparm_requested_for: '<Test User sys_id>',
    variables: { example_variable: 'Example value' }
});
gs.info(JSON.stringify(result));
```

The `variables` object here is a guess at the shape. The docs describe an array, so test both.

## Related

- [[Scripting with Catalog Variables]] · [[Service Catalog Overview, Item Types and Roles]] · [[Catalog Client Scripts, UI Policies and Variable Editors]] · [[Variable Sets and Multi-Row Variable Sets]]
