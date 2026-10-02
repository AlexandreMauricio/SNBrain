---
type: reference
tags: [reference, fields, task, glide-api, notifications, security]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Journal field type" (pp. 953-959) and "Table administration" (pp. 525-526), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Journal fields

Journal fields hold a running log of entries, each stamped with user and time. On task tables they are **Additional comments** (`comments`) and **Work notes** (`work_notes`) ([[task]]). Entries are stored in Journal Entry (`sys_journal_field`), not in the task row.

## The three types

| Type | Accepts input | Shows earlier entries | Appears in the list-view activity stream |
|---|---|---|---|
| `journal` | yes | yes, below the input box | yes |
| `journal_input` | yes | no | no (only with its record) |
| `journal_list` | no | shows the journal fields it depends on, interleaved by time | no (separate block) |

## In scripts

- **`setValue()` is not supported.** Assign directly:

```javascript
var gr = new GlideRecord('incident');
gr.addQuery('priority', 1);
gr.query();
while (gr.next()) {
    gr.work_notes = 'Placeholder note added by script.';
    gr.update();
}
```

- Read entries: `current.work_notes.getJournalEntry(-1)` returns all entries as one string, entries separated by a blank line (`\n\n`); `split("\n\n")` gives an array.
- Previous entries cannot be edited.

## HTML in journal entries

- HTML typed into a journal field is escaped and shown as text.
- Text wrapped in `[code]...[/code]` is rendered as HTML (a link, bold text). `<script>` is still blocked by the HTML sanitizer.
- Controlled by `glide.ui.security.allow_codetag` (default true). Clear *Allow support for embedding HTML code by using the [code] tag* under **System Properties > UI Properties** to disable it.

## Properties

| Property | Default | Effect |
|---|---|---|
| `glide.email.journal.lines` | 3 | journal entries included in email notifications; -1 = all (**System Properties > Email**) |
| `glide.history.max_entries` | 250 | entries shown in the activity formatter |
| `glide.max_journal_list_size` | (add; guide uses 10) | size in MB above which a journal field shows a preview with **Show All** |
| `glide.shortened_journal_length` | (add; guide uses 512000) | characters shown in that preview |
| `glide.ui.textarea.character_counter` | off | character counter under multi-line and journal fields (4000-character limit by default) |

## Other facts

- Journal fields show whether or not the table is audited.
- In Core UI, journal fields and the activity formatter must be in the same form section, with nothing between them.
- Suggested responses for journal fields: **Configure Responses** on the label (role `personalize_responses`); not available in Core UI.
- Data lookup does not work with journal fields.

## Related

- [[Formatters]] · [[Field Types Reference]]
