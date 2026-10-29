---
type: reference
tags: [reference, scripting, javascript]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > Explore > JavaScript syntax editor, topics "JavaScript syntax editor", "Using the JavaScript syntax editor", "Syntax editor keyboard shortcuts and actions", "JavaScript syntax editor macros", "Context menu in the syntax editor", "Syntax errors and warnings", "JavaScript API context-sensitive help", "Create a script macro for the syntax editor", and ServiceNow Otto for Code > "Keyboard shortcuts", https://www.servicenow.com/docs/r/api-reference/scripts/c_SyntaxEditor.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# JavaScript syntax editor

The editor on every script field (plugin `com.glide.syntax_editor`). Concepts: [[Scripting Overview - Script Types and Where They Run]]. Grouped and paraphrased.

## Settings

| Property | Effect |
|---|---|
| `glide.ui.javascript_editor` | use the syntax editor on script fields |
| `glide.ui.syntax_editor.show_warnings_errors` | markers for errors, warnings, both or none |
| `glide.ui.syntax_editor.linter.eslint_config`, `...ecmascript2021` | ESLint rules for normal and ES12 scripts |
| `glide.ui.syntax_editor.context_menu` | right-click menu on tokens |

## Features

- Colouring, indentation, line numbers, closing brackets and quotes, code folding, Tab / Shift+Tab indent, syntax check on save or on demand (bullets next to bad lines).
- **Context-sensitive help**: Ctrl+Space lists valid names for the script type (server APIs and `current` / `previous` in a business rule, client APIs in a client script, `spUtil` for portal scripts); `.` after a class lists methods, `(` shows parameters; Ctrl+J (Cmd+J) shows documentation.
- **Context menu** on bold tokens (needs a browser with SharedWorker): script include > **Open Definition**, **Find References**; Glide API > **Show Documentation**; table > **Show Definition**, **Show Data**.
- Toolbar: toggle editor, format, comment / uncomment, check syntax, search and replace (regex between slashes, e.g. `/a{3}/`), save, full screen, help, Script Debugger.

## Keyboard shortcuts

| Action | Windows | Mac |
|---|---|---|
| Suggestions | Ctrl+Space | |
| Full screen | Ctrl+M (classic table); Ctrl+Alt+Enter (Otto table) | Cmd+Option+Enter |
| Format | Ctrl+Shift+B (classic); Ctrl+Alt+L (Otto table) | Cmd+Shift+B / Cmd+Option+L |
| Toggle comment | Ctrl+/ | Cmd+/ |
| Search, next, previous | Ctrl+F, Ctrl+G, Ctrl+Shift+G | Cmd+F, Cmd+G, Cmd+Shift+G |
| Replace, replace all | Ctrl+E, Ctrl+; (classic); Ctrl+Alt+K, Ctrl+Alt+R (Otto table) | Cmd+E, Cmd+; / Cmd+Alt+K, Cmd+Alt+R |
| Help (shortcut list) | Ctrl+H | Cmd+H |
| Generate code with Otto | Ctrl+Enter | Cmd+Enter |

The two shortcut tables in the docs disagree for full screen, format and replace; probably old editor versus the newer editor used with Otto for Code. Use Help in your instance to see which applies.

## Script macros

Type the keyword and press Tab; `help` + Tab lists them. Stored in Editor Macros (`syntax_editor_macro`), managed at **System Definition > Syntax Editor Macros** (admin: **Name**, **Comments**, **Text**). Shipped: `vargr` (GlideRecord query), `vargror` (query with OR), `for` (array loop), `info` (`gs.addInfoMessage("")`), `method` (function template), `doc` (comment block).

## Related

- [[Otto for Code]] · [[Debugging Scripts]]
