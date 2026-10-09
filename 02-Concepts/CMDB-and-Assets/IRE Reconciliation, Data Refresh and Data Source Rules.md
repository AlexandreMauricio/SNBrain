---
type: concept
tags: [concept, cmdb, data-integrity, integrations, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE) > Configure, topics "Reconciliation rules", "Create a CI reconciliation rule" (static and dynamic), "Create a data refresh rule", "Create an IRE data source rule" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# IRE Reconciliation, Data Refresh and Data Source Rules

**In one line:** the rules that decide which discovery source may **update** which CI attribute (reconciliation), when a higher-priority source's value has gone stale enough for a lower one to take over (data refresh), and which sources may not **create** CIs of a class at all (data source rules). Part of [[Identification and Reconciliation Engine (IRE) Overview|IRE]].

Without reconciliation rules, sources overwrite each other freely.

**Where:** **CI Class Manager** > class > **Class Info > Reconciliation Rules**. List: **Configuration > Identification/Reconciliation > Reconciliation Definitions**.
**Roles:** read `sn_cmdb_editor` or `itil`; write `sn_cmdb_admin` or `itil_admin`.

## Static reconciliation rules

Table **Reconciliation Definition** (`cmdb_reconciliation_definition`). A rule lists discovery sources with priorities and the attributes they may update.

| Field | Notes |
|---|---|
| Active | |
| Discovery Source + Priority | several pairs. **Lower number = higher priority.** Sources with no rule get the lowest priority |
| Apply to all attributes | authorises the sources for every attribute of the class. Overridden by any rule naming a specific attribute |
| Attributes | own or inherited attributes the sources may update |
| Update with Null | attributes these sources may blank. By default a non-null value is never overwritten with null |
| Filter Condition | CIs the rule applies to, for example *Department is Finance*. Evaluated **after** the payload has changed values unless `glide.identification_engine.enable_reconciliation_filter_before_update` is true |

How an update is judged: after an authorised source writes an attribute, later updates are accepted only from the same source or a higher-priority one. A lower-priority source gets through only if it is the first to update the CI, or the attribute is **stale** under a data refresh rule.

Precedence between rules:

1. A rule naming the attribute beats an *Apply to all attributes* rule, whatever the priorities (and even if the CI is stale).
2. A rule defined on the class beats one inherited from a parent.
3. At the same level, rule priority decides.

- Rules for different sources on the same attribute coexist: both are authorised, ordered by priority.
- A child class rule overrides the parent's for that attribute, even when the child's is static and the parent's dynamic.
- Create a rule for **every** source that should be allowed to update an attribute.

Example: rule 1, Discovery may update `name` on `cmdb_ci_computer` (so on all child classes). Rule 2, ServiceWatch may update `name` on `cmdb_ci_linux_server`. Rule 3, ServiceWatch may update all attributes on `cmdb_ci_linux_server`. With 1 and 3 only, Discovery still owns `name` on Linux servers and ServiceWatch everything else; adding 2 gives ServiceWatch the name there too, while Discovery keeps it on the other computer classes.

**Last writer per attribute** is kept in **Data Source History** (`cmdb_datasource_last_update`), but only from the moment a rule is enabled. **Expect some unexpected updates right after enabling a rule**, until the top source has written each CI once.

## Dynamic reconciliation rules

Table **Dynamic Reconciliation Definitions** (`cmdb_dynamic_reconciliation_definition`). Instead of ranking sources, the rule picks a value from what all sources reported, as held in the CMDB 360 data store: for example the largest or the most reported value. Useful when sources cannot sensibly be ranked.

- **Needs CMDB 360 enabled**; otherwise the choice of rule type is not even offered.
- One dynamic rule per class attribute.
- **A dynamic rule beats a static rule on the same attribute** (same class level).
- When the rule type is not conclusive (no single most-reported value), IRE falls back to last reported, last discovered and last updated.
- Cannot be added while creating a new child class: save the class first.
- Steps: **Add** > **Dynamic Reconciliation Rule** > **Dynamic Rule Type** > attributes > filter condition > **Save**.

After changing rules: **Preview Rule** (precedence per attribute), and with CMDB 360 **Preview Data** (CMDB value and reported values for one CI) and **Recompute**.

## Data refresh rules

Table **Data Source Staleness Definition** (`cmdb_datasource_staleness`). Per class and discovery source: **Effective Duration**. If that source has not updated the attributes it owns within the duration, the CI is stale for it and a lower-priority authorised source may update.

- **0 (default) = stale immediately**, so lower-priority sources can always update.
- A value such as `15 x` is read as 15; a wholly invalid value as 0.
- Created in the **Data Refresh Rules** section under Reconciliation Rules.
- **No effect where dynamic reconciliation rules apply.**

## IRE data source rules

Table **IRE Data Source Rule** (`cmdb_ire_data_source_rule`). **Configuration > Identification/Reconciliation > IRE Data Source Rule** (role `sn_cmdb_admin` or `itil_admin`).

Stops a source from **inserting** CIs of a class (and its children) while still letting it update existing ones. Typical: an IP scanner that would create empty server CIs.

| Field | Notes |
|---|---|
| Applies to | the class |
| Data source | the source |
| Insert Not Allowed | the block |
| Active | one active rule per class / source pair |

- Inherited by child classes; a child's own rule overrides.
- The blocked insert fails with `INSERT_NOT_ALLOWED_FOR_SOURCE`. With `createOrUpdateCIEnhanced()` the item is kept as a **partial payload**; when a permitted source later inserts the same CI, the two are merged (static reconciliation applies), the partial payload is deleted, and the first source can update the CI from then on.
- With plain `createOrUpdateCI()` **the whole payload fails**.
- Do not apply to lookup and related items. **No effect where dynamic reconciliation rules apply.**

## Gotchas

- No reconciliation rule can be made for system fields or IRE's own fields such as **Discovery source** (`discovery_source`), and rules cannot dot-walk.
- Property `glide.reconciliation.override.null` (default true) lets a lower-priority source fill an **empty** field.
- With domain separation, reconciliation rules can be scoped per domain; a parent domain's rules apply to child domains unless overridden.
- Support article on precedence: KB0756709.

## Related

- [[IRE Identification Rules]] · [[IRE Properties and Tables Reference]] · [[CI Class Manager]]
