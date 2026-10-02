---
type: meta
tags: [meta]
status: documented
source: own
updated: 2026-10-01
---

# Index: Concepts

What things are, how they relate, and the settings that control them. Notes are grouped in topic subfolders. Add each new note under the right heading.

<!-- One line per note: [[Note Name]] - short description -->

## Foundations (`Foundations/`)

- [[Tables, Records and Table Relationships]] - tables, the three dictionary tables, extension, reference, many-to-many, views (documented)
- [[Table Extension and Extension Models]] - parent and child classes, table per class, hierarchy, partition, storage aliases (documented)
- [[Custom Tables and Entitlements]] - what counts as custom, prefixes, subscription mapping (documented)
- [[Dictionary Entry Form]] - every field of a dictionary entry: type, reference, choice, calculated, cascade rule (documented)
- [[Read-Only Field Options]] - Australia read-only options and the legacy behaviour property (documented)
- [[Dictionary Attributes Reference]] - attribute list grouped by purpose, rules for writing them (documented)
- [[Dictionary Overrides]] - per-child-table differences for a parent field (documented)
- [[Function Fields]] - glidefunction fields computed at query time (documented)
- [[Record Hierarchies and Hierarchical Queries]] - is in hierarchy conditions on department, location, manager (documented)
- [[Sys ID]] - the 32-character unique record identifier and how to read it (documented)
- [[Record Numbering]] - number formats, counter, gaps, uniqueness, padding (documented)
- [[Data Policies]] - mandatory and read-only for all data sources, conversion to and from UI policies (documented)
- [[Data Lookup and Record Matching]] - matcher tables, definitions, priority lookup (documented)
- [[Field Normalization and Transformation]] - normal values, aliases, rules, transforms, data jobs (documented)
- [[Dynamic Schema]] - dynamic attribute store, attributes, categories, namespaces, choice sets (documented)
- [[ServiceNow AI Platform Overview]]: what the platform is; experimentation and feature preview
- [[Date and Time Fields, Formats and Time Zones]]: UTC storage, formats, time zones, time worked, resolve time

## ITSM (`ITSM/`)

- [[Assignment Rules and Data Lookup Rules]] - when each runs and what it can set (documented)
- [[Many-to-Many Task Relations]] - typed relationships between tasks and with knowledge articles (documented)
- [[Time Cards and Time Sheets]] - time card management, policies, states, approvals (documented)
- [[State Models and State Transitions]]: allowed state moves on task tables

## Service Catalog (`Service-Catalog/`)

## CMDB and Assets (`CMDB-and-Assets/`)

- [[Companies and Normalization Data Services]] - company records and normalized company names (documented)

## SLA and Schedules (`SLA-and-Schedules/`)

- [[Schedules and Schedule Entries]]: business hours, holidays, child schedules, relative durations
- [[Business Calendars and Fiscal Calendars]]: named periods for filters, reporting and job scheduling

## Users, Groups and Access (`Users-Groups-and-Access/`)

- [[Users, Groups and Roles Overview]] - the three objects, how users are created, identity types, group facts (documented)
- [[Base System Roles]] - what each base role allows and contains (documented)
- [[Role Management]] - create, nest, assign, delegate, time-limit, read-only role, auditing (documented)
- [[Impersonation]] - how it works, limits, logging and auditing (documented)
- [[User Sessions and Timeouts]] - terminate, lock out, deactivate, timeout properties (documented)
- [[Non-Interactive Users]] - web service access only accounts for integrations (documented)

## Forms and Lists (`Forms-and-Lists/`)

- [[Form Layout, Sections and Views]] - form tools, sections, splits, annotations, embedded lists, personalization, required fields (documented)
- [[Attachments]] - attachment tables, events, size, role and extension limits, indexing (documented)
- [[Formatters]] - activity, process flow, parent breadcrumbs, approval summarizer, custom formatters (documented)
- [[Form Templates]] - templates, automatic and child templates, modules, applyTemplate (documented)
- [[UI Actions]] - buttons, links and menu items, fields, condition rules, overriding (documented)
- [[Form and Attachment Properties]] - properties and preferences for forms, attachments, activity formatter (documented)
- [[Field Administration]] - field rules and limits, mandatory behaviour, labels, unique, highlighted values (documented)
- [[Field Types Reference]] - field types, database mapping, when a type can change, document ID setup (documented)
- [[Choice Lists]] - labels versus values, None behaviour, security, common tasks (documented)
- [[HTML Field Editor]] - TinyMCE properties and plugins (documented)
- [[Reference Fields]] - display value order, cascade rules, reference key, decorations, auto-complete (documented)
- [[Reference Qualifiers]] - simple, dynamic and advanced qualifiers, INSTANCEOF, related list tags (documented)
- [[E164 Phone Number Fields]] - territory logic, properties and attributes (documented)
- [[List Configuration and List Controls]] - layout, list control options and scripts, sort order, personal lists, ranking, context menus (documented)
- [[List Editor]] - what it bypasses, properties, list_edit ACL operation (documented)

## Scripting (`Scripting/`)

