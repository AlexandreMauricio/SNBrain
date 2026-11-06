---
type: reference
tags: [reference, portal, service-catalog, knowledge, cmdb, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Configuring Service Portal > Using portal widgets > Widget library (example, search, Knowledge Management, Service Catalog, configuration page and service status widgets, about 90 topics), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g). The docs say the library is not a definitive list.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Service Portal Base Widget Library

**In one line:** the base widgets that ship with Service Portal, what each shows, and the instance options worth knowing.

From the Brazil docs; not tested. Base widgets are read-only (clone to change; clones stop getting upgrades). Almost every widget also has **Bootstrap color**, and with user criteria enabled **Who Can View / Who Cannot View** instance options; those are not repeated below. How instances work: [[Service Portal Pages, Containers and Page Route Maps]].

## General and example widgets

| Widget | Shows / notes | Key instance options |
|---|---|---|
| Announcements | active `announcement` records | Type (Banner, Widget or custom; empty = all), Title, Glyph, **Use Display Style**, Paginate, Max Records, View All Page |
| Approvals | `sysapproval_approver` records for the user; e-signature supported | Glyph, Buttons side by side, Max elements (default 10), **Comments mandatory for rejection** |
| Approval Info, Approval Record, Approval Info Record | approval details and record with activity; the last uses the Approval Configuration | colour only, or none |
| Breadcrumbs | path through the portal (customise: KB0719179) | none |
| Breakout Game | the 404 page; example of a link function | none |
| Calculator | example of client-server data passing | none |
| Carousel | scrolling images; slides in the instance's **Carousel Slides** related list (Name, Order, HREF/URL, Background 1022x300 px; the instance needs a name) | |
| Change Password | updates the password on the local `sys_user` | none |
| Cool Clock | example of instance options | Title, Timezone (full name, default America/Los_Angeles), Second hand color |
| Data table from instance definition | filtered list, exportable | Table, Filter, Fields, Maximum entries, Order by, Order direction, Title, Glyph, Link to this page |
| Data Table from URL definition | table chosen by URL | Title, Use Instance Title, Glyph, Link to this page, Fields, **Enable Filter** (desktop only); no Maximum entries |
| Documents | documents on a record (plugin `com.snc.multiprovider_documents`; 100 MB per document) | Record ID, Record table, Title, Popup before upload, Metadata form view (default `dw`) |
| Form | a platform form; URL parameters `sys_id`/`sl_sys_id`, `table`/`sl_table`/`t`, `view`/`v`; checks cross-scope access (`glide.service_portal.enforce_cross_scope_check_in_form`); timer fields display wrongly | |
| Header Menu | configured through the portal, not dragged; cloning not supported (KB0697352) | none |
| Hello World 1, 2, 3 | examples of template, client and server script | |
| HTML | free HTML | Title (hidden), HTML |
| Icon Link | link to a page, URL, catalog category or item, KB topic, article or category | Title, Glyph, Bootstrap class name, Type, Template (Top icon, Circle icon, Color box) |
| Icon menu list | list of links with glyphs from its **Menu Items** | |
| Language Switch | lets users change the page language | none |
| Link button | button nested in another widget | Link for button (`?id=<page>`), Contents of button |
| Login | `sys_user` credentials; *Forgot Password?* goes to `glide.security.password_reset.uri` (hide with `glide.security.forgot_password.display.link` false); self-registration and PIV/CAC links | Show panel, Use Advanced View |
| My Requests (old) | open `sc_request` records | Title, Maximum entries |
| My Requests (`my-requests-v2`) | requests, incidents and tasks per the **My Request Filter** module | Title, Show View (open or closed), Items per page |
| Organization Chart, New Organization Chart | manager tree from `sys_user` | old: user and node colours, URL or Page (URL wins); new: Primary and Secondary fields, **Profile URL** `?id=user_profile&sys_id={sys_id}`, Hide Search, Hide Actions, max reports (12), max manager level (7) |
| Simple List | any list | Table, Filter, Display field, Secondary fields, List page, **Enforce field-level Read ACLs on Filter query terms** (always on when `glide.service_portal.enable_acls_for_encoded_query_in_list` is true), Link to this page, Show even when empty, View, **Disable record watcher**, Glyph, size, Maximum entries, List body height, Image field, Rounded images, Hide footer |
| Sample Footer | set on the theme | none |
| Ticket Attachments | attachments under 24 MB; drag and drop | Record ID, Record table |
| Ticket Conversations | journal entries of a `task` record (limit `glide.service_portal.stream_entry_limit`, default 100) | Use dynamic placeholder, No readable journal field message, **Enter key behavior** (or `glide.service_portal.comment.enter_adds_newline`) |
| Ticket Fields, Request Fields | request details and its catalog variables | Pickup message (keep it inside `${}`) |
| Ticket Location | location on a ticket | none |
| User Profile | profile and accessibility preferences | Show current user |

The **Data Table** widgets need **Public** on both the widget and the underlying *Data Table* widget for guests.

## Search widgets

