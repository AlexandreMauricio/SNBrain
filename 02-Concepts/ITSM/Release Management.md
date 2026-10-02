---
type: concept
tags: [concept, change, task]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Release Management" (pp. 3101-3111), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Release Management

**In one line:** Release Management v2 groups work items (projects, stories, defects, problems, changes) into releases with phases and tasks, optionally under a product.

Plugin `com.snc.release_management_v2`. Menu **Release**.

## Tables

| Table | Label | Notes |
|---|---|---|
| `rm_product` | Product | optional; **Configuration Item** links it to the CMDB |
| `rm_release` | Release | **Release Type** (Major, Minor, Upgrade, Patch), **State**, **Percent complete**, planned start/end/duration; can have child releases |
| `rm_release_phase` | Release Phase | stages such as design, build, test, deploy |
| `rm_task` | Release Task | work under a phase |
| `rm_m2m_release_task` | Release Items | work items and changes attached to a release |
| `dsl` | Definitive Media Library | physical and logical store of software media |

## Roles

`release_v2_admin` (everything), `release_v2_user` (read modules), `sn_release_read` (read-only, plugin `com.snc.release_management_read_roles`, comes with Business Stakeholder).

## State categories (for custom states)

| Category | `rm_release` | `rm_task` |
|---|---|---|
| pending | -5 | -5 |
| open | 1 | 1 |
| work in progress | 2, 4, 10 | 2 |
| completed | 3 | 3 |
| close states | 3, 7 | 3, 4, 7 |
| skipped | 4, 7 | 4, 7 |

Defaults: open 1, work 2, close 3, skipped 7, pending -5.

## Scoping a release

Related lists on the release (Projects, Scrum Epics / Stories, SAFe items, Defects, Enhancements, Incidents, Problems, Changes) with **Attach task**. Needs Agile Development 2.0 / PPM / SAFe plugins for those item types. A problem tracks releases as fixes through `rm_release.parent` ([[Problem Management Overview and Lifecycle]]).

Domain separation: Basic.

## Related

- [[Change Management Overview and Lifecycle]]