- [[Order of Execution for Rules, Engines and Notifications]] - before rules, engines, database operation, after rules, notifications (documented)
- [[UI Policies]] - conditions, actions, order, inheritance, scripts, limits (documented)
- [[Mail Scripts]] - template, email, event objects; examples (documented)

## Flows and Automation (`Flows-and-Automation/`)

- [[Events and the Event Queue]]: gs.eventQueue, registry, script actions, queues, states
- [[Scheduled Jobs]]: script, report and template jobs; run options; inactivity monitors

## Notifications and Email (`Notifications-and-Email/`)

- [[Email Architecture and Accounts]] - default accounts, one SMTP rule, message states, size limits, account groups (documented)
- [[Email Properties Reference]] - sending, receiving, limits, display and recipient logging properties (documented)
- [[Email Filters, Address Filters and Bounce Management]] - allow and deny lists, inbound filters, bounces, granular email roles (documented)
- [[S-MIME Email Encryption]] - signing and encryption, key pair and certificates, properties (documented)
- [[Email Notifications]] - when, who, what; weight and duplicates; recipients ignore ACLs (documented)
- [[Notification Variables and Links]] - field, URI, comments, mail script, unsubscribe and report variables (documented)
- [[Baseline Email Notifications and Events]] - shipped notifications and the events behind them (documented)
- [[Email Templates, Layouts and Calendar Invitations]] - layout, template, notification; mailto replies; iCalendar (documented)
- [[Email Watermarks, Digests, Retention and Translation]] - watermarks, reply separators, digests, retention, translation, domains (documented)
- [[Push and Messaging App Notifications]] - mobile push, Slack and Teams notifications (documented)
- [[Inbound Email Actions]]: classification new/reply/forward, matching, the email object
- [[Notification Preferences and Channels]]: devices, subscriptions, mandatory and forced
- [[Provider Notifications]]: Next Experience, Workspace and Virtual Agent notifications with actions
- [[Email Client]]: sending email from a record; configurations, templates, quick messages

## Knowledge (`Knowledge/`)

## Portals and Workspaces (`Portals-and-Workspaces/`)

## Security (`Security/`)

## AI (`AI/`)

- [[Email Agentic Workflow and Notification Agent]]: intent to action on inbound email

## Data Management (`Data-Management/`)

- [[Data Management Overview]] - policies, console, driver and associated tables, the rule types (documented)
- [[System Archive and Archive Rules]] - ar_ tables, flattening, references to strings, related records, destroy rules, ACLs, properties (documented)
- [[Live Archive with RaptorDB Professional]] - archive to object storage, S3 facade, requirements (documented)
- [[Table Cleaner]] - cleanup rules, slow rule handling, limits, properties (documented)
- [[Update Jobs, Delete Jobs and One-Time Delete Rules]] - previewable bulk changes with rollback (documented)
- [[Database Rotation - Table Rotation and Table Extension]] - shards by creation date, query consequences (documented)
- [[Exporting Data]] - export routes, roles, what each format contains, surprises (documented)
- [[Export Limits and Properties]] - row and cell limits, display value and header properties, URL parameters (documented)
- [[Rollback and Delete Recovery]] - rollback contexts, modules, retention properties, database support (documented)

## Instance Administration (`Instance-Administration/`)

- [[Instance Clone Overview]] - clone workflow, exclusions versus preservers, cleanup scripts, what gets destroyed, authentication (documented)
- [[Clone Options and States]] - request options and defaults, scheduling limits, clone and script states (documented)
- [[Instance Scan]]: checks, suites, scan types, findings
- [[Transaction Quotas, Application Quotas and Operational Toggles]]: what cancels long transactions
- [[Monitoring and Troubleshooting Instance Performance]]: transaction log, slow patterns, index suggestions
- [[System Events and Scheduled Jobs Dashboards]]: event queue and scheduler health, stuck jobs
- [[Upgrades - Process, Upgrade Center and Upgrade Console]]: preview, monitor, history, upgrade plan, guided upgrade
- [[Skipped Records in Upgrades]]: why customised records are skipped and what to do
- [[Plugins]]: activation, no deactivation, finding installed components
- [[System Properties]]: the sys_properties table, cache flush cost, private properties
- [[System Properties Reference]]: curated list by topic with defaults
- [[Admin Center, Store and Application Manager]]: procuring, installing, updating, repairing applications
- [[Subscription Management]]: subscription types, measured roles, custom table mapping
- [[Otto for Setup and Multi-Instance Trust]]: guided setup, batch update sets, trust between instances

## Search (`Search/`)

- [[Zing Text Search and Global Search]]: keyword search syntax, text indexes, stop words, relevance, global search setup
- [[AI Search Overview]]: indexed sources, search profiles, query language, security, external content
- [[Contextual Search]]: related search results on forms and record producers

## Localization (`Localization/`)

- [[Languages, Translation Tables and Locale]]: language resolution, the five translation tables, translating custom content
- [[Currency and Price Fields]]: reference vs session currency, price types, FX Currency
- [[Localization Framework, Workspace and Dynamic Translation]]: machine translation and managed translation projects
