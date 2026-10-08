---
type: concept
tags: [concept, platform, update-sets, instance-admin, admin, api, domain-separation, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Deploying applications > Administer your apps (whole section, 1,180 cleaned lines, read in full 2026-10-08 through the docs site) - Application sharing; ServiceNow application repository (manage applications, entitlements, release a scope, publish, install, delete, manage and publish and install customizations, convert to application repository mode, convert to development mode, preserve applications during a clone and results after a clone, repository for self-hosted air-gapped customers with install and configuration); Publish an application to the ServiceNow Store; Create application files to include sample data; Publish an application to an Update Set; Queued Application Operations; Custom licensing for ISV applications and its definition; Domain separation and Creator Workflow apps. https://www.servicenow.com/docs/r/application-development/r_ManagingApplications.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Application Repository, Publishing and Administering Apps

**In one line:** a finished custom application is shared by publishing it to the company's **application repository** (then installed per instance), to the ServiceNow Store, or to an update set; this note covers those routes, application customizations, switching an application between installed and development mode, clones, and the queue behind CI/CD installs.

From the Brazil docs. Update set mechanics: [[Update Sets]]. Pipelines: [[ReleaseOps]], [[AEMC Pipelines and Deployments]]. Who may publish: [[Delegated Development and Deployment]]. Managing installed applications: [[Admin Center, Store and Application Manager]].

## Sharing methods

| Method | Reaches | Typical use |
|---|---|---|
| Publish to the application repository | all instances of the same company | move an application to test or production |
| Publish to the ServiceNow Store | all customers | share or sell |
| Publish to an update set | any instance given the file | a saved version for compliance or backup |
| Push to team development instances | the team development hierarchy | push changes to the parent instance |

**Update sets or the repository, never both, for one scoped application** (skipped changes, commit errors). Whichever is chosen is kept.

Schema deletes: `com.glide.apps.include_my_schema` = true makes deleting a table or column of a scoped application part of the application (default on new instances, and on upgraded ones without custom applications; otherwise false, the pre-Paris behaviour).

## Application repository

- Part of the ServiceNow Store, multi-tenant: each company sees only its own applications. Portal: `https://apprepo.service-now.com` (Now Support sign-in). Not available on-premise (see the air-gapped variant below).
- Limits: **20 versions** per application (the oldest is dropped) and **1 GB** per application.
- **Entitlement** = permission for an instance to install the application. After publishing, all company instances are entitled.

| Task | Where | Role |
|---|---|---|
| Publish | **System Applications > My Company Applications** > *In Development* > the application > **Publish to My Application Repository** > **Submit** | admin, or delegated developer with *Publish To App Repo* |
| Install | **My Company Applications** > find it > pick a version > **Install** | admin |
| Entitlements | portal > **Select Action > Manage Entitlements**: *Entitle all instances* (default), *Entitle selected instances*, *Remove all existing entitlements* | none stated |
| Delete from the repository | uninstall everywhere first; portal > *My app repos* > **Flag for Deletion** (deleted after 90 days) or *Flagged Apps* > **Delete Immediately** | primary customer admin of the account |
| Release a scope | only when no application uses it; portal > *Scopes* > trash icon. A scope held by the repository cannot be used for a new application | primary customer admin |

**Can Edit Application in Studio** (true by default) can be set false before publishing.

### Customizing someone else's application

A Store application or a scoped application delivered by a plugin cannot be changed itself, but the company can keep an **application customization** package on top of it, versioned through the repository.

- Create: open the application in ServiceNow Studio, or **System Applications > All** > the application > **Switch to this Application**, and make changes.
- Publish: **System Applications > All Available Applications > All** > the application > **Publish Customizations to My App Repo** (or Studio's publish menu). **One customization per vendor or customer code.**
- Install: same list > select a customization version > **Install**. For plugin-delivered applications the base version is the release name.
- Entitlement follows the base application; an instance without the base application cannot take the customization.
- **The customization package is authoritative**: local changes on the target (customer updates) are not honoured. To keep a locally set field use the *Loader exempt* dictionary attribute; for a property, make it private.

### Switching modes

| Action | When | Effect |
|---|---|---|
| **Convert to Application Repository Mode** (*In Development* tab) | an application moved so far by update sets (it sits in Custom Applications, `sys_app`, on every instance) must now be installed from the repository, for example for CI/CD | the record moves to `sys_store_app`; **development is no longer possible on that instance**; for a scoped application its customer updates are deleted. Then update it from the repository |
| **Convert to Development Mode** (*Installed* tab; set the scope picker to that application first) | an installed copy of your own application must become the development copy, for example after cloning production over development | new versions can be built and published; **the instance no longer receives repository updates** for it. Check the installed version is the one to continue from (a warning shows if the repository has a newer one). Demo data links (`sys_metadata_link`) must be recreated |

Convert to development mode is controlled by `sn_appclient.store_app_convert_enabled` (default true); the scope must match a key in `sn_appauthor.all_company_keys`; installed global applications qualify.

### Clones

A clone copies the application versions **installed on the source**. On the target, a development copy ends up at the source's installed version, and an application that does not exist on the source is deleted. Before cloning, save anything newer on the target:

| Saved as | After the clone |
|---|---|
| Source control (commit the latest) | automatic: remote changes are applied after the clone (`glide.source_control.post_clone_import_enabled`, default true; delay `glide.source_control.post_clone_import_delay_time_sec`, default 0; `glide.source_control.post_clone_import_pause_refresh_time_sec`, default 10,800). If the application was never on the source: delete the repository configuration (`sys_repo_config`) and import from source control |
| Update set (**Publish to Update Set**) | delete the cloned version if there is one, then load the update set |

Application customizations after a clone, by case:

| Source has | Target had | Target after | Do |
|---|---|---|---|
| no base application | base + customization installed | no base | reinstall both |
| no base application | base + customization in source control | no base; `sys_repo_config` with empty app field | delete that record, import from source control, install base |
| base only | base + customization installed | base only | reinstall the customization |
| base only | base + customization in source control | base; repository config kept; customization version shows none | apply remote changes |
| base 1 + customization 1 | version 2 of both installed | version 1 of both | reinstall version 2 of both |
| base 1 + customization 1 | version 2, customization in source control | version 1, repository config kept | apply remote changes |
| version 2 of both | version 1 (installed or in source control) | version 2 | nothing |

See also [[Instance Clone Overview]].

### Self-hosted, air-gapped instances

The repository also exists as a scoped application installed on a **dedicated** customer instance, for customers who cannot reach the public Store. Obtained through the account representative and Support; role `maint` to install and configure, then admin. **Do not install it where the public Store is reachable: those instances lose Store access.** Customizing it is unsupported.

Each client instance is **paired** once. On the client: `sn_appclient.repository_base_url` = the repository instance URL; clear `sn_appclient.upload_base_url` and `sn_appauthor.upload_base_url`; set `sn_apprepo.credential` (in `conf/overrides.d/glide.properties` on the node, then restart or reload the file); `sn_appclient.repo_auth_name` = `sn_repo.AppRepo`; `glide.test_instance` false on both sides; `sn_appclient.client_calls_allowed` true (a scheduled job may reset it when disconnected); `sn_appclient.app.install.offline` false. On the repository instance: a `core_company` record with **Primary** true; a `sn_repo_instance` record per client with **State** *Pairing* and the instance name (from the client's `stats.do`). Then on the client, in Scripts - Background (server side, scope `sn_appauthor`), run `new ConfigChecker().checkForChanges()`. State *Blocked* suspends an instance; a change of instance name, id or credential needs a new pairing. Published applications appear under **Application Repository > Artifacts > Internal Apps**.

## Other publishing routes

**Store:** scoped application only (never global), Technology Partner Program membership and certification. **System Applications > Applications** > *In Development* > the application > **Publish to Store** (admin, or delegated developer with *Publish To App Store*).

**Update set:** **My Company Applications** > *In Development* > the application > **Publish to Update Set** (admin, or delegated developer with *Publish To Update Set*).

| Field | Meaning |
|---|---|
| **Version** | appended to the name: `<Application name> - <Version>`; saved in the application's version. Empty: first set is the plain name, later ones get a sequence number |
| **Description** | default: the application's short description |
| **Include data** | a limited number of records per application table, as sample data. Not for migrating data. Number counters travel too (the target takes the larger value); translated fields only in English |

The latest update of every application file is copied into a new, **complete** update set. Transfer it ([[Move an Update Set between Instances]]) and run any fix scripts of the application on the target.

**Sample data as application files:** on the list of an application table, filter, then **Create Application Files** (column context menu in List v2, list title menu in List v3) > **Load When**: *New Install and Upgrades*, *New Install*, or *New Install with Demo Data*. It is a snapshot; later changes to the records are not followed.

## Queued application operations (CI/CD)

Since Tokyo, CI/CD API calls that need the instance-wide update lock (`UpdateMutex`, visible in `sys_mutex`) are **queued** instead of rejected when the lock is busy. The API contracts are unchanged.

- Queued endpoints: `api/sn_cicd/app_repo/install` and `/rollback` (also `v1`, `v2`), `api/sn_cicd/sc/apply_changes` (also `v1`, `v2`), `api/sn_cicd/sc/import`, `api/sn_cicd/app/batch/install`, `api/sn_cicd/plugin/{plugin_id}/activate` and `/rollback`.
- Each request becomes a NowMQ message (subject `sys.applifecycle.operation`; operation types `app_install`, `plugin_activation`, `batch_install`, `rollback`, `import_app`, `apply_changes`) and an **execution tracker** (the progress id returned by the API): *Pending* with its queue position in **Message**, then *Running*.
- **System Diagnostics > Application Operation Queue** (admin): pause or resume the queue; cancel a pending operation by setting its tracker to *Cancelled* (a running one cannot be cancelled); recent history covers 24 hours.
- Manual installs from the UI are **not** queued and can starve for the lock when many requests arrive: pause the queue.
- The queue pauses itself (*Upgrade Paused*) 2 hours before a scheduled upgrade (`com.glide.update_operation.queue_upgrade_window`) and resumes afterwards; requests keep queueing meanwhile.
- **Parallel**: application installs and plugin activations may run in parallel (`com.glide.update_operation.parallel_operation_enabled`, default on; at most `glide.update.app_operation_queue.parallel.max`, default 2). Never in parallel: two operations on the same scope (including customizations), two with schema changes, two with fix scripts. Held resources are listed in `sys_padlock` by progress id. A deferred job cools down (`com.glide.update_operation.job_cancel_timeout_minutes`); failing to get a lock is not a failure, but failing to download or find the package 3 times (`com.glide.update_operation.max_failure_count`) fails the operation.

More on these APIs: [[ServiceNow SDK CLI Reference]] and [[ServiceNow Studio Source Control, Fluent Apps and Deployment]].

## Custom licensing for ISV applications

For a Store application that is licensable, not in a ServiceNow or global scope, and sold on a **capacity** subscription: a **license definition** tells Usage Analytics what to count ([[Subscription Management]]). **My Company Applications** > the application > *Subscription Management* section: **Subscription Model** = Capacity > **License Definition** > **New**: **Name**, **Description**, **Metric Type**, **Frequency**, **Performance Validated**, **Table** (the application's own tables), **Query**, **Aggregation** (Count or Count (Distinct)), **Aggregation Column** (must be indexed), **Group By** (up to 3 columns, case-sensitive). One definition per application; it becomes read-only once the application is approved on the Store, so a change means a new definition and a new version through review. Plugins: `com.glide.usageanalytics` and the scoped app author plugin (printed as `com.sn_appauthorr`, probably a typo (?)).

## Domain separation

Not supported for application development and the low-code products (support level *No support*: a domain field may exist on tables, without logic behind it).

## Related

- [[Update Sets]] · [[ReleaseOps]] · [[AEMC Pipelines and Deployments]] · [[Delegated Development and Deployment]] · [[Application Scope and Namespace Identifiers]] · [[Admin Center, Store and Application Manager]] · [[Instance Clone Overview]] · [[Application Development Good Practices - Plan, Build, Validate, Deploy]]
