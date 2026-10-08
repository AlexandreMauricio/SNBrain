---
type: how-to
tags: [how-to, platform, update-sets, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Deploying applications > System update sets (read in full 2026-10-08) - Create and select an update set as the current set, Mark an update set complete, Set up the source instance for an update set, Retrieve an update set, Preview a remote update set, Commit an update set, Save an update set as a local XML file, Back out an update set. https://www.servicenow.com/docs/r/application-development/system-update-sets/using-system-update-sets.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Move an Update Set between Instances

**Goal:** capture configuration changes on one instance and apply them on the next (development to test, then test to production).
**Prerequisites:** role `admin` on both instances (`security_admin` elevation to import an XML file); both instances preferably on the same release; an admin account on the source instance for the update source.
**Navigation:** All > System Update Sets > Local Update Sets / Update Sources / Retrieved Update Sets

Concepts, problems and rules: [[Update Sets]].

## Steps

On the **source** instance:

1. **System Update Sets > Local Update Sets > New**: **Name** (follow the naming convention), **Description**, optional **Release date**; **Application** is the scope currently selected. **Submit and Make Current**.
2. Make the changes. Check now and then that the update set picker (application scope menu in the header) still shows your set: changing scope switches it.
3. Open the update set, review the *Customer Updates* list (stray records, properties, endpoints), set **State** to **Complete** and save. Do not reopen it later; further changes go in a new set.

On the **target** instance:

4. First time only: **System Update Sets > Update Sources > New**: **Name**, **Type**, **URL** of the source instance, **Username** and **Password** of an admin account there > **Test Connection** > save (the record can only be saved once the connection works; the URL cannot be changed afterwards).
5. On the update source: **Retrieve Completed Update Sets**. Sets already retrieved are skipped.
6. **System Update Sets > Retrieved Update Sets** > open the set (state *Loaded*). Preview runs automatically; otherwise **Preview Update Set**.
7. Resolve every row in *Update Set Preview Problems* (accept or skip the remote update, bring missing objects), then **Run Preview Again** if needed.
8. **Commit Update Set**. Read the commit log for errors and unsafe edit warnings.
9. Test. A fix is a **new** update set on the source, committed after the first one, in order.

Without connectivity between the instances: on the source open the complete set > related link **Export to XML**; on the target **Retrieved Update Sets > Import Update Set from XML** > choose the file > **Upload**; continue at step 6.

## Result / how to check it worked

The retrieved set shows state *Committed*, a local copy of the update set exists under **Local Update Sets**, and the changed objects behave as on the source.

## Example

On development, update set `STRY0010001 - Example form change` (scope Global) captures a new field on the *Example Table* form and a UI policy. It is marked Complete. On test, the update source *Development* retrieves it; preview reports one *Collision* on the form section because someone changed the same form on test last week. After **Compare with local**, the remote update is accepted, the set is committed, and *Test User* confirms the field appears.

## Tables / fields involved

- Update Set (`sys_update_set`): **Name** (`name`), **State** (`state`), **Parent** (`parent`)
- Customer Update (`sys_update_xml`): one row per changed object
- Retrieved Update Set (`sys_remote_update_set`) and Update Source (`sys_update_set_source`): names not given in the pages read (?)

## Other ways to do this

[[ReleaseOps]] automates retrieval, testing and commit across the pipeline. A scoped application is better moved through the application repository ([[Application Repository, Publishing and Administering Apps]]) than by update set; do not mix the two.

## Gotchas

- Data records (tasks, users, most group memberships) are not captured: only configuration.
- A record created separately on each instance (same name, different sys_id) becomes a duplicate unless its table coalesces; move it instead of recreating it.
- Committing in the wrong order overwrites newer changes with older ones; batch related sets under a parent to commit them together.
- **Back Out** on the local copy reverses a commit but can lose data and needs a **Release date** on the set; never back out the *Default* set.
- Set committed sets on production to **Ignore** so a clone back to sub-production does not offer them again.
