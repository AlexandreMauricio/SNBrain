---
type: how-to
tags: [how-to, cmdb, data-integrity, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE), topic "Identification simulation" (generate payload, simulate, logging level, examine run logs) (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Simulate an IRE Payload with Identification Simulation

**Goal:** build a valid IRE payload for a class and see what [[Identification and Reconciliation Engine (IRE) Overview|IRE]] would do with it (insert, update, error) **without committing anything**.
**Where:** **All > Configuration > Identification/Reconciliation > Identification Simulation**.
**Roles:** `sn_cmdb_admin` or `admin` (running an existing payload: `admin`).

## Generate a payload

1. **Start with CI Class** > **Start**.
2. **Data source**: the source the update would come from (for Discovery choose *ServiceNow*).
3. **Class**.
4. **Criterion Attributes**: pick an identifier's attributes and give the values that identify the CI.
5. **Additional Attributes**: values a matching CI would be updated with.
6. Dependent class: fill the same two sections for every **Container level** shown.
7. **Generate Script**. Fill any fields reported missing and generate again.
8. **Copy Script** to reuse the JSON elsewhere.

## Run a simulation

1. With the generated payload, or **Start with Existing Payload** > **Start** > choose the **Data source** > paste the JSON. Optional: **Use Enhanced Identification** (uses `identifyCIEnhanced` instead of `identifyCI`).
2. **Run Simulation**.
3. In the results pane, **Run #1** shows the Context ID and Run ID; expand it for **Input**, **Logs** and **Output**.
4. Adjust rules or payload and run again. When right, send the payload for real with `createOrUpdateCI()`.

## Logging

- Settings icon in the simulation: **IE Log Level** and **Service Cache Log Level**.
- Real runs: **Configuration > Identification/Reconciliation > Identification Logs**, filtered by **Source** and **Time Range**. Up to 1000 runs (property `glide.identification_logs.max_run_ids`), up to 2 months old. One **Context ID** per payload, one **Run ID** per execution of it.
- Level for real runs: Discovery property `glide.discovery.identification.log_level` (Info, Warn, Error, Debug, DebugVerbose, DebugObnoxious).

## Example

Class **Linux Server**, data source *ServiceNow*, criterion attribute **Serial number** = `EX-0001`, additional attribute **Name** = `example-host-01`. **Generate Script**, **Run Simulation**. The output shows an INSERT if no CI has that serial number, or an UPDATE naming the matched CI. Change the serial to one that two CIs share and the output reports the duplicates instead.

## Gotchas

- Generation does not support non-CMDB tables; simulation of a hand-written payload with them does.
- A payload with two items identical on a class identifier is rejected before any rule runs.
- The simulation stores its work in `cmdb_ie_context`, `cmdb_ie_run` and `cmdb_ie_log` ([[IRE Properties and Tables Reference]]).

## Related

- [[IRE Error Messages]] · [[IRE Identification Rules]]
