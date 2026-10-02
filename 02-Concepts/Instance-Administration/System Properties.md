---
type: concept
tags: [concept, instance-admin, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Add a system property", "Create a system properties module", "Query join and complexity size limits", "Web proxy" (pp. 133-139), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# System properties

**In one line:** a system property is a named setting in the `sys_properties` table that switches or tunes platform behaviour; many documented properties do not exist until you create them.

## Facts

- List: type `sys_properties.list` in the navigator. Many also appear on pages under **System Properties** (UI Properties, Email Properties, System, and so on).
- A documented property that is missing from the table uses its default. **Create the record** to change it (search first to avoid duplicates).
- **All values are strings.** `gs.getProperty('x')` returns `'true'` or `'false'`, not a boolean.

| Field | Meaning |
|---|---|
| **Name** | exact property name |
| **Type** | string, integer, true\|false, choice list, etc. |
| **Value** | the setting |
| **Choices** | comma-separated; `Label=value` pairs allowed |
| **Ignore cache** | ticked: only the `sys_properties` cache is flushed on change, other caches keep the old value. Leave clear normally; tick only for a property that changes more than monthly and is read from the table |
| **Private** | excluded from update sets, so a dev value cannot overwrite the production value |
| **Read roles / Write roles** | who may read or change it |

## The cost of changing one

Changing or adding a property **flushes the cache** on all nodes: a heavy performance hit for 1 to 10 minutes. So:

- do not change properties during business hours;
- do not use a property for a value that changes more than once or twice a month: use a custom table.

## Examples of properties in this guide

- Join limit: **System Properties > System**, "Max number of database joins per query". Leave unchanged unless support says otherwise.
- Web proxy for outbound HTTP: `glide.http.proxy_host`, `glide.http.proxy_port`, `glide.http.proxy_username`, `glide.http.proxy_password`, NTLM variants (`glide.http.proxy_ntusername`, `..._ntpassword`, `..._nthost`, `..._ntdomain`), and `glide.http.proxy_bypass_list` (semicolon-separated, `*` wildcard). Never write the real values in notes.
- `glide.email.override.url`: base URL used in emailed links.

Full catalogue: [[System Properties Reference]].

## Related

- [[Add a System Property]] · [[Monitoring and Troubleshooting Instance Performance]]
