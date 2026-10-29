---
type: reference
tags: [reference, service-catalog, instance-admin]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Reference, topic "Service Catalog properties", plus properties named on other pages of the chapter, https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/r_ServiceCatalogProperties.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Service Catalog properties reference

Navigation: **All > Service Catalog > Catalog Administration > Properties** (sections Homepage, Catalog Items, Order Guides, Cart, Request Fulfillment, Search, Security, Pricing, Portal, Virtual Agent (with plugin `com.glideapp.cs.sm_topic_blocks`), Mobile, Other). Properties not on that page are set in `sys_properties.list`. Concepts: [[Service Catalog Overview, Item Types and Roles]]. Grouped and paraphrased; defaults as given by the docs.

## Homepage and display

| Property | Notes |
|---|---|
| `glide.sc.max_items` | items or categories previewed per section, default 5 |
| `com.glide.servicecatalog.view_includes_category_descriptions` | category descriptions on the category page, default yes |
| `glide.sc.use_sub_cat_section` | subcategories in a panel (true, default) or list at top |
| `glide.sc.homepage.show.collapse` | expand/collapse icon on category widgets, default false |
| `glide.sc.cat_view_use_popup_for_details` | info-icon pop-up instead of Preview, default false |
| `glide.sc.auto_expand` | items expanded when not using pop-ups, default 2 |
| `glide.sc.show_additional_cats` | "Exists in categories" section, default true |
| `glide.sc.home.filter` | content types allowed on the home page (blank = all) |
| `glide.sc.placeholder.image`, `glide.sc.mobile.limit.description` | Classic Mobile only |

## Catalog items

| Property | Notes |
|---|---|
| `glide.sc.producer.redirect_url` | record producer default redirect: generated record or catalog home |
| `glide.sc.variable.attachment.delete.v2` | delete the `sys_attachment` when an attachment variable's file is replaced or removed |
| `glide.sc.variable.attachment.default_max_size` | attachment variable size cap in MB, default 20 |
| `glide.sc.item.cannot_add_to_request` | classes that cannot be added to an existing request; default `sc_cat_item_guide, sc_cat_item_producer, sc_cat_item_wizard` |
| `glide.sc.item.cannot_try_it` | classes without Try It; default adds `sc_cat_item_service` |
| `glide.sc.item.not_normal_cart_item` | classes that do not make a normal cart item |
| `glide.sc.item.copy.include_relationship` | extra tables copied by **Copy** (comma separated, no spaces) |
| `glide.sc.variable.reference.clickthrough` | info-icon clickthrough on reference variables |
| `glide.sc.enable_url_prefill` | URL and component prefill of variables, default on |
| `sn_now_assist_cr.*` | conversational limits: see [[Conversational Catalog Requests and Virtual Agent]] |

## Order guides

| Property | Notes |
|---|---|
| `glide.sc.item.order_guide_exclusion` | classes that cannot be in a guide |
| `glide.sc.guide.tab.validate` | check mandatory fields when switching tabs in Choose Options, default true |
| `glide.sc.render_order_guide_column` | show the guide next to its items on cart preview and status; confirm before deleting such items |
| `glide.sc.reset_cascade`, `glide.sc.reset_cascade_all` | reset cascaded (or all) item values when going back to Describe Needs; Core UI only |
| `glide.sc.sog.empty_payload`, `.inactive_order_guide`, `.invalid_order_guide_id`, `.json_parsing`, `.mandatory_json_parameters` | which scriptable order guide errors create failure records |

## Cart and checkout

