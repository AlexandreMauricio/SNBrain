---
type: concept
tags: [concept, integrations, api, import-sets, cmdb]
status: documented
source: ServiceNow Australia Platform Administration PDF, "ServiceNow AI Platform integrations" (pp. 2365-2390), read 2026-10-01. This chapter is an overview; REST, SOAP, import sets and MID Server are documented in other guides
sn-release: Australia
verified:
updated: 2026-10-01
---

# Integration options and interfaces overview

**In one line:** data gets in and out of an instance through web services (REST, SOAP), import sets (files, JDBC, LDAP), email, and the MID Server for anything inside the customer network; this chapter lists the options and documents a few specific ones.

## Ways to integrate

| Technique | Direction | Notes |
|---|---|---|
| **Direct web service** | in/out | every table is automatically available through the REST Table API and SOAP |
| **Mapped web service** | in | data lands in an import set table and a transform map writes the target table |
| **Scripted web service** | in | a scripted endpoint that runs a process instead of writing one table |
| **Import sets** | in | from HTTPS, FTPS, SCP files (XML, CSV, Excel) or a JDBC query |
| **JDBC** | in | query an external database through a MID Server |
| **ODBC driver** | out | external tools query the instance |
| **Export / URL access** | out | lists and reports by URL ([[Exporting Data]]) |
| **Email** | in/out | [[Inbound Email Actions]], notifications |
| **LDAP, SAML, digest token** | users and sign-on | |
| **CTI** | in | telephony client opens a URL |
| **Syslog probe** | out | send log lines to a log server through a MID Server |

Where to get an integration: one shipped with the platform, a certified one from the Store, one from Share, a custom-built one, or build your own with the interfaces above. Instance-to-instance integrations use the same interfaces on both sides.

## Integrations described in this guide

### Google Maps

Properties under **System Properties > Google Maps**: `google.maps.key` (API key), `google.maps.key.geocoding`, `google.maps.method` (must be `key`: Google stops accepting the client-ID method from May 2026), `google.maps.table` (default `cmn_location`; needs name, latitude, longitude), start position and zoom, `google.maps.max_items` (500). Use your own Google key. A scheduled job *Refresh Latitude Longitude info of Records* refreshes coordinates (at least every 30 days) for tables listed in `cmn_coordinate_refresh_config`.

### Microsoft SCCM to CMDB

One-way scheduled import of computers, disks, network adapters, operating system, processors and software from the SCCM SQL Server database through a **MID Server and JDBC data sources** into staging tables `imp_sccm<version>_*`, transformed into `cmdb_ci_computer`, `cmdb_ci_disk`, `cmdb_ci_network_adapter`, `cmdb_ci_spkg`, `cmdb_software_instance` (or `cmdb_sam_sw_install` with Software Asset Management).

- The legacy plugins (2007, 2012 v2, 2016) are deprecated; the guide recommends the **Service Graph connector for Microsoft SCCM** (CSDM-aligned, uses the identification and reconciliation engine, IntegrationHub ETL).
- The Computer Identity data source runs first, the rest in order. Incremental by default; clear **Last run datetime** on a data source to force a full import.
- The SQL login needs `db_datareader`.
- **Assigned to** is matched on the field named in `glide.discovery.assigned_user_match_field` (`user_name`).
- The import must contain complete data for a CI: partial data deletes relationships.
- Use Asset Intelligence imports or the plain software imports, never both.

### CTI (computer telephony)

The telephony client opens `https://<instance>.service-now.com/cti.do?sysparm_caller_name=<name>` (or `sysparm_caller_phone`, `sysparm_task_id`, `sysparm_view`, `sysparm_<field>=<value>` to prefill, `sysparm_cti_rule=<function>` for custom logic). The default *CTI Processing* script finds the user by name, then phone; shows the user's open incidents, or a new incident form prefilled from the URL. Authenticated users only.

### JDBC probe

A probe executed by the MID Server against an external database (Oracle, SQL Server, MySQL drivers), either through a JDBC data source (import set) or **direct**: an output record in the ECC queue with **Topic** `JDBCProbe` and an XML payload with `jdbc_driver`, `connection_string`, and either `table_name`, a `work` element (select, insert, update, delete) or `sql_statement`. Result returns as XML in the ECC queue input, 200 rows by default (`jdbcprobe_result_set_rows`). Add `skip_sensor` when Discovery is active. **There is no sanitisation of the SQL**: never build it from untrusted input. Connection strings carry credentials: keep them out of notes.

### Syslog probe

```javascript
var sl = new Syslog('<syslog server FQDN>', 'mid.server.<MID Server name>', 16);
sl.log('Example log message', 6);
```

Script include `Syslog`, callable from a business rule or event; the MID Server delivers the message (facility 16, priority 6 = informational).

### Verizon eBonding

A SOAP incident exchange; the guide only describes moving it from test to production (production SOAP endpoint, certificate and keystore, integration user).

## Integration sessions

- Inactive timeout for integration (API) sessions: `glide.integration.session_timeout` minutes (the guide states both one and five minutes as the default in different places; check the instance).
- Maximum session length regardless of activity: create `glide.active.session.timeout.invalidate.session` = true, then set `glide.integrations.active.session.life_span` (minutes, greater than the inactive timeout).
- One service account shared by many integrations can keep sessions alive indefinitely.

## Related

- [[Non-Interactive Users]] · [[User Sessions and Timeouts]] · [[Transaction Quotas, Application Quotas and Operational Toggles]] · [[System Properties Reference]]
