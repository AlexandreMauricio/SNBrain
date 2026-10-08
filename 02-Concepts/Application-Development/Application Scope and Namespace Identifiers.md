---
type: concept
tags: [concept, platform, schema, update-sets, fix-script, scripting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Learning about developing > Anatomy of an application (read 2026-10-08 through the docs site; whole section): Anatomy of an application, Custom application record, Application versions, Application scope, Global scope, Namespace identifier (and examples), Application tables, Dependencies for custom applications, Application files, View file properties, Application File form, Application file protection policy, Relationships between configuration records, Fix scripts (create, test, run), Fulfillment tables, Specify that a table is a fulfillment table. https://www.servicenow.com/docs/r/application-development/c_PartsOfAnApplication.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Application Scope and Namespace Identifiers

**In one line:** an application is a custom application record plus the tables it owns and the *application files* (configuration records) assigned to it; its **scope** gives all of them a name prefix and fences them off from other applications.

From the Brazil docs. How scopes talk to each other: [[Application Access Settings and Cross-Scope Privileges]].

## Scope

- Every custom application gets a **private scope**, chosen at creation and never changed. By default it can read and change its own tables and logic; others cannot unless allowed.
- **Global scope**: everything built before scoping existed, most ServiceNow-shipped applications, and applications created by users with `sn_g_app_creator.app_creator`. No prefix, so names can collide, and global applications bypass scope protection among themselves (read records, call APIs, create configuration records on each other's tables). Global applications can go to the application repository but **not** to the Store.
- Build new tables in a scoped application: it protects data and lets responsibility be split through delegated development.

## Namespace identifier

`x_` + the instance's customer prefix (property `glide.appcreator.company.code`, two to five characters, assigned by ServiceNow) + `_` + the application ID (default: the application name; up to 40 characters, truncated beyond 18).

| Case (prefix `acme`, application *Book Rooms*) | Name |
|---|---|
| The application | `x_acme_book_rooms` |
| Its table Conference Rooms | `x_acme_book_rooms_conference_rooms` |
| A field of that table created in the same scope | `capacity` (no prefix) |
| A global application | no identifier |
| A custom global table | `u_marketing_event` |
| A field added to that global table from the Book Rooms scope | `x_acme_book_rooms_theme` |
| A field added to it from global | `u_theme` |

A field created from another scope carries that scope's prefix, so scripts read `u_marketing_event.x_acme_book_rooms_theme`. Adding it requires the table to allow configuration from other scopes.

## Custom application record

The application's master record (Application, `sys_scope` family), created automatically. From it: name, **version** (compared with the repository or Store to offer updates), the scope, scoped (application) administration, design and runtime access, JavaScript mode, runtime access tracking, table access for other applications, subscription monitoring, default menu, the role needed to use the application, logo, and related lists of all application files, **dependencies** on other applications (what an administrator reviews for risk), and the design-time and run-time cross-scope access granted.

*Can Edit Application in Studio* set to false before publishing stops people who install the application from editing it in Studio (source control features stay).

## Tables

An application owns its tables and decides what other scopes may do with them. User access is by ordinary ACLs, usually with an application role named at creation. Limits the docs give:

- at most 1000 columns per table in theory; the database decides the real limit;
- row size at most 65,535 bytes;
- no more than about 10 medium or longer String fields per table (beyond that: *Row size too large (> 8126)*);
- a label starting with digits has them replaced by the `u_` prefix.

Custom tables count against the subscription's entitlement ([[Custom Tables and Entitlements]]). See also [[Tables, Records and Table Relationships]].

## Application files

Any configuration record that extends an application: business rule, script include, flow, UI action. The application does not own the table (Business Rule `sys_script`), only its records there.

- All such tables extend **Application File** (`sys_metadata`). You never create a `sys_metadata` record directly: saving the configuration record maintains it.
- Each change also writes one record to Customer Updates (`sys_update_xml`) in the current update set, keeping the two in step; editing a file last changed in another update set raises a warning.
- Form header > **Show File Properties** (admin) shows the file view: **Display name**, **Update name** (the unique identifier used for versions and updates), **Class**, **Application**, **Protection policy**, created / updated, and related lists *Related Record Versions* (compare, revert) and *Related Record Updates*. Related links: Show Related Record, Show Parent Record, Descendants.
- **Application File Types** defines parent-child links (a UI policy is a child of its table; its actions are children of the policy) so related records stay in one application. Do not edit that table.

**Protection policy**: *Read-only* files cannot be changed by anyone but ServiceNow. If you customised a file that an upgrade later marks read-only, yours stays writable (upgrades skip customer-changed records); reverting it to baseline makes it inherit the new policy. Script includes of your own applications have their own policy (None / Read-only / Protected): [[Application Administration and Collaboration Descriptors]].

## Fix scripts

Server-side JavaScript shipped with an application to repair or seed data when it is installed or upgraded. **System Definition > Fix Scripts**; `script_fix_admin` can write them, only admin can run them.

| Field | Meaning |
|---|---|
| **Name**, **Description**, **Script** | |
| **Unloadable** | the run records Customer Updates (`sys_update_xml`); enforced when testing |
| **Before** | run before the install or upgrade instead of after |
| **Record for rollback** | keep what it did so it can be reverted |

- Runs automatically on the **first** installation or on the update that introduces it. On later updates earlier fix scripts do not run again: run them by hand (**Run Fix Script**) if needed.
- Write it to be safe to run twice.
- **Run Fix Script** > *Proceed* (wait for the result) or *Proceed in Background*; progress under the Progress Workers related list, where **Cancel job** stops it. Never test on production.

```javascript
// Fix script: server-side, runs in the application's scope at install or upgrade.
// Safe to run more than once: it only fills empty values.
var gr = new GlideRecord('x_acme_book_rooms_conference_rooms');
gr.addNullQuery('capacity');
gr.query();
while (gr.next()) {
    gr.setValue('capacity', 4);
    gr.update();
}
```

The table and field are the docs' sample names, not a tested script.

## Fulfillment tables (Store applications)

To let a production instance enforce paid use, a table can be marked a **fulfillment table** (table > *Table Subscription Configuration* related list > **Fulfillment table**; roles `usage_admin`, admin): only the record's *owner* or a subscribed fulfiller may update its records. Ownership is the **Ownership condition** (`owner_condition`), for example opened_by is me OR caller_id is me. Defaults: task extensions = `opened_by`; catalog requests = `requested_for`; other tables of subscription applications = `sys_created_by`. Enforcement itself is switched in [[Subscription Management]].

## Related

- [[Application Access Settings and Cross-Scope Privileges]] · [[Application Administration and Collaboration Descriptors]] · [[Application Development Tools and Lifecycle]] · [[Sys ID]] · [[Business Rules]]
