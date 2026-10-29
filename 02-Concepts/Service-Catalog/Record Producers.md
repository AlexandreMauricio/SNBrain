---
type: concept
tags: [concept, service-catalog, scripting]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Record Producer", "Create a record producer", "Create record producers from tables", "Populate record producer data and redirect users", "Variables to collect data for record producer fields", "Record Producer form", "Service Catalog variable editors", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_RecordProducer.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Record producers

**In one line:** a record producer (`sc_cat_item_producer`) is a catalog item whose form creates a record in another table, for example an incident or HR case, instead of a Requested Item.

## How it works

- Looks like a catalog item to the user, but on submit it inserts a record into its **Table name**. The link from producer to created record is kept in Item Produced Record (`sc_item_produced_record`).
- Target: tables and database views **in the same scope** as the producer, or tables in another scope that allow create from other applications.
- Use it only for **task-based** records. Do **not** create `sc_request`, `sc_req_item` or `sc_task` records with a producer: use a catalog item so the standard request process (flows, approvals) runs. Same rule in [[Request Management Data Model and Process]].
- Navigation: **All > Service Catalog > Catalog Definition > Record Producers**. The Variables, Variable Sets, Categories and Catalogs related lists appear after the first save.

## Ways to fill the new record

1. **Variable named like the field**: a variable `caller_id` fills `caller_id`. On the variable form, **Map to field** and **Field** do the same mapping explicitly. Use the variable type matching the field type (table below).
2. **Template** (Generated Record Data > **Template**): static values for every record.
3. **Script** (server-side, runs before insert): `current.<field>` is the record being created, `producer.<variable>` is what the user entered, `RP.getParameterValue('<param>')` reads URL parameters (RP = Render Properties, not Record Producer). `RP.getParameterValue('sysparm_id')` gives the producer's sys_id.
4. **Post insert script**: runs on the record after insert and overrides values set by the template or earlier mapping.

Do not call `current.update()`, `current.setAbortAction()` or change `current.sys_class_name` in the producer script. If the script aborts creation, no `sc_item_produced_record` row is written.

### Variable type per field type

| Field type | Variable type |
|---|---|
| True/False | Yes/No |
| Reference | Reference |
| Date, Due Date | Date |
| Date/Time | Date/Time |
| Choice (or field with a choice list) | Select Box |
| Email, URL, HTML | Email, URL, HTML |
| List, UI Action List | List Collector |
| String longer than 256 | Multi-Line Text |
| String, Integer, Decimal, Floating Point | Single-Line Text |
| File Attachment | Attachment |
| anything else | Multi-Line Text |

Returned values in scripts are strings, except a Reference (sys_id) and a List (comma-separated sys_ids: `producer.field.split(',')`). Pass a date to `new GlideDateTime(producer.date_field)`.

Encrypted targets: a variable mapped to an encrypted field is **not** stored in Question Answer (`question_answer`), so it does not show in the variable editor. A masked and encrypted variable mapped to an encrypted field copies the decrypted value into the target.

## Redirect after submit

- In the script: `producer.redirect = "home.do";` (Core UI) or `producer.portal_redirect = "sp?id=sc_home";` (Service Portal).
- Form field **Redirect To**: *Generated Task record* or *Catalog Homepage*; default from property `glide.sc.producer.redirect_url`.

## Create from a table

**System Definition > Tables**, open the table, related link **Add to Service Catalog**: give Name, Short Description, Category, pick fields (and `|- container start -|` / `|- container end -|`). Each chosen field becomes a variable with Name = column name, Question = column label, Order 100, 200..., and question choices copied for choice fields. The producer appears in the table's Record Producers related list. With a workflow, set the condition to *Run the workflow*.

## Where the answers live afterwards

The created record shows the answers through the **default variable editor** (formatter `com_glideapp_questionset_default_question_editor`), reading Question Answer (`question_answer`). It is on Incident and Change by default; add the formatter to other task-extended tables. Catalog client scripts and UI policies reach it with **Applies on the Target Record**. See [[Catalog Client Scripts, UI Policies and Variable Editors]].

## Discrepancy

- [[Create an Incident Record Producer]] (Australia ITSM guide) links a producer to its parent incident with `RP.getParameterValue('sysparm_req_parent')`; this chapter (Brazil) uses `sysparm_parent_sys_id` and `sysparm_parent_table` for requests created from another record. Possibly two mechanisms; unconfirmed. See [[Delegated Requests and Requests from Other Records]].

## Related

- [[Service Catalog Overview, Item Types and Roles]] · [[Catalog Item, Record Producer and Order Guide Forms]] · [[Catalog Variables and Variable Types]] · [[Service Catalog Wizards]] (wizards are built on record producers)
