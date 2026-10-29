---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Splunk (about 410 cleaned lines, read 2026-10-29) - overview, Configure, SGC for Splunk add-on, Install SGC for Splunk add-on, Targeted CMDB tables (class list). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-splunk-integration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Splunk

**In one line:** Store app `sn_sec_sgc_splunk` that imports the hosts behind **Splunk forwarders** into the CMDB; with ServiceNow's **Splunk add-on** installed in Splunk it also brings MAC, OS details, installed software, file systems, last logon and open ports for Windows and Linux assets.

From the Brazil docs (ServiceNow Xanadu, Washington DC, Vancouver); guided setup only; not tested. This is the asset (CMDB) connector, not event ingestion from Splunk. General: [[Service Graph Connectors Overview]].

## Basic versus add-on data

| Without add-on (default query) | With **ServiceNow Add-on for Windows and Linux Assets** |
|---|---|
| forwarder version, type, last check-in; OS; host; host IP | plus MAC address, OS details, asset name, installed software, file system, last logon date, open ports |

Connection property **`is_snow_addon_installed`** (default false) switches to the extended query; set it true only after installing the add-on.

## The Splunk add-on (Splunk side)

Role in Splunk: `admin` or `security_admin`. **Apps > Find More Apps** > install **ServiceNow Add-on for Windows and Linux Assets** (from Splunkbase). It relies on **Splunk_TA_nix** 9.0.0+ and **Splunk_TA_windows** 8.9.0+ and supports standalone, distributed and search-head-cluster deployments. Its scheduled searches (**Settings > Searches, reports and alerts**) run in a fixed order and fill KV stores (asset details, process details, software details and similar) that the connector reads; keep the default schedules. If your Windows or Linux data is in custom indexes, edit the add-on's **search macros** (defaults point at the `main` and `_internal` indexes). Workload rules: **Settings > Workload Management > Workload Rules**.

## Guided setup (ServiceNow side)

**All > Service Graph Connectors > Splunk > Setup** > **Best Experience** (role `admin`; ITOM units, `com.snc.itom.discovery.license` activated, `com.snc.itom.license`, Integration Commons, CMDB CI Class Models, Datastream Action; `sn_observability` only for events):
1. **Configure Splunk authentication credentials**: Splunk user name and password.
2. **Configure Splunk HTTP Connection**: alias such as `sn_sec_sgc_splunk.SGSplunk`, URL builder, host or IP without `https`, port (management port **8089** in the example), MID Server when Splunk is not publicly reachable.
3. Optional: set `is_snow_addon_installed`.
4. **Test Connection**: status **201** means success.
5. Scheduled imports: Run = Once for a test, **Use connection** off for the first run, **Concurrent import** on, Partition Method **Custom size**, size **15,000**, pre/post-import scripts on; **Execute now**.
6. Optional more Splunk instances: Application Access on data source and scheduled import tables, **Add Connection** in Flow Designer (URL in https form), MID Server, test.

## Classes

Computer, File System, IP Address, Network Adapter, software (Software Installation with SAM; Software + Software Instance without). The class page labels `cmdb_ci_computer` as "Hardware" in one place.

## Related

- [[Service Graph Connectors Overview]] · [[Scheduled and Concurrent Imports]] · [[Service Graph Connector for SentinelOne]]
