---
type: concept
tags: [concept, cmdb, data-integrity, integrations, api, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CMDB Identification and Reconciliation (IRE)" > Explore (Components and process, Identification and Reconciliation Engine), "General guidelines for using CMDB Identification" (payload part), "IRE support for non-CMDB tables" (overview; the per-rule procedures for non-CMDB tables repeat the CMDB ones and were only skimmed), Reference > "Domain separation" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html and the pages under it), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-11-06
---

# Identification and Reconciliation Engine (IRE) Overview

**In one line:** IRE is the gate every well-behaved data source passes through before writing to the CMDB: it **identifies** each incoming CI (does it already exist?) and **reconciles** updates (is this source allowed to change this attribute?), so several sources can feed the CMDB without creating duplicates or overwriting each other.

Used by Discovery, Service Mapping, Event Management, Service Graph Connectors and IntegrationHub ETL, CMDB Workspace (manual create and edit), and by import sets or third parties that call its APIs.

## The two halves

| | What | Driven by | When |
|---|---|---|---|
| **Identification** | match the payload item to an existing CI, or decide it is new | identification rules ([[IRE Identification Rules]]), or the source's own unique key | always |
| **Reconciliation** | allow or reject each attribute update according to the source | reconciliation, data refresh and data source rules ([[IRE Reconciliation, Data Refresh and Data Source Rules]]) | **updates only**; an insert is not reconciled |

- The CMDB is updated in real time. **There is no staging area** in which to check the result first (use [[Simulate an IRE Payload with Identification Simulation]]).
- Side products: **de-duplication tasks** when duplicates are found ([[Duplicate CI Detection in IRE]]) and **reclassification tasks** when a class change is needed but not allowed ([[CI Reclassification During IRE Processing]]).
- A new class inherits identification and reconciliation rules from its parent.
- **Dynamic IRE** replaces hand-written identification rules for hardware classes: [[Dynamic IRE]].

## APIs

Server-side. Global: `SNC.IdentificationEngineScriptableApi`. Scoped apps: `sn_cmdb.IdentificationEngine.<method>` (plugin Configuration Management For Scoped Apps, `com.snc.cmdb.scoped`, active in the base system). Also exposed over REST.

| Method | Does |
|---|---|
| `createOrUpdateCI()` | insert or update according to the rules. **No partial commit**: one bad item fails the whole payload |
| `identifyCI()` | same decision, nothing committed |
| `createOrUpdateCIEnhanced()` | adds the enhanced options below |
| `identifyCIEnhanced()` | enhanced, nothing committed |
| `CMDBTransformUtil` | for import set transform maps only ([[Apply IRE to an Import Set]]) |

Enhanced options:

| Option | Default | Effect |
|---|---|---|
| `partial_payloads` | on | park items that cannot yet be identified. Turns the next two on regardless |
| `partial_commits` | on | valid items are committed even if others fail |
| `deduplicate_payloads` | on | identical items inside one payload are merged |
| `generate_summary` | off | adds counts per class to the output |

## Payload shape

```json
{ "items": [
    { "className": "cmdb_ci_linux_server",
      "values": { "name": "example-host-01", "serial_number": "EX-0001" },
      "lookup":  [ { "className": "cmdb_serial_number",
                     "values": { "serial_number": "EX-0001", "serial_number_type": "system", "valid": "true" } } ],
      "related": [ ],
      "sys_object_source_info": { "source_name": "ExampleSource", "source_native_key": "1001",
                                  "source_feed": "computers", "source_recency_timestamp": "2026-01-01 13:00:00" } }
  ],
  "relations": [ { "parent": 0, "child": 1, "type": "Runs on::Runs" } ] }
```

- `relations` point to items by index or by an optional `internal_id`. `referenceItems` adds references between any two items (main, lookup, related).
- Item-level `settings` and flags control reclassification.
- The data source passed to the API must be a valid choice of **Discovery source** (`discovery_source`) on `cmdb_ci`.

## How a CI is identified

1. **By source key:** if `sys_object_source_info` carries `source_name` + `source_native_key` and **Source** (`sys_object_source`) already knows that pair, the CI is found directly. Fast, no rules involved. Property `glide.identification_engine.skip_sys_object_source_matching` = true makes rules win whenever the payload has criterion attributes (useful when a source's identifying attributes change while its key does not).
2. **By `sys_id`** in `values`, when the caller knows it.
3. **By identification rule:** identifier entries tried in priority order.
4. **Dependent CIs** are identified only after the CI they depend on: a Tomcat is found *in the context of* its server, because a config path alone repeats on many hosts.

## Timestamps IRE maintains

- **Most recent discovery** (`last_discovered`) and **Discovery source** (`discovery_source`) are updated on **every** processing, even when nothing else changes. A `last_discovered` in the payload is used only if newer than the CI's; without one, now is used.
- **First discovered** (`first_discovered`): payload value or now on insert; later only if the payload supplies it.
- `source_recency_timestamp` updates `last_scan` in `sys_object_source`.
- Properties changing this are in [[IRE Properties and Tables Reference]].

## Partial and incomplete items

| Kind | Meaning | Stored in | Later |
|---|---|---|---|
| **Partial** | not enough to identify yet, but has a source key or criterion attributes, and one of the errors MISSING_MATCHING_ATTRIBUTES, REQUIRED_ATTRIBUTE_EMPTY, MISSING_DEPENDENCY, INSERT_NOT_ALLOWED_FOR_SOURCE | **CMDB IRE Partial Payloads** (`cmdb_ire_partial_payloads`, JSON), keys in `cmdb_ire_partial_payloads_index` | merged with a later payload that matches its identifier key, then committed and deleted. **Deleted after 90 days** otherwise |
| **Incomplete** | cannot be identified at all, or another error | **CMDB IRE Incomplete Payloads** (`cmdb_ire_incomplete_payloads`) | logging only, never reprocessed |

Typical case: a disk feed names the computer only by source key; the disk and computer items wait as partial until the computer feed supplies the computer's attributes. Conflicts on merge are settled by `source_recency_timestamp` (same source key) or by static reconciliation rules. A partial payload holds at most `glide.identification_engine.partial_payload_items_max_size` items (1000) before being split.

## Payload guidelines

- **At most 500 CIs per payload.**
- No two items with the same criterion values (DUPLICATE_PAYLOAD_RECORDS).
- **Do not send system fields** (`sys_domain`, `sys_updated_on`, `sys_mod_count`...).
- Send the minimum criterion attributes the rule needs; send `sys_id` when known.
- When many CIs depend on the same CI, **serialize the calls**: concurrent inserts under one parent clog the system.

## Before and after scripts

IntegrationHub ETL lets a data source of a CMDB integration run custom scripts: **before** (sees the batch of input payloads; can modify one or mark it SKIPPED with a reason shown on the import set row) and **after** (sees input and output; has the sys_ids IRE created or updated).

## Non-CMDB tables

From Brazil, IRE also works on some tables outside the CMDB:

- In an application scope: any non-CMDB table.
- In global: only those preset in the base system. Brazil: Location (`cmn_location`), Department (`cmn_department`), Cost Center (`cmn_cost_center`), Building (`cmn_building`), User ([[sys_user]]), Group ([[sys_user_group]]).

Differences: **only independent identification rules**; no relationships in payloads; `discovery_source`, `last_discovered`, `first_discovered` are filled only if the columns exist; the table name stands in for `sys_class_name`. **CI Class Manager cannot manage these rules**: use the list views (**Identification/Reconciliation > CI Identifiers**, and the reconciliation, data refresh, inclusion and data source rule lists). Simulation can run such payloads but not generate them. CMDB 360 and IntegrationHub ETL support these tables.

## Domain separation

Supported. Rules for identification are global; reconciliation rules can be per domain.

| Mode | Property `glide.identification_engine.platform_domain_separation_enabled` | Matching |
|---|---|---|
| **Strict** (default) | false | only CIs in the caller's own domain. The same CI in parent and child domains is **not** a duplicate |
| **Platform** | true | the caller's domain, its child domains, visibility and contains domains, and global. Cross-domain duplicates are detected |

- **Switching to platform mode on an established instance can suddenly flag many duplicates** and break applications. The docs reserve it for advanced cases; no benefit if IRE already works well.
- Either mode: no domain is sent in the payload (the caller's is used); an inserted CI gets the caller's domain; an updated CI keeps its own; de-duplication tasks (`reconcile_duplicate_task`) and reclassification tasks (`reclassification_task`) take the CI's domain.
- No `sys_domain` on `cmdb_identifier`, `cmdb_identifier_entry`, `cmdb_related_entry`, `cmdb_ie_active_config`. Domain fields exist on `cmdb_reconciliation_definition`, `cmdb_datasource_precedence`, `cmdb_datasource_staleness`: a parent domain's rules apply to child domains unless overridden.

## Support articles named by the docs

KB0750382 (log the payload sent to IRE), KB0750386 (how IRE processes a payload step by step), KB0750383 (run identification on demand with a payload).

## Related


- [[CMDB REST APIs - Instance, Meta, IRE and Data Ingestion]] (REST endpoints for the IRE)
- [[IRE Error Messages]] · [[CMDB Dependent Relationship Rules - Hosting and Containment]] · [[CI Classes, Dependency and Principal Class]] · [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]]
