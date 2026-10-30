---
type: concept
tags: [concept, discovery, cmdb, release-specific]
status: documented
source: ServiceNow Brazil docs, IT Operations Management > Agent Client Collector > Exploring (overview, architecture summaries), and ITOM/OT SU Licensing landing, read 2026-10-30. Configuring (203 topics) and reference (105) not read. https://www.servicenow.com/docs/r/it-operations-management/discovery/discovery-schedule-form.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Agent Client Collector Overview

**In one line:** an agent installed on Windows, Linux and macOS devices that collects data and monitors health, instead of or alongside agentless discovery.

From the Brazil docs; not tested. Built on a **Sensu** framework. The framework is called ACC-F. Domain separation is supported.

- **Compared with [[Discovery Overview]]:** Discovery is agentless, run from a MID Server. An agent suits remote devices that a network scan cannot reach. The two can run together.
- **Monitoring:** servers, databases, application servers, middleware; can be extended.
- **Other uses:** Log Analytics, live CI data, [[Service Mapping Overview|Service Mapping]] without MID Server credentials, and [[Digital End-User Experience Overview and Architecture|DEX]].

**Licensing:** ITOM usage is counted in **subscription units** (SU) through ITOM/OT SU Licensing, by CIs. Check before scaling.

## Example

Install the agent on *Example Laptop 01*, confirm the CI updates, and add a monitoring check for it.

## Related

- [[Discovery Overview]] · [[Event Management Overview]] · [[MID Server Overview and Architecture]]
