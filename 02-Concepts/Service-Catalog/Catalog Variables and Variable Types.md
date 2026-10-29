---
type: concept
tags: [concept, service-catalog, fields]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Reference, topics "Service catalog variables", "Types of service catalog variables" (and one page per type), "Variable support in various channels", "Create a service catalog variable", "Define help information", "Service Catalog variable attributes", "Define a question choice for a variable", "Audit service catalog variables", "Prefilling variable values on the catalog item form", "Configure a default width", "Define a regular expression for a variable", "Pass variables between tasks", "Using variables for price setup", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_ServiceCatalogVariables.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Catalog variables and variable types

**In one line:** variables (also called questions, table `item_option_new`) are the fields of a catalog item form; their answers travel with the RITM or produced record and can be shown, edited and used by fulfilment.

## Where answers are stored

- Catalog items: Options (`sc_item_option`) linked to the RITM through Variable Ownership (`sc_item_option_mtom`), shown by the VEditor.
- Record producers: Question Answer (`question_answer`), shown by the default variable editor.
- MRVS rows: Multi Row Question Answer (`sc_multi_row_question_answer`).
All internal: no business rules on them. See [[Catalog Client Scripts, UI Policies and Variable Editors]].

## Types

| Type | Notes |
|---|---|
| Attachment | upload one file per question; attributes `max_file_size` (MB, integer) and `allowed_extensions`; capped by `glide.sc.variable.attachment.default_max_size` (default 20) and the platform `com.glide.attachment.max_size`. Not in MRVS; no item variable assignment in guides; antivirus scan on submit / add to cart if enabled |
| Break | horizontal line, no data |
| Check box | consecutive check boxes form a group (label it with a Label variable placed first, else "Options"); one mandatory box makes the group mandatory; **Selection Required** forces ticking (e.g. "I agree"); can carry price |
| Container start / split / end | layout box, 1-3 columns, can nest and sit inside variable sets; not on mobile; Service Portal max two columns at top level |
| Date, Date/Time, Duration | Date/Time stored in GMT, shown in user time zone; Duration default and `g_form` values as `DD HH:MM:SS`, attribute `max_unit` |
| Email | validated address |
| HTML | formatted input or read-only content (e.g. terms); not shown in cart or approval summaries |
| IP Address | IPv4/IPv6, validation script type |
| Label | text across the form, no data, cannot be mandatory |
| List collector | pick several records from **List table**; max 100 shown; attribute `glide_list` (glide list instead of slushbucket), `no_filter`; refresh with `g_form.refreshSlushbucket()` |
| Lookup multiple choice / Lookup select box | radio buttons / drop-down from a table (**Lookup from table**, **Lookup value field**, **Lookup label field(s)**, optional price fields) or, with **Lookup source** = *Choices*, from `sys_choice` (**Choice table**, **Choice field**, **Choices depend on** another question). Max 10,000 choices |
| Custom, Custom with label | UI macro (phase one Jelly only); in Service Portal through a linked widget |
| Masked | shows asterisks; **Use encryption** (default true) stores it encrypted; read with `variables.<name>.getDecryptedValue()`; **Use confirmation** asks twice; fulfillers need `catalog_view_masked` to reveal |
| Multi-line text, Single-line text, Wide single-line text | `max_length` attribute; single-line types take a **Validation Regex** |
| Multiple choice | radio buttons from question choices |
| Numeric scale | Likert-style radio buttons, **Scale min/max** |
| Reference | stores a sys_id; use `getDisplayValue()` in scripts; attributes `ref_ac_columns`, `ref_ac_order_by`, `ref_auto_completer` |
| Requested For | who the request is for; one per item; not in MRVS; see [[Delegated Requests and Requests from Other Records]] |
| Rich Text Label | formatted label; only `g_form.setVisible()` works on it; not in summaries, MRVS, conditions or reports |
| Select box | drop-down of question choices; `is_searchable_choice` (Core UI only) |
| UI page | inserts a UI page; not in Service Portal or mobile |
| URL | HTTP, HTTPS, FTP validated; not editable in Now Mobile |
| Yes/No | Yes and No choices |

