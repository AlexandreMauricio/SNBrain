---
type: concept
tags: [concept, security, access-control, roles, scripting, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Key Management Framework (chapter read in full 2026-10-08) - Module access policy overview, Create a module access policy, Module access policy visualization, Module access policy debugger. https://www.servicenow.com/docs/r/platform-security/platform-encryption/module_access_policy_overview.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Module Access Policies (MAPs)

**In one line:** a module access policy says which caller (a role, an application scope, a script, the system user, another instance) may encrypt or decrypt with a given cryptographic module; with no policy granting access, encrypted fields simply look empty.

From the Brazil docs. The modules they protect: [[Key Management Framework (KMF)]].

## Behaviour

- **Default is Reject.** A caller needs an explicit policy with result Track.
- A user without access sees the encrypted field or column **empty**, in forms and lists.
- The first time a script calls a module it is denied and the developer gets an error; a policy named `AutoGen-<module name>` is created from the module's default so the module owner can decide.
- *Autogen* policies are generated from the module's default policy when nothing granular exists. They are **not** applied for scheduled jobs or for field encryption modules (modules whose parent is Field Encryption).

## Policy fields

**All > Key Management > Module Access Policies > All > New** (roles `sn_kmf.cryptographic_manager` or `sn_kmf.admin`). Table: `sys_kmf_crypto_caller_policy`.

| Field | Notes |
|---|---|
| **Policy name**, **Crypto module**, **Active** | |
| **Type** | **Role** (**Target Role**), **Scope** (**Target Scope**), **Script** (**Script Table** and **Target Script**), **System user**, **Resource Exchange** (crypto spec, approval type one-time or recurring, target instance host; see [[KMF Key Exchange and Key Import]]) |
| **Specify purpose**, **Crypto spec**, **Granular operation** | restrict the policy to one operation of a symmetric specification, for example encrypt but not decrypt |
| **Impersonation** | on a role policy: the policy also applies while someone impersonates a user with the role |
| **Result** | **Track** (allow and record use), **Reject** (deny unless another policy grants), **StrictReject** (deny whatever else exists) |

- Without Field Encryption Enterprise only the **Role** type is available, and at most five policies.
- Script policies can be tied to a script version, so a changed script invalidates the policy.

## Seeing who has access

Open a module (**Key Management > Cryptographic Modules > All**): the visualization page shows

| Section | Content |
|---|---|
| **Global policies** | *Default rule* (when nothing matches), *Platform backend* (internal platform code), *Script engine*, *System user*; each with **Manage** or **Add** |
| **Granular policies** | tabs Role, Scope, Scope and Domain (with domain separation), Script, Resource exchange (Password2 or Field Encryption submodules), Identity (with Secrets Management Enterprise); active ones by default |
| **Users with access** | every user who can use the module, grouped by user |

Labels: *Track* or *Allow* = granted; *Reject* = denied unless a Track policy is found; *StrictReject* = denied; *N/A* = the policy does not exist, denied.

## Debugger

- **All > Diagnostics > Session Debug > Debug Module Access Policies**; switch off with **Disable All**. Messages appear at the bottom of any page that triggers an evaluation.
- Who may see them: `sn_kmf.admin`, `sn_kmf.cryptographic_manager`, plus the roles listed in `glide.kmf.module_access_policies.debugger.authorized.roles` (comma separated).
- Each block: the module requested, then every policy evaluated in order (name, type, target, granular operation, result), then the decision. Typical endings: granted; denied with no policy to evaluate; denied for insufficient privileges.
- To debug as another user, impersonate them; role policies must have **Impersonation** true for that to reflect their access ([[Impersonation]]).

## Related

- [[Key Management Framework (KMF)]] · [[KMF Key Exchange and Key Import]] · [[Access Control Lists (ACLs)]] · [[Impersonation]]
