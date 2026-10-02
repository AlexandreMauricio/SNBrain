---
type: reference
tags: [reference, fields, schema, workspace]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topics "Field types reference", "Database field type", "Dictionary entry data types", "Document ID field", "Condition field types", "Geo point field type" (pp. 875-888, 899-902, 911-912), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Field types reference

The field type is the **Type** of the dictionary entry ([[Dictionary Entry Form]]). The first column is the internal type name (what `sys_dictionary` stores), the second the name shown in the UI. Only types with a description in the guide are listed in detail. Concepts: [[Field Administration]].

## Text

| Type | UI name | Notes |
|---|---|---|
| `string` | String | up to 255 characters = single-line box, 256 or more = multi-line. Oracle: no more than 4000 from the UI |
| `string_full_utf8` | String (Full UTF-8) | full UTF-8, supports emoji |
| `multi_small` | Multi Small | text area for short texts |
| `html` | HTML | rich text editor ([[HTML Field Editor]]) |
| `translated_text`, `translated_html` | Translated Text / HTML | shows the translation for the user's language |
| `wiki_text` | Wiki | wiki markup editor |
| `url` | URL | clickable when locked; can require HTTPS. Max length hidden by default; browsers support about 2,083 characters |
| `email`, `ph_number`, `phone_number_e164` | Email, Phone Number, Phone number (E164) | E164 type validates and formats |
| `ip_address` | IP address | IPv4 and IPv6 |
| `journal` | Journal | accepts entries and shows earlier ones with user and time |
| `journal_input` | Journal Input | accepts entries, does not show earlier ones |
| `journal_list` | Journal List | displays the journal fields it depends on, chronologically |
| `password` | Password (1 Way Encrypted) | stored as a hash, cannot be decrypted |
| `password2` | Password (2 Way Encrypted) | can be decrypted in the instance; length at least 255 |
| `name_values`, `simple_name_values` | Name-Value Pairs | unique names mapped to values, e.g. HTTP headers |
| `script`, `script_plain` | Script, Script (Plain) | JavaScript editor with syntax checking; `script` needs a dependent table field to list fields |
| `condition_string` | Condition String | a JavaScript condition, syntax-checked on update |
| `conditions` | Conditions | a condition builder; needs a dependent field naming the table |
| `email_script`, `html_script` | Email Script, HTML script | text or HTML with `${fieldname}` variables and a variable picker |

## Numbers, dates and choices

| Type | UI name | Notes |
|---|---|---|
| `integer` | Integer | whole number. Search with `=100` |
| `long`, `longint` | Long, Longint | large whole numbers |
| `decimal` | Decimal | two decimal places (attribute `scale` changes it) |
| `float` | Floating Point Number | scale 7; max length not below 7 |
| `currency` | Currency | decimal with four digits after the point plus a currency selector. Cannot later become FX Currency |
| `currency2` | FX Currency | |
| `price` | Price | currency with control over conversion and display |
| `percent_complete` | Percent Complete | decimal shown as a bar in lists |
| `boolean` | True/False | check box |
| `choice` | Choice | [[Choice Lists]] |
| `radio` | Radio | one choice as radio buttons; horizontal or vertical since Zurich |
| `glide_date_time` | Date/Time | stored in UTC |
| `glide_date`, `glide_time`, `glide_duration` | Date, Time, Duration | |
| `date` | Other date | date and time kept exactly as entered, **no UTC conversion** |
| `due_date` | Due Date | date and time |
| `time` | Time | stored with the date 1970-01-01, so **not adjusted for daylight saving** |
| `integer_time` | Integer time | six digits `160432`, no time zone handling |
| `timer` | Timer | |
| `order_index` | Order Index | display order |

## References and structure

