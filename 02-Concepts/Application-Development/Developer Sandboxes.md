---
type: concept
tags: [concept, platform, instance-admin, update-sets, roles, domain-separation, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Developer Sandboxes (read 2026-10-08 through the docs site; whole section, 689 cleaned lines): Developer Sandboxes, Exploring Developer Sandboxes, Supported ServiceNow AI Platform features, Source control and Developer Sandboxes, Update sets transfer between sandboxes and base instance, Developer Sandboxes and metadata, General guidelines and use cases, Get help, Installing Developer Sandboxes, Entitlements, Cloning and upgrading considerations, Domain separation, Components installed (roles, plugins, tables), Properties installed, Administering (allocate, requesting, retire). https://www.servicenow.com/docs/r/application-development/developer-sandboxes/sandboxes-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Developer Sandboxes

**In one line:** up to 30 short-lived, isolated copies of a non-production instance's configuration, each on its own application node of that same instance and each for one developer, so people can build in parallel without overwriting each other; work leaves a sandbox through Git (preferred) or update sets.

From the Brazil docs. A paid, standalone product; not a replacement for sub-production instances. Not the same as a personal developer instance ([[Personal Developer Instances]]).

## Facts

| Topic | Detail |
|---|---|
| Plugin | `com.glide.dsb`; for cloning also *Dev Sandboxes CC* (`com.glide.dsb.cc`) on the clone source |
| Licensing | packs of 10 sandboxes; minimum one pack per instance, at most three (30). A pack cannot be split across instances. The install page also mentions a "free pack" allowing 34 on one instance, without explaining it (?) |
| Requirements | non-production instance on Yokohama or later and on ADCv3 (moved there during setup if needed). Not for self-hosted instances by default, nor UI/worker node instances. Regulated environments: ask support |
| Enabling | not self-service: open a case with support, giving the instance and the licensed number. One application node is added per sandbox |
| Performance | the docs state the number of sandboxes does not affect the base instance |
| Sign-in | same credentials as the base instance; a user can be in the base instance and several sandboxes at once. For SSO set on the base instance `glide.sso.acr.enable` = false and `glide.authenticate.multisso.enabled` = true |
| Menu | **All > Sandbox Management > Sandbox Management Home**: totals (total, available, allocated) and per sandbox status, data use, owner, last access, allocation date |
| Supported inside | metadata changes, update sets, legacy source control (own branch per sandbox), ServiceNow IDE, Workflow Studio, Build Agent, installing and upgrading applications and plugins independently, outbound integrations. Inbound integrations must be repointed to the sandbox URL by hand |
| Domain separation | support level Basic; set it up on the base instance **before** creating sandboxes. Installing the plugin inside a sandbox does not work properly |

## Roles

| Role | Can |
|---|---|
| `admin` | allocate and retire |
| `sandbox_manager` (Sandbox manager) | manage the lifecycle of all sandboxes without being admin |
| `sandbox_user` (Sandbox user) | request and view sandboxes |
| delegated developers | ask an admin or sandbox manager for one |

## What is isolated

- **Metadata** (scripts, business rules, everything under `sys_metadata`): a full copy per sandbox. A plugin activated in a sandbox is not active on the base instance.
- **Users' roles and credentials changes**: per sandbox.
- **Table data**: depends on the table's mode, recorded in `sys_dsb_table_config` (set on the base table, inherited by its children):

| Mode | Behaviour |
|---|---|
| **Shared** (default since Zurich) | one set of rows for the base instance and every sandbox: a record created in a sandbox is immediately visible everywhere |
| **Full Copy** | snapshot at creation, then isolated. Used for tables extending `sys_metadata`. Costs database space and creation time |
| **Zero Copy** | isolated and empty at the start |
| **Partial Copy** | rows matching a filter (`sys_dsb_query_condition`); of limited use because of references between tables |

- **A schema change in a sandbox isolates that table** there (adding a column to a shared table, for example); rows added afterwards stay in the sandbox.
- Changing the mode of Task or CMDB tables requires support. Custom table configuration must be reapplied by support after an upgrade.
- **Consequence:** testing with data in a sandbox touches shared rows unless the table is isolated. Synthetic test data: AI Data Kit.
- New metadata reaches other developers only after it is merged into the base instance, and then only in sandboxes allocated afterwards.

## Lifecycle

| Step | How |
|---|---|
| Allocate (admin or sandbox manager) | Sandbox Management Home > **Allocate sandbox** > **Allocate to** (owner), **Sandbox alias** (display name; the URL cannot be changed) > **Allocate**. Taken from a pre-created pool refreshed every 24 hours, so it may lag the base instance slightly; with the pool empty, ten minutes to two hours. Shows *Initializing* until ready |
| Open | select its name on the home page, or copy its URL from the context menu |
| Work | one person per sandbox; one Git branch per sandbox (Git credentials are inherited from the base instance and can be changed locally) |
| Hand over | push to Git, or use the automatic update sources: on the sandbox a source named *Base instance*, on the base instance *Sandbox: <name>*; retrieve, preview and commit as usual, in either direction |
| Retire | save the work first; more options > **Retire sandbox** > **Retire**. Both update sources disappear with it |
| Refresh the baseline | the admin clones or merges so that later sandboxes start from the new state |

Keep sandboxes short: a story, a sprint, a test round. An urgent fix mid-sprint: take a second sandbox on a new branch instead of stashing.

| Sub-production instance | Developer sandbox |
|---|---|
| separates teams or projects | separates developers inside one project |
| may start from different configurations | all start from the same baseline |
| durable | temporary, work committed to version control |

The docs recommend pairing sandboxes with ServiceNow Fluent and the ServiceNow IDE, because XML metadata merges badly: [[Source-Code Development - Fluent, JavaScript Modules and React]].

## Upgrades and clones destroy sandboxes

| Event | What happens | What to do |
|---|---|---|
| Family, patch or security **upgrade** of the base instance | all sandboxes are retired and recreated in base state (a banner shows progress). From Australia Patch 3, update sets holding at least one change since creation, complete or not, are exported first to the base instance's retrieved update sets as `DSB <sandbox> (<date>): <update set>` | commit to Git beforehand, or afterwards preview and commit the backups in the new sandboxes |
| **Clone** over the instance | sandboxes are **not** recreated and nothing is backed up | save everything yourself first. Install `com.glide.dsb.cc` on the source so preservers keep the feature enabled. With a custom clone profile, include the Developer Sandboxes cleanup script, the exclude entries for tables starting `sys_dsb`, and the preservers for `sys_dsb` tables and *DSB Properties* |

## Tables

| Table | Holds |
|---|---|
| `sys_dsb` | the sandboxes (readable by admin and `sandbox_manager` only) |
| `sys_dsb_table_config` | data mode per table |
| `sys_dsb_table_alias` | table aliases used by sandbox operations |
| `sys_dsb_query_condition` | filters for partial copy |
| `sys_dsb_message` | messages |
| `sys_dsb_lifecycle_log`, `_assign_log`, `_create_log`, `_destroy_log` | lifecycle events |

## Properties (`sys_properties`)

| Property | Default | Effect |
|---|---|---|
| `glide.dev_sandbox.default_table_config` | `shared_table` | default data mode; also `full_copy`, `zero_copy` |
| `glide.dev_sandbox.num.controller` | 2 | controller nodes; never 0; more controllers = fewer sandboxes |
| `glide.dev_sandbox.node.healthy_time_min` | 10 | minutes a node counts as healthy before its sandbox is reassigned; keep above the restart time (about 3 minutes) |
| `glide.dev_sandbox.node.poll_interval_seconds` / `poll_timeout_min` | 10 / 2 | checks for a node going offline during retirement |
| `glide.dev_sandbox.lifecycle.max_concurrent_events` | 5 | simultaneous allocations and retirements |
| `glide.dev_sandbox.backup_tables` | `sys_repo_config` | tables whose sandbox content is kept across a clone and restored |
| `glide.dev_sandbox.export.poll_interval_seconds` / `poll_timeout_min` | 10 / 10 | waiting for update set export before an upgrade; on timeout the upgrade goes on regardless |
| `glide.dev_sandbox.cleanup_retries` | 3 | attempts to remove leftover tables |
| `glide.dev_sandbox.dsb_db_copier_threads`, `glide.db.dsb.data_copy_processor.threads` | 1 (1 to 5) | copy concurrency; **do not change without the account manager** |
| `glide.db.dsb.data_copy_processor.chunk_copy.threads` | 5 | copiers per table |
| `glide.dev_sandbox.enabled` | ? | named as the switch that turns the feature on; not in the property table |

## Related

- [[ServiceNow IDE and ServiceNow SDK]] · [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] · [[Team Development]] · [[Build Agent]] · [[Application Development Tools and Lifecycle]]
