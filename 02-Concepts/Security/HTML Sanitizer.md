---
type: concept
tags: [concept, security, forms-lists, scripting, script-include, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > HTML sanitizer (6 topics, 212 cleaned lines) - Exploring, Configuring, Enabling, per-field sanitization, logging. The built-in allow list is summarised, not reproduced, read in full 2026-10-08 through the docs site. https://www.servicenow.com/docs/r/platform-security/c_HTMLSanitizer.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# HTML Sanitizer

**In one line:** HTML typed or pasted into HTML and Translated HTML fields is cleaned of markup that could run script or load outside content, according to an allow list that an administrator can extend or restrict in a script include.

From the Brazil docs. The fields: [[HTML Field Editor]]. Scored settings: [[Hardening Settings - Validation, Files, Logging and Other]].

Removes markup that could run script or pull in outside content (`<script>`, `<embed>`, event handler attributes ...) from **HTML** and **Translated HTML** fields, and keeps formatting markup.

- Switches: `glide.html.sanitize_all_fields` and `glide.translated_html.sanitize_all_fields` (true on new instances).
- Per field instead: set the first property to false, then dictionary attribute `html_sanitize=true` (or `=false`) on individual fields.
- What is allowed: a built-in inclusion list (not editable): global attributes `id`, `class`, `lang`, `title`, `style`; the usual text, list, table, form and image elements with their common attributes; `a` with `href`. URL attributes accept only the protocols `http`, `https`, `mailto` and `data`.
- Customising: script include **HTMLSanitizerConfig** (server side, global): object `HTML_WHITELIST` adds, `HTML_BLACKLIST` removes, and **the exclusion list wins**. Each entry is an element name (or `globalAttributes`) with `attribute: [names]` and optionally `attributeValuePattern: {attribute: regular expression}`; `urlAttributes: {protocols: [...]}` adds URL protocols.

```javascript
// inside the HTMLSanitizerConfig script include (server side, global scope)
HTML_WHITELIST: {
    globalAttributes: { attribute: ["id", "name"] },
    img: { attribute: ["style", "align"], attributeValuePattern: { src: ".*jpeg" } },
    iframe: {}
},
```

- Removed markup is logged in the system log with source `HTMLSanitizer` (`syslog_list.do?sysparm_query=source%3DHTMLSanitizer`); property `glide.html_sanitize.discarded_log.enable` (true).
- **Placeholders defeat it**: if an HTML field stores `${description}` and the real text is substituted afterwards, only the placeholder was sanitized. Keep real HTML in HTML fields.

## Related

- [[HTML Field Editor]] · [[Journal Fields]] · [[Hardening Settings - Validation, Files, Logging and Other]] · [[High Security Settings]] · [[Antivirus Scanning]] · [[Dictionary Attributes Reference]]
