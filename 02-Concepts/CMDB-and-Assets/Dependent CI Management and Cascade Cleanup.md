---
type: concept
tags: [concept, cmdb, data-integrity, data-management, automation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB classifications and class dependency, topic "Dependent CIs management" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBClassifications.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Dependent CI Management and Cascade Cleanup

**In one line:** when a CI is retired, archived or deleted, the CIs that depend on it (its network adapters, the applications hosted on it) become orphans; this feature finds them and raises CMDB Data Manager tasks to retire, archive or delete them too.

Dependent and independent classes are explained in [[CI Classes, Dependency and Principal Class]].

> "Orphan" here means a CI of a dependent class that has lost its dependent relationship. CMDB Health uses a wider definition (any CI matching a health orphan rule).

## Turning it on

1. Set up [[CMDB Data Manager]] (retirement definitions, Managed by Group for approvals).
2. Properties. **None of them exists in the base system: add each to `sys_properties` to see or change it.**

| Property | Default | Effect |
|---|---|---|
| `cmdb.dependent.ci.cascade.op.enabled` | true | task creation and cascade operations |
| `cmdb.dependent.ci.cascade.retire.enabled` | false | cascade retirement; the business rule that tracks retired CIs runs only when true |
| `cmdb.dependent.ci.extra.rel.check` | true | true = relationships outside the dependency chain ("extraneous") are **not** deleted or archived |
| `cmdb.dependent.ci.stale.record.cleanup.duration` | 2 days (dependent ledger), 1 day (end-of-life ledger) | days a ledger row may stay in PROCESSING before it is reset to NEW. Zero or negative = default. Guideline 1 to 3 days; 3 to 5 where processing jobs run long |

- Turn off completely: both `cascade` properties false. Stop only task creation: `cascade.op.enabled` false.
- Cleanup applies from the moment it is enabled. For orphans that already exist, activate the scheduled job **Cleanup Orphan CIs**: it scans the whole CMDB once, then deactivates itself. It can take days on a large CMDB.

## How the work is done

Candidates are written to **CMDB Dependent CI Ledger** (`cmdb_dependent_ci_ledger`) with an action. The scheduled job **CMDB DependentCI Policy Processor** then creates a Data Manager task against one of three on-demand policies: *Dependent CI - Deletion*, *Dependent CI - Archive*, *Dependent CI - Retire*.

- A Data Manager admin (or the **Managed By Group**) must approve each task. To run without approval, clear **Needs Review** on the policy.

| Trigger | What happens |
|---|---|
| **Retire** (Life Cycle Stage set to End of Life) | business rule *Track "Retired" CIs* adds the CI to **CMDB CI End Of Life Ledger** (`cmdb_ci_end_of_life_ledger`) if its class has downstream dependencies. Scheduled job **CMDB Cascade Retire Dependent CIs** reads its relationships in `cmdb_rel_ci` and adds each dependent CI to the dependent ledger with action Retire |
| **Archive** | the CI's relationship rows are archived with it; CIs orphaned by that are added to the ledger |
| **Delete** | the CI's relationship rows are deleted; business rule *CMDB Dependent CI Delete* checks the other end of each one and adds orphans to the ledger with action Delete |

A CI is **not** treated as an orphan (so not archived or deleted) when:

- it is an unhandled duplicate (an open de-duplication task refers to it),
- it has more than one parent CI, or
- its class is in **CMDB Dependent CI Class Exclusion** (`cmdb_dependent_ci_class_exclusion`). Pre-filled with `cmdb_ci_vm`, `cmdb_ci_vmware_instance` and other VMware classes; add or remove rows as needed.

Relationships outside the dependency chain are tracked in **Dependent CI Relations Evaluation Config** (`cmdb_dependent_ci_extra_rels_config`).

## Stuck records

Ledger rows are set to PROCESSING while handled. If processing crashes or times out they stay there; a cleanup job resets rows not updated within `cmdb.dependent.ci.stale.record.cleanup.duration` days to NEW and reassigns them to the current node. The system log records how many were reset.

## Example: cascade retire

1. Enable the feature, including `cmdb.dependent.ci.cascade.retire.enabled`.
2. In CMDB Data Manager create and publish a Retire policy covering an independent CI, for example a Linux server with a network adapter and a file system.
3. Scheduled job **CMDB Data Manager Retire Policy Processor** creates the task. Approve it on the Data Manager overview page (set the task to Work in progress if it does not move by itself). The server is retired and added to `cmdb_ci_end_of_life_ledger`.
4. **CMDB Cascade Retire Dependent CIs** adds the adapter and file system to `cmdb_dependent_ci_ledger` (state Ready, action Retire).
5. **CMDB DependentCI Policy Processor** creates the "Dependent CI - Retire" task. Approve it.

## Related

- [[CI Class Manager]] · [[CMDB Overview and Class Hierarchy]]
