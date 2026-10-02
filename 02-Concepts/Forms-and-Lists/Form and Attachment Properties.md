---
type: reference
tags: [reference, forms-lists, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration" (pp. 744-799), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Form and attachment properties

System properties and user preferences that control forms, collected from the form administration chapter. Edit under **System Properties > UI Properties** or **Security** where a label is given, otherwise in `sys_properties.list` (add the property if missing). Concepts: [[Form Layout, Sections and Views]], [[Attachments]], [[Formatters]], [[Form Templates]].

## Form behaviour

| Property or preference | Notes |
|---|---|
| `glide.ui.task.insert` | *Allow the use of the "Insert" and "Insert and Stay" options on task derived tables*. Off by default |
| `glide.ui.focus_first_element` | false puts focus on the first element of the page instead of the first writable field (helps screen reader users) |
| `enter_submits_form` (user preference) | false stops Enter submitting the form from a single-line text, choice or Boolean field. Takes effect at next login |
| `glide.ui.form_multiple_splits` | true allows more than two columns. Add it and put it in the **UI** category |
| `glide.ui.form.enforce_required_fields` | true enforces Required Form Fields (`sys_ui_element_required`) |
| `glide.short.labels` | label style for derived (dot-walked) fields: "Caller Email" (long) versus "Email" (short). Per field: attributes `long_label` / `short_label` |
| `glide.ui.show_template_bar.<TABLENAME>` | false hides the template bar on that table |
| `tabbed.forms` (user preference) | sections and related lists as tabs |
| `owned_by_indicator.form` (user preference) | customer updates indicator in the form header |

## Personalization and annotations

| Property | Notes |
|---|---|
| `glide.ui.personalize_form` | false disables form personalization |
| `glide.ui.personalize_form.role` | roles allowed to personalize (default `itil`) |
| `glide.ui.form_annotations` | false disables annotations |
| `glide.ui.show_annotations` (user preference) | the user's annotation toggle |

## Attachments

| Property | Notes |
|---|---|
| *Maximum file attachment size in megabytes* | blank = 1 GB maximum |
| `glide.attachment.role` | roles that may attach; empty = all |
| `glide.attachment.extensions` | allowed extensions, comma-separated, no dots |
| `glide.ui.disable_attachment_view`, `glide.ui.attachment_popup` | true and false hide the `[view]` link |
| `com.glide.attachment.max_get_size` | bytes above which an image is linked, not scaled (5242880) |
| `glide.ui.activity_stream.scale_images` | thumbnails in the activity stream |
| `glide.ts.index.attachment.debug`, `glide.ts.index.attachment.list_terms.debug` | attachment indexing logs |

## Activity formatter

| Property | Notes |
|---|---|
| `glide.ui.incident_activity.fields` | fields shown in the incident activity formatter |
| `glide.ui.activity.email_roles` | roles that see emails in the stream (default `itil`) |
| `glide.history.max_entries` | default 250 |
| `glide.max_activity_size` | default 102400 bytes |
| `glide.ui.activity_stream.style.comments`, `glide.ui.activity_stream.style.work_notes` | colours |
| `glide.ui16.emailStreamResponseActions` | email reply button |
| `glide.ui.show_live_feed_activity` | Live Feed / Activity toggle |

## Related

- [[Dictionary Attributes Reference]]
