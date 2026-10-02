---
type: concept
tags: [concept, instance-admin, scripting, update-sets]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Instance Scan" (pp. 2750-2786), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Instance Scan

**In one line:** a built-in linter for your configuration: **checks** look for bad practice (security, upgradability, performance, manageability, user experience), **scans** run them, and each violation becomes a **finding** pointing at the offending record.

## Vocabulary

| Term | Meaning |
|---|---|
| Check | one rule. Has category, priority, resolution details, a version that increments on change |
| Suite | a bundle of checks and child suites. Store/ServiceNow suites are protected |
| Scan | one execution. Produces a **result** (status In progress, Pending, Complete, Failed, Cancelled) |
| Finding | a record that broke a check, with **Source table**, **Source**, **Count**. Can be **muted** (with a reason) or get a **scan task** |

## Check types

| Type | Works on | Notes |
|---|---|---|
| Table check | one table + conditions | without **Advanced**, every matching record is a finding; with it, a script decides |
| Column type check | every column of a given type, all tables | script per record |
| Script only check | nothing in particular | runs once, **only in a full scan** |
| Linter check | script fields | gets the parsed syntax tree as `engine.rootNode` |

In scripts, `engine.current` is the record and `engine.finding.increment()` raises a finding.

```javascript
(function (engine) {
    engine.rootNode.visit(function (node) {
        if (node.getTypeName() === "NAME" &&
            node.getNameIdentifier() === "badFunction" &&
            node.getParent().getTypeName() === "CALL") {
            engine.finding.incrementWithNode(node);
        }
    });
})(engine);
```

This flags real calls to `badFunction()` and ignores comments, strings and same-named methods.

## Scan types

| Scan | Runs | Where |
|---|---|---|
| Full | all active checks, whole instance | **Instance Scan > Checks > Execute Full Scan**, or scheduled |
| Suite | one suite against the full instance, scoped apps or update sets | suite form > **Execute Suite Scan** |
| Point | applicable checks on one record | **Run Point Scan** related link (record on a `sys_metadata` table, active) |
| Update set | applicable checks on the **current** version of records in the set | update set form > **Scan Update Set** |
| Application | an app's files | application record > **Scan Application** |
| Test | one check | check form > **Test Check** |
| Reactive | automatically when an execution tracker fails | triggers in `scan_trigger` |

- By default scans look only at **customised, active** records. Point scans also look at base records. Properties `glide.scan.base_system_records` and `glide.scan.inactive_records` change that.
- An update set scan does not see problems that exist only in the update set's stored version.

## Limits and housekeeping

- Scan timeout: 3 hours (transaction quota rule **Scan timeout**, 10,800 s). Check timeout: 10 minutes (`glide.scan.process_check.time_out`, 600 s). Minimum 5 s.
- Parallel scans: `glide.scan.queue.enabled` and `glide.scan.parallel_scan_enabled` (both true), `glide.scan.max_parallel_scans` (5, range 1 to 15). Not for point scans. Extra scans wait as Pending.
- Results older than 90 days, and test-scan results older than 14 days, are removed by table cleaner policies (**Instance Scan > Table Cleanup**). See [[Table Cleaner]].
- Not fully domain-separation aware.

## Roles

`scan_user` (run scans, read checks, results, findings), `scan_check_writer`, `scan_admin` (create checks). Many scan actions in the guide ask for admin.

## Reviewing

- **Instance Scan > Results** > a result > related lists Scan Findings, Checks, Failures, Scan Log, Target. **Results Dashboard** compares with the previous scan; **Rescan** repeats.
- **Instance Scan > Dashboard** (full scans only): filter by category and priority, watch trends.
- **Resolved** on a finding is a manual status, not proof it is fixed.

## When to use

Before promoting an update set, before and after an upgrade, and on a schedule to get a baseline. See [[Scan an Update Set or Record with Instance Scan]].

## Related

- [[Rollback and Delete Recovery]] · [[Instance Clone Overview]]
