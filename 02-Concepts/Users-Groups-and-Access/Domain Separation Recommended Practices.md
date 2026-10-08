---
type: concept
tags: [concept, domain-separation, access-control, admin, scripting, business-rule, platform, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Domain separation for service providers > Recommended practices for service providers (chapter read in full 2026-10-08 through the docs site) - Customizing domain properties and themes, Managing domain separation for specific uses, Configuring domain separation with the domain picker, Performance considerations, Setting up domain hierarchies, Checking domain logs, Importance of the Default domain, Contains queries and domain access, Domain paths query method, Slow queries and SQL debugging, Before Query business rules, Avoiding domain path in scripts, Domain assignments, CSM plugin. https://www.servicenow.com/docs/r/platform-security/bp-domain-sep-recommended.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Domain Separation Recommended Practices

**In one line:** keep tenants standard, keep the hierarchy shallow in exceptions (few *contains* and *visibility* grants), always have a default domain, change the hierarchy rarely and in small batches, and never let scripts depend on domain paths.

From the Brazil docs, written for service providers. Concepts: [[Domain Separation Overview]]. Records, properties and tools: [[Domain Separation Administration]].

## Design

- **80 / 15 / 5**: at least 80% of what tenants get is standard, about 15% varies by parameter (a property or data value per domain), under 5% is tenant-specific configuration. Every one-off is something to maintain and a place to make mistakes.
- Before building: start from the base system and confirm the gap; prefer no-code; put variation in server-side logic driven by domain-separated properties ([[Domain Separation Administration]]); in client scripts use only supported APIs and limit synchronous server calls; peer-review code.
- Fields and tables exist once for everybody: a new field is global whatever domain you were in. ACL scripts do not run for list columns, so hide a field with a role-only read ACL.
- A new table that holds tenant data, or supports a process that must flow down, gets `sys_domain` (and `sys_overrides` for process tables): [[Domain-Separate a Custom Table]].
- Branding (theme, logo) is set on the company record.
- By default records take the domain of their company (task, user, group, location, department ...); all of these except task allow a manual override (**Managed domain**).
- Notifications can be overridden per domain, and the override follows the domain of the record the email is about, not the user's.
- Service Catalog is domain-separated; the provider should own categories and items.
- Administrators: accounts in global, used only for administration. **Test from inside a real domain, never from global**, because overrides are not processed properly in global. Give administrators a separate ordinary account if they also work as users.
- Document and test how each kind of record gets its domain.

## Default domain

Always define exactly one (name it *Default*, tick **Default**). Without it, unassigned tasks and users become global and visible to all tenants. Its records are visible only to administrators (unless visibility is granted). Review it regularly, move records to their proper domain, and treat recurring arrivals as a defect to fix at the source.

## Hierarchy and performance

- The number of domains matters less than what they carry and how they are related. The classic drop-down picker loads every domain before the session responds; with many domains switch to the reference picker (`glide.ui.domain_reference_picker.enabled`).
- Check the Domain Map before adding a domain; do not load more than about 30 domains by import or integration without testing first.
- **Contains** and **visibility** add OR conditions to every query of the users concerned; a contained domain with many children multiplies them. Treat both as exceptions, and prefer placing the user or domain where the hierarchy already gives the access.
- Changing a domain's parent recalculates paths and cascades through every related table. Do it only when needed, **never as a mass update**, in small batches, and wait for the previous batch: in Domain Log (`syslog_domain`) look for the message `DWR execution completed.` (DWR = domain work request). Do not move data between domains while the instance is in use.
- After any hierarchy change read `syslog_domain` for errors and warnings (for example orphan records in `sys_ui_list`), fix them, and run the validation again ([[Domain Separation Errors]]).
- The picker can lie: after a session timeout the session falls back to the home domain (and elevated roles are lost) while the header still shows the earlier choice. Reload before making changes.

## Queries

- Query method: domain paths (`glide.sys.domain.provider` = `domain_paths`, `glide.sys.domain.paths.installed` = true). If an instance shows anything else, contact support.
- Slow queries: **System Diagnostics > Stats > Slow Queries** (`sys_query_pattern`), search for `domain_path`. Usual causes: too many OR conditions from contains or visibility; not on domain paths; a missing index (check the explain plan).

## Before-query business rules

A *before query* business rule ([[Business Rules]]; server side) adds conditions to a query. In a domain-separated instance it is a supplement, **not a substitute**: it does not prevent leakage as reliably as the platform's domain filter.

Use it when:

- an application does not support domain separation and outside parties must be limited to some rows;
- a table is domain-separated but rows must be narrowed further for some domains (several vendors working for one customer, each seeing only what is assigned to them).

Rules for writing them:

- place the rule as low in the hierarchy as possible so it runs only for the users concerned;
- always fill in the condition;
- avoid OR clauses and non-indexed fields;
- keep them few;
- remember they do not run where business rules are skipped (transform maps with business rules off, scripts that disable the engine).

They run before ACLs, usually perform better than ACLs for cutting large result sets, and are silent (no "rows removed by security" message). Combining many of them with ACLs to imitate domain separation is customisation you must maintain, and it scales badly.

## Scripts

- **Never read or compare `sys_domain_path` in a script.** The value is recalculated whenever the hierarchy changes. Use `sys_domain`; the shipped `Domain - ...` business rules are the model.
- `sys_domain_path` is not captured in update sets (hierarchies differ per instance): after importing an update set, validate that paths are right on the target.

## Customer Service Management

With CSM installed, ask support to enable `csm_auto_account_domain_generation`: every new account then gets its own domain under TOP, or under the parent account's domain. Without it new accounts land in the default domain.

## Related

- [[Domain Separation Overview]] · [[Domain Separation Administration]] · [[Domain-Separate a Custom Table]] · [[Domain Separation Errors]] · [[Business Rules]] · [[Access Control Lists (ACLs)]]
