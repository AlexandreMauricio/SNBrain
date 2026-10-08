---
type: reference
tags: [reference, flows, automation, email, service-catalog, sla, api]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Reference > Workflow Studio flow trigger types (read 2026-10-08 through the docs site). https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/flow-triggers.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flow Trigger Types Reference

**What it is:** every way a flow can start, the options of each, and the data pills the trigger hands to the flow. Building with them: [[Building Flows - Properties, Triggers, Stages and Error Handling]]. Reusable triggers: [[Saved Triggers and External Event Sources]].

## Record triggers

**Created**, **Updated**, **Created or Updated**, on a non-system table plus conditions. The two update types ask *when to run*:

| Option | Behaviour |
|---|---|
| **Once** | one run in the life of the record |
| **For each unique change** | a run for every unique update to a non-system field, even while a run is in progress. The system remembers earlier values: State In Progress > On Hold triggers, going back to In Progress does not. Can recurse in non-interactive sessions when the flow itself updates the trigger record |
| **Only if not currently running** | every unique change, unless a run on this record is still going (the old *Always*) |
| **For every update** | every update, regardless of running contexts |

Flows that ask for approval should trigger **once**; to resubmit, use *Go back to* ([[Flow Logic Reference]]).

### Advanced options

| Group | Options |
|---|---|
| Session | Only Run for Non-Interactive Session / Only Run for User Interactive Session / Run for Both |
| User | Run for any user / Only run if triggered by the following users / Do not run if triggered by the following users |
| Table | Run only on current table / Run on current and extended tables |
| Where | **Run flow in background** (default, asynchronous) / **Run flow in foreground** (in the user's session, so the user sees the result at once, at the cost of waiting) |

## Other trigger types

| Type | Triggers | Needs |
|---|---|---|
| REST | **REST API - Asynchronous**: an inbound API call or webhook, start conditions configured without code | Integration Hub Enterprise |
| Scheduled | Daily, Weekly, Monthly, Run Once (a past time means as soon as possible), Repeat (an interval) | none. Uses the instance time zone; start can lag behind the schedule because flows are queued |
| Application | Kafka Message, MetricBase, Proactive Analytics, **Service Catalog**, **SLA Task** | the application concerned |
| Inbound Email | an email received | email receiving on |
| Spoke | conditional or event-driven webhooks from a third-party product | the spoke, an external trigger endpoint |

### Inbound email processing order

1. The email is classified as new, reply or forward.
2. Active inbound email **triggers** are evaluated first. A match runs its flow.
3. If that flow issues *stop processing*, the email is done. By default one flow per email; multiple flows need extra configuration ([[Building Flows - Properties, Triggers, Stages and Error Handling]]).
4. Only when no trigger is left does the system try inbound email **actions** ([[Inbound Email Actions]]).

Flows give control that inbound actions lack: moving attachments, choosing the target record, reading single attachments. They run as the sender; when that user lacks roles, have the flow call a subflow that runs with the roles needed. Comparison: [[Inbound Email Flow or Inbound Email Action]].

## Pills by trigger

| Trigger | Pills |
|---|---|
| Record | **[Table] Record**; **Changed Fields** (array, update triggers only: loop with For Each); **[Table] Table**; **Run Start Date/Time** (instance time zone); **Run Start Time UTC** (string) |
| Scheduled | Run Start Date/Time, Run Start Time UTC |
| REST API - Asynchronous | Path Parameters, Query Parameters, Request Headers, Request Body (complex object) |
| Service Catalog | **Requested Item Record**, Table Name, Run Start Date/Time, Run Start Time UTC |
| SLA Task | **Task SLA Record**, `sla_flow_inputs` (object with SLA definition values) |
| Inbound Email | **Email Record**, [Table] Table (of the target), **Subject**, **Body Text**, **User Record** (Guest when the sender is unknown), **From address** |
| MetricBase | MetricBase Trigger Definition Record, Level, Time of Metric Event, Record |
| Kafka Message | Messages: array of Headers (key and value), Payload, Key |

## Guidelines

- Trigger = fixed start data. Variable input = subflow.
- Narrow conditions; distinct conditions per flow on a table.
- Records written by update sets or XML import never trigger.
- Catalog tables: use the Service Catalog trigger.
- The triggering user must be able to read what the conditions test; if the conditions need role-restricted data, give the flow that role (flow roles).

## Related

- [[Saved Triggers and External Event Sources]] · [[Flow Core Actions Reference]] · [[Flows, Subflows and Actions Overview and Architecture]]
