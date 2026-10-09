---
type: table
tags: [table, cmdb, schema, reference-field]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Explore > CMDB schema model, topic "Configuration Item [cmdb_ci] class" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/explore-cmdb.html), read through the docs site API 2026-10-09. The page prints labels only; column names are not given and are marked ?
sn-release: Brazil
verified:
updated: 2026-10-09
---

# cmdb_ci

**Label:** Configuration Item
**Extends:** Base Configuration Item (`cmdb`)
**Extended by:** every IT CI class, for example [[cmdb_ci_hardware]], [[cmdb_ci_service]], Database (`cmdb_ci_database`), Application (`cmdb_ci_appl`)
**Purpose:** the attributes every IT configuration item shares. See [[CMDB Overview and Class Hierarchy]].

**Access:** role `sn_cmdb_admin`, `sn_cmdb_editor`, `asset`, `admin` or `itil`.

> Do not change these attributes in the dictionary (for example **Location** from reference to list). CMDB features may break.

## Columns

Labels as printed in the docs. **Column names are not printed on the page**: confirm against `sys_dictionary` before using one in a script or query.

### Identity and classification

| Label | Name | Notes |
|---|---|---|
| Name | `?` | name of the CI |
| Class | `?` | system class name |
| Sys ID | `sys_id` | [[Sys ID]] |
| Category, Subcategory | `?` | |
| Description | `?` | fit (how deployed) and function (purpose) |
| Asset tag | `?` | asset or service tag |
| Serial number | `?` | see the serial number rules in [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]] |
| Model Number | `?` | manufacturer's original model number |
| Correlation ID | `?` | ID of the CI in another data source |
| Attributes | `?` | |
| Comments, Tags | `?` | |

### Network

| Label | Name | Notes |
|---|---|---|
| IP Address | `?` | primary IP address |
| MAC Address | `?` | |
| DNS Domain | `?` | |
| Fully Qualified Domain Name | `?` | |

### Status and discovery

| Label | Name | Notes |
|---|---|---|
| Operational Status | `?` | configurable choice list |
| Discovery source | `?` | the primary (most trusted) discovery source |
| First Discovered, Most Recent Discovery | `?` | date/time |
| Monitor | `?` | whether the CI is monitored |
| Fault Count | `?` | faults recorded to date |
| Requires verification | `?` | flag |
| Skip sync | `?` | lets synchronisation between Asset Management and the CMDB be skipped |
| Can Print | `?` | |
| Start Date, Installed | `?` | last started, last installed |
| Updates | `?` | "configurable choice list with values for update states" in the docs; meaning unconfirmed |

### Assignment, dates and finance

| Label | Name | Notes |
|---|---|---|
| Assigned | `?` | date/time of assignment to a user |
| Checked in, Checked out | `?` | date/time |
| Due, Due in | `?` | |
| Ordered, Order received, Purchased | `?` | |
| Warranty expiration | `?` | |
| Cost, Cost currency | `?` | |
| GL account, Invoice number, PO number | `?` | |
| Lease contract | `?` | |
| Justification | `?` | |

### System

Created, Created by, Updated, Updated by, Domain, Domain Path.

## Reference columns

| Label | References |
|---|---|
| Asset | Asset table |
| Assigned to, Managed by, Owned by, Supported by | User ([[sys_user]]) |
| Approval Group, Change Group, Support group | Group ([[sys_user_group]]) |
| Company, Manufacturer, Vendor | Company (`core_company`, [[Companies and Normalization Data Services]]) |
| Model ID | Product Model (`cmdb_model`, [[Models, Model Categories and the Product Catalog]]) |
| Cost center | Cost Center |
| Department | Department |
| Location | Location |
| Schedule | Schedule (normal processing) |
| Maintenance Schedule | Schedule |

## Related tables

| Table | Label | Relation |
|---|---|---|
| `cmdb_rel_ci` | CI Relationship | relationships between two CIs |
| `cmdb_serial_number` | Serial Number | many serial numbers per hardware CI |
| `cmdb_related_entry` | Related Entries | registers the non-hierarchy tables that reference CIs |
| `svc_ci_assoc` | Service Configuration Item Association | CI to application service |

## Example queries

All CIs in a list: `cmdb_ci_list.do` in the filter navigator (read only).
