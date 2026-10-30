---
type: concept
tags: [concept, discovery, cmdb, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, IT Operations Management > ITOM Visibility > Service Mapping (156 topics; Exploring Service Mapping and its method pages, roles in components), read at overview depth 2026-10-30. Configuring and Using pages, pattern steps and Service Mapping Plus not read. https://www.servicenow.com/docs/r/it-operations-management/discovery/discovery-schedule-form.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Service Mapping Overview

**In one line:** builds maps of the devices, applications and configuration behind each application service, using top-down discovery and other methods.

From the Brazil docs; not tested. See [[Discovery Overview]]. It discovers **service instances**; the docs mostly say application services.

## Mapping methods

| Method | Uses |
|---|---|
| **Pattern-based** | main method; patterns are commands that detect a CI's attributes and outbound connections |
| **Tag-based** | key-value tags from cloud and containers |
| **Traffic-based** | observed connections, adding to pattern-based |
| **Predictive Intelligence** | machine learning suggestions |
| **CMDB-based** | CMDB data when no MID Server is available; uses Application Dependency Mapping (ADM) logic |
| **With Agent Client Collector** | no MID Server credentials needed |
| **Kubernetes Visibility Agent** | container environments |

- **Multi-source service mapping:** one unified service from several sources.
- **Automated Service Suggestions:** machine-learned candidates from discovered processes.
- **Lightweight Service Model:** stores current topology, no historical snapshots, for large inventories.

## Roles

| Role | Can |
|---|---|
| `service_mapping_admin` | set up and maintain; contains `app_service_admin`, `app_service_owner`, `discovery_admin` |
| `app_service_admin` | create and change service instances and maps |
| `app_service_user` | view maps |

The release notes change `app_service_admin` and `app_service_owner`: see [[Brazil Release Changes from Australia]]. `svc_ci_assoc` links CIs to services.

## Example

Map service *Example Web Service* from entry point *https://app.example.com*: a load balancer, an Apache server and a database appear in the map.

## Related

- [[Discovery Overview]] · [[Event Management Overview]] · [[CSDM Overview and Data Domains]]
