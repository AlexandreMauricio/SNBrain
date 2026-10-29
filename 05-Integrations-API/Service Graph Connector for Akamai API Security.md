---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Akamai API Security (about 230 cleaned lines, read 2026-10-29) - overview with data mapping and full-load script, Configure using SGC Central, Target CMDB classes, Accessing connection details, Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-akamai.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Akamai API Security

**In one line:** Store app (prefix `sn_akamai_api_sec`) that imports the APIs Akamai API Security has discovered, with security and risk attributes, into **API Component** (`cmdb_ci_api_component`) CIs for [[API Insights]].

From the Brazil docs (Xanadu, Yokohama, Zurich; Akamai REST APIs `/api/v3/apis`, `/api/v3/sources`, `/auth/token`); not tested. Grouped with the API connectors: [[Service Graph Connectors Overview]].

## Setting up the connection

Akamai side: a service account with client credentials. SGC Central (connector 1.0.0; prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`) > connector type **Akamai**:
1. **Create and test connection**: connection name, connection URL, OAuth client ID, client secret, token URL.
2. **Set configuration properties**: optional **Source name** or **Source alias** (comma-separated) to import only some sources or gateways (changing them resets `last_run_datetime`, so the next run is a full load); **Import tags** and **Tags value separator** (`=`).
3. **Configure import schedule**: activate the **Sources** parent import (or **Execute Now**).

## Loads

The first scheduled import is a **full load**, later ones are **delta**. For recurring full loads, schedule the script **Reset Last Run Datetime for SG-Akamai** (a **Scheduled Script Execution**, `sysauto_script`).

| Data source / staging | Target |
|---|---|
| `sn_akamai_api_sec_akamai_sources` | **Akamai API Security Sources** (`sn_akamai_source`), a non-CMDB table |
| `sn_akamai_api_sec_sga_akamai_api_component` | API Component and Key Value |

API Component attributes: correlation ID, **Internet Facing**, operational status, product instance identifier, **Request Data Types**, **Response Data Types** (plus authentication type per the overview).

## Connection properties

| Property | Default | Meaning |
|---|---|---|
| Import tags | false | import API tags |
| Tags storage type | `cmdb_key_value` | `cmdb_key_value` or `attributes` (the **Attributes** field of the API Component) |
| Tags value separator | null | delimiter between key and value |

Connections: **All > Service Graph Connectors > Akamai API Security > Connections**.

## Related

- [[API Insights]] · [[Service Graph Connectors Overview]] · [[Service Graph Connectors Catalog]]