| Widget | Notes |
|---|---|
| Homepage Search | Title, Short description, Typeahead search style object `{title: 'Search', color: 'blue', size: 'lg'}` |
| Typeahead Search | Title, Color, glyph, Size (xs to lg), **Limit** (default 15, suggestions or typeahead), **Contextual Search Sources** |
| Faceted Search | results and facets on `sp_search`; Facet List Title, typeahead options, Max results for All / single source, Show Did You Mean, Typeahead limit |
| Legacy: Search Page | replaced by Faceted Search: Show score, max results, Did You Mean |
| AI Search Assist, Contextual Search | in the *Create Incident* record producer, results while typing ([[Contextual Search]]) |

With AI Search on, Homepage, Typeahead, Faceted, Catalog Homepage Search and Knowledge Breadcrumbs also take **Search Application**, **Search Results Configuration**, **Disable All Suggestions**, **Placeholder** and **AI Search Source Filter**, overriding the portal's. See [[Service Portal Search Configuration]].

## Knowledge widgets

Plugin `com.glide.service-portal.knowledge-base`. KB also in Category, KB Article Comments (star rating and comments, or follow `glide.knowman.show_star_rating` / `glide.knowman.show_user_feedback`), KB Article Page, KB Categories (no options; works with KB Category Page, which lists all articles if alone), KB Knowledge Bases (menu when the portal has several bases, hidden with one), KB Most Viewed, KB News (Max number default 5, KB category), KB Search (embeds Typeahead), KB Top Rated, KB View, KB View 2 (category cards), Knowledge Breadcrumbs (Show Search Box). Details: [[Knowledge Portal and Search]].

## Service Catalog widgets

Plugin `com.glide.service-portal.service-catalog`; **Service Catalog v2** (`com.glideapp.servicecatalog.portal`, active by default) adds Catalog Homepage Search (`cat-homepage-search`), SC Scroll to top (`sc-scroll-to-top`), Requests and Approvals (`sc_request_and_approvals`) and Recent & Popular Items (`sc-recent-popular`).

| Widget | Key options / notes |
|---|---|
| Catalog Content | items grouped by category; none |
| Catalog Homepage Search | Title, Short description, Typeahead Search object |
| Recent & Popular Items | Popular Items used in (None, last 3, 6 or 12 months, Life time with a performance cost), Number of Items (8), My Recent Items By (View or Request) |
| Requested Items | Title, Display field, Filter, Table, Link to this page, Maximum entries |
| Requests and Approvals | tabs from `task` and `sysapproval_approver`; hidden when empty |
| SC Catalog Item (`widget-sc-cat-item-v2`) | Show Add Cart Button, Show field validation messages, Show Add/Update Wish List buttons, Order Item Section on Top, Show More/Less on mobile (150 characters); record producer button label through JSON `"record_producer_label"` |
| SC Categories | Page, Number of categories (10), Category Layout Flat or Nested (three levels), Hide at XS, Omit badges, Check canView per item; over 200 items per category: Flat, Omit badges true, canView false |
| SC Category Page | Click event name (`$sp.cat_item_list.click`), items per page, Show items from Child Categories (false when SC Categories is Flat); sorted by Order then Name |
| SC Order Guide (`widget-sc-order-guide-v2`) | Describe Needs, Choose Options (include toggle per item with **Show Include Toggle (Service Portal)**), Summary; Title, Show More/Less, Compact Mode, Hide Delivery Time, Show Add to Cart |
| SC Popular Items | Limit (9), Include Record Producers |
| SC Shopping Cart | `sc_cart`; Cart Template (`small_shopping_cart_v2.html` or `large_shopping_cart_v2.html`), Auto update cart; embeds SC Save Bundles, SC Saved Carts and SP Variable Editor |
| SC Wish List Cart (`sc_wishlist_cart`) | needs **Enable Wish List** on the catalog and `glide.sc.use_cart_layouts` true; Auto update wish list |

Header switches for cart and wish list: [[Service Portal Portal Record, Branding and Themes]]. Item-level portal settings: [[Service Catalog in Employee Center, Service Portal and Mobile]].

## Service status widgets

Plugin `com.glide.service-portal.service-status`. Business Service Status (`cmdb_ci_service`, Number of Services 250), Current Status (ongoing outages in `cmdb_ci_outage`; Show outage details, Standalone), Planned Maintenance (next five days), Service History, Service Status (one service from the URL; green no issues, blue planned maintenance, yellow degradation, red outage), Service Status Legend, Service Status Subscription.

**Configuration page widgets** (Service Portal Config Overview, Portal config, SP Page Map, SP Portal Map, Theme Preview, Widget Edit Panel) are internal and cannot be extended.

## Example

On *example_home*: Homepage Search titled *Example Help*, Simple List on `incident` filtered to the caller's open records with **Enforce field-level Read ACLs** ticked, and Icon Link *Example Catalog* with Template Circle icon.

## Related

- [[Service Portal Widgets]] · [[Service Portal Widget Development]] · [[Service Portal Pages, Containers and Page Route Maps]] · [[Service Portal Search Configuration]]
