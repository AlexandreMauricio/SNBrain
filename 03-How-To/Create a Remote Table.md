---
type: how-to
tags: [how-to, integrations, scripting, api]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Remote tables > Activate the remote tables plugin, Create a remote table, Create script definitions for a remote table, Example 1 and Example 2 (retrieving incidents from another instance), Debugging remote table script definitions, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/remote-tables/create-remote-table.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Create a Remote Table

**Goal:** show records from another system (here another instance's incidents) in a list on this instance without importing them. Concepts and API list: [[Remote Tables]].

From the Brazil docs; not tested. Roles: `admin` for the plugin; `delegated_developer` (with scripting) or `admin` for the table and definition.

## Steps

1. Activate **Remote Tables** (`com.glide.script.vtable`) in **System Applications > All Available Applications > All** (with domain separation and delegated admin, do it from the global domain).
2. Create an outbound REST message for the source (**System Web Services > Outbound > REST Message**) with the methods you need, e.g. all records and one by `sys_id` ([[Integration Options and Interfaces Overview]], [[Connections, Credentials and Aliases]]).
3. **System Definition > Remote Tables > Tables > New**: label (name becomes `u_st_<name>` in global), tick **Remote Table**, add the columns you will fill (strings, references, numbers), set application access. Submit.
4. **System Definition > Remote Tables > Definition > New**: name, table, application, **Active**; under **Advanced** set **Cache TTL** (e.g. 300), isolation, Enhanced Capacity if over 1,000 rows, Editable if you need writes.
5. Write the **Query** script (server-side, runs in the definition's scope): call the REST message, map the JSON with `sn_tfrm` transformer rules (always map `sys_id`), `v_table.addRow(row)`, report failures with `v_query.setLastErrorMessage()`. Handle `v_query.isGet()` and common equality filters with dedicated calls.
6. Open `u_st_<name>.list`; check errors under the list. For details set `glide.script.vtable.log.debug = true` and use the session debugger, then set it back.

## Example

Remote table **Example Remote Incidents** (`u_st_example_remote_incidents`) with columns `u_number`, `u_short_description`, `u_active`, `u_caller` (string). REST message **Example Remote Instance** with methods **All Incidents** (`GET https://<source_instance>.service-now.com/api/now/table/incident?sysparm_limit=200`) and **By SysId** (`.../incident/${sys_id}`), using a basic-auth profile for an invented integration user.

Query script (server-side; definition in the global scope):

```javascript
(function executeQuery(v_table, v_query) {
    var msg;
    if (v_query.isGet()) {
        msg = new sn_ws.RESTMessageV2('Example Remote Instance', 'By SysId');
        msg.setStringParameterNoEscape('sys_id', v_query.getSysId());
    } else {
        msg = new sn_ws.RESTMessageV2('Example Remote Instance', 'All Incidents');
    }
    try {
        var response = msg.execute();
        if (response.haveError()) {
            v_query.setLastErrorMessage(response.getErrorMessage());
            return;
        }
        var rules = new sn_tfrm.TransformerRuleList()
            .fromJSON()
            .addRule('sys_id', '$.sys_id')
            .addRule('u_number', '$.number')
            .addRule('u_short_description', '$.short_description')
            .addRule('u_active', '$.active')
            .addRule('u_caller', '$.caller_id.value');
        var transformer = new sn_tfrm.Transformer(
            new sn_tfrm.TransformerDefinition(rules, '$.result'), response.getBody());
        while (transformer.transform())
            v_table.addRow(transformer.getRow());
    } catch (ex) {
        v_query.setLastErrorMessage(ex.message);
    }
})(v_table, v_query);
```

`By SysId` returns a single object in `result` on the Table API, so its record path may need to differ from the list call (unconfirmed; the docs example reuses `$.result` for both).

## Related

- [[Remote Tables]] · [[sys_db_object]]
