---
type: concept
tags: [concept, domain-separation, users, access-control, security, platform, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Domain separation for service providers (whole chapter, 85 topics, 5,168 cleaned lines, read in full 2026-10-08 through the docs site; much of it repeated link lists). This note covers Exploring domain separation, Delegating configuration options to customers, Domain assignment, Visibility domains and Contains domains, Domain scope, Concepts for service providers (Global queue v.2, Service provider connector), Installed with domain separation, and from the recommended practices - Domain separation explained, value proposition, definition, hierarchies, Context, Segregating and securing data, Cross tenant intelligence, Alternatives, Evaluating the need, Benefits, How a database query works, Service provider reference architecture (decision trees, dedicated, hybrid, SIAM), Domain separation terms. Diagrams are not reproduced. https://www.servicenow.com/docs/r/platform-security/c_DomainSeparation.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Domain Separation Overview

**In one line:** one instance serves several tenants (customers of a service provider, or strictly separated business entities): every record carries a **domain**, every query is silently limited to the domains the user may see, and processes and UI can be overridden per domain, all arranged in a hierarchy where **data rises up and process flows down**.

From the Brazil docs. Administration and tools: [[Domain Separation Administration]]. Which applications support it: [[Domain Separation Support Levels by Application]]. Design advice: [[Domain Separation Recommended Practices]]. Other ways to restrict rows: [[Access Control Lists (ACLs)]], [[Security Attributes, Security Data Filters and Field Query Controls]].

> Before activating: it adds permanent administration overhead, and **it can be disabled but never removed** from an instance. Some things stay global whatever you do: system properties, table schema, ACLs, script includes.

## What is separated

| Layer | Meaning |
|---|---|
| **Data separation** | users see only records of their domain and its child domains (plus global records); a query cannot return other tenants' rows |
| **UI separation** | views, lists, forms, labels, menus, dashboards, branding per domain |
| **Business logic (process) separation** | notifications, business rules, client scripts, UI policies, UI actions per domain |
| **Hierarchical modelling** | parents see children's data; a parent's logic applies to children unless overridden lower down |
| **Cross-tenant intelligence (domain scope)** | the platform works out data, logic and context for users who can see several tenants |

Data changes in a domain do not create update set records; integration accounts are limited the same way as people.

## The domains

| Term | Meaning |
|---|---|
| **global** | not a domain: the *absence* of one. A table without a domain field is all global; a record with an empty domain shows `global`. Visible to everyone unless security says otherwise |
| **TOP** (the **primary** domain) | root of the hierarchy. A *process domain*: holds processes and overrides of global ones, never users |
| **Default** domain | where task and user records land when nothing assigns them a domain. Only the provider sees it; anything in it signals a configuration or procedure gap and must be moved. Without a default domain such records become global, visible to all |
| Customer domain | a tenant: its data, users, and its own process and UI variations |
| Process domain | processes and UI for a set of domains; no users or core data |
| Data domain | data shared by several customers without sharing their domains; uncommon, can hurt performance |

Users belong in customer domains (occasionally data domains), never in global or process domains. The exception is administrator accounts, which sit in global and should not be used as everyday accounts.

## Three kinds of relationship

| | Parent / child | Contains | Visibility |
|---|---|---|---|
| Between | domain and domain (the hierarchy) | domain and domain, many-to-many, outside the hierarchy | a user or group and a domain |
| Affects | **data and process** | data only | data only |
| Domain picker | yes | yes: in the home domain the user sees the contained domains too; switching to one shows only that one | **no**: always visible, whatever the picker says |
| Use | the design itself | targeted extra access for a whole domain's users; each relationship adds OR conditions to queries | sparingly, through groups; easily grants more than intended |

Tables: Contained Domain (`domain_contains`), User Visibility Domain (`sys_user_visibility`), Group Visibility Domain (`sys_user_group_visibility`). Group members get the group's visibility domains and lose them on leaving. A visibility domain does not replace ACLs.

A suggested layout: under TOP, a branch *Unrestricted* (customers the provider may see broadly: one *contains* covers them all) and a branch *Restricted* (customers with strict access terms: visibility granted per domain through groups). A customer sits in exactly one vertical line and consumes only the processes of its own ancestors.

## How a record gets its domain

Stored in **Domain** (`sys_domain`); one domain per record. Set, in the docs' list, by: the company of the user, a business rule, the module used (`sysparm_domain=<domain sys_id>` in the module's arguments), a form template with the domain preset, the parent record (a change task takes the change request's domain; a problem takes the incident's), the domain on the user record, and as last resort the domain of the creating user.

- Assigning a user to a **company** puts them in the company's domain; changing a company's domain cascades to its locations, departments, groups and users, except records with **Managed domain** ticked.
- **Deactivating a domain** deactivates its companies, and their users can no longer log in ("Company inactive - your access to this instance is not authorized").
- Cannot be domain-separated: Access Control (`sys_security_acl`), Script Include (`sys_script_include`), System Property (`sys_properties`), `sys_security_restricted_list`, Dictionary (`sys_dictionary`) and Dictionary Override (`sys_dictionary_override`). Do not separate other `sys_` platform tables either.

