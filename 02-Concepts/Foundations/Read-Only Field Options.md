---
type: concept
tags: [concept, platform, schema, security, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 489-492), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Read-only field options

**In one line:** from the Australia release, the dictionary field **Read only option** decides not only that a field looks read-only but whether client scripts and server-side APIs may still change it.

## The options

Every option shows the field as read-only in the UI. They differ in what can still write to it.

| Read only option | Client scripts | Server-side APIs (Table API, GraphQL, `GlideRecordSecure`), background scripts |
|---|---|---|
| **Display Read Only** | can change it | can change it |
| **Client Script Modifiable** | can change it | cannot |
| **Strict Read Only** | cannot | cannot |
| **Instance Configured** | decided by the property `glide.read_only.legacy_read_only_behavior` | same |

- Fields that were read-only before Australia are set to **Instance Configured** by the upgrade.
- `glide.read_only.legacy_read_only_behavior` defaults to `client_script_modifiable` (the pre-Australia behaviour). Accepted values: `display_read_only`, `client_script_modifiable`, `strict_read_only`.
- That property is meant **only for testing on non-production instances**: it changes every Instance Configured field at once.

## Recommended sequence

1. On a non-production instance, set the property to the stricter value (**All**, type `sys_properties.list`, open the property, change **Value**).
2. Test the client scripts and integrations that write to read-only fields.
3. On production, set **Read only option** field by field ([[Dictionary Entry Form]]) to the option you verified.

## Where it lives in the data

- [[sys_dictionary]]: **Read only option** (column name not given in the guide), plus the legacy **Read only** check box, which is selected and greyed out when an option is set.

## Related

- [[Dictionary Entry Form]] · [[Dictionary Overrides]] (read-only can be overridden per child table)
