---
type: concept
tags: [concept, service-catalog, scripting, script-include]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Using variables for price setup", "Set a recurring price", "Extend the pricing model", "Hiding prices in the service catalog", "Catalog Item form", "Service Catalog properties", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_ServiceCatalogVariablePricing.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Catalog pricing

**In one line:** an item has a **Price** and optional **Recurring Price** with a **Recurring Price Frequency**; answers to some variables add to them; display can be hidden per item, per item class or globally.

## Base price

On the item's **Pricing** tab: **Price** (with currency), **Recurring Price**, **Recurring Price Frequency** (for example Monthly), **Omit Price in Cart**. Recurring prices show in the catalog, search, item page, cart and summary; the cart groups items by frequency; a request lists them in the **Recurring Prices** related list.

## Variables that change the price

| Variable | How |
|---|---|
| Check box | **Price if checked**, **Recurring price if checked**; pricing models Calculated, Fixed, Multiple, per currency |
| Multiple choice, Select box | **Price** and **Recurring Price** on each question choice |
| Reference, List collector | tick **Pricing implications**; the referenced record's `price`, `u_price`, `recurring_price` or `u_recurring_price` is added (negative values lower it; a list collector adds each selection) |
| Lookup select box, Lookup multiple choice | **Lookup price field**, **Lookup recurring price field** on the lookup table |

`glide.sc.enhance.labels` appends the price to option labels (Core UI and Service Portal). Order guide variables never carry a price. Price-affecting questions make an item non-conversational in Virtual Agent.

## Custom price logic

Set `glide.sc.use_custom_pricegenerator` = true, then edit `calcPrice` in script includes **CatalogPriceCalculator** and **CatalogRecurringPriceCalculator** (server-side, global). Changing base script includes is a customisation (skipped at upgrade).

## Hiding prices

- Per item: **Omit Price in Cart** (price shown as "-" on edit cart, confirmation and status screens).
- Per class: `glide.sc.item.cannot_show_price` (class list; guides, producers and wizard launchers by default).
- Everywhere: `glide.sc.price.display` (zero prices hidden by default; can be *Always show prices* or *Never show prices*; overrides cart layout settings).
- Classic Mobile: **Hide Price (classic mobile listings)**.

## Related

- [[Catalog Variables and Variable Types]] · [[Cart, Checkout and Cart Layouts]] · [[Service Catalog Properties Reference]]
