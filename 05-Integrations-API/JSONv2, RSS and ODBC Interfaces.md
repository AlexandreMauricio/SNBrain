---
type: concept
tags: [concept, api, integrations, data-management]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Web services > Inbound > JSONv2 and RSS (opening pages), Additional integration resources > ODBC driver (overview, getting started), read 2026-10-30. Data Retrieval and Modification API details, RSS options, ODBC install and configuration pages listed, not read in detail. https://www.servicenow.com/docs/r/api-reference/web-services/c_JSONv2WebService.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# JSONv2, RSS and ODBC Interfaces

**In one line:** older or niche ways to reach instance data, for when REST is not the fit.

From the Brazil docs; not tested. New work: [[REST API Fundamentals]]. Export by URL: [[Exporting Data]].

- **JSONv2:** a platform processor, `https://<instance>.service-now.com/<table>.do?JSONv2`; authenticated; insert, update and query. Results in `records`; errors in `__error` and `__status`.
- **RSS:** feed generator and reader over table data; basic authentication.
- **ODBC driver:** **read-only** SELECT from external tools over web services, so ACLs apply. Versions older than 2.1.1 unsupported. Create a user with role `odbc` plus ACLs for it. Limit: 512 characters for views, so at most 11 table sys_ids. No Java or JDBC-ODBC bridge. **Live Connect** is the newer SQL route: [[RaptorDB Standard and Professional and Live Connect]].

## Related

- [[SOAP Web Services]] · [[GraphQL API Framework]]
