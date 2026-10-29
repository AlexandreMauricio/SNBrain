---
type: concept
tags: [concept, data-management, flows, api, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MetricBase (whole chapter: Explore, Configure, Request the plugin, Working with demo data, View demo data, MetricBase APIs, Define and collect data, Create a time-series definition, Retention policy schedules, Retention policies, Accessing data, Access data from a list, Retrieving data, Detecting anomalies, Create and train a model, Trigger flows and the four trigger types, Execute triggers conditionally, Assign a trigger to a flow, View trigger logs, Manage, Reference, Developer resources, Domain separation, Roles), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/metricbase/metricbase.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# MetricBase

**In one line:** a separately licensed time-series database (plugin **MetricBase**, `com.snc.clotho`; scoped API namespace `sn_clotho`) that stores sampled, aggregated metric values outside the normal instance tables, charts them, and fires Workflow Studio flows when values cross bands, trend toward a threshold, stop arriving, or look anomalous.

From the Brazil docs; not tested. Step by step: [[Create a MetricBase Trigger and Flow]]. Uses in this vault: [[API Insights]] (API usage), [[Digital End-User Experience Overview and Architecture]] (device metrics, fixed policies), [[Workforce Optimization for ITSM]].

## Setup facts

- Activated by ServiceNow after purchase (production and sub-production, usually within days). Also ask for **MetricBase Demo** (`com.snc.clotho.demo`): a fictional drone fleet with tables, metrics, triggers, a scheduled job that adds data every five minutes, anomaly logs and the **Data Explorer** (role `clotho_admin`) for trying the JavaScript APIs.
- ServiceNow connects the instance to a MetricBase server. **One MetricBase database talks to one instance only**: a clone cannot share the original's database.
- Values are stored as **floats** only.

## Time-series definition

**MetricBase > Time Series Metrics > New** (role `clotho_admin`): **Label**, **Table name** (an instance table whose records are the subjects, e.g. a drone table), **Metric field name** (the series, like a virtual column), **Retention policy**, **Retention policy aggregator** (last, min, max, avg per sampling period), **Display value aggregator** and **Display value aggregate duration** (only for what `<table>.list` shows, unrelated to retention), **Subject field** (a unique column, default `sys_id`) and its **Data Type**.

Data is then sent by REST or JavaScript **at the rate the retention policy expects**, already aggregated; other rates or durations give errors.

## Retention policies

Policies (**MetricBase > Retention Policies**) chain schedules that get coarser over time; data is deleted after the last one. Policies cannot be customised on the metric; schedules (**Retention Policy Schedules**) have limits: max 26 months (794 days), max sampling period 1 day, max 160,000 data points, and the duration must be a multiple of the period.

| Policy | Schedules |
|---|---|
| Ultra Dense | 1 day at 10 s, 3 months at 1 min, 1 year at 1 h |
| Dense | 8 days at 1 min, 94 days at 10 min, 13 months at 1 h |
| Operational Intelligence | same as Dense |
| High | 1 week at 1 min, 1 month at 10 min, 13 months at 1 h |
| Medium | 1 week at 10 min, 1 month at 30 min, 13 months at 2 h |
| Medium High | 13 months at 1 h |
| Coarse | 1 week at 1 h, 1 month at 2 h, 13 months at 1 day |
| Sparse | 13 months at 1 day |

Use the coarsest policy that works. The demo walk-through describes a policy of 1 min for 8 days, 10 min for 94 days and then 1 h for **397** days, while the Dense row says 13 months (397 days is about 13 months, so likely the same thing).

## Reading the data

- `<table>.list` in the navigator, then column menu **Time Series Chart** (Time Span, Transform, ad-hoc Add / Multiply / Divide not saved) or **Time Series Chart Designer** (Reporting, e.g. the **Envelope** transform for min and max).
- REST: **MetricBase Time Series API**. JavaScript (scoped `sn_clotho`): `Client` (run transforms), `Data`, `DataBuilder` (build points to insert), `Transformer` (e.g. `metric('<metric>').avg()`, `groupBy('<field>')`, `fit({model: 'linear'})`), `TransformPart`, `TransformResult`. The endpoint `now/v1/clotho/transform/topic` is internal only.

## Anomaly models

**MetricBase > MetricBase Models > New**: model name, table, metric, filter (train on normal-looking data), **Group by** (one model per value, e.g. per server role), **Model Class** (PEWMA, ARIMA, STL, Holt-Winters, or the default **Find Best Fit Model**), training start and end dates, **Valid until** (a retrain reminder only), Active. **Submit and Train**; results appear on **MetricBase Model Instances**; **Set Model** overrides the trained parameters.

## Triggers

Trigger definitions (**MetricBase > MetricBase Triggers > Trigger Definitions**; the gap trigger page says **MetricBase > Workflow Studio > Trigger Definitions**, an unconfirmed menu variant) run nothing alone; a flow with the **MetricBase** trigger type does the work. Each trigger has **levels** (higher = more severe, usually one flow per level).

| Type | Fires when | Level columns |
|---|---|---|
| **Band** | aggregated value (None = last, Max, Min, Average over a **Window**) falls inside or outside a band | Function + Value (lower end), Band Function + Band Value (upper end), **Tolerance** against flapping; at least two levels |
| **Linear predictor** | a line fitted over the definition **Window** (at least 10 sampling periods) with a **Confidence Level** and **Trend** (up/down) is predicted to reach the **Threshold**; also fires if the latest point already reached it | Function (Less than or is), Window = how far ahead to look |
| **Gap** | no data for a duration (`hh:mm:ss`) | Function (Greater than or is), Window; levels at least 10 minutes apart. Polling = floor((difference between level gaps)/2), between every 5 and every 30 minutes (30 with one level), so it can fire late |
| **Model** | value deviates from a trained model by N standard deviations; **Spike Direction** upward, downward or either | Function (Greater than or is), Number of Standard Deviations; table and metric come from the model |

- **Condition scripts** (also "moderator scripts"; **MetricBase Triggers > Trigger Condition Script**): server-side JavaScript, global or scoped, function `filter(triggerDefinition, current, start, level)` returning true to run the flow. Must be fast. Attach in the flow trigger, or in **MetricBase Trigger Flows** (`sys_flow_metric_trigger`), where it does not show in Workflow Studio but still runs.
- A trigger used by a flow cannot be deleted until the flow is deleted. **Legacy triggers** are deprecated (existing ones carry forward, no new ones).
- Logs: **MetricBase Triggers > Trigger logs > Show Log Entries**.

## Health and debugging

- **MetricBase > MetricBase Health Dashboard** (`clotho_admin`): **Health** (database connection, **MetricBase Lag Statistics**: several seconds means contact support), **Series** (Total Series Count, stale series ratio for a staleness period, Data Utilization Efficiency = share of non-null points, Average Unutilized Data Gap).
- **System Diagnostics > Stats > Stats** (MetricBase Statistics), **MetricBase > MetricBase Status** (personalise columns), **System Diagnostics > Session Debug > Debug MetricBase** (shows transforms and their duration at the bottom of pages).

## Roles and domain separation

| Role | Purpose |
|---|---|
| `clotho_admin` | MetricBase administrator; contains `flow_designer`, `clotho_rest_accumulate`, `clotho_rest_put` |
| `clotho_rest_accumulate`, `clotho_rest_put` | REST accumulate and PUT |
| `mbplus_reader`, `mbplus_writer` | query / modify "MetricBase plus" tables (not explained further on the page) |

Several task pages say `admin` instead of `clotho_admin`. Domain separation: **Basic** support ([[Domain Separation Support Levels by Application]]).

## Related

- [[Create a MetricBase Trigger and Flow]] · [[Flow Trigger Types Reference]] · [[Building Flows - Properties, Triggers, Stages and Error Handling]]
