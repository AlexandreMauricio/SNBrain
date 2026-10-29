---
type: concept
tags: [concept, service-catalog, portal, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Service catalog categories", "Create a category", "Configure dynamic categories", "Service catalog setup", "Set up Platform URLs for catalog modules", "Multiple service catalogs setup", "Tables provided with multiple service catalogs", "Migrating from Core UI to Angular portal", "Service catalog home page configuration", "Configure search and navigation", "Refine search results", "Configure keyword search for catalog items", "Configure AI-based catalog search experience", "Configure preview", "Create a renderer", "Customize a catalog homepage", "Customize the multi-catalog homepage", "Show item details in sections or pop-ups", "Configure Classic Mobile devices", "Using the content management system with the service catalog", "Service Catalog home page", "Define a content item", "Add a catalog item", "Specify related items and articles", "Add an ordered item link", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_ServiceCatalogCategories.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Catalogs, categories and the catalog home page

**In one line:** catalogs (`sc_catalog`) and nested categories (`sc_category`) organise items; the Core UI catalog home page, its search and its renderers are configured by properties and drag-and-drop, while portals use their own widgets.

## Catalogs

- **Catalog Definitions > Maintain Catalogs**: **Title**, **Application**, **Manager** (one; catalog_manager or catalog_admin), **Editors** (catalog_editor), **Active**, **Enable Wish List**, **Description**, **Background Color**, **Desktop image**, **'Catalog Home' page**, **'Continue Shopping' page**. Related list **Catalog Items** lists its items.
- Users get read access through an ACL on `sc_catalog`.
- An item can be in several catalogs and categories (**Catalogs** and **Categories** related lists or fields on the item; related lists override the fields). Sharing a Password Reset item across team catalogs is the classic example.
- If the default catalog is made inactive, also deactivate the **Catalog** module, or users still reach it.
- Module URL to one catalog and view: `catalog_home.do?sysparm_catalog=<sc_catalog sys_id>&sysparm_catalog_view=<sys_portal_page view>`. A missing or invalid view falls back to the Catalog Portal Page default; set both for performance.
- Searches return only items from the catalog being viewed.

## Categories

- **Catalog Definition > Maintain Categories**: **Title**, **Application**, **Catalog**, **Active**, **Location**, **Parent**, **Description**, **Icon** (as subcategory), **Header icon** (top level), **Desktop image** (only if the renderer uses it), Classic Mobile image and render type, **Hide description**.
- A category with no active item anywhere below it is not shown and cannot be added. Visibility is by user criteria, which do not cascade to items ([[User Criteria and Catalog Access]]).
- **Dynamic categories** (**Maintain Dynamic Categories**): **Type** *Requested items* or *KB Articles*, **Search how long?** (e.g. `7 00:00:00` for the last 7 days), **Number of Entries**; shown on the right of the home page; limited to the current catalog. The portal **Popular Items** widget uses the *Top Requests* dynamic category.

## Content items

**Catalog Definition > Content Items** (`sc_cat_item_content`): **Content type** *KB Article*, *Catalog Content* (HTML block) or *External Content* (URL); **Target** *Within Catalog* (iframe; some sites will not render; HTTP inside HTTPS gives mixed-content warnings) or *New Window/Tab*; **Meta**, **Hide on Service Portal**.

## Item extras

- **Related Articles** and **Related Catalog Items** related lists (admin, catalog_admin or catalog_editor): shown in Service Portal and Now Mobile. Not for order guides; not usable as related items: wizard launchers, content items, standard change templates, Admin Home catalog items.
- **Ordered Item Links** (**Catalog Definition > Ordered Item Links**): a reusable link on the ordered-item screen, rendered with `?req_item=<RITM sys_id>`; set on the item's **Ordered Item Link** field. Not in Classic Mobile or Service Portal for guides.
- **Copy** (UI action) duplicates details, attachments, variables, client scripts and approvals (Insert copies only the details); a copy of an active item is active. `glide.sc.item.copy.include_relationship` lists more tables (comma separated, no spaces) to copy.
- Description editor accessibility checker: properties `glide.ui.html.editor.toolbar` = `a11ycheck` and `glide.ui.html.editor.enabled_plugins` = `a11ychecker`.
- **Service Catalog Overview** dashboard (catalog_admin): requests by channel (12 months), item diagnostic scores, VA render types, fulfilment automation coverage (item field **Fulfillment automation level**), translation coverage.

## Core UI home page (Self-Service > Service Catalog)

- Add, arrange and remove categories with the **+** (add content) icon on **Service Catalog > Catalog**; on **Catalogs** for the multi-catalog home page. Add a **Request for** block there too.
- **Renderers** (**Catalog Definition > Renderers**, a UI macro each): catalog renderers *All Details*, *Image Only*, *Title and Image*, *Title Only*; category renderers *Category Items*, *Category Items No Title*, *Category Details*.
- Properties: `glide.sc.max_items` (5 items or categories per section), `glide.sc.auto_expand` (2 items expanded), `glide.sc.cat_view_use_popup_for_details` (hover pop-up instead of Preview), `glide.sc.use_sub_cat_section` (subcategories in a bottom panel or a top list), `glide.sc.show_additional_cats` ("Exists in categories" section; one page spells it `glide.sc.show_additional.cats`), `glide.sc.homepage.show.collapse`, `glide.sc.home.filter`, `com.glide.servicecatalog.view_includes_category_descriptions`.
- Homepages are replaced by dashboards in Next Experience (existing ones viewable by direct URL on upgraded instances).
- New instances use the Angular catalog experience (plugin `com.glideapp.servicecatalog.ui16_portal`, active by default; install it on upgraded instances). Items then behave as in Service Portal, including client scripts and UI policies.

## Search

- Restrict who can search: `glide.sc.can_search` (blank = all; `None` removes search). Items in inactive categories: `glide.sc.search.disabled_cats` (default true = returned). No search field for some classes: `glide.sc.item.cannot_show_search`. Suggestions ("Did you mean?"): `glide.sc.search.suggestions`. Others: `glide.sc.search.allow_empty_search` (heavy), `glide.sc.search.exclude_catalogs`, `glide.sc.search.rowcount`, `glide.sc.show_listing_breadcrumbs`, `glide.sc.use_breadcrumb_links.cms`.
- Keyword ranking: item **Name**, then **Meta**, then **Description** / **Short description**, then category name or description, then catalog name or description and item class. Only active items with a valid catalog and category that the user can see are returned. **Meta** feeds Zing (and AI Search keyword search); without Meta, Zing uses names and descriptions.
- If results look stale: **System Definition > Text Indexes**, open the index for `sys_metadata`, **Regenerate Text Index**; enable **Suggest alternate search spellings** under **System Properties > Text Search**. See [[Zing Text Search and Global Search]].
- AI Search in Service Portal and Now Mobile: **AI Search > Search Experience > Search Applications** > the portal's search application > search profile (make your own) > search source **Service Portal Catalogs** > **Conditions** listing the searchable catalogs (independent of the portal's catalogs). Facets show the item's primary category even if reached through another. See [[AI Search Overview]].

## Legacy: CMS and Classic Mobile

- CMS (use Service Portal for new work): catalogs linked to CMS sites (`sc_catalog_site`, properties `glide.sc.home.cms_page`, `glide.sc.search.cms_page`, `glide.sc.continue.shopping.target`) and to portal pages (`sc_catalog_view_mtom`, default page `catalog_default`). A catalog without a portal page record falls back to view `catalog_<catalog name>`, which looks blank; add a page record (Catalog: Service Catalog, Portal Page: Catalog (`catalog_default`), Default: true).
- Classic Mobile was withdrawn in September 2022; its layout module, description limit (`glide.sc.mobile.limit.description`) and picture fields remain on forms. It never supported order guides, wizards or content items.

## Related

- [[Service Catalog Overview, Item Types and Roles]] · [[Service Catalog in Employee Center, Service Portal and Mobile]] · [[Service Catalog Properties Reference]]
