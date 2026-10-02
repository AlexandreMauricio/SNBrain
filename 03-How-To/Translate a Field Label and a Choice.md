---
type: how-to
tags: [how-to, fields, choice-list, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System Localization", topics "Translate a field label", "Translate a choice label", "Debug translations" (pp. 2341-2346), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Translate a field label and a choice

**Goal:** make a custom field and its choices appear in another active language.
**Prerequisites:** role admin. The language plugin is active.
**Navigation:** the form with the field; All > System Localization > Choices

## Steps

Field label:

1. On the form, right-click the field label > **Configure Label**.
2. Replace **Label**, **Plural** and **Hint** with the translated text.
3. Set **Language** to the target language code.
4. Right-click the header > **Insert** (creates a new row and keeps the English one).

Choice:

1. **System Localization > Choices > New**.
2. **Table**, **Element** (column name), **Language** (code), **Label** (translated), **Value** (same as the English choice), **Sequence**.
3. Submit. Repeat per choice.

## Result / how to check it worked

Switch language with the picker: the label and the choices show translated. With **System Localization > Enable I18N Debugging** the label shows the prefix GMLD and choices CHC.

## Example

| Table | Element | Language | Label | Value |
|---|---|---|---|---|
| Incident | `u_example_reason` | `pt` | Motivo de exemplo | (field label row) |
| Incident | `u_example_reason` | `pt` | Falha de rede | `network` |

## Tables / fields involved

- [[sys_documentation]]: **Label** (`label`), **Language** (`language`), **Element** (`element`), **Table** (`name`)
- `sys_choice`: **Label**, **Value**, **Language**, **Element**, **Table**

## Gotchas

- **Update** instead of **Insert** in the label form overwrites the English label.
- The choice **Value** must be identical across languages or records show an untranslated value.
- Background: [[Languages, Translation Tables and Locale]].
