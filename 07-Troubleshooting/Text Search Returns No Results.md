---
type: troubleshooting
tags: [troubleshooting, platform, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Zing text indexing and search engine", topics "Debug Zing", "Disable a stop word in Zing", "Fields excluded from text indexing", "Regenerate the text index for a single record", "Enable or disable the Zing junk filter" (pp. 1055-1057, 1099-1100, 1114-1115, 1128), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Text search returns no results

## Symptom

A **for text** list search or a global search finds nothing for a word that is visibly in a record, or shows "Your text query contained only common words or ambiguous wildcards".

## Causes

| Cause | Sign |
|---|---|
| The table is not text-indexed | no **for text** option in the list search field picker |
| The field is excluded | field is a date, boolean, `sys_*` field, has `no_text_index`, or is encrypted |
| The word is a stop word, or **stems** to one | short word or acronym (for example `AMS` stems to `am`) |
| Junk filter | single character or two-digit number |
| An automatic stop word | the word is extremely common in that table |
| Stale or interrupted index | the record was changed recently, or indexing was interrupted |
| ACLs | the user cannot read the record: by design |
| Lower-case `or` / `not` | treated as search words, and then all words are required |
| Table created by update set | text indexing is off on the target |

## Check

1. **System Diagnostics > Session Debug > Debug Text Search**, repeat the search in a list: the debug output shows the stemmed terms and which were dropped.
2. **System Definition > Text Indexes** > the table: state, **Index Stop Words**.
3. **System Definition > Text Index Stop Words** for the global list.
4. Re-index just the record:

```javascript
var gr = new GlideRecord('<table>');
gr.get('<sys_id>');
gs.eventQueue('text_index', gr, '<table>', 'update', 'text_index');
```

Wait for the `text_index` event to be processed and search again. If it now works, the index was stale.

## Fix

- Stop word: deactivate it globally and set it to *Not a Stop Word* on the table, then regenerate the index.
- Two-digit or single-character terms needed: set table attribute `text_index_filter_junk=false`, regenerate (bigger index).
- Stale index: regenerate for the table, preferably with `new GlideTextIndexEvent().indexUpdate('<table>', 'null')` which keeps search working during the rebuild.
- Not indexed: enable text indexing on the table (**Text Index Configurations**).

## Related

- [[Zing Text Search and Global Search]]
