---
type: concept
tags: [concept, fields, platform, glide-api, reporting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Currency administration" (pp. 2122-2153), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Currency and price fields

**In one line:** a currency value is never one number: the platform keeps the amount **as entered** with its currency code and a copy converted to a **reference currency**, and shows users a third thing, the amount in their **session currency**; filters and totals use the reference copy, which is why they can look wrong.

## Standard currency fields

Three stored pieces per value: amount as entered, three-letter ISO code, amount in the reference currency (converted at the rate of the moment it was saved).

| Term | Decided by |
|---|---|
| **Reference currency** | system locale `glide.system.locale` (format `language.COUNTRY`), else Java default (`en.US`) |
| **Session currency** | single-currency mode if on, else the user's locale (user record country/language, then system locale, then browser) |

- **Set the system locale once, on a fresh instance. Do not change it after currency values exist**: stored reference values are not re-converted, so totals and filters become wrong.
- Rates: table `fx_rate` (**System Localization > Exchange Rates**), each row currency to euro, refreshed daily from the European Central Bank by the scheduled job *Update Currency Conversion Rates*. To use your own rates, deactivate the job and maintain the table (keep the older jobs *ECB Exchange Rate Load* and *Retrieve System Rates* off).

### Why lists and reports confuse people

- Lists show session currency; **sorting, filtering and aggregation use the reference value**, converted at different days' rates. A filter for 100 can match a record showing 99.
- A report shows values in the session currency of whoever runs it.
- Number format follows the user's locale, not the currency.
- In lists a globe icon cycles between as-entered, session and reference values.

### Single-currency mode

`glide.i18n.single_currency` = true and `glide.i18n.single_currency.code` = the ISO code (after setting the system locale to match). Everyone sees one currency; number formatting still follows locale; price fields lose their options.

### Price fields

A price field is a currency field with a per-value **Type**: **Calculated** (default: like currency, shown in session currency), **Fixed** (always shown in the currency entered), **Multiple** (one price per enabled currency; only the first is used in calculations).

### Other properties

`glide.currency_price.use_all_fraction_digits` (four decimals instead of two), `glide.sys.audit_currency_value` (audit stores `USD;1234.56`), `glide.currency_price_optimizer.enabled` (faster lists), `glide.excel.convert_to_user_currency`, `glide.excel.fixed_currency_usd`, `glide.csv.use_row_currency`.

### In scripts

```javascript
var rate = parseFloat(current.base_rate);               // number, session currency
var code = current.base_rate.getCurrencyCode();         // as entered, e.g. JPY
current.total_cost.setValue(code + ';' + (rate * 2));   // code;amount
```

| Method | Returns (example: entered JPY 21345.67, session EUR, reference USD) |
|---|---|
| `getValue()`, `getSessionValue()` | `1563.72` (session, unformatted) |
| `getReferenceValue()` | `1152.48` |
| `getCurrencyValue()` | `21345.67` (as entered) |
| `getDisplayValue()` | formatted session value with symbol |
| `getCurrencyCode()` / `getSessionCurrencyCode()` / `getReferenceCurrencyCode()` | `JPY` / `EUR` / `USD` |
| `getCurrencyString()` | `JPY;21345.67` |

- Never strip formatting from `getDisplayValue()` to calculate.
- `GlideAggregate` on currency works on reference values.
- **Do not use `deleteMultiple()` on tables with currency fields**; delete record by record so the linked currency records go too.
- Import: `setDisplayValue()` takes a locale-formatted number (session currency) or `EUR;1.234,56`.
- The backing table `fx_currency_instance` is maintained by the platform; do not edit it.

## FX Currency fields

A separate, newer field type (**FX Currency**, active by default) for genuinely multi-currency data. Independent of standard currency fields; **a standard field cannot be converted to FX**.

- The field is a reference (length 32, do not change) to a row in `fx_currency2_instance` holding **Amount**, **Currency code**, **Conversion rate**, **Reference amount**, **Reference currency code**. These are dot-walkable (`cost.amount`, `cost.currency`).
- The reference amount is calculated once, on insert or update, before business rules, and **not recalculated** later.
- Rates: `fx_system_rate` (ECB, daily, euro to currency) or a **custom rate table** extending `fx_conversion_rate` (**From currency**, **To currency**, **Span start/end**, **Order**, **Rate**).
- Per-field settings in **System Localization > FX Currency Configuration**: display digits, display value (as entered, session, reference), aggregation source (as entered or reference), reference currency and its source, rate table, **Conversion date source** (for example a transaction date field instead of "now"), rate filter.
- Global defaults: `glide.currency2.display_digits`, `glide.currency2.display_value` (`as_entered`), `glide.currency2.system_rate_table`, `glide.currency2.default_reference_currency`.
- **List filters match the currency as entered**: filtering on USD does not return a value entered in EUR.
- Aggregates return `USD;1234.56`; with mixed currencies and aggregation on as-entered values, the result is empty.
- Audit string: `EUR;111.222;<sys_id of the rate>`.
- Roles: `currency_admin`, `currency_instance_admin`.

## Related

- [[Field Types Reference]] · [[Languages, Translation Tables and Locale]] · [[Exporting Data]]
