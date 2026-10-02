---
type: table
tags: [table, schema, users]
status: documented
source: ServiceNow Australia Platform Administration PDF, "User administration", topics "The User record" and "Create a user" (pp. 349-354), plus mentions in "Table administration" (p. 588) and "Instance Clone" (p. 707), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sys_user

**Label:** User (Users)
**What it stores:** one record per person, service account or AI identity that can access the instance: login name, password, contact details, location, preferences.
**Extends:** not stated in the guide

## Key columns

Labels are from the User form. Names are given only where the guide states them.

| Label | Name | Type | Meaning | Confidence |
|---|---|---|---|---|
| User ID | `user_name` | string | unique login name. A duplicate imported by update set takes the ID from the older record | documented (name from the auto-complete example) |
| Given name / First name | `first_name` | string | | documented |
| Family name / Last name | `last_name` | string | first and last name cannot both be empty | documented |
| Name | `name` | string | the display value shown in reference fields | documented |
| Email | `email` | email | validated by the *email* validation script (**System Definition > Validation Scripts**) | documented |
| Title | ? | | job title | documented |
| Department | ? | reference | Department (`cmn_department`) | documented |
| Manager | ? | reference | `sys_user`. Basis of the Manager Hierarchy; path stored in *Manager HP1* | documented |
| Location | ? | reference | Location (`cmn_location`). Decides the E.164 phone territory | documented |
| Password | ? | | set with **Set Password** after saving | documented |
| Password needs reset | ? | boolean | force a change at first login | documented |
| Locked out | ? | boolean | locks the user out and ends their sessions. Admins are prevented from locking themselves out | documented |
| Active | ? | boolean | inactive users are hidden from non-admins in lists, lookups and type-ahead | documented |
| Web service access only | `web_service_access_only` | boolean | non-interactive user: API only, no UI login ([[Non-Interactive Users]]) | documented |
| Internal Integration User | ? | boolean | marks service accounts as internal integration users | documented |
| Identity type | `identity_type` | choice | Human, Machine, AI. May need adding to the form | documented |
| Language, Time zone, Date format, Time format | ? | | per-user locale. Time format must be added to the form | documented |
| Calendar integration | ? | choice | Outlook or None | documented |
| Business phone, Mobile phone, Photo | ? | | | documented |
| Last login, Last login time, Failed login attempts | ? | | maintained by the system and guest users | documented |

Minimum to create a user: **User ID** and either first or last name.

## Relations

- `sys_user_has_role` (`user`, `role`): the user's roles
- `sys_user_grmember` (`user`, `group`): group memberships
- Referenced everywhere: [[task]].`assigned_to`, `caller_id` on Incident, watch lists

## Gotchas

- ServiceNow adds its own service accounts to this table for some features.
- Delete all records is not allowed on this table.
- Clone: preserve or exclude it together with `sys_user_role` ([[Instance Clone Overview]]).
- XML import matches users by display value to an existing local record ([[Export and Import Records as XML]]).

## Related

- [[Users, Groups and Roles Overview]] · [[Create a User]] · [[sys_user_group]]
