---
type: how-to
tags: [how-to, workspace, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Entity view action mapper > Create a multi-data source list display, Create an EVAM definition, Define a data source, Define configuration bundle, Define view template, Create action definition (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/entity-view-action-mapper-evam/tutorial-create-evam.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Create a Multi-Source Card List with EVAM

**Goal:** show records from two tables (for example requested items and incidents) in one card list, each table with its own card layout and the same click behaviour. Concepts: [[Entity View Action Mapper (EVAM)]].

From the Brazil docs; not tested. Role `admin` or `evam_admin`. Showing the definition inside a page (UI Builder or a workspace component) is not covered by these pages.

## Steps

1. **EVAM definition**: **All > Entity View Action Mapper (EVAM) > EVAM Definitions > New**: name, active, sort order, application. Submit, then reopen it to get the related lists.
2. **Data sources**: in **EVAM Data source M2Ms**, **Create and Link** one per table: table, condition, **Sort By** (a datetime field such as **Created** (`sys_created_on`) if you want both tables interleaved by date).
3. **Configuration bundles**: in **EVAM View Config Bundle M2Ms**, **Create and Link** one bundle per data source; set their order (lower first).
4. **Action definition**: **All > Entity View Action Mapper > Action Definition > New**, e.g. a **UXF Client Action** that opens the record (navigation).
5. **View templates**: **View Definitions > View Templates > New**: JSON with `component`, `staticValues`, `mappings`, `actionMappings` (see the concept note for the keys).
6. **View configurations**: **View Definitions > View Configurations > New**, one per case inside each bundle: table, condition, order, required roles, table fields, the template, the actions. Add a second configuration on the same table with a different condition when you want a different card (open versus closed).
7. Optional **EVAM Data Filters** on the definition.
8. Check the result where the definition is consumed.

## Example

Definition **Example Requests and Incidents**, two data sources:

| Data source (table) | Bundle | View configurations | Template |
|---|---|---|---|
| Example Requests (**Requested Item**, `sc_req_item`; condition: Requested for is the current user) | Example Request Bundle | Open requests (active = true), Closed requests (active = false) | Example Open Request Template, Example Closed Request Template |
| Example Incidents (**Incident**, `incident`; condition: Caller is the current user) | Example Incident Bundle | Open incidents, Closed incidents | Example Open Incident Template, Example Closed Incident Template |

A requested-item card template along the lines of the docs' example (field names are base-system ones; check them in your instance):

```json
{
  "component": "now-card-evam-record",
  "staticValues": {
    "detailLabelOne": { "translatable": true, "key": "created" },
    "detailLabelTwo": { "translatable": true, "key": "number" }
  },
  "mappings": {
    "highlightedHeaderLabel": "state",
    "titleLabel": "cat_item.name",
    "imageURL": "cat_item.picture",
    "subtitle": "cat_item.short_description",
    "detailValueOne": "sys_created_on",
    "detailValueTwo": "number"
  },
  "actionMappings": { "clickAction": "navigation" }
}
```

## Related

- [[Entity View Action Mapper (EVAM)]] · [[UI Builder Data Resources, Controllers and Client Scripts]]
