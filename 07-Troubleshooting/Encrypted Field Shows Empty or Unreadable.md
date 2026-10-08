---
type: troubleshooting
tags: [troubleshooting, security, fields, access-control, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Key Management Framework and Field Encryption chapters (both read in full 2026-10-08) - Module access policy overview, Module access policy debugger, Exploring Field Encryption (cloning considerations), Field Encryption and system clones, Archive tables and Field Encryption, View declined cryptographic module usage requests, Check External Key Management Service Key Status, Field Encryption Enterprise API table. Assembled from those pages; no page presents it as one troubleshooting list. https://www.servicenow.com/docs/r/platform-security/exploring-fe.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Encrypted Field Shows Empty or Unreadable

**Symptom:** a field protected by Field Encryption is empty in forms and lists, shows cipher text, shows asterisks while typing, or a script gets null or cipher text from it.

Background: [[Field Encryption - Modules, Encrypted Fields and Access]], [[Module Access Policies (MAPs)]].

| Situation | Cause | Fix |
|---|---|---|
| Empty for one user, fine for others | no module access policy grants that user (role) access; the default is Reject | add or correct a Role policy with result Track; check for a StrictReject policy that overrides it |
| Empty for everyone right after activation | the configuration was activated before any policy existed | create the policies (users, scripts, system context) |
| Typing shows asterisks | the user's policy allows encrypt but not decrypt | add the decrypt operation, or accept it as designed |
| Value shows but is read only | decrypt without encrypt | add the encrypt operation if they should edit |
| Empty or unreadable on a freshly cloned instance | the clone copied data and modules but the keys are wrapped for the source | complete the key exchange ([[KMF Key Exchange and Key Import]]); expected, not data loss |
| Cipher text in an `ar_` archive table | no active configuration on the archive table, by design | restore the record to the base table to read it ([[Field Encryption - Mass Jobs, Clones, Archives and Migration]]) |
| A business rule, flow or integration stopped working after encryption | the script or system process has no policy | add a Script or System Access policy; look at **Key Management > Module Key Policies > Module Key Rejections** |
| Script gets cipher text from `getValue()` | `glide_encryption.set_value_support_cle.disabled` is true, or the caller lacks module access | use `getDisplayValue()`, check the property and the policy |
| Nothing can be encrypted or decrypted, banner about the key | with external key management, the AWS key is Disabled, Pending deletion or Unavailable | re-enable the key or fix the connection; status syncs within 30 minutes ([[Field Encryption - Customer-Supplied Keys and External Key Management]]) |
| Old records unreadable after a key action | the key was suspended or destroyed | resume the key; a destroyed key cannot be recovered ([[Key Management Framework (KMF)]]) |
| Impersonating a user does not show what they see | the role policy has **Impersonation** unticked | tick it, or log in as the user |

## Finding the reason

**Diagnostics > Session Debug > Debug Module Access Policies**, then reload the record: the messages at the bottom list each policy evaluated and the final decision ("no module access policies to evaluate", "insufficient privileges").

## Related

- [[Field Encryption - Modules, Encrypted Fields and Access]] · [[Module Access Policies (MAPs)]] · [[Encrypt a Field with Field Encryption]]
