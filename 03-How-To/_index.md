---
type: meta
tags: [meta]
status: documented
source: own
updated: 2026-10-01
---

# Index: How-To

Step-by-step procedures, grouped by topic (the notes themselves stay in one flat folder). Sections mirror `02-Concepts/`. Add new lines with `add-index-line.ps1 -Section "<heading start>"`.

<!-- One line per note: [[Note Name]] - short description -->

## Foundations and platform administration

- [[Create a Table]] - table form, columns, controls, application access (documented)
- [[Delete a Custom Table or All Records in a Table]] - empty a table or remove a custom table (documented)
- [[Generate a Schema Map]] - visual map of extensions and references (documented)
- [[Create or Drop a Table Index]] - btree or columnstore index, drop a custom index (documented)
- [[Create a Many-to-Many Relationship]] - sys_m2m definition between two tables (documented)
- [[Create a Data Policy]] - conditions and data policy rules (documented)
- [[Create a Custom Data Lookup]] - lookup table extending dl_matcher plus definition (documented)

## ITSM: incident, problem, change and request

- [[Create an Assignment Rule]] - assign unassigned tasks by condition (documented)
- [[Create an Assignment Data Lookup Rule]] - assign incidents from a lookup matrix (documented)
- [[Configure Incident Auto-Close]] - days, resolution date or last update, run-as user of the job
- [[Create an Incident Record Producer]] - record producer with variables and a template; module opening a templated incident
- [[Create a Major Incident Trigger Rule]] - propose or promote incidents automatically
- [[Create a Blackout or Maintenance Schedule]] - freeze periods and maintenance windows for conflict detection
- [[Create an On-Call Escalation Trigger Rule]] - start an on-call escalation subflow from a task

## Service Catalog

## CMDB and Assets

- [[Configure a Service Availability KPI in Digital Portfolio Management]] - KPI group mapping, commitment, outage, PA collection job, check on the Run tab

## SLA and Schedules

- [[Define a Schedule]]
- [[Create an SLA Definition]] - duration, schedule, conditions, retroactive start, validating with the timeline

## Users, Groups and Access

- [[Create a User]] - user form, password, identity type (documented)
- [[Create a Group and Add Members]] - group form, members, hidden group business rule (documented)
- [[Assign Roles to Users and Groups]] - group roles, user roles, nested roles, time-limited roles (documented)
- [[Create an ACL]] - create a table or field ACL, check it with the execution plan and the watcher (documented, Brazil)
- [[Domain-Separate a Custom Table]] - add sys_domain, set, default and cascade business rules

## Forms and Lists

- [[Configure a Form Layout]] - fields, sections, annotations, embedded lists, charts, related lists (documented)
- [[Create a Process Flow Formatter]] - stage records with conditions (documented)
- [[Create a UI Action]] - button or link running a script, override per child table (documented)
- [[Add or Delete a Field]] - create a column from the form layout, delete custom columns (documented)
- [[Set a Default Field Value]] - constant or javascript default, examples (documented)
- [[Make a Field Dependent on Another Field]] - dependent choice and reference fields (documented)
- [[Define a Field Style]] - CSS by value or scripted condition (documented)
- [[Configure Choice List Options]] - edit options, reuse a list, remove or relabel None (documented)
- [[Configure a Reference Qualifier]] - steps plus role and group membership examples (documented)
- [[Configure a List Layout and List Control]] - columns, calculations, buttons and filters (documented)

## Scripting

- [[Create a UI Policy]] - condition plus UI policy actions (documented)
- [[Create and Register an Event]]

## Flows and Automation

- [[Create a Scheduled Script Job]]
- [[Create and Test a Playbook]] - new playbook, parent table, trigger, stages, activities, test run, activate
- [[Build a Flow in Workflow Studio]] - create, add trigger and steps, test, activate, attach to a catalog item (documented)
- [[Create a Decision Table in Workflow Studio]] - inputs, columns, rows, default result, test, publish, use from a flow (documented)

## Application Development

- [[Build a Request App in Creator Studio]] - app, form, questions, publish, approval playbook, workspace list, test, submit for review, deploy (documented, Brazil)
- [[Build an App in App Engine Studio]] - table extending Task, record producer, decision table, approval flow, test (documented, Brazil)

## Notifications and Email

- [[Set Up Email with Your Own Mail Servers]] - own SMTP, POP3, IMAP, OAuth 2.0, Microsoft Graph (documented)
- [[Create an Email Notification]] - notification form and preview (documented)
- [[Create an Inbound Email Action]]
- [[Enable the Email Client for a Table]]
- [[Create an Email Client Template]]
- [[Make a Notification Mandatory or Forced]]

## Knowledge

## Portals and Workspaces

## Security and single sign-on

- [[Set Up SAML Single Sign-On]] - recovery user, IdP record from metadata, test connection, activation, routing users (documented, Brazil)
- [[Raise the Hardening Compliance Score]] - work the non-compliant settings by score impact, update and compare the score

## AI

## API, integrations and imports

- [[Set Up an LDAP Integration]] - certificate, server, OU definitions, data source, transform map, schedule (documented, Brazil)
- [[Register an OAuth Client for Inbound REST Calls]] - client credentials or authorization code client, token request, checks and gotchas
- [[Create a Connection and Credential Alias]] - alias, credential, HTTP connection and attributes for a flow integration
- [[Set Up Log Export Service]] - Hermes check, certificates, sources, then a Kafka or MID Server consumer

## Reporting and dashboards

- [[Create a Database View]] - join tables, left joins, where clause rules, restrict and relabel fields (documented)

## Update sets and moving changes between instances

- [[Move an Update Set between Instances]] - create, complete, retrieve, preview, commit; XML alternative (documented, Brazil)

## Data Management

- [[Create an Archive Rule]] - console wizard and Core UI form, related records, destroy rule (documented)
- [[Restore Archived Records]] - from the console or the archive log (documented)
- [[Create a Table Cleanup Rule]] - age-based automatic deletion (documented)
- [[Bulk Update or Delete Records with a Job]] - update and delete jobs with preview and rollback (documented)
- [[Export Data with a URL]] - processors, sysparm parameters, splitting large exports (documented)
- [[Export and Import Records as XML]] - copy records between instances, display value matching (documented)
- [[Set Up Export to Google Sheets]] - Google OAuth app, application registry, alias, credential, connection, property (documented)
- [[Restore a Deleted Record]] - Deleted Records and Delete Recovery modules (documented)
- [[Roll Back a Patch, Plugin Activation or Background Script]] - rollback contexts and script execution history (documented)

## Instance Administration

- [[Request, Schedule, Cancel or Roll Back a Clone]] - clone request form, recurrence, cancel and rollback windows (documented)
- [[Register a Clone Target Instance]] - OAuth setup per target, basic authentication fallback (documented)
- [[Configure Clone Exclusions, Preservers and Cleanup Scripts]] - definitions and clone profiles (documented)
- [[Carry In-Progress Update Sets Through a Clone]] - batch under a parent update set retrieved on the source (documented)
- [[Scan an Update Set or Record with Instance Scan]]
- [[Process the Skipped Records List after an Upgrade]]
- [[Add a System Property]]
- [[Set the System Time Zone and Date Format]]

## Search

- [[Configure Contextual Search on a Form]]

## Localization

- [[Translate a Field Label and a Choice]]
