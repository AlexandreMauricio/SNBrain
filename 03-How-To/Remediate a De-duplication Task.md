---
type: how-to
tags: [how-to, cmdb, data-integrity, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB data management > Duplicate CIs remediation, topics "Review de-duplication tasks (manual)", "Remediate a de-duplication task (manual)", "Remediate a single de-duplication task", "Create a de-duplication template", "Run a template to process de-duplication tasks", "Publish or unpublish", "Schedule", "Retire a de-duplication template" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-data-management-landing.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Remediate a De-duplication Task

**Goal:** resolve duplicate CIs: one task with the Duplicate CI Remediator, or many with a template.
**Roles:** view `sn_cmdb_editor` or `itil`; remediate `cmdb_dedup_admin`, `sn_cmdb_admin` or `itil_admin`.
**Before you start:** read [[Duplicate CI Remediation]] (main CI, what merges, related tables). To rehearse without changing anything, set `glide.duplicate_ci_remediator.dry_run` to true.

## A. One task with the Duplicate CI Remediator

1. **All > Configuration > Identification/Reconciliation > De-duplication Tasks** > open the task. **Work notes** say how the duplicates were detected; related list **Duplicate Audit Results** lists the CIs (with **Relationship** and **Depend on CI** for dependent CIs, and **Discovery source**).
2. **Remediate** > choose **Use the Duplicate CI Remediator** (also offered: the AI option with Otto, a custom remediation workflow, Restricted Mode).
3. **Select Main CI:** from **Recommended** (most related items, most relationships, newest discovered, newest updated, oldest created, previous main CI) or **All**. Then:
   - **Remediate Manually** to choose what to merge, or
   - **Use Main CI**: keep the main CI's values, merge relationships and default related items only; skip to step 6.
4. **Merge Attribute Values:** for each attribute with differing values, keep **Main CI Value** or open **Other Values** and pick one.
5. **Merge Relationships and Related Items:** merge all relationships or not; choose related tables in the list collector (default list preselected).
6. **Determine Duplicate CI Actions:** **Set attributes to custom values** (recommended; for example Operational Status = Retired) or **Delete**.
7. **Review and Confirm** > **Remediate**. Nothing is changed until this click. It runs in the background; the task ends **Closed Complete** and the remediator is notified.

## B. Many tasks with a template

1. **Workspaces > CMDB Workspace > Governance > Management tools > De-duplication Template Library** > optionally **Create a library** > **Create a template**:
   - **General information:** Name, **Class**, library; **Automatically select all de-duplication tasks that match the selected class**, **Add all child classes**.
   - **Create condition:** a filter on the CIs, or (**Use script**) a script returning an array of `reconcile_duplicate_task` sys_ids.
   - **Select main CI:** Newest updated, Most related items, Oldest created, Most relationships, Discovery source, Has asset, or by condition. If the method yields none or several CIs, *Newest updated* is used.
   - **Merge attributes:** assign attributes to a merge method; options **Allow null value updates from duplicate CIs to main CI** and **Allow updates from duplicate CIs only when the main CI value is null**.
   - **Merge relationships:** all, none, or by condition.
   - **Merge related items:** default list, none, all available, or by condition.
   - **Duplicate CI actions:** Delete, or Set attributes to custom values.
   - **Review and test:** pick a sample task > **Save and Preview Results** > **Save & Exit**.
2. **Publish** the template (library pane > **Publish**).
3. **De-duplication Dashboard** > the template's card > **Assign tasks** (add from *Available de-duplication tasks*) > **Run template**. Or **Run all**.
4. Watch **Running**, then **Completed** > **Details** for per-task state and errors. The insights pane links to tasks completed with errors and tasks matching no template.
5. Optional: card > More options > **Create schedule**.

A single task can also be sent through a template: dashboard > **View de-duplication tasks** > task > **Remediate** > **Remediate using a template**.

## Example

Three Linux server CIs named `example-host-01` share a serial number and sit in one task. Route A: main CI = the oldest created (recommended list), **Remediate Manually**, keep its attribute values except **Operating System** taken from the newest CI, merge all relationships and the default related items, **Set attributes to custom values**: Operational Status = Retired. After **Remediate**, the two others carry `duplicate_of` = the main CI and are retired.

## Gotchas

- **Delete cannot be undone from here** (see the platform's rollback and delete recovery).
- Changing any choice after using the AI option switches to manual mode; the main CI chosen by the skill cannot be changed.
- A published template cannot be edited: unpublish first (not while it is running or queued).
- The remediator is not available for non-CMDB tables.
- After remediation, review the class's identification and inclusion rules so the same duplicates do not come back ([[IRE Identification Rules]]).

## Related

- [[Duplicate CI Detection in IRE]] · [[CMDB Workspace]]