Channel support (Core UI, Service Portal, Now Mobile, LLM and NLU Virtual Agent, workspace variable editor) is nearly universal; exceptions: UI Page only in Core UI; Custom types not in the NLU agent or workspace editor; Duration, HTML, List collector, Masked not in the NLU agent; price-affecting choices lose their pricing in conversations.

## Variable form (main fields)

- **Question** (label) and **Name** (internal; auto-filled from the question when empty). **A variable without a name cannot be used in scripts, UI policies or audit.** Two variables with the same name collide silently.
- **Order**, **Mandatory** (on load only), **Read only**, **Hidden**, **Active**.
- **Global**: available on every catalog task of the fulfilment; otherwise attach it to specific tasks (needed to pass data between tasks of different groups). Not allowed in MRVS.
- **Annotation**: **Show help**, **Help tag**, **Help text** (plain), **Instructions** (rich), **Always Expanded** (overridden by the item's **Expand help for all questions**); **Tooltip**, **Example text**.
- **Type Specifications**: type-specific fields, **Variable width** (25-100 percent, overrides **Catalog Variables > Variable Default Size**; not in Service Portal or Now Mobile), **Variable attributes** (comma separated; semicolon between values; show them with UI policy *Show attributes when Type is One of Certain Values*), reference qualifiers (scripts there restricted to admins), **Unique** (MRVS only).
- **Default Value** (can be scripted).
- **Permission**: **Read roles**, **Write roles** (edit in the variable editor after ordering), **Create roles** (answer before ordering). Empty means everyone with access to the item.
- **Availability**: **Visible Elsewhere**, **Visible on Bundles**, **Visible on Guides**, **Visible on Summaries**, **Remove from Conversational Interfaces**.
- **Disable initial slot fill**: opt out of pre-fill from the requester's search text.
- **Map to field** / **Field**: record producers only.

## Question choices

Related list **Question Choices**: **Text** (shown), **Value** (stored), **Order**, **Price**, **Recurring price**, **Inactive**. Changing choices affects existing RITMs; a deleted choice still shows its value on old RITMs.

## Validation regex

**Catalog Variables > Variable Validation Regex**: write the pattern without slashes or inline flags (`/.../i` is invalid), use the **Regex Flag** list (None, Case Insensitive, Both for Unicode-aware). Avoid catastrophic backtracking. Items with regex errors cannot be added to the wish list.

## Pricing with variables

Check box (**Price if checked**, **Recurring price if checked**, pricing models Calculated / Fixed / Multiple per currency), multiple choice and select box (choice **Price** / **Recurring Price**), reference and list collector (**Pricing implications**: uses a `price`, `u_price`, `recurring_price` or `u_recurring_price` field on the referenced record), lookup select box (**Lookup price field**). See [[Catalog Pricing]].

## Audit

`glide.sc.audit.variables` (on by default): changes show in RITM and catalog task history, prefixed `VARIABLE:`. Unnamed variables are not audited.

## Prefill from the URL or a component

`/sp?id=sc_cat_item&sys_id=<item>&sysparm_variable_values={"<name>":"<value>"}` (reference values as sys_ids). Next Experience: property **variableValues** on the catalog item component in UI Builder; Virtual Agent inline items: same property as a JSON string. Prefilled values behave like typed ones (UI policies and client scripts react). Not for Custom, labels, containers or MRVS. Turn off with `glide.sc.enable_url_prefill` = false or the widget option **Disable URL prefill**.

## Related

- [[item_option_new]] · [[Variable Sets and Multi-Row Variable Sets]] · [[Scripting with Catalog Variables]] · [[Create a Catalog Item with Variables]]
