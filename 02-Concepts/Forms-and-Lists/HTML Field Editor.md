---
type: reference
tags: [reference, fields, forms-lists, knowledge]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "HTML field editors" (pp. 912-921), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# HTML field editor

HTML fields (knowledge articles, catalog item descriptions, email client, content blocks) are edited with **TinyMCE** (the default; Core UI and configurable workspaces; the guide names version 6.8.2) or the legacy **htmlArea** (Core UI only). Choose with **System Properties > UI Properties**, *HTML field editor to use* (`glide.ui.html.editor`). Concepts: [[Field Types Reference]].

## TinyMCE properties

| Property | Notes |
|---|---|
| `glide.ui.html.editor.valid_plugins` | plugins that **may** be used (space-separated) |
| `glide.ui.html.editor.enabled_plugins` | plugins actually enabled; must be within the valid list |
| `glide.ui.html.editor.toolbar.valid_buttons` | buttons that may be added |
| `glide.ui.html.editor.toolbar` | the toolbar: space-separated buttons, no commas |
| `glide.ui.html.editor.paste.html_import` | paste from non-Word sources: **Clean** (keep structure, drop inline styles), **Merge** (keep inline formatting), **Prompt** |
| `glide.ui.html.editor.paste.word_import` | same three options for Microsoft Word content |
| `glide.ui.html.editor.paste.filtered_inline_elements` | inline elements removed by *Remove formatting* on paste; default `strong, b` |
| `glide.ui.html.editor.font.collection` | font list, `Name=family,fallback;` entries separated by `;` |
| `glide.ui.html.editor.convert_urls` | default false |
| `glide.ui.html.editor.relative_urls` | default true; base is the instance URL |
| `glide.ui.html.editor.extended_valid_elements` | extra allowed elements; default empty |
| `glide.ui.html.editor.contextmenu` | editor context menu items, default `link image table`; `false` disables it. Ctrl plus right-click shows the browser menu |
| `glide.ui.html.editor.toolbar.on.focus` | true hides the toolbar when focus leaves. Not present by default |
| `glide.ui.html.editor.default_link_target` | default target of links |

Removing plugins, or adding custom ones to the valid list, can have side effects.

## Plugins available

a11ychecker (accessibility check with auto-repair), accordion, advlist, align_listitems, anchor, autolink, autoresize, charmap, codemirror, codesample, directionality, editimage, emoticons, formatpainter, fullscreen, help, image, insertdatetime, link, lists, media, nonbreaking, pagebreak, powerpaste, preview, readonlynoborder, searchreplace, table, tableofcontents, visualblocks, visualchars, wordcount (not supported in workspaces).

## Per-field settings (dictionary attributes on the HTML field, Advanced view)

These override the system properties for that field. List **everything** you want, not only additions.

| Attribute | Effect |
|---|---|
| `editor.toolbar=blocks|bold italic underline|bullist numlist|link unlink|image media code` | the toolbar for this field; `|` separates groups |
| `editor.plugins=table link image lists advlist ...` | plugins for this field (space-separated) |
| `editor.height=250` | height, 72 to 2000 |
| `tinymce_allow_all=true` | allows deprecated tags such as `<b>` and `<i>` entered in code view (no validation) |
| `tinymce_allow_script_urls=true` | allows JavaScript in URLs |
| `editor.config=new TinymceConfigScript().getConfiguration()` | menu bar and style formats from the script include `TinymceConfigScript` (set `menubar` there, e.g. `'file edit format'`) |

Attributes combine with commas: `editor.height=300,editor.plugins=...,editor.toolbar=...`.

- Default toolbar: `bold italic underline undo redo | fontfamily fontsize table | forecolor backcolor link unlink | image media code | alignleft aligncenter alignright | bullist numlist fullscreen`.
- Height that grows with the text: add `autoresize` to `glide.ui.html.editor.enabled_plugins`.
- Default font size for a field: default value `<p style="font-size:10pt;"></p>`.
- Accordion sections: add `accordion` to `glide.ui.html.editor.toolbar`.
- htmlArea's toolbar is the property `glide.ui.html.toolbar` (use `separator` between groups).
- PowerPaste is always on and cannot be removed.

## Images, video and links

- **Images**: from the image library (`db_image`, managed under **System UI > Images** by `image_admin`) or as an attachment of the record. Pasted images become attachments. `glide.ui.html.image.allow_url` = false removes *Upload from URL*.
- **Video**: from the video library (`db_video`), a URL, or an attachment. Formats mp4 and webm. **`db_video` is a public table with no security: unauthenticated users can access videos uploaded to it.** By default the HTML sanitizer removes videos. Allowed types: **System UI > Embed Object Types**.
- Enter gives a paragraph (`<p>`); Shift+Enter a line break (`<br>`).
- In Chrome and Firefox paste with the keyboard shortcut, not the Paste icon.

## Notes

- HTML sanitisation of these fields is controlled by the dictionary attributes `html_sanitize` and `html_sanitize_config` ([[Dictionary Attributes Reference]]).
- Word shapes and nested lists with custom icons are not converted on paste.
- HTML fields in split-pane forms can behave oddly because of the narrow width.

## Related

- [[Field Administration]]
