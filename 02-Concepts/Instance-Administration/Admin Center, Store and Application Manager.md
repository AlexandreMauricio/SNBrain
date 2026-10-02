---
type: concept
tags: [concept, instance-admin, platform, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Admin Center" (pp. 139-170), "ServiceNow Store" (pp. 171-201), "Application Manager" (pp. 202-226), "Legacy Application Manager" (pp. 227-253), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Admin Center, Store and Application Manager

**In one line:** the **Store** is where applications are procured (licence, trial, terms); **Application Manager** on the instance is where an admin installs, updates, repairs or uninstalls them; **Admin Center** is the admin's landing area that links to both.

## Admin Center

The **Admin** menu / **All > Admin Center**. Role admin.

| Part | What it is |
|---|---|
| Admin Home | dashboard: critical incidents, changes, instance version, scheduled upgrade, licensed applications to update. The shared dashboard cannot be edited; **Create new dashboard** to personalise |
| Adoption Blueprints | recommended applications grouped by business goal, in four tracks: Build a foundation, Enhance the experience, Optimize the functionality, Add advanced features. Shows what is installed, what needs an update, and a *Next Up* suggestion. Recommendations only |
| Configuration Hub | per product family: weekly change in errors, over-allocated subscriptions, files customised in the last 7 days, slow executions; **Explore** tab to browse and edit configuration tables of the selected applications |
| Application Manager, Subscription Management, Security Center, AI Admin Hub, Upgrade Console | linked applications |

Blueprint names in this release: Expand technology services while reducing costs; Deliver extraordinary employee experiences; Modernize your change management process; Reduce incidents with AI based automation; Ensure technology teams meet compliance and performance standards; Operationalize workforce effectiveness.

## Terms

| Term | Meaning |
|---|---|
| Plugin | ServiceNow package extending the platform; comes with licence and release; not sold in the Store. See [[Plugins]] |
| Application | standalone features; from the Store or your own |
| Integration | an application connecting to an outside system |
| Product | a collection of applications; each unlicensed member is procured individually |
| Entitlement | the right of an instance to install an application |

## ServiceNow Store

- Log in with the Now Support account. **My Store Activity** shows requests in process, procured applications and products, payments, trials.
- An application must be **procured in the Store first** when it has custom terms and conditions, needs a paid licence, or needs the provider's approval. Otherwise it can be installed straight from Application Manager.
- Flows: get a free application (request and/or accept terms), buy a ServiceNow application (**Request license** / **Request purchase**), buy a partner application (**Request purchase** / **Contact seller**), **30-day trial** (non-production only).
- After procurement the application appears in Application Manager **within 24 hours** (two business days in federal/regional stores).
- **Version support**: the Store keeps versions for the current platform release and two before it. Check **Version summary** and **Dependencies** on the listing. Plugin dependencies cannot be obtained from the Store.
- Unaccepted standard or custom terms block procurement and installation.
- On-premise: download an encrypted `.store` file (expires in two weeks), upload with **Upload Offline Application** (`sn_appclient.app.install.offline` = true).
- Regulated environments (GCC, NSC, SPP-AU, SPP-SG) have isolated stores; the customer does its own security review.

## Application Manager

**Admin > Application Manager**. Active by default. Roles admin, `sn_appclient.app_client_user`, `sn_appclient.app_client_company_installer`. Not domain-separation aware: install from the global domain.

| Tab | Shows |
|---|---|
| Available for you | everything installable or obtainable; filters Free, Paid, Licensed, Compatible, Trial Started. Syncs with the Store every 24 hours; **Sync now** forces it |
| Updates | installed items with a newer version |
| Installed | what is on the instance, with version |
| Activity log | recent, in progress, scheduled, failed, completed operations |

- **Install**: choose version, check the dependency list (*Needs to be procured from the store*, *Will be updated*, *Installed*, *Inactive plugins*), then **Install now** or **Install later** (scheduled).
- **Update**: **Proceed to update**; if you customised the application, test the update in sub-production first.
- **Uninstall**: only some applications; **Retain fields and data** keeps tables and data.
- **Repair**: reinstalls files to their original state. Files with customer updates go into a remote update set named `Repair/Upgrade app <scope> at <timestamp>`. Changes made outside an application customization are overwritten.
- **Entitle this instance**: for an application purchased but not linked to the instance (filter *Instance not entitled*).

### State indicators on an application

| Indicator | Do |
|---|---|
| Unavailable for Instance | wrong instance type (trials are non-production only) |
| Incompatible | pick another version or upgrade the instance |
| App Terms Not Accepted / Store Terms Not Accepted | accept terms in the Store |
| Not Licensed / License Required for Subprod / License Expiring | buy or renew |
| Approval Required / Approval Requested / Purchase in Progress / Purchase Rejected | Store request status |
| Trial Available / Trial Active / Trial Expired | 30-day trial status |
| Service Provider Blocked | ask the service provider |
| Deactivation Requested | provider asks you to uninstall |
| Beta App / Innovation Lab | experimental, unsupported |

"Installation blocked" on a Now Assist suite member: that application version is not licensed; license it or uninstall it.

### Skipped records when installing applications

| Source | Application | Outcome |
|---|---|---|
| Source control | scoped or global | no skips; local changes must be stashed |
| App repository | scoped | skips generated, customisations preserved |
| App repository | global | changes applied; skips only on a superior claim |
| Store | scoped | skips generated |

Deletions shipped by an application author sit in its `author_elective_update` folder and are applied or not according to properties `com.glide.apps.include_my_deletes`, `com.glide.apps.include_my_schema`, `com.glide.apps.include_only_sys_choice`, `com.glide.apps.force_skips`, `com.glide.apps.include_global_deletes`.

## Legacy Application Manager

**System Applications > All Available Applications**. Removed from Australia patch 1; bookmarks redirect to the new Application Manager. The application **scope picker** in the header (which also switches the current update set to the scope's default) is unaffected.

## Related

- [[Plugins]] · [[Subscription Management]] · [[Upgrades - Process, Upgrade Center and Upgrade Console]] · [[Skipped Records in Upgrades]]
