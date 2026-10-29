---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Microsoft Defender for Endpoint (about 430 cleaned lines, read 2026-10-29) - overview with data mapping, Configure using SGC Central, Configure using guided setup, Target CMDB classes, Properties, Accessing connection details, Life cycle management. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-cmdb-integration-msdefender.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Microsoft Defender for Endpoint

**In one line:** Store app `sn_defender_integ` that reads the machines protected by Microsoft Defender for Endpoint (Plan 1 or 2) through the **List machines** API and loads computers, IPs, network adapters and OS software into the CMDB, mainly for Security Operations.

From the Brazil docs (Washington DC, Xanadu, Yokohama); not tested. The docs title it both "Microsoft Defender Endpoint" and "Microsoft Defender for Endpoint". General: [[Service Graph Connectors Overview]]. Same OAuth pattern as [[Service Graph Connector for Microsoft Azure]].

## Microsoft side

An active Defender for Endpoint subscription and an Azure app registration for it: tenant ID, client ID, client secret; permissions **Machine.Read.All** and **Machine.ReadWrite.All** (the docs ask for ReadWrite too, although the connector only reads: worth questioning before granting).

## Setting up the connection

SGC Central (connector 1.1.0+; prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`) > **Microsoft Defender** > **Configure connection**: one default connection **SG Defender OAuth2.0 connection** (keep the name; single connection): client ID, client secret, token URL `https://login.microsoftonline.com/<tenantid>/oauth2/v2.0/token`, optional MID Server → **Update and test connection** → schedule **SG-Defender Machines**.

Classic guided setup (**All > Service Graph Connectors > Microsoft Defender > Setup**, being deprecated): same credentials on an **Application Registries** form, **Test Connection**, activate the scheduled job. Requirements there: ITOM Visibility or Discovery units, `com.snc.itom.discovery.license` (activate), `com.snc.itom.license`, Datastream Action, and `sn_observability` only for event ingestion.

**Upgrade to 1.2.0**: machines move from **Server** (`cmdb_ci_server`) to **Computer** (`cmdb_ci_computer`); migrate existing data (KB2096769).

## Data and classes

One data source, **SG-Defender Machines** → Computer (discovery source, install status, OS, OS version), IP Address and Network Adapter (**Owns::Owned by**), software records for the **operating system only**, and **SG-Defender Machines Related** (`sn_defender_integ_sg_defender_machines_related`: agent version, device ID, **exposure level**, first seen, **health status**, last reported, managed by, **onboarding status**).

Life cycle management covers Windows Server (`cmdb_ci_win_server`), IP Address, Network Adapter and Computer. Note the Windows Server entry despite the 1.2.0 move to Computer: unconfirmed whether both still apply.

System property `sn_defender_integ.pagination_record_count` (500): rows per List machines call. Connections: **All > Service Graph Connectors > Microsoft Defender > Connections** (path assumed from the other connectors; the page omits it).

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Microsoft Intune]] · [[Service Graph Connector for Microsoft Azure]]
