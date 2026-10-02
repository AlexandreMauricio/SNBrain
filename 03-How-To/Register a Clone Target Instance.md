---
type: how-to
tags: [how-to, instance-admin, security, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Instance Clone", topics "OAuth 2.0 authentication for clone targets", "Register an instance for cloning", "Set up OAuth authentication for a clone target", "Reset OAuth for a clone target" (pp. 707-712), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Register a clone target instance

**Goal:** make a sub-production instance selectable as a clone target, authenticated with OAuth.
**Prerequisites:** `clone_admin` on the source; `clone_admin` and `oauth_admin` on the target (the latter only for setup). OAuth needs Australia Patch 5 or later on both instances.
**Navigation:** All > Clone Admin Console > Clone Home > Configuration > Clone instances

## Steps

1. On the source, open **Configuration > Clone instances** and select **New**.
2. Enter the target instance URL in **Target Instance** and select **Continue**. A version check decides which authentication method is offered.
3. Select **Setup OAuth on Target**. The target opens in a new tab.
4. On the target's OAuth setup page, select **Set up OAuth** and copy the generated **Client ID**.
5. Back on the source tab, paste it into **Client ID** and select **Add Target**.
6. The browser goes to the target: select **Allow** (log in first if the session expired). It then returns to the source.

## Result / how to check it worked

The target is listed under **Clone instances** and can be chosen on the clone request form. No re-registration is needed for routine clones; a short-lived token is obtained automatically for each request.

## Example

Register `https://<dev-instance>.service-now.com` from production once; later requests reuse the registration.

## Tables / fields involved

- `sys_user`: **identity_type** (only for the basic authentication fallback)
- `sys_properties`: `glide.db.clone.allow_clone_target` on the target

## Other ways to do this

**Basic authentication (fallback, when the target cannot do OAuth):** enter the credentials of a target user that has `clone_admin` and `soap`, with `identity_type` set to **machine**. That user can no longer log in to the UI. The field may need adding to the User form.

## Gotchas

- If an authentication error appears on the request form later, use **Reset OAuth** in the Authenticate dialog: generate a new client ID on the target, paste it, **Complete Setup**, **Proceed**, **Allow**.
- No Client ID generated: check you have `oauth_admin` on the target and the page finished loading.
- Browser did not return to the source: **Reset OAuth or Retry** in the console.
- Other failures: [[Clone Target Registration Errors]].
