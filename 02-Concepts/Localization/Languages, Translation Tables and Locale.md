---
type: concept
tags: [concept, platform, admin, choice-list, fields]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System Localization" (pp. 2317-2364), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Languages, translation tables and locale

**In one line:** ServiceNow ships translations of its own UI text in language plugins; everything you create (fields, choices, messages, catalog text) you translate yourself, by adding rows to five translation tables keyed by language.

## Which language a user sees

1. the language chosen on the login page (if `glide.ui.login.language.select` is on);
2. else the language picker (user menu > **Preferences > Language & Region**);
3. else **Language** (`preferred_language`) on the user record;
4. else the system default `glide.sys.language` (`en`).

If a string has no translation in that language: the language's **Fallback** language (set on the language record), then English. The *guest* user's language is what the login page and role-less users get.

Never translated: journal fields, free-text fields such as **Short description**, report titles, plugin names.

## Setup order

1. **Instance locale** `glide.system.locale` (`en.GB`, `de.DE`...). Sets number format and the **reference currency**. Set before go-live and never change ([[Currency and Price Fields]]). Per-user differences go in the user's **Country code**.
2. **Activate language plugins** (I18N: French, German, Portuguese, Brazilian Portuguese, Spanish, and about twenty more). They **cannot be uninstalled**, and they activate Knowledge Management internationalization.
3. Default language; fallback languages (**System Localization > Languages**).
4. Locations, regions for portal language selectors, country choices.
5. After activating other plugins later: on any language record, **Repair non-english sys_choice records** so translated choices for the new plugin become active.

## The translation tables

| Prefix | Table | Holds | Typical source |
|---|---|---|---|
| GMLD | [[sys_documentation]] (Field Label) | table and field labels: **Label**, **Plural**, **Hint**, per language | **Configure Label** on a field |
| CHC | `sys_choice` (Choice) | one choice row per language, same **Value**, translated **Label** | **System Localization > Choices** |
| TRF | `sys_translated` (Translated Name / Field) | values of *translated_field* type fields (module titles, related list names, up to 255 chars) | edit the value while in the target language |
| TRT | `sys_translated_text` (Translated Text) | values of *translated_text* / *translated_html* fields (catalog item names and descriptions); English stays in the main table | edit the field while in the target language |
| MSG | `sys_ui_message` (Message) | script and UI messages by **Key** | `gs.getMessage()`, `getMessage()`, `${}` in widgets |

Plus `sys_language` (Languages: **Name**, **ID** as BCP 47 code, **Text direction**, **Active**, **Fallback**).

**Debug prefixes**: **System Localization > Enable I18N Debugging** (session) or property `glide.ui.i18n_test` shows each translatable string prefixed with the code above, telling you which table to edit.

## Translating your own content

| What | How |
|---|---|
| A field label | right-click the label > **Configure Label**, type the translation, set **Language**, then **Insert** (not Update) |
| A choice | new `sys_choice` row with the language code and the same **Value** |
| A catalog item, variable, long text | switch language with the picker, overwrite the text, save |
| A related list name | in the target language, **Configure > List Control**, change **Label** |
| A client script message | add the text to the script's **Messages** field, use `getMessage('text')`, create `sys_ui_message` rows per language |
| A UI page or portal widget | wrap text in `gs.getMessage()` / `${}` and add message rows |
| Playbook text | **Translated Messages** tab of the process definition |
| Many strings | export the translation table rows, translate outside, import with the supplied import tables (`u_sys_choice`, `u_sys_documentation`, `u_sys_translated`, `u_sys_ui_message`, `u_sys_translated_text`) and their *Translation Map* transform maps |
| Notifications, surveys | not covered: one version per language plus logic to pick it |

- Find untranslated custom strings: activate the hidden modules under **System Localization > Non-translated Items**.
- Do not edit plugin-provided translation rows in place (upgrades overwrite): export, change, re-import with a transform map that has **Run business rules** on.
- A new `sys_ui_message` row with an existing key and language changes every place that key is used; message rows are global.
- A language without a plugin: create the `sys_language` row, import translations, add a `sys_choice` on `sys_user.preferred_language` so users can pick it. For volume, the guide recommends the Localization Framework: [[Localization Framework, Workspace and Dynamic Translation]].

## Sorting and matching

- Sort lists by the session language's alphabet: property `com.glide.db.session_language_collation_feature`; per column attribute `i18n_session_language_sortable`. Slower on large tables.
- Case- and accent-**sensitive** search on a column: attribute `i18n_locale_text_match=true` plus property `com.glide.db.ui_i18n_locale_text_match`; affects every query on that column including ACLs and business rules. The two attributes exclude each other.

## Other properties

`glide_i18n.date.default_to_locale` (format dates by user locale), `glide_i18n.ip_geolocation` (guess guest language), `glide_i18n.language_fallback_enabled`, `glide.ts.stemming_language`.

## Related

- [[Choice Lists]] · [[Field Administration]] · [[Translate a Field Label and a Choice]]
