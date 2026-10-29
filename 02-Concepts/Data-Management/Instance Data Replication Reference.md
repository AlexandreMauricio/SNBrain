---
type: reference
tags: [reference, data-management, integrations, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Instance Data Replication > Reference (Data privacy, Adapter descriptions, Excluded tables, Domain separation and IDR, System properties, Roles) and Transform replication data, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/instance-data-replication-idr/reference-instance-data-replication.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Instance Data Replication Reference

Lookup lists for [[Instance Data Replication (IDR) Overview]]. From the Brazil docs; not tested.

## Adapters (transform step, run on the way to the consumer)

Each adapter has a Name and a Description. Adapters never change producer data; they cannot act on journal fields (**Comments**, **Work notes**); calculated fields (for example `name` on `sys_user`) replicate but cannot be transformed. `sys_id`, `sys_created_*`, `sys_updated_by`, `sys_domain`, `sys_mod_count` and similar are mapped automatically and cannot be remapped; other `sys_` fields cannot be replicated through a transform.

| Adapter | Does | Example (invented values) |
|---|---|---|
| **Calculation** | operation + constant (multiply, max, min, floor...) | Multiply 1.08: 10 → 10.80; Max 1000: 1020 → 1000 |
| **Concatenate String** | appends a string | `_v2`: `PATCH1` → `PATCH1_v2` |
| **Fixed-width format** | reformats with `#` (digit), `@` (any character), `\` (escape) | `##########` → `(###) ###-####` |
| **Map** | comma-separated exact literal pairs | `PRB=TASK, done=complete` (whole value must match: `PRB1000` is not mapped) |
| **Pattern** | regex groups, output with `$0` (whole), `$1`, `$2`... | `(.*),(.*)` with `$2 $1`: `Doe, Jane` → `Jane Doe` |
| **Replace** | find and replace; `$2 text` = only the 2nd occurrence, `${2} text` = first two | |
| **Split** | split on a delimiter (no spaces), output with `$n` groups | `-` with `$2, $1`: `Jane-Doe` → `Doe, Jane` |
| **Task number** | replace a number prefix or add a prefix/suffix | replace `PRB` with `STRY` |
| **Time zone conversion** | converts a time to an output time zone | |

Bidirectional sets allow only the task number adapter.

## Excluded tables

Cannot be replicated, **including their child tables** (for example **Catalog Item** (`sc_cat_item`) extends a `sys_` metadata table, so it is excluded):

- Prefixes `V_PREFIX`, `SYSX_`, `sys` (exception: `idr_sys_domain`), `ts_`, `ua_`, `usageanalytics_`, `wf_`, `ecc_`, `clone_`, `jrobin_`, `rrd_`, `imp_`, `pf_`, `pfd_`.
- Rotated tables such as `syslog`, `sys_querystat`, `ecc_queue`, `ecc_event`, `cmdb_metric`, `sysevent` ([[Database Rotation - Table Rotation and Table Extension]]).
- Tables without a `sys_id`; `sso_federation`, `saml2_update1_properties`, `sso_properties`, `digest_properties`, Instance.
- **Avoid**: `cmdb` and `cmdb_ci`; if you must, constrain with conditions and include all required columns.

Note: the `sys` prefix exclusion sits oddly with the overview's advice not to replicate `sys_user` into a populated consumer (which implies `sys_user` can be replicated). Unconfirmed which is true in practice.

## System properties

Added in **System Properties** (`sys_properties`).

| Property | Type | Default | Purpose |
|---|---|---|---|
| `idr.instance.comparison.batch.size` | integer | 10,000 | comparison results over 1 million records in the range are split into batches of this size |
| `idr.instance.comparison.max.runtime` | integer | 15 (minutes) | max runtime of a data comparison |
| `idr.dct.comparison.skip.fields` | string | `caller_id,sys_created_on,sys_created_by,sys_updated_on,sys_updated_by` | fields ignored when comparing |
| `idr.message.gap.order_enforcement.enabled` | string | true (stop replication on an out-of-order message) | false re-queues missing messages from the latest producer values without stopping; both instances on the same family, Vancouver or later |
| `idr.cdc.replication.table.reader.attachment.size` | integer (bytes) | 100,000,000 | attachment size limit; the same page also says IDR does not restrict attachment size by default (unconfirmed which) |
| `idr.max.seeding.limit` | integer | empty | max records per seeding request; unset means no limit on V2 sets (compare the 3 million limit on the seeding page and 10 million in the status messages) |

## Roles

| Role | Purpose | Contains |
|---|---|---|
| `idr_admin` | all IDR tables | `idr_rest` |
| `idr_read` | read IDR tables | `idr_rest` |
| `idr_rest` | make a diagnostic request | - |

The docs advise using these instead of `admin` where possible; IDR is per-user subscription managed ([[Subscription Management]]).

## Data privacy and domain separation

- One set can serve several consumers, possibly other companies and other regions; approval warns the producer when the consumer is in a different region.
- Changing a **discrete rule** on an active multi-consumer set can expose data (including personal data) to the wrong consumer.
- With bidirectional, data a consumer creates goes to the producer and can then reach every other consumer.
- IDR works at data level and **does not explicitly support domain separation**: filter sets by domain to segregate ([[Domain Separation Overview]]).

## Related

- [[Instance Data Replication (IDR) Overview]] · [[Set Up Instance Data Replication]] · [[Instance Data Replication Errors and Statuses]]
