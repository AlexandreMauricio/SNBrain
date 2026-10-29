---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Rapid7 (about 290 cleaned lines, read 2026-10-29) - overview, Configure connections, Targeted CMDB classes (class list). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-rapid7-integration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Rapid7

**In one line:** Store app `sn_sec_sgc_rapid7` that imports the assets known to **Rapid7 InsightVM** (4.0) into the CMDB as unclassed hardware with IP addresses, complementing InsightVM discovery.

From the Brazil docs (ServiceNow **Utah, Vancouver, Washington**); guided setup only; not tested. General: [[Service Graph Connectors Overview]].

**Unconfirmed variant:** the product is InsightVM and the key is an InsightVM API key, yet both pages say the API token needs the **InsightIDR viewer** role. Which Rapid7 role is really needed is open.

## Guided setup

**All > Service Graph Connectors > Rapid7 > Setup** > **Best Experience** (role `admin`; ITOM units, `com.snc.itom.discovery.license` activated, `com.snc.itom.license`, Integration Commons, CMDB CI Class Models, Datastream Action; `sn_observability` only for events):
1. **Configure Rapid7 authentication credentials**: a credential (for example `<Rapid7 credential>`) with the InsightVM **API Key**.
2. **Configure Rapid7 HTTP Connection**: connection alias such as `sn_sec_sgc_rapid7.SGRapid7`, URL builder on, connection URL by region (for example `https://us.api.insight.rapid7.com`), host without `https`.
3. **Test Connection** (status 200).
4. Optional **Add multiple instances** (better after a first successful import).
5. **Set up scheduled import jobs**: Active; Run = Once for a test; **Use connection** off for the first run; **Concurrent import** on; Partition Method **Custom size**; Partition size **15,000**.

## Classes

**Unclassed Hardware** (`cmdb_ci_unclassed_hardware`), IP Address, and the detail table **SGC Rapid7 Asset** (`sn_sec_sgc_rapid7_sgc_rapid7_asset`). No software classes are listed.

## Related

- [[Service Graph Connector for Qualys]] · [[Service Graph Connectors Overview]] · [[Scheduled and Concurrent Imports]]
