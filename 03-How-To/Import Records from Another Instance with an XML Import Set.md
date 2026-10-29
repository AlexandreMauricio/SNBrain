---
type: how-to
tags: [how-to, import-sets, integrations]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets > Importing from another ServiceNow instance, topics "Importing from another ServiceNow instance", "XML records from lists", "Using XML import sets", "Create an XML data source to another instance", "Create a transform map", "Add onBefore scripts to the transform map", "Retrieving data from a CSV formatted file", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/c_ImportingFromAnotherSNInstance.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Import records from another instance with an XML import set

**Goal:** pull a table's records from a source instance into the current one, with business rules, transformation and sys_id reconciliation.
**Prerequisites:** admin on the target instance (elevated privileges with High Security Settings); a user on the source instance with read access (user name, not email); related data (users, CIs, locations...) already imported first.
**Navigation:** All > System Import Sets > Administration > Data Sources

## Steps

1. **New** data source: **Type** File, **Format** XML, **Xpath for each row** `/xml/<source_table>`, **Expand node children** true, **File retrieval method** HTTPS, **Server** `<source instance>.service-now.com`, **File path** `/<source_table>.do?XML` (add `&sysparm_query=...` to filter), **User name**, **Password**. Submit.
2. **Test Load 20 Records** to create the staging table (these 20 rows cannot be transformed).
3. **Transforms > New**: target table = the same table; map fields.
4. Transform script **onBefore** to keep the source sys_id on inserts:
   ```javascript
   // onBefore transform script (server-side, global)
   if (action == 'insert') target.setNewGuidValue(source.u_sys_id);
   ```
5. A second **onBefore** script per reference field whose records have different sys_ids on the two instances, matching on a unique value:
   ```javascript
   var ref = new GlideRecord('sys_user');
   ref.addQuery('email', source.u_assigned_to_email);   // a unique value carried in the data
   ref.query();
   if (ref.next()) target.assigned_to = ref.getUniqueValue();
   ```
6. **Load All Records**, **Run Transform**, review the runs.

## Result / how to check it worked

Records exist on the target with the same sys_ids as on the source, and references point at the local users or groups.

## Example

Copy *Example Projects* records: data source path `/x_example_project.do?XML&sysparm_query=active=true`, Xpath `/xml/x_example_project`, coalesce on `u_sys_id` mapped to sys_id, onBefore keeps sys_ids and resolves `project_manager` by email.

## Tables / fields involved

- `sys_data_source`, staging table, `sys_transform_map`, the target table.

## Other ways to do this

- **Export / Import XML from lists** ([[Export and Import Records as XML]]): keeps every field and sys_id, no business rules, no transformation; display values are matched to local sys_ids only for `sys_user`, `sys_user_group`, `sys_user_role`, `sys_group_has_role`.
- **CSV over HTTPS**: data source File / CSV / HTTPS with path `incident.do?CSV` (or with `sysparm_query`), then a normal transform map. (If Server and path fields do not show for HTTPS, switch to SCP temporarily to fill them, per the docs.)
- For one record at a time as things happen, use REST instead.
- Comparison: [[Copying Records Between Instances]].

## Gotchas

- Imports read one table at a time: load referenced tables first (CIs, users, locations before incidents; incidents before problems and changes).
- Setting the `update_synch` dictionary attribute to move data with update sets is no longer allowed.
