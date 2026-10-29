---
type: concept
tags: [concept, workspace, portal, admin, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Entity view action mapper (whole chapter, 13 topics: Exploring, View configurations and templates and bundles, Configuring, Define a data source, Define view template, Define configuration bundle, Managing, Create a multi-data source list display, Create an EVAM definition, Create action definition, Reference, Roles, Domain separation), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/entity-view-action-mapper-evam/entity-view-action-mapper.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Entity View Action Mapper (EVAM)

**In one line:** a configuration layer that turns records from **several tables** into one card grid or list with the same look and the same actions, without custom code; used by Next Experience workspaces, Service Portal search, Virtual Agent search results and similar UIs.

From the Brazil docs; not tested. Where it shows up in this vault: the SOW announcements and related-records cards ([[Service Operations Workspace Access and Landing Page]], [[Service Operations Workspace Configuration and Customization Reference]]), AI Search results ([[ITSM Virtual Agent Topics and Setup]]) and the UI Builder data resource toggle ([[UI Builder Data Resources, Controllers and Client Scripts]]). Step by step: [[Create a Multi-Source Card List with EVAM]].

## Building blocks

The idea is **entity → map → view / action**: a data source (the entity, e.g. a user or a community post) has fields; a mapping puts those fields into a card component's properties; actions are wired to the card.

| Record | Menu (**All > Entity View Action Mapper (EVAM) > ...**) | Holds |
|---|---|---|
| **EVAM definition** | EVAM Definitions | the main record: name, sort order (ascending / descending), and related lists **EVAM Data source M2Ms**, **EVAM View Config Bundle M2Ms** (bundles ordered, lowest number wins), **EVAM Data Filters** |
| **Data source** | Data sources | a table, a condition, a **Sort By** column (only datetime fields sort across different tables) |
| **Configuration bundle** | (linked from the definition) | a group of view configurations, e.g. one per data source |
| **View configuration** | View Definitions > View Configurations | table + condition + **Order** (lower wins) + required roles + table fields and custom fields + the view template + declarative actions |
| **View template** | View Definitions > View Templates | JSON that maps fields to a card component |
| **Action definition** | Action Definition | label, name, **Implemented as** = **Server Script** (e.g. assign or delete a record) or **UXF Client Action** (e.g. open a record; pick a predefined client action) |

Several view configurations can use the same data source with different conditions (for example open versus closed requests), each with its own template.

## View template JSON

| Key | Meaning |
|---|---|
| `component` | the card component, e.g. `sn-search-result-evam-card` (search results) or `now-card-evam-record` |
| `staticValues` | fixed texts or settings for component properties, each with `key` and optional `translatable` (true = translated to the user's language) |
| `mappings` | component property → data source field (dot-walking allowed, e.g. `cat_item.name`) |
| `actionMappings` | card events → action names, e.g. `clickAction` → `navigation` |

Base system examples: bundles **Service Portal Search Bundle** and **Service Portal bundle** (`sp_bundle`), templates such as the **Attachment Search Template**, and example view configurations in the demo data set `demo_evam_dataset`.

## Roles and domain separation

`admin` or **`evam_admin`** configure everything; the docs also list `itil` as relevant when EVAM shows ITSM records. EVAM **supports domain separation** (support level not stated on the page).

## Related

- [[Create a Multi-Source Card List with EVAM]] · [[UI Builder Overview and Concepts]] · [[UI Builder Data Resources, Controllers and Client Scripts]]
