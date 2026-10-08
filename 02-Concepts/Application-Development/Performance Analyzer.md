---
type: concept
tags: [concept, platform, workspace, instance-admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Testing and debugging applications (chapter introduction) and Performance Analyzer (whole section, 128 cleaned lines, read in full 2026-10-08 through the docs site) - Explore, Configure, Test applications (metrics by duration, application, page route, interaction), Reference. https://www.servicenow.com/docs/r/application-development/performance-analyzer/performance-analyzer-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Performance Analyzer

**In one line:** an admin tool on the instance that shows page load times for UX framework (Next Experience, workspace) pages, from totals per application down to a waterfall of every resource loaded in one interaction.

From the Brazil docs; the section is short and gives no table names or properties.

## Where and who

- **All > Next Experience Developer Tools > Performance Analyzer**; role `admin`.
- On the instance automatically since Zurich; on earlier releases install it from the ServiceNow Store.

## Drilling down

| Level | Choose | Shows |
|---|---|---|
| Duration | **Duration**: last 15 minutes up to last 7 days | per application: total UI time, download time, trend, comparison with the previous period |
| Application | **Application** | the same per page route |
| Page route | **Page route** | each interaction: timestamp, interaction type, total UI time, download time, record |
| Interaction | **Timestamp** | a waterfall: the requests as a tree-shaped timeline with details per resource |

## The other testing and debugging tools named in the chapter introduction

| Tool | For |
|---|---|
| Automated Test Framework | [[Automated Test Framework Overview]] |
| Script Debugger (role `script_debugger`) and Session Log | stepping through server-side JavaScript; viewing and downloading logs |
| Script Tracer | narrowing down which script line ran |
| Test Management 2.0 | managing manual test versions, with Agile Development 2.0 |
| Impersonation | [[Impersonation]] |

ATF's own timing of whole tests: *Performance profiling* in [[ATF Test Suites, Schedules and Administration]].

## Related

- [[UI Builder Overview and Concepts]] · [[Workspace Builder]] · [[Application Development Tools and Lifecycle]]
