---
type: reference
tags: [reference, data-management, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Exporting data", topic "Data export reference" (pp. 665-673), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Export limits and properties

Navigation: **System Properties > Import Export** for the limit properties; others are added in System Properties (`sys_properties`). Concepts: [[Exporting Data]]. Grouped and paraphrased.

## How the row limit is decided

1. The format-specific limit property, if set.
2. Otherwise the general limit `glide.ui.export.limit`, if set.
3. Otherwise the default limit.

`sysparm_record_count` in a URL asks for a number of rows but cannot exceed the limit in force.

| Format | Format-specific property | Default |
|---|---|---|
| XML | `glide.xml.export.limit` | 10,000 rows |
| CSV | `glide.csv.export.limit` | 10,000 rows |
| Excel XLSX | `glide.xlsx.export.limit` | 10,000 rows |
| Excel XLS | `glide.excel.export.limit` | 10,000 rows |
| JSON | `glide.json.export.limit` | 10,000 rows |
| Excel XLSX cells | `glide.xlsx.max_cells` | 500,000 cells |
| Excel XLS cells | `glide.excel.max_cells` | 500,000 cells |
| PDF rows | `glide.pdf.max_rows` | 1,000 (allowed 0 to 5,000; a higher value falls back to 1,000) |
| PDF detail pages | `glide.pdf.max_detail_pages` | 250 (maximum 250) |
| PDF columns | `glide.pdf.max_columns` | 25 (only 25 header labels fit a page) |

- Over 500,000 cells, an Excel export stops and the last row reads "Export stopped due to excessive size. Use CSV for a complete export." Raising the cell limit risks memory problems. Excel puts 32,000 rows per sheet.
- `glide.ui.export.warn.threshold`: above this many rows the user chooses between waiting and receiving the file by email (subject to email size limits).
- Raising limits above the defaults can hurt performance; the guide prefers splitting the export ([[Export Data with a URL]]).

## Display value and header properties

Apply to URL exports, list exports and export sets, unless a URL parameter overrides them.

| Format | Property | Default |
|---|---|---|
| CSV | `glide.export.csv.raw.value` | false (display value; also crops strings to 32,000 characters) |
| CSV | `glide.export.csv.column_header_label` | false (field names) |
| Excel | `glide.export.excel.display_value` | true |
| Excel | `glide.export.excel.column_header_label` | true (labels) |
| XLSX | `glide.export.xlsx.display_value` | true |
| XLSX | `glide.export.xlsx.column_header_label` | true |
| JSON | `glide.json.return_displayValue` | false (raw) |

## URL parameters that override them

| Parameter | Effect |
|---|---|
| `sysparm_display_value` | `true` display value, `false` raw; for CSV, XLS, XLSX, XML |
| `displayvalue` | JSON only: `true`, `false` or `All` (both) |
| `sysparm_export_column_header_label` | `true` labels, `false` names; for CSV, XLS, XLSX |

## Other properties

| Property | Effect |
|---|---|
| `glide.export.csv.charset` | CSV encoding (default Windows-1252; set UTF-8 for translated data) |
| `glide.csv.export.line_break` | how line breaks appear in CSV |
| `glide.excel.use_user_date_format` | dates in Excel use the user's format instead of the system format |
| `glide.excel.fixed_currency_usd`, `glide.excel.convert_to_user_currency` | currency conversion in Excel |
| `glide.export.debug` | logs export processing ("Export API" lines: query time, write time). Turn off after debugging |
| `glide.oauth.export.to.sheets.alias` | sys_id of the connection alias for Google Sheets export |

## Related

- [[Exporting Data]]
