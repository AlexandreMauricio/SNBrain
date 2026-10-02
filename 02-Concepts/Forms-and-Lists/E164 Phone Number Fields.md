---
type: reference
tags: [reference, fields, users]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Phone number field type" (pp. 961-972), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# E.164 phone number fields

The field type **Phone number (E164)** (`phone_number_e164`) validates and formats numbers for local and international display. It does not replace the plain phone field. Concepts: [[Field Types Reference]].

## How territory is decided

- The field shows a territory selector and an input box. A red underline means the number does not fit the territory's format and cannot be saved.
- **Territories belong to locations, not users.** A user's territory comes from their location, searching up the location hierarchy until a territory is found.
- Make the phone field **dependent** on a User or Location field (e.g. `caller_id` on Incident) so the right territory is preselected.
- Letters are not valid.

## Properties and per-field attributes

Each property (add it to `sys_properties`) sets the default for all E.164 fields; the dictionary attribute overrides it for one field.

| Property `glide.phone_number_e164.` | Attribute | Default | Effect |
|---|---|---|---|
| `strict` | `pn_strict` | true | false allows saving numbers that do not match the territory (green underline; territory **Other / Unknown**) |
| `allow_national_entry` | `pn_allow_national_entry` | true | false forces international format starting with `+` |
| `display_national` | `pn_display_national` | false | `true` or `form` (local on forms, international in lists), `all`, `user` (local when it matches the viewer's territory), `false` |
| `display_territory_selector` | `pn_display_territory_selector` | true | false hides the selector; only local or national numbers can then be entered |
| `display_territory_text` | `pn_display_territory_text` | read-only | when a territory label is shown: `all`, `national`, `read-only`, `read-only-national`, `list`, `list-national`, `none` |
| `display_users_idd` | `pn_display_users_idd` | false | show the international direct dialling prefix on forms |

Switching from optional to strict validation can make existing numbers fail.

## Territory display rules

**System Policy > Rules > Telephone Display Rules**: per territory, **Country calling code**, **International direct dial**, **STD**, prefixes, **Active**, **Display** (in the selector; a hidden territory is added temporarily when a number with its code is typed), **Order** (default 100; lower is higher in the list). Validation and format rules are regular expressions already defined for all territories, applied in **Order**.

## Related

- [[Field Administration]]
