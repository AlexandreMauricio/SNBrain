---
type: concept
tags: [concept, data-management, platform, roles]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Exporting data" (pp. 653-656, 664-667), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Exporting data

**In one line:** records can be exported from a form, a list, a URL, a web service or an export set, in CSV, Excel, XML, JSON, PDF or Google Sheets; the format decides whether you get labels or names, display values or raw values.

## Ways to export

| From | Formats | How |
|---|---|---|
| A record | PDF, XML | form **Additional actions** menu, **Export** |
| A list | Excel, CSV, XML, JSON, PDF, Google Sheets, Export Set | right-click a column header, **Export**, then **Download** |
| A URL | CSV, XLS, XLSX, JSON, XML | [[Export Data with a URL]] |
| Web services (REST, SOAP) | | external application pulls the data |
| Export set | file pushed to an external location | `export_set_admin` or admin |

## Who can use what

- PDF, Excel, CSV, JSON, Google Sheets: all users.
- **XML: admin only.**
- Export Set: `export_set_admin` or admin.

## What each format contains

| Format | Fields exported | Header | Values (default) |
|---|---|---|---|
| CSV | fields shown in the list or form view; dot-walked fields get their full name (`u_assignment_group.parent`) | field name | display value (raw if `glide.export.csv.raw.value`) |
| Excel | fields shown in the view | label | display value |
| PDF | fields shown in the view (including fields hidden by UI policies or client scripts) | label | display value |
| JSON | every column | field name | raw value |
| XML | **every column, whatever the view** | field name | raw value |

Display versus raw, by field type:

| Field type | Display value | Raw value |
|---|---|---|
| Reference | display value of the referenced record | its sys_id |
| Choice | label | value |
| Date/time | user time zone and format | UTC, system format |
| Currency, price | value with symbol | USD value without symbol |

Controls for this are in [[Export Limits and Properties]].

## Things that surprise

- **A list export can differ from what the user sees.** It runs in a background thread without the user's session data, so ACLs that depend on the session behave differently.
- CSV is encoded in **Windows-1252** by default. For translated data set `glide.export.csv.charset` to UTF-8.
- XML does not keep image field data. The URL XML processor also omits attachments and journal fields; the list **Export > XML** includes journals.
- A form PDF is only produced for a saved record; an unsaved form gives an empty page.
- PDF prints left to right and can render right-to-left languages wrongly.
- An embedded list is exported by exporting its parent record.
- Excel currency cells use Accounting formatting. `glide.excel.fixed_currency_usd` exports everything in US dollars; `glide.excel.convert_to_user_currency` in the session currency; the first wins if both are true. Rates come from Exchange Rates (`fx_rate`).

## Related

- [[Export and Import Records as XML]] · [[Set Up Export to Google Sheets]] · [[Export Limits and Properties]]
