---
type: concept
tags: [concept, forms-lists, task, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topic "Using formatters" (pp. 760-775), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Formatters

**In one line:** a formatter is a form element that shows something that is not a field of the record, rendered by a UI macro.

## Shipped formatters

| Formatter | Shows |
|---|---|
| **Activity formatter** | the history of the record: comments, work notes, field changes, emails |
| **Process flow formatter** | the stages of a process across the top of the form |
| **Parent breadcrumbs** | the chain of parent tasks |
| **Approval summarizer** | a summary of the record being approved, on the approval form |
| **CI relations formatter** | a toolbar of CI relationships on a CI form |

Formatters are not included in a form's PDF export.

## Activity formatter

- On by default for Task and its children and for Approvals (`sysapproval_approver`). Any **audited** table can have one: **System UI > Formatters > New**, **Formatter** = `activity.xml`, **Type** = Formatter. Only one per form. Add it to the form as **Activities (filtered)**.
- Users only see activity for fields they can read.
- Which fields appear: activity filter icon, **Configure available fields** (also property `glide.ui.incident_activity.fields`, kept in sync).
- In Core UI a field cannot sit between a journal field and the activity formatter.

| Property | Effect |
|---|---|
| `glide.ui.activity.email_roles` | roles that can see emails in the stream. Default `itil`. Empty means everyone sees all emails, including ones quoting work notes |
| `glide.history.max_entries` | entries shown, default 250 |
| `glide.max_activity_size` | bytes of content shown per activity, default 102400 |
| `glide.ui.activity_stream.style.comments` / `.work_notes` | colours; defaults transparent and gold |
| `glide.ui16.emailStreamResponseActions` | true adds an email reply button |
| `glide.ui.show_live_feed_activity` | Live Feed / Activity toggle (Core UI only, needs `glide.ui.polaris.experience` = false) |

## Process flow formatter

- Each stage is a record in Flow Formatter (`sys_process_flow`), **System UI > Process Flow**: **Table**, **Name**, **Label**, **Order** (left to right), **Condition** (when this stage is the current one), **Active**.
- The current stage is highlighted and earlier ones get a check mark. See [[Create a Process Flow Formatter]].

## Parent breadcrumbs

- Shows up to six levels of parents on a task; needs a value in **Parent**.
- In its UI macro, `pc.setLabelField("field_name")` changes the link text and `pc.setTitleField("field_name")` the hover text (script include `ParentCrumbs`).
- For a non-task table with a self-reference field named `parent`: open the formatter, change **Table**, **Insert**.

## Custom formatters

1. Create a UI macro (**System UI > UI Macros**, role `ui_macro_admin`) in Jelly. It represents a row, so it must begin and end with `<TR></TR>`.
2. Create a formatter (**System UI > Formatters**): **Formatter** = the macro name plus `.xml`, the **Table**, **Type** = Formatter.
3. Add it to the form.

A UI macro with the **same name as a shipped formatter** (without `.xml`) overrides it.

## Approval summarizer warning

Its **Reject** button denies individual requested items before the request is approved. It must be hidden once the overall request is approved: using it afterwards cancels the item's workflow and leaves the stage inconsistent.

## Related

- [[Form Layout, Sections and Views]] · [[task]]