| Type | UI name | Notes |
|---|---|---|
| `reference` | Reference | one record of another table |
| `glide_list` | List | several records of another table |
| `document_id` | Document ID | a record on **any** table; depends on a field holding the table name |
| `table_name` | Table Name | pick a table (only the current scope's tables in a scoped app) |
| `field_name` | Field Name | pick a field of the table chosen in a Table Name field; must depend on it |
| `sys_class_name` | System Class Name | the record's table |
| `GUID` | Sys ID (GUID) | |
| `collection` | Collection | the dictionary entry that represents the table itself; one per table |
| `domain_id`, `domain_path` | Domain ID, Domain Path | domain separation |
| `related_tags` | Related Tags | tags on the record, read-only in the field |
| `workflow` | Workflow | a workflow stage |
| `geo_point` | Geo Point | longitude, latitude (6 decimals; ranges -180..180 and -90..90) |
| `file_attachment` | File Attachment | exactly one file of any type |
| `image`, `user_image`, `audio`, `video` | Image, Audio, Video | media (`audio`: mp3 or ogg) |
| `compressed` | Compressed | large binary data stored compressed |
| `data_structure` | Data Structure | String, Boolean, Integer, Decimal, Object or Array values |
| `color`, `icon` | Color, Icon | CSS colour with preview; icon picker |
| Dynamic Attribute Store | | [[Dynamic Schema]] |
| Address (Simple) | | address suggestions from an external API; needs `glide.ui.address.suggestions.api.host.url` and `glide.ui.address.suggestions.api.host.apikey.encrypted` |

**Not supported in configurable workspaces** (per the guide): audio, video, image, color, icon, compressed, geo_point, journal, journal_list, time, name_values, data_structure, collection, among other internal types. Most everyday types are supported.

## Database mapping (MySQL)

| Field | Dictionary type | Database type |
|---|---|---|
| String up to 40 | `string` | VARCHAR(40) |
| String 41 to 255 | `string` | VARCHAR(n) |
| String 256 and more | `string` | MEDIUMTEXT |
| Choice, Suggestion | `string` | VARCHAR(40) |
| Integer | `integer` | Integer |
| Decimal | `decimal` | Decimal(15,2) (older instances 12,2) |
| True/False | `boolean` | TINYINT(1) |
| Date | `glide_date` | DATE |
| Date/Time, Time, Duration, Due date | `glide_date_time`, `glide_time`, `glide_duration`, `due_date` | DATETIME |
| Reference | `reference` | VARCHAR(32) |
| List, Journal, URL | `glide_list`, `journal`, `url` | MEDIUMTEXT |
| Image | `user_image` | VARCHAR(40) |

## When a type can be changed

| Situation | Allowed |
|---|---|
| Field empty in every record | any change |
| Field has data | only between types with the same physical type (duration to date/time: both DATETIME) |
| String to another string type | if nothing would be truncated |
| String to GUID | only if every value is already a sys_id |
| GUID to string | always |

Otherwise use the copy approach in [[Field Administration]].

## Document ID field: setup

1. Add a String field for the table name (e.g. *Model table*) and a **Document ID** field (e.g. *Model ID*).
2. In the Document ID field's dictionary entry (Advanced view), set **Dependent** to the table-name column (e.g. `u_model_table`).
3. Optionally add the attribute `show_all_tables` to allow system tables.

The lookup then asks for the table and the record; the sys_id goes in the Document ID field and the table name in the other.

## Notes on specific types

- **Name-value pairs in scripts**: `gr.nv_field.name1 = "value1";` adds a mapping; read with `gr.nv_field.name1`; iterate with `for (var name in gr.nv_field)`; the field prints as JSON.
- **IP address** (`ip_addr`, *IP Address (Validated IPV4, IPV6)*): VARCHAR(40). IPv6 is stored in canonical form (`1507:f0d0:1002:51::4`) unless the attribute `ip_data_control` says otherwise (`canonical`, `canonicalize_when_possible` default, `expanded`, `none`).
- **Image**: gif, jpg or png; displayed at up to 250 pixels.
- **Percent complete**: attribute `target_field=<decimal field>` compares with a target; `target_threshold_colors=0:tomato;50:khaki;90:lightgreen` colours by percent of target (without a target field, 100 is assumed). Example: target 65, value 59 is 90.7% of target, so lightgreen.
- **Suggestion**: any string field with dictionary **Choice** = Suggestion offers suggested text, maintained with **Configure Choices** (**Apply to Table** decides whether a parent table's children share them).
- **Wiki** (`wiki_text`): `= Header =`, `'''bold'''`, `''italic''`, `*` bullets, `:` indent, `{| class="wikitable" ... |}` tables, `<nowiki>`, `[http://url text]`, and an image name in double square brackets prefixed with `Image:`. With **Dependent** set to a field such as `number`, a record number in double square brackets links to that record.
- **E.164 phone numbers**: [[E164 Phone Number Fields]]. **Journal**: [[Journal Fields]]. **Reference**: [[Reference Fields]].

## Condition field options

- `show_condition_count=true` shows how many records match.
- `condition_builder=v2` switches a Conditions field to condition builder v2 in Core UI.

## Related

- [[Function Fields]] · [[Choice Lists]] · [[Dictionary Attributes Reference]]
