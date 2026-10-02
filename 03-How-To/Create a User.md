---
type: how-to
tags: [how-to, users, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "User administration", topic "Create a user" (pp. 352-354), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a user

**Goal:** add a user record by hand so the person can log in.
**Prerequisites:** role `user_admin`.
**Navigation:** All > User Administration > Users

## Steps

1. Open **All > User Administration > Users** and select **New**.
2. Fill at least **User ID** and a given or family name. Usually also **Email**, **Department**, **Title**, **Time zone**, **Language**.
3. Choose **Identity type** (Human, Machine, AI) and tick **Active**.
4. Save the record, then select **Set Password**. Tick **Password needs reset** to force a change at first login.
5. Add **Roles**, **Groups**, **Delegates** as needed (prefer groups).
6. Submit.

## Result / how to check it worked

The user appears in the Users list. Impersonate the user to check what they can see.

## Example

User ID `test.user`, given name *Test*, family name *User*, email at a placeholder domain, member of *Example Service Desk* (which carries the `itil` role).

## Tables / fields involved

- [[sys_user]]: the record
- `sys_user_grmember`, `sys_user_has_role`: memberships and roles

## Gotchas

- A User ID that already exists is refused.
- An email that fails validation can only be saved by temporarily deactivating the *email* validation script (**System Definition > Validation Scripts**), then reactivating it.
- **Machine** identity turns on **Web service access only**: no UI login.
- Supported date formats include `2026-08-19`, `19/08/2026`, `08/19/2026`, `19.08.2026`; time formats `16:30:45`, `04:30 PM` and variants.
- Most instances create users through LDAP instead ([[Users, Groups and Roles Overview]]).
