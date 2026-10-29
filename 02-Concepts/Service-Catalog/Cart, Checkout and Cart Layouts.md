---
type: concept
tags: [concept, service-catalog, request, portal]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Service Catalog checkout models", "Cart layout", "Configure the cart layout", "Configure Service Catalog cart widgets", "Configure Service Catalog preview screens", "Configure Service Catalog status screens", "Migrating to cart layouts", "Migrate customizations and enable cart layouts", "Legacy flexible checkout and delivery forms", "Modifications in the delivery screen", "Modifications in the checkout form", "Define item quantity choices", "Remove item restrictions", "Create up to ten copies of Service Catalog request", "Clone a request", "Create a custom cart", "Saving catalog items to a wish list", "Service Catalog request screens", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_EnableATwoStepCheckout.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Cart, checkout and cart layouts

**In one line:** ordering goes through a cart (`sc_cart` / `sc_cart_item`) and a one-step or two-step checkout; the look of the cart, preview and status screens is set by **cart layout** records rather than by editing UI macros.

## Checkout models

| Model | Flow | Set by |
|---|---|---|
| One-step (default) | Order Now / Proceed to checkout > order summary | default |
| Two-step | Checkout > confirmation screen (edit, delivery address, special instructions, attachments) > Submit Order > summary | `glide.sc.checkout.twostep` = true; `glide.sc.checkout.twostep.back` shows **Back to Catalog** |

- In two-step, client script **set location** fills **Deliver to** from the user's address; `glide.sc.prioritise.user.location` prefers the location record, `glide.sc.auto.cart.address.reset` updates open carts when the address changes.
- Two-step checkout **disables** the delegated request experience ([[Delegated Requests and Requests from Other Records]]).
- Access to an item is checked again at checkout, also from scripts and APIs.
- Order guides use two-step by default, items one-step: mixing them gives different cart experiences. Orders from a wizard use two-step (`glide.expert.checkout.twostep`, default true).
- `glide.sc.enable_order_now` = true: **Order Now** orders only the current item, leaving the cart untouched (old Order Item button deprecated).
- Service Portal: `glide.sc.sp.twostep` shows the order confirmation pop-up; per item, the **Request method** (Order / Request / Submit) changes the button label, confirmation dialog and delivery info.

## Cart layouts

**Catalog Definitions > Maintain Cart Layouts** (enabled by `glide.sc.use_cart_layouts`, default true on new instances). Records:

- Widgets: **Item Ordering Widget**, **Shopping Cart Widget**, **Item Ordering Widget (Order Guide)**.
- Preview screens: **Cart Preview Screen** (one-step), **(Two Step)**, **(Wish List)**, **(Classic Mobile)**.
- Status screens: **Order Status Screen**, **(Classic Mobile)**.

Each has **Title**, **Target** (do not change), **Components**, **Columns**, **Buttons**, **Button Labels** (a renamed button is renamed on every screen that shows it), and **Widget Macros** / **Column Macros** related lists (Jelly macros; base ones are read-only examples, your own survive upgrades). In two-step preview **Shipping Address** and **Shipping Location** are mutually exclusive components.

Properties that still win over layouts: `glide.sc.price.display`, `glide.sc.allow.quantity`, and `glide.sc.checkout.cancel` (layout's Cancel Request also shows the button). Deprecated when layouts are on: `glide.sc.allow.checkout.clone` (use **Clone Checkout**), `glide.sc.checkout.request.number` (use the **Request Item Number** column), `glide.sc.checkout.twostep.back` (use **Back to Catalog**).

Per item: add **Use cart layout** to the item form; clear it to use the item's own **Omit price in cart**, **No cart**, **No order**, **No order now**, **No proceed checkout**, **No quantity**.

### Migrating an upgraded instance

If the upgrade found customised cart macros, layouts are off. Save the customisations, revert macros `sc_catalog_homepage_cart`, `sc_catalog_requested_for`, `catalog_item`, `catalog_cart_default`, `sc_cart_main` (and the UI page `com.glideapp.servicecatalog_category_view` or Catalog Cart dynamic content if changed), remove their `sys_update_xml` rows, run in Scripts - Background `var cm = new CartLayoutMigration(); cm.configureLayoutProperty(); cm.setLayoutFalse(); cm.setEmptyLayout();`, rebuild the changes as widget macros, then set `glide.sc.use_cart_layouts` = true.

### Legacy options

- Custom cart: a UI macro (copy of `catalog_cart_default`) linked through the item's **Cart** field. Summary screen: UI page `com.glideapp.servicecatalog_checkout_view` (customising it makes upgrades skip it).
- Checkout description column: `glide.sc.ess.description` (default `short_description`).
- **Requested for** search in the cart: `glide.sc.request_for.columns` (extra `sys_user` columns, semicolon separated) and `glide.sc.request_for.order_by`.

## Quantity

Choices are the choice list of `sc_cart_item.quantity` (default 1-10): add or delete choices in **System Definition > Choice Lists**. Who may change quantity: `glide.sc.allow.quantity`. After approval, quantity changes are blocked except for catalog_admin (`glide.sc.restrict.quantity.changes`).

## Item restrictions by class

Default: order guides, record producers and wizard launchers cannot be added to an existing request, have no **Try It**, do not create normal cart items, show no price and no search field. Edit the class-name lists in `glide.sc.item.cannot_add_to_request`, `glide.sc.item.cannot_try_it`, `glide.sc.item.not_normal_cart_item`, `glide.sc.item.cannot_show_price`, `glide.sc.item.cannot_show_search`.

## Cloning a request (bulk ordering)

Up to **10** copies for other users. Enable **Clone Checkout** on the Order Status Screen layout and `glide.sc.allow.checkout.clone`; limit with `glide.sc.allow.clone.roles` (blank = all). Each copy is a separate request with that user as **Requested for** and the cloner as **Opened by**; MRVS data and its scripts are copied. In Service Portal turn on the Order Status page option **Allow Cloning**. Not possible when RITMs are for different users or a user lacks access.

## Wish list and bundles

- **Enable Wish List** on the catalog (off by default; disabling it deletes wish-list items unless another catalog keeps them). Needs `glide.ui.doctype` true. No duplicates: re-adding updates the entry. **Add to Cart** moves it out of the wish list.
- Service Portal and Employee Center: **Save as Bundle** from the cart, then add or replace the cart with a bundle (a bundle loses order guide links). **Save as Draft** keeps an unfinished item under My Requests > Drafts (hide per item with **Hide 'Save as draft'**).

## Other cart facts

- Inactive items in a cart cannot be checked out; `glide.sc.remove_inactive_cat_items_from_cart` removes them.
- Each item line becomes its own RITM (2 PCs + 1 chair + 1 desk = one REQ, three RITMs). Fulfillers can tick **Backordered** on a RITM. Cancelling a request cancels unreceived purchase and transfer orders.
- `glide.sc.checkout.task.display` shows the request's tasks on the order status page.

## Related

- [[Catalog Pricing]] · [[Service Catalog Properties Reference]] · [[Request Management Data Model and Process]] (what checkout writes) · [[Service Catalog in Employee Center, Service Portal and Mobile]]
