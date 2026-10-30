---
type: concept
tags: [concept, integrations, flows, roles, domain-separation, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Integration Hub Remote Process Sync (overview, Getting started, process sync definitions, capture definitions), role, table and property mentions across the other pages, read at overview depth 2026-10-30. Build your first integration, attachment actions and field tables not read in full. https://www.servicenow.com/docs/r/integrate-applications/create-integrations-applications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Remote Process Sync

**In one line:** one-way or bidirectional sync of a business process across ServiceNow instances, with records, attachments and journal fields correlated and delivered in order. Replaces the eBonding spoke.

From the Brazil docs; not tested. Needs [[Integration Hub Overview and Subscription|Integration Hub]]: one page says a subscription, Getting started says the **Enterprise** package (unconfirmed variant). For service providers it keeps many customer instances in step.

Compared by the docs with [[Instance Data Replication (IDR) Overview]] and the Remote Instance spoke, which suit simple cases; this one integrates by high-level business process. Plan it with the people on the remote instance.

## Building blocks

A **Process Sync Definition** (Name, Description, Application, Domain) has related lists:

- **Capture Definitions:** when to send and what: the trigger (record create, update or delete), its conditions and the captured fields.
- **Process Events**
- **Remote Systems** (`ih_sync_remote_system`): the other instance, with the Inbound API user and **Run Inbound Flows as** user.
- **Outbound Flows**, **Inbound Flows:** Workflow Studio subflows.

A captured record goes to the outbound queue, the outbound subflow runs, and the remote side matches it through correlation.

## Queues

| Table | Holds |
|---|---|
| `ih_sync_outbound_record` | outbound queue: **IntegrationHub > Remote Process Sync > Outbound Queue State** |
| `ih_sync_inbound_record` | inbound queue |
| `ih_sync_correlation` | correlation |

## Roles

| Role | Can |
|---|---|
| `ih_process_sync` | create and change definitions and related records |
| `ih_process_sync_api` | APIs only; combined with `snc_external` on the integration user |
| `ih_process_sync_run_as` | run the flows; needs access to the tables they touch |

Remote credentials must match the user holding `ih_process_sync_api` on the other instance. The example build activates [[Explicit Roles and Elevated Privilege Roles|explicit roles]] on each instance. **Remote Process Sync Dashboard** (**All > Integration Hub > Dashboards**): `integration_admin` or admin; needs `glide.hub.process.sync.record.successful.status` = true.

## Properties

| Property | Controls |
|---|---|
| `glide.hub.process.sync.capture.non_interactive.changes` | capture of non-interactive changes; set false to skip them |
| `glide.hub.process.sync.retry.times`, `.retry.interval.seconds` | retries |
| `glide.hub.process.sync.jobs.inbound.process_maxtime`, `.outbound.process_maxtime` | job run time |
| `glide.hub.process.sync.jobs.inbound.subflow.execution_timeout`, `.outbound.subflow.execution_timeout` | subflow timeout |
| `glide.hub.process_sync.inbound_queue.<state>.ttl.seconds`, `.outbound_queue.<state>.ttl.seconds` | how long queue rows stay; states `ready`, `processed`, `skipped`, `error` |

Debug is written two ways: `glide.hub.process.sync.debug` and `glide.ih.process.sync.debug`. Unconfirmed variants. Then read the logs.

## Domain separation

Works across domain-separated instances. Configuration sits in the domain of the parent record; only records from that domain and its children are captured. The outbound row takes the source record's domain, the inbound row that of the Inbound API user. The inbound subflow runs in the domain of the **Run Inbound Flows as** user.

## Example

Definition *Example Request Fulfilment* captures updates when *State* (`state`) becomes Work In Progress, on *Incident* (`incident`). Remote system *Example Partner Instance* receives them through integration user *Example Sync User*; on return, a subflow updates the local record.

## Related

- [[Integration Hub Overview and Subscription]] · [[Instance Data Replication (IDR) Overview]] · [[Flow Spokes Shipped with the Platform]]
