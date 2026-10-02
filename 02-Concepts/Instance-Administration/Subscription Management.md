---
type: concept
tags: [concept, instance-admin, roles, users]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Subscription Management" (pp. 300-342) and "Now Support administration" (pp. 342-343), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Subscription Management

**In one line:** the application where you see what the company has bought (subscriptions), how much of it is used, and where you keep custom tables and applications mapped to a subscription, so the instance stays compliant with the contract.

## Access

**Admin > Subscription Management** or **All > Subscription Management**. Roles `usage_admin`, `sn_sub_man.admin`, admin. Active by default, no cost. Subscription data arrives daily and **only on production**; self-hosted instances must import it (Now Support request *Request On-Prem Licensing Information*, then **Subscription Management > Import Entitlement Data**).

## Subscription types

| Type | Measured by | Allocation |
|---|---|---|
| Per-User | users with **measured roles** (Fulfiller, Business Stakeholder, Creator meters) | by role automatically; manual (adding groups) only for accounts that already allocated manually in the past |
| Unrestricted User | all active users of the instance | automatic |
| Capacity | devices, subscription units, transactions, records, nodes | automatic, from a **capacity definition** (table query or script; **Execute** shows the current count) |
| Unlimited | none | automatic |
| Display Only | not measured | none |

Status per subscription: **Compliant**, **Near capacity** (threshold on the Settings tab, default 90 percent), **Even**, **Over-allocated**, **Account-level only**.

## Who counts as a user

- *Active user* in the per-user counts excludes users who have not logged in for 365 days, **Web service access only** users, and users with an empty **User ID**.
- For unrestricted-user subscriptions, active = `sys_user` record with a User ID and **Active** = true.
- **Measured role** = a role that needs a subscription. Automatic assignment gives each user the lowest-cost subscription that covers their roles; custom roles are classified by the ACLs they grant.
- So: every role you give a user or group can consume a paid entitlement. Give measured roles to groups, not individuals, and remove them when no longer needed ([[Role Management]]).

Fixing an over-allocated per-user subscription: remove a group from the subscription, remove the role from a group, remove users from the group, or buy more. Changes show after the daily job.

## Custom tables and applications

- Every **custom table** on production must be mapped to a subscription that has custom table entitlements (see [[Custom Tables and Entitlements]]).
- Scoped application: map the **application** once; tables added later follow. Global tables: map each one.
- **Issues** tab: *Unmapped global custom tables*, *Unmapped custom applications*, with a recommended product (based on scope/package, the table it extends, or related tables; App Engine as fallback). Recommendations appear the day after the table is created. **Map to product**.
- Tables: `ua_custom_table_inventory` (filter **Allotment type** is Grandfather for grandfathered tables), `ua_exempted_table_inventory` (exempt tables), `license_details` (subscriptions), `sys_app` (**Subscription** column).
- **Grandfathered** tables: existing custom tables preserved at a licence migration; cannot be swapped for others. **Exempted** tables: mostly extensions of certain system tables; do not count.
- At renewal a new SKU may appear as a new subscription: note your mappings (and manual group allocations) before the end date and redo them after.

## Other views

- **Insights**: over-allocated and available subscriptions.
- **Account entitlements** (from production): Now Assist usage (assists by instance, domain and skill), Now Assist creators (distinct users across instances), cloud capacity (purchased, used, available, excess, in TB; *Top 10 table view* shows the largest tables). Other production instances share their data through **Multi-Instance Management > Trust Configuration** (**Grant access** = true).
- Consolidated subscriptions: capacity subscriptions with the same definition are pooled.
- Domain separation: basic support; tenants see only their own allocations and assist usage.

## Now Support

The Now Support portal is where instances are managed with ServiceNow (cases, upgrades, clones, plugin requests). A customer admin there manages the company's portal users: profile menu > **Manage users and accounts** > view, **Add new user**, **Edit Role(s)**. These are not instance users.

## Related

- [[Admin Center, Store and Application Manager]] · [[Custom Tables and Entitlements]] · [[Base System Roles]] · [[Non-Interactive Users]]