## Session scope and record scope

- **Session scope**: set at login to the domain on the user record (the *home domain*); changed with the **domain picker**, which lists the domains in reach. The session's domains are appended to **every** database query (a WHERE clause added by the platform, before ACLs run).
- **Record scope**: when a form is open, the *record's* domain decides which processes, UI and reference data apply. It takes precedence, so a provider agent working an ACME incident gets ACME's rules. It persists if the picker changes, and each browser tab has its own.
- Users with role `domain_expand_scope` get the form UI action **Toggle Domain Scope**: expand to session scope (choose values from all visible domains) or collapse to the record's domain. Not shown for global records or when both domains are the same.
- Picking a reference value from another domain (assigning an ACME incident to a provider agent) does not change the record's domain. A user without access to the referenced record's domain does not see the display value (instances activated from Madrid on).

## What a customer can be allowed to administer

Designed for the provider to configure, not for tenants to self-administer. Base roles assume one admin team per instance (`domain_admin` manages all domains), so create narrow "customer admin" roles with ACLs.

| Safe | With care | Never |
|---|---|---|
| CMDB data; reports; users without roles; departments, groups without roles, locations, cost centres | catalog items in the customer's domain (a role limited to price, description, picture; Catalog Builder templates); user and group administration (role grants cannot be subdivided, and affect security and licensing); flows with `flow_designer` (they can read and copy flows of domains above; needs shared governance) | **choice lists**: `sys_choice` rows are keyed by table, domain and language, and an update ships all values of the field and replaces them; also fields, business rules and anything shared |

## When it fits, and the alternatives

Fits: moderate process alignment across tenants; tenants mostly as fulfillers under the provider's processes; contractual data isolation that a shared database can satisfy; separate entities that still need combined reporting.

Does not fit: tenants who want to own and administer their environment or roadmap; isolation required at database level (domains share one database); every tenant wanting entirely different processes; mere departmental privacy (ACLs suffice); tenants who are only requesters.

| Alternative | For | Against |
|---|---|---|
| Separate instances | clean separation, own release timing, own data centre region, no side effects | cost, keeping instances aligned, duplicated work, integrations between them |
| One instance without domains (ACLs, views, reference qualifiers, before-query rules) | cheap for simple cases | heavy customisation that upgrades skip, every supporting table must be handled, all testing is yours |

Provider architectures described: **shared** instance (fulfillers shared across domains, shared administration, practically unlimited end users), **dedicated** instance per customer (own admin team and licences, sized per customer), **hybrid** (shared for most services, dedicated for one, integrated), **SIAM** (services of several providers integrated behind one experience).

## Installed components

- Role `domain_admin`. Task field **Task for** (`task_for`, reference to User). Group **Type** values Security, Support, Visibility.
- `sys_domain` added to `sys_attachment`, `sys_user_has_role`, `sys_group_has_role`, `sys_email`, `sys_user_group`, `core_company`, `cmn_location`, `cmn_department`, `sys_gauge`, `sys_report`, `kb_feedback`, `sysapproval_approver`, `sys_user_grmember`.
- Business rules, by family (all named `Domain - ...`): **Set Domain** (user, group, department, location and CI from the company; attachment and email from the parent record; approvals from the approved record; task SLA from the task; roles from user or group; workflow context and history), **Default** (task from the *Task for* user, else Default; user to Default instead of global), **Cascade** (company to its users, groups, departments, locations; task to its workflows, SLAs, approvals, attachments, emails; user and group to their role and membership rows; email to attachments; article to feedback), **Override Copy** (copying child records when a UI policy, UI action, data policy, application menu, gauge or embedded list control is overridden), **Activate/Deactivate** and **Deactivate Companies**, **Validate Default** / **Validate Primary** (only one of each), **Disallow Global Domain Record** (no domain named global).
- Client script *Domain - Set Company and Location* on incident (fills company and location from the caller if empty).

## Service provider concepts

- **Global queue v.2**: a custom application giving agents one virtual list of tasks assigned to them across several instances, without copying the data (useful under data residency rules). A proof of concept published by ServiceNow.
- **Service provider connector**: reference design for a Store application a provider gives its customers to connect their instance to the provider's: roles, menus, dashboards, guided onboarding, task and catalog e-bonding, CMDB synchronisation. Building blocks: Instance Data Replication, Integration Hub, a virtual work queue (keep under 1,000 rows), remote tables, flows.

## Related

- [[Domain Separation Administration]] · [[Domain Separation Recommended Practices]] · [[Domain Separation Support Levels by Application]] · [[Domain-Separate a Custom Table]] · [[Domain Separation Errors]] · [[Access Control Lists (ACLs)]] · [[Business Rules]] · [[sys_user]]
