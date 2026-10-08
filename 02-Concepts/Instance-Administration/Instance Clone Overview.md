---
type: concept
tags: [concept, instance-admin, update-sets, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Instance Clone" (pp. 694-708, 725-726, 729-732), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Instance Clone overview

**In one line:** a clone copies data and configuration from a source instance (usually production) over a target instance (sub-production), **overwriting the target**, using the source's most recent backup.

## What it is for

Resetting the drift between sub-production and production: validating upgrades, testing new applications and capabilities. Role: `clone_admin`.

## Vocabulary

| Term | Meaning |
|---|---|
| Source / target instance | where data is copied from / to |
| **Exclusion** | a table whose data is **not** copied; the target gets the table empty but usable |
| **Preserver** | data on the **target** that is kept instead of being overwritten |
| **Cleanup script** | script run on the target after the clone |
| **Clone profile** | reusable set of exclusions, preservers, scripts and options |
| On-demand backup | a fresh differential backup taken at the clone start time |
| Clone chaining | clone production to one test instance, then that instance to the others, so heavy steps run once |

## How a clone runs

1. Build configuration (profile, inclusions, exclusions, preservers).
2. Preflight checks on source and target.
3. Backup: the latest daily backup (at most 36 hours old), or an on-demand one.
4. Pre-clone: prepare space.
5. Provision a new database instance for the target.
6. Restore the backup into it.
7. **Exclusions**: excluded tables are emptied.
8. **Preservers**: preserved data is copied from the old target into the new one.
9. Node repoint: the instance switches to the new database.
10. Cleanup scripts are scheduled (in the global scope) and run after the clone shows Complete.

The pre-clone target data is kept 24 hours for rollback (not available if the clone downgraded the target).

## Exclusions versus preservers

| Table is... | Result on the target |
|---|---|
| preserved and excluded | target's own records stay as they were |
| preserved, not excluded | target's records stay **and** source records are copied in |
| excluded, not preserved | empty but usable table |
| neither | source records replace the target's |

Differences that matter:

- **Excluding a parent table also empties its child tables** (only the parent is listed). Excluding `task` empties Incident, Problem and Change. For table-per-hierarchy children you can exclude just the child.
- **Preserving a table does not preserve its children**; add each child. (On RaptorDB, descendants are preserved automatically.)
- **Preservers are defined on the source instance.** Defined on the target, they do nothing.
- Wildcards in exclusions need the dot: `sys_script.*`.
- Default exclusions: logging, auditing, notifications, workflow contexts (`wf_context` and other `wf_` tables, to avoid timer problems), licence usage.
- Preserve or exclude `sys_user` and `sys_user_role` (and the related tables the guide lists) together, or nobody may be able to log in after the clone.
- Preservers are for settings and themes (authentication settings, `sys_ui_bookmark`, `sys_ui_recent_selection`, `sys_user_preference`), not bulk data. For users, groups and roles, export and re-import instead. Database views cannot be preserved. The regex condition operator is not supported.
- Do not modify or delete the preservers *Core Instance Properties*, *Semaphores* and *Email Accounts*.
- Multi-Provider SSO adds preservers for `sys_certificate`, `digest_properties`, `sso_properties`, `saml2_update1_properties` and some `sys_properties`. Remove the three SSO ones together or not at all.

## Cleanup scripts

- Ordered by **Order** (lower first; same order runs in parallel). Always run in global scope.
- Shipped examples: Disable emails, Configure Email Accounts, Clear scheduled job node association, Regenerate all text indexes, Bad MID Server credentials after clone, Install deactivated plugin, Schedule drop backup tables.
- **If one script errors, the following ones do not run**, so custom scripts need error handling. From Australia Patch 5 the status of each script is visible and failed ones can be resumed.
- Changes to cleanup scripts (defined on the source) must be made before the Restore phase to take effect in that clone.

## What a clone destroys on the target

In-progress work that exists only on the target: work-in-progress update sets, and applications not yet on the source. Export update sets before and re-import after, and reinstall such applications ([[Carry In-Progress Update Sets Through a Clone]]). An application in development on the target keeps being editable but at the source's version; if absent from the source, it is deleted.

## Other facts

- **Different releases**: allowed. The target ends up on the source's release.
- **Cloning over production**: only possible while `glide.db.clone.allow_clone_target` is true on it. The property is true by default on instances whose name ends in Dev, Test, Stage, UAT or QA. Set it back to false on production afterwards.
- **Clone Admin Console** (**All > Clone Admin Console**) replaces the legacy `clone_instance.do` page from Australia. Tabs: Clone Activity, Instance Overview (last-cloned times), Configuration, Help. Older history is in Clone History (`clone_instance`).
- **Authentication to the target**: OAuth 2.0 (Australia Patch 5 or later on both sides; one-time setup per target, no local admin account). Basic authentication is the fallback and needs a target user with `clone_admin`, `soap` and `identity_type` = machine (who can then no longer log in to the UI).
- **Multi-Instance View**: see clone activity and cleanup script status of linked instances from one primary instance.

## Related

- [[Request, Schedule, Cancel or Roll Back a Clone]] · [[Register a Clone Target Instance]] · [[Configure Clone Exclusions, Preservers and Cleanup Scripts]] · [[Clone Options and States]] · [[Clone Target Registration Errors]] · [[Update Sets]] · [[Application Repository, Publishing and Administering Apps]]
