---
type: meta
tags: [meta]
status: documented
source: own, adapted from the sister vault HALO ITSM (2026-11-06)
updated: 2026-11-06
---

# Screenshots

## Why images get lost

A screenshot pasted into the Claude chat is **not a file**: Claude can see it and write down what it shows, but cannot save it into `_attachments/`. An image is kept only if the user drops the file in `00-Inbox/` (or in `_attachments/` directly).

## Where a kept screenshot goes

In the **documentation note** for that screen (concept, reference or how-to), because that is where a later reader looks. The exercise **embeds the same file** (an image embed: `!` followed by the file name in double square brackets) instead of keeping its own copy.

- Every embedded image gets a caption: what it shows, the instance label from [[Instances]] and the date. Screens differ between instances and releases.
- The note's text still records every field, default and option the image shows (images are not searchable).

## Which screenshots are worth keeping

Keep one when it shows what text describes badly: a layout or an easy-to-miss button, a dialog with many options, a flow as Workflow Studio draws it, an error worth recognising. Don't keep one that only repeats the note's text or an image already in `_attachments/`.

**Images from ServiceNow docs, training or support articles** are not copied into the vault, which is pushed to GitHub. Describe them in words and say where the original lives.

## Steps (Claude, processing images in `00-Inbox/`)

1. **Check for real data:** customer names, user names, emails, ticket contents, instance URLs. If any are visible, don't keep it, or ask for a cropped or redacted one.
2. Rename to a descriptive lowercase-hyphen name, move to `_attachments/`.
3. Embed in the documentation note with its caption; embed in the exercise too.
4. Delete the inbox copy.
