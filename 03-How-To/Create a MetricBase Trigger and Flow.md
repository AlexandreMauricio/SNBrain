---
type: how-to
tags: [how-to, data-management, flows, scripting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MetricBase > Create a time-series definition, Create a MetricBase band / linear predictor / gap / model trigger, Execute triggers conditionally, Assign a trigger to a flow, View trigger logs, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/metricbase/metricbase-triggers.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Create a MetricBase Trigger and Flow

**Goal:** store a metric in MetricBase and run a Workflow Studio flow when it misbehaves. Concepts, trigger types and retention policies: [[MetricBase]].

From the Brazil docs; not tested. Needs the MetricBase subscription. Roles: `clotho_admin` for metrics, `admin` on most trigger pages.

## Steps

1. **Metric**: **MetricBase > Time Series Metrics > New**: label, table, metric field name, retention policy, retention policy aggregator, subject field. Submit.
2. **Send data** at the policy's sampling rate, pre-aggregated, as floats: REST (MetricBase Time Series API) or server-side JavaScript in the `sn_clotho` scope API (`DataBuilder` + `Client`), for example from a scheduled job.
3. Check it: `<table>.list`, column menu **Time Series Chart**.
4. **Trigger**: **MetricBase > MetricBase Triggers > Trigger Definitions > New**, pick **Band**, **Linear Predictor**, **Gap** or **Model** (a model needs **MetricBase Models > New > Submit and Train** first). Fill the header, **Save**, then double-click cells in the **Trigger Levels** list to add levels, **Update**.
5. Optional **condition script**: **MetricBase Triggers > Trigger Condition Script > New** (server-side, global or scoped): `filter(triggerDefinition, current, start, level)` returns true to continue.
6. **Flow**: **MetricBase > Trigger Flows > New Flow** (name, application, protection, Run As, Run with roles) **> Add a trigger > MetricBase**: select the trigger, optional filter conditions and condition script; add actions (for example create an incident, send an email).
7. **Test** in Workflow Studio: choose the level, time of metric event and the record (nothing is created by the trigger itself). Then **Activate** the flow.
8. Watch **MetricBase Triggers > Trigger logs**.

## Example

| Item | Value |
|---|---|
| Table | `u_example_server` (a custom table, one record per monitored server) |
| Metric | **Example CPU Percent** (`u_example_cpu`), policy **High**, aggregator Average |
| Data | a scheduled job every minute posting the average CPU per server |
| Band trigger | **Example CPU High**, aggregator Average, Window 5 minutes; level 1: above 85 (tolerance 2); level 2: above 95 |
| Gap trigger | **Example CPU Missing**: level 1 00:10:00, level 2 00:30:00 |
| Condition script | **Example Ignore Maintenance**: returns false when the server record's maintenance flag is true |
| Flow | **Example CPU Alert**: level 1 sends an email to Example Group, level 2 creates an incident for Example Group |

Condition script sketch (server-side, global scope; field name invented):

```javascript
function filter(triggerDefinition, current, start, level) {
    // skip servers flagged as in maintenance
    if (current.u_in_maintenance == true)
        return false;
    return level >= 1;
}
```

## Related

- [[MetricBase]] · [[Flow Trigger Types Reference]] · [[Building Flows - Properties, Triggers, Stages and Error Handling]]