| Property | Notes |
|---|---|
| `glide.sc.checkout.twostep` | two-step checkout, default false |
| `glide.sc.checkout.twostep.back` | Back to Catalog button (deprecated with cart layouts) |
| `glide.expert.checkout.twostep` | two-step for orders from a wizard, default true |
| `glide.sc.checkout.cancel`, `glide.sc.checkout.cancel.condition` | let ESS users cancel at checkout, under a condition such as `current.opened_by == gs.getUserID()` |
| `glide.sc.allow.checkout.clone` | cloning at checkout (deprecated with cart layouts) |
| `glide.sc.allow.clone.roles` | who may clone (bulk order); blank = all |
| `glide.sc.req_for.roles`, `glide.sc.req_for.roles.default` | who may order for others; default behaviour `allow` / `deny` |
| `glide.sc.request_for.columns`, `glide.sc.request_for.order_by` | extra columns and sort for the Requested for picker |
| `glide.sc.checkout.request.number` | RITM number column (deprecated with cart layouts) |
| `glide.sc.ess.description` | checkout description field, default `short_description` |
| `glide.sc.auto.cart.address.reset`, `glide.sc.prioritise.user.location` | delivery address sources |
| `glide.sc.enable_order_now` | Order Now orders only the current item |
| `glide.sc.allow.quantity` | roles that may change quantity; blank = all |
| `glide.sc.remove_inactive_cat_items_from_cart` | drop items deactivated while in a cart, default false |
| `glide.sc.use_cart_layouts` | cart layouts, default true |
| `glide.sc.checkout.task.display` | tasks on the order status page |
| `glide.sc.round.delivery.times` | round delivery estimates over a day |
| `glide.sc.cart.enabled` | cart in Now Mobile, default off |

## Request fulfilment

| Property | Notes |
|---|---|
| `glide.sc.restrict.quantity.changes` | no quantity changes after approval except catalog_admin |
| `glide.sc.approval.hover` | pending approver's name on the stage hover |
| `glide.approval_engine.sc_task`, `glide.approval_engine.sc_request` | approval engine for catalog tasks and requests |
| `glide.sc.audit.variables` | audit variable changes (on) |
| `glide.sc.hide_variable_editor_background` | plain variable editor, default false |
| `glide.sc.delivery_summary.name` | delivery plan summary uses task name instead of short description |
| `glide.sc.variable.snapshot` | order of variables on the RITM |

## Search

`glide.sc.item.cannot_show_search`, `glide.sc.search.allow_empty_search`, `glide.sc.can_search`, `glide.sc.show_listing_breadcrumbs`, `glide.sc.search.disabled_cats` (default true), `glide.sc.search.exclude_catalogs`, `glide.sc.search.rowcount`, `glide.sc.search.suggestions` (default true). See [[Catalogs, Categories and the Catalog Home Page]].

## Security

| Property | Notes |
|---|---|
| `glide.sc.use_user_criteria` | user criteria instead of entitlements, default true |
| `glide.sc.user_criteria_migration` | show both related-list families during migration, default false |
| `glide.sc.entitlement.override` | roles that bypass entitlements |
| `glide.sc.category.canview.override` | roles that see any category, default admin, catalog_admin |
| `glide.sc.catalog_item.subscription_enforcement` | `allow_bypass` (default) or `require_criteria` for service subscriptions |

## Pricing

`glide.sc.enhance.labels` (prices in option labels), `glide.sc.item.cannot_show_price`, `glide.sc.price.display` (overrides cart layouts), `glide.sc.use_custom_pricegenerator` (use the price calculator script includes, default no). See [[Catalog Pricing]].

## Portal

`glide.sc.sp.twostep` (order confirmation pop-up), `glide.sc.portal.use_cart_v2_header` (Cart V2 in header). A "maximum number of questions for conversation mode" property is listed here without a name.

## Mobile

`glide.sc.mobile.category.order_by`, `glide.sc.mobile.include_desktop_only_items`, `glide.sc.mobile.item_class_not_supported`, `glide.sc.mobile.unsupported_discover`, `glide.sc.mobile.primary_color`. See [[Service Catalog in Employee Center, Service Portal and Mobile]].

## Other

| Property | Notes |
|---|---|
| `glide.sc.log.variable_actions` | feed the Variable Action Logger, default false |
| `glide.sc.use_breadcrumb_links.cms` | links in CMS breadcrumbs, default false |
| `glide.sc.ui_policy.variable_set_run_first` | variable set UI policies before item ones, default false |
| `sc_orphan_item_option_delete_limit` | orphan `sc_item_option` rows deleted when a RITM is deleted |

## Catalog Builder and Virtual Agent

`glide.sc.builder.*` and `glide.sc.cb.item.update_set_prefix`: see [[Catalog Builder]]. `glide.sc.conversational.request.question.limit`, `glide.sc.va.reference_question_choices.limit`, `glide.sc.va.inline_render.question.limit`, `glide.sc.va.render_type.legacy`: see [[Conversational Catalog Requests and Virtual Agent]]. Universal Request: `sn_uni_req.enable_ur_all_cat_items`, `sn_uni_req.enable_ur_all_rec_prod_items`.

## Related

- [[System Properties]] · [[System Properties Reference]]
