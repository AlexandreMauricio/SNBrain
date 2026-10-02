---
type: concept
tags: [concept, instance-admin, update-sets, ai, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Multi-instance Management" (pp. 254-259) and "ServiceNow Otto for Setup" (pp. 259-300), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Otto for Setup and multi-instance trust

**In one line:** *Otto for Setup* is the guided path from "product licensed" to "product configured": install the bundle from a **Product Hub**, walk a **Configuration Console** of setup items, and package the result as a batch update set for the next instance. *Multi-Instance Management* controls which of your instances may see each other's data for certain applications.

## Otto for Setup: the flow

1. **Admin Home > Manage your products**: one card per product family, with state *Ready to install*, *Installation in progress* or *Ready to configure*. New customers on supported sub-production instances get a zero-touch install.
2. **Product Hub** (per product family): tabs *Not installed*, *Installed*, *Updates available*; **What's included**; install icon per app bundle.
   - An **app selection modal** separates **mandatory** apps (locked) from **optional** ones (tick what you want; unlicensed ones are disabled with a message). The button shows "Install N selected items".
   - "Jumbo" bundles redirect to Application Manager for the same choice.
   - Individual registered plugins can be installed from the hub too; their dependencies are mandatory.
3. **Configure** opens the **Configuration Console**: a **Platform** module (shared) and product modules. Items show icons: tick = configured, gear = default configuration applied, lock = prerequisite pending, labels *New* / *Update*. **Mark as configured** when done. **Configure with AI** appears for items that have an agent.
4. Changes are captured in a **batch update set** in the console's preferred scope. **Package and download** produces the XML; **Completed batches** lists earlier ones.
5. On the next instance: Product Hub > **Upload batch** > **Preview** > resolve preview problems > **Commit Update Set Batch**.

Works without AI; the agents (AI Search configuration, external content connector, group and roles assignment, operational data import, SSO configuration) need the corresponding subscription. Role admin. Available with certain SKUs (Foundation and Pro+ tiers of ITSM, ITOM, CBS, HRSD and others).

### Platform module items

| Item | What you set | Role |
|---|---|---|
| Branding | portal theme, Virtual Agent branding, workspace themes | admin |
| Localization | default language, system time zone, currency, date and time format | admin |
| Identity management | SSO providers (SAML, OIDC; needs the Multiple Provider SSO plugin), LDAP servers | admin; `user_admin` and `import_admin` for LDAP |
| Inbound / Outbound email | accounts, properties, inbound actions | `email_account_admin` |
| Operational data | departments, locations, users, groups (single or **Bulk upload** from an Excel template), role and group assignment | admin, `user_admin` |
| Assets | hardware, consumables | admin |
| Knowledge management | knowledge base, flows, templates, article import | |
| CMDB | CI lists per type (types from property `cmdb_lite_ci_config`) | |
| AI Search | internal and external sources | admin |
| Security Settings | link to Security Center | `sn_vsc.security_center_viewer` |

All in Global scope.

### Not carried by the batch update set

Reconfigure directly on production: **SSO**, **LDAP**, **notification templates and settings**.

### Preview problems when committing

| Action | Effect |
|---|---|
| Compare with local | side-by-side incoming versus local; do this first |
| Accept remote update | incoming version overwrites the local record (not undoable through update sets) |
| Skip remote update | keep the local record |
| Show local record / Show local update | inspect what is on the target |

If the upload fails immediately: make sure it is the unmodified XML from the source instance; otherwise repackage and download again. Source and target must be on compatible versions.

## Multi-Instance Management

**All > Multi-Instance Management > Trust Configuration**. Used by applications that show data across a customer's instances (Subscription Management, Security Center).

- Per instance and per application: **Grant access** = what *this* instance allows the instance on that row to see (editable); **Is granting access** = what that instance allows this one (read-only).
- Defaults: sub-production shares with production only; production shares with nobody. Promoting or demoting an instance resets its settings.
- **Trustor** = the instance exposing data or accepting messages; **trustee** = the one trusted. Trust is per application **capability**.
- A **trust profile** describes the wanted trust for an application across instances. A **manager instance** (production; set on the managed instance under **Manager Instances**, table `sn_mif_managed_by_instance`, and approved there) can push profiles to **managed instances** with **Sync Trust Profile**. An instance cannot be both. Roles admin or `sn_mif.mif_admin`.

## Related

- [[Admin Center, Store and Application Manager]] · [[Subscription Management]] · [[Upgrades - Process, Upgrade Center and Upgrade Console]]
