---
type: how-to
tags: [how-to, instance-admin, update-sets]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Using Instance Scan", topics "Execute a point scan", "Execute an update set scan", "Mute a finding" (pp. 2766-2780), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Scan an update set or a record with Instance Scan

**Goal:** check your own changes against the instance's checks before moving them.
**Prerequisites:** role admin (point scan: `scan_user`). Active checks exist.
**Navigation:** All > System Update Sets > Local Update Sets

## Steps

Update set:

1. Open the update set.
2. Under Related Links select **Scan Update Set**.
3. When the tracker finishes, **Go to Result**.

Single record (business rule, client script, any `sys_metadata` record):

1. Open the record and select **Run Point Scan** under Related Links.
2. **Go to Result**.

## Result / how to check it worked

On the Scan Result: **Scan Findings** lists violations (source record, check, count); **Checks** lists what ran; **Failures** lists checks that errored. To silence an accepted finding, open it and select **Mute** with a reason.

## Example

Update set *Example - incident form changes* containing one business rule: only checks targeting `sys_script` (and linter/column-type checks that apply) run against that rule.

## Tables / fields involved

- `scan_result`, `scan_finding`, `scan_check` (names as commonly used; this guide names only `scan_task` and `scan_trigger`)

## Gotchas

- The update set scan reads the **current** record, not the version captured in the set.
- **Run Point Scan** is hidden if the record is inactive, no check applies, or `glide.scan.enable_point_scan_ui_action` is false.
- Script-only checks never run here (full scan only).
- Background: [[Instance Scan]].
