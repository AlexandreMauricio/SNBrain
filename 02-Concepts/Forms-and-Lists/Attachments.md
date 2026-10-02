---
type: concept
tags: [concept, forms-lists, security, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topic "Administering attachments" (pp. 754-760), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Attachments

**In one line:** a file attached to any record is a row in Attachment (`sys_attachment`) holding the metadata, with the bytes stored in 4k chunks in Attachment Document (`sys_attachment_doc`).

## How it works

- A 12k file gives one `sys_attachment` row and three `sys_attachment_doc` rows.
- Uploading, reading, renaming and deleting raise events usable in notifications and script actions:

| Event | When |
|---|---|
| `attachment.uploaded` | upload; one event even if several files are uploaded at once |
| `attachment.read` | read or downloaded |
| `attachment.renamed` | renamed |
| `attachment.deleted` | deleted, including when the parent record is deleted (one event per attachment then) |

For `attachment.read`, `current` is the `sys_attachment` record, `parm1` the file name and `parm2` the table name. This is how to log who downloaded what.

## Controlling attachments

| Want | How |
|---|---|
| Limit file size | **System Properties > Security**, *Maximum file attachment size in megabytes*. Blank means the 1 GB maximum. Email attachment size is separate |
| Restrict who can attach | `glide.attachment.role`: comma-separated roles. Empty means everyone |
| Restrict file types | `glide.attachment.extensions`: `xls,xlsx,doc,docx` (no dots, no spaces). Empty allows all; any entry blocks everything unlisted. Checks the extension only, not the real type |
| Disable drag and drop | **System Properties > UI Properties**, *Allow attachment drag and drop in supported HTML5 browsers* |
| No attachments on a table | add the attribute `no_attachment` to the table's Collection dictionary entry ([[Dictionary Attributes Reference]]) |
| Hide the `[view]` link | `glide.ui.disable_attachment_view` = true and `glide.ui.attachment_popup` = false. The link opens the file in the browser, which can execute script in it; the file name link still works |
| Icons per file type | **System UI > Attachment Icon Rules**, by MIME type or file extension (MIME type wins) |
| Search inside attachments | per table: **System Definition > Text Index Configurations**, add a Text Index Table Attribute Map with attribute *Attachment index* = true, then **Generate Text Index**. Does not cascade to child tables. On by default for Knowledge. Reindexing a large table takes hours |

## Images in the activity stream

- `glide.ui.activity_stream.scale_images` (on by default) makes thumbnails, up to about 525 by 350 pixels.
- **Images over 5 MB can cause an out-of-memory error and an instance restart** when the thumbnail is generated. `com.glide.attachment.max_get_size` (integer, bytes, base value 5242880) makes larger images show as a link instead of being scaled.

## Debugging

`glide.ts.index.attachment.debug` (log indexing exceptions; safe to leave on) and `glide.ts.index.attachment.list_terms.debug` (log every indexed term; only while debugging).

## Related

- [[Form Layout, Sections and Views]] · [[Form and Attachment Properties]]
