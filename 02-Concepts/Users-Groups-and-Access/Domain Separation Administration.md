---
type: reference
tags: [reference, domain-separation, users, access-control, admin, instance-admin, glide-api, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Domain separation for service providers (chapter read in full 2026-10-08 through the docs site) - Setup and administration (Request domain separation, Domain separation plugin, Domain system properties and user preferences, Create a domain, Make a domain the default, Manually manage the domain, Domain Separated Tables, Domain Override Viewer, Enable or disable a domain, View domain relationships, Select a primary domain, Create Contains relationships, Expand domain scope, visibility domains, domain-specific choice list), Advanced administration (domain selection menus, application properties), Domain Migration Tool, Process administration with example, logging and debug messages, Post-Production Activation Utility, Domain Job Management, Delete by domain, Domain Separation Center (configure, audits, schedules, results). https://www.servicenow.com/docs/r/platform-security/c_DomainSeparationSetup.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Domain Separation Administration

**What this is:** the plugins, properties, records and tools used to set up and run a domain-separated instance.
**Where:** All > Domain Admin (Domains, Domain Map, Domain Separation Center, Domain Migration Tool, Cleanup Queue)
**Role required:** `admin` (`domain_admin` can create, edit and delete domains)

Concepts first: [[Domain Separation Overview]]. Design advice: [[Domain Separation Recommended Practices]].

## Activation

| Plugin | Id | Notes |
|---|---|---|
| Domain Support - Domain Extensions Installer ("the Domain Separation plugin") | `com.glide.domain.msp_extensions.installer` | subscription; requested through Now Support (**System Applications > All Available Applications > All > Request plugin**). Not reinstalled if already active |
| Domain Separation (the pages name it only as a prerequisite of the domain reference picker; what else it adds is not stated (?)) | `com.snc.pa.domain_support` | request the installer first |
| Domain Migration Tool | `com.glide.domain.migration_tool` | on a clone, on request |
| Post-Production Domain Separation Activation Utility | `com.glide.domain.activation_utility` | |

- Activate **at the very start of an implementation**, before other plugins. Activating on a live instance puts every existing record and all logic in global, and scripting records into domains afterwards risks data loss and downtime. For that case there is the activation utility: a guided setup that installs with data and process separation switched off, creates the domains, logs and explains errors, and needs downtime or restricted access while domain values are populated.
- Replaces the old Company Separation plugin (cannot be activated since Helsinki; `glide.db.separation.field` controls it where it still exists).
- Domain **paths** are the query method for everyone since Helsinki (domain numbering is gone).

## Domain record

**Domain Admin > Domains > New** (table `domain`; the pages also call the domain table `sys_domain`):

| Field | Meaning |
|---|---|
| **Name** | unique; never `global` |
| **Type** | Vendor, Customer, MSP (extendable) |
| **Primary** | the top of the hierarchy; exactly one; no parent, at least one child |
| **Default** | exactly one; receives unassigned tasks and users. The field may need adding to the form |
| **Parent** | required for the domain to appear on the map |
| **Active** | deactivate instead of deleting; cascades to the domain's companies (and activating a company activates its domain) |
| **Description** | |

Related lists: **Companies**, **Contains Domains**, **Contained By**.

- **Domain Map** (**Domain Admin > Domain Map**): read-only tree of active domains with a parent.
- **Contains**: on the containing domain, related list **Contains Domains > Edit**. With the picker on global only child domains are offered: use **Toggle Domain Scope** to see all.
- **Visibility domains**: add the related list *Visibility domains* to the group form (preferred) or the user form, then **Edit**. Columns: **Domain**, **Inherited**, **Granted By** (the group), **Parent visibility**.
- **Managed domain** (`?` column name not given): a check box on user, group, department, location and CI records; ticked, the **Domain** field appears and is set by hand instead of following the company.

## Properties and preferences

| Property | Default | Effect |
|---|---|---|
| `glide.sys.domain.use_record_domain_for_processes` | true | processes follow the record's domain (business rules always do) |
| `glide.sys.domain.use_record_domain_for_data` | true (activations since Fuji) | related data (reference pickers, related lists) follows the record's domain |
| `glide.sys.domain.use_record_domain`, `..._for_client_scripts`, `glide.sys.domain.domain_change_notify`, `glide.sys.domain.no_change_roles` | | ignored when either of the two above is true |
| `glide.sys.domain.skip_domain_insert_businessrules` | true (activations since Jakarta) | business rules on the domain table chosen by session domain, which makes inserting domains much faster |
| `glide.sys.domain.skip_non_global_businessrule_if_nodomain` | true (recommended) | on tables without a domain, or with `queryNoDomain()`, only global business rules run |
| `glide.sys.restrict_global_domain_processes` | set true | a global user sees only global rows on process tables until **Expand Domain Scope** |
| `glide.sys.domain.partitioning` | | data separation on or off |
| `glide.sys.domain.delegated_administration` | | process separation on or off |
| `glide.sys.domain.enabled` | | master switch |
| `glide.sys.domain.provider` = `domain_paths`, `glide.sys.domain.paths.installed` = true | | the domain paths query method is in use |
| `glide.sys.domain.verbose` | | true: verbose domain logging |
| `glide.ui.domain_reference_picker.enabled` | create, true | Core UI: type-ahead picker instead of a full drop-down (removes the *global* entry; the return arrow goes home) |
| `glide.ui.polaris.domain_picker.role` | create | Next Experience: roles that see the picker, comma separated. By default `itil` and roles containing it; the docs recommend admins only |
| `com.glide.domain.audit.big_tables.additional` | | tables never to audit in the Domain Separation Center |
| `csm_auto_account_domain_generation` | off; enabled by support | Customer Service: each new account gets its own domain under TOP (or under its parent account's domain); otherwise new accounts go to the default domain |

User preferences (admin-set, global or per user): `glide.domain.session_scope` (false; true makes session scope the default on forms) and `glide.domain.session_scope_notification` (true; shows a cue when the scope is expanded).

Core UI picker: gear icon > *General* > **Show domain picker in header**.

## Process administration (overrides)

- While working in a domain, an administrator can make domain-specific versions of client scripts, system policies, application and module names, application roles and module filters, among others.
- **Editing a record that belongs to a higher domain (or global) from inside a lower domain does not change it: the update becomes an insert in the current domain, with Overrides (`sys_overrides`) pointing at the original.** At run time the lowest matching version wins.
- Lookup order for a transaction: the **record's** domain, then each ancestor, then global.
- Wrong way: editing the higher record and then changing its **Domain** field (leaves no record at either level).
- Tables with `sys_overrides` are *process tables*; on them visibility runs the opposite way to data: children see the parents' records, parents do not see the children's. From global, related links **Expand Domain Scope** / **Collapse Domain Scope** show or hide all domains' versions (reports too).
- Example from the docs: in domain *Example Customer* an administrator renames an application menu and adds a role to it, and activates a module with an extra filter; new records appear in that domain only, and administrators of other domains keep seeing the global versions.
- `admin` passes all checks in every domain: grant it carefully (an admin can also edit their own user record and so change domain).

**Domain Override Viewer** (type "domain" in the navigator): tables that have overrides with counts, the overridden parent records with their domain, and **View Overrides**. **Domain Separated Tables**: every table with a `sys_domain` column, plus those deriving their domain from a referenced record through the dictionary attribute `domain_master=<reference field>`.

**Domain-specific choices**: select the domain in the picker, right-click the field label > **Configure Choices**, edit, and move through update sets. A choice added from global is appended to every domain's list (active if added as *Selected*, inactive if *Available*). Keep values unique across domains.

## Domain-separated properties for applications

`sys_properties` is not domain-separated, so since Paris:

| Table | Columns |
|---|---|
| System Application Property (`sys_application_property`) | `name` (unique; scope prefix for scoped apps), `description`, `type`, `default_value`, `property` (optional reference to a `sys_properties` row it overrides), `usage_notes`, `read_roles`, `write_roles` |
| System Application Property Value (`sys_application_property_value`) | `sys_application_property`, `sys_domain`, `sys_overrides`, `value`; unique per property and domain |

Read through the server-side API `GlideApplicationProperty` (global and scoped): it looks in these tables for the current domain first and falls back to the system property. The docs' example: first day of the week Sunday in a parent domain, Monday in a child.

## Changing the hierarchy and cleaning up

- Re-parenting a domain triggers recalculation of domain paths on every domain-separated table. **Domain Job Manager**: pause the job (auto-resumes after 1 hour unless told not to), queue several hierarchy changes, run them as one job, **View Job Progress**.
- **Delete by domain** (**Domain Admin > Cleanup Queue**): only inactive leaf domains. **Prepare For Cleanup** > select > **Move to Staging** with a retention in days (once *Staged and Deletion Planned* it cannot be withdrawn); **Preview Domain Data** scans what the domain holds.
- **Domain Migration Tool** (**Domain Admin > Domain Migration Tool**, table `domain_migration_tool_status`; elevate to `security_admin`): run on a **clone**, turns a domain-separated copy into a dedicated instance for one tenant. Give **Target domain** and **Additional data domains** (children are not kept unless listed); first run the audit *Validate Domain Separated Table Schema* and fix findings; **Start Migration**. It deletes data outside global, target and listed domains, collapses or deletes process overrides, fixes `sys_choice`, `sys_ui_list` and `sys_ui_related_list`, removes the domain plugin's business rules, UI actions, jobs, installation exits and modules, sets the three switch properties false and deletes the other domains. Needs data and process separation on when it starts. Progress in `sys_execution_tracker` (*Running Migration on Tables*) and `syslog_domain` (source `MigrationTool`). It never touches the source instance; review the remaining configuration afterwards.

## Domain Separation Center

Dashboard at `https://<instance>.service-now.com/domaincenter`: health audits defined in `domain_audit_definition` (shipped only; none can be added).

- **Configure Audits**: all inactive at first; tick **Active**, choose **Frequency** (Daily, Weekly, Monthly; no daily audits on large tables).
- **Audit Schedules**: hour (24-hour clock), weekday (1 = Sunday) or day of month; audits of one frequency run one after another. **Execute Now** runs the whole frequency (single audits cannot be run alone).
- **Configure Domain Center**: **Enables detail domain logging** (costs performance); a list marking large tables.
- Tiles **Errors**, **Warnings**, **Running Audits**, **Inactive Audits**. An audit result has a **Detail ID**: filter Domain Log (`syslog_domain`) on **Source** `=<Detail ID>` to see each offending record. Buttons **Rerun Audit**, **Deactivate Audit**, **Copy Details**.

## Related

- [[Domain Separation Overview]] · [[Domain Separation Recommended Practices]] · [[Domain Separation Errors]] · [[Domain-Separate a Custom Table]] · [[Domain Separation Support Levels by Application]] · [[Instance Clone Overview]] · [[System Properties Reference]]
