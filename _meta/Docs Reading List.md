---
type: meta
tags: [meta]
status: documented
source: own
updated: 2026-10-01
---

# Docs reading list

ServiceNow documentation pages processed into the vault, and pages still to read. Check this list before ingesting a page (`find-related.ps1 -Doc "<part of the URL>"`).

## Sources and the status they get

| Source | Status of notes taken from it |
|---|---|
| Official product documentation | `documented` |
| Official developer site (API reference, guides) | `documented` |
| Official training material | `documented` |
| Community posts, blogs, videos, LLM answers | `unverified` until tested |
| The user's own test in an instance (PDI or other) | `verified`, with date and release |

Record the release family of each page: the same page can differ between releases.

## Processed

| Page | URL | Release | Read | Notes created |
|---|---|---|---|---|
| Table administration (tables and extension, dictionary, attributes, overrides, indexes, many-to-many, Task table, assignment rules, planned tasks, task relations, time cards, database views, record hierarchies) | `ServiceNow Australia Platform Administration PDF`, pp. 460-590 | Australia | 2026-10-01 | [[Tables, Records and Table Relationships]], [[Table Extension and Extension Models]], [[Custom Tables and Entitlements]], [[Dictionary Entry Form]], [[Read-Only Field Options]], [[Dictionary Attributes Reference]], [[Dictionary Overrides]], [[Function Fields]], [[Record Hierarchies and Hierarchical Queries]], [[Order of Execution for Rules, Engines and Notifications]], [[Assignment Rules and Data Lookup Rules]], [[Many-to-Many Task Relations]], [[Time Cards and Time Sheets]], [[Database Views]], [[task]], [[planned_task]], [[reminder]], [[sys_db_object]], [[sys_dictionary]], [[sys_documentation]], [[sys_storage_alias]], [[System Fields on Every Table]], 8 how-tos, [[Approaches to Auto-Assigning Tasks]] |
| Data Management (console, policies, System Archive, Live Archive, table cleaner, update and delete jobs, database rotation, properties, sys_id) | `ServiceNow Australia Platform Administration PDF`, pp. 591-652 | Australia | 2026-10-01 | [[Data Management Overview]], [[System Archive and Archive Rules]], [[Live Archive with RaptorDB Professional]], [[Table Cleaner]], [[Update Jobs, Delete Jobs and One-Time Delete Rules]], [[Database Rotation - Table Rotation and Table Extension]], [[Sys ID]], [[sys_auto_flush]], 4 how-tos, [[Approaches to Deleting Many Records]]; record hierarchy form added to [[Record Hierarchies and Hierarchical Queries]] |
| Exporting data (formats, URL export, XML export and import, limits, properties, Google Sheets) | `ServiceNow Australia Platform Administration PDF`, pp. 653-687 | Australia | 2026-10-01 | [[Exporting Data]], [[Export Limits and Properties]], [[Export Data with a URL]], [[Export and Import Records as XML]], [[Set Up Export to Google Sheets]]; role data_mgmt_tools_admin added to [[Data Management Overview]] |
| Roll back and delete recovery | `ServiceNow Australia Platform Administration PDF`, pp. 687-693 | Australia | 2026-10-01 | [[Rollback and Delete Recovery]], [[Restore a Deleted Record]], [[Roll Back a Patch, Plugin Activation or Background Script]] |
| Instance Clone (overview, Clone Admin Console, configuration, request, manage, reference) | `ServiceNow Australia Platform Administration PDF`, pp. 694-732 | Australia | 2026-10-01 | [[Instance Clone Overview]], [[Clone Options and States]], [[Request, Schedule, Cancel or Roll Back a Clone]], [[Register a Clone Target Instance]], [[Configure Clone Exclusions, Preservers and Cleanup Scripts]], [[Carry In-Progress Update Sets Through a Clone]], [[Clone Target Registration Errors]] |
| Form administration (form design and layout, personalization, annotations, attachments, formatters, templates, UI actions, UI policies, advanced form configuration) | `ServiceNow Australia Platform Administration PDF`, pp. 733-799 | Australia | 2026-10-01 | [[Form Layout, Sections and Views]], [[Attachments]], [[Formatters]], [[Form Templates]], [[UI Actions]], [[UI Policies]], [[Form and Attachment Properties]], [[Configure a Form Layout]], [[Create a Process Flow Formatter]], [[Create a UI Action]], [[Create a UI Policy]], [[UI Policy or Client Script]] |
| Field administration (fields, numbering, normalization, data policy, data lookup, dynamic schema, field types, choice lists, function fields, HTML editor, journal, phone, reference fields and qualifiers) | `ServiceNow Australia Platform Administration PDF`, pp. 800-997 | Australia | 2026-10-01 | [[Field Administration]], [[Record Numbering]], [[Data Policies]], [[Data Lookup and Record Matching]], [[Field Normalization and Transformation]], [[Dynamic Schema]], [[Field Types Reference]], [[Choice Lists]], [[HTML Field Editor]], [[Reference Fields]], [[Reference Qualifiers]], [[E164 Phone Number Fields]], [[State Fields and Task State Values]], [[Journal Fields]], [[Function Fields]] (extended), 9 how-tos, [[Data Lookup Rule Not Working]], [[UI Policy or Data Policy]] |
| List administration (layout, calculations, list controls, sort order, list editor, personal lists, detail rows, fixed queries, hierarchical lists, context ranking, context menus) | `ServiceNow Australia Platform Administration PDF`, pp. 998-1026 | Australia | 2026-10-01 | [[List Configuration and List Controls]], [[List Editor]], [[Filter and Sort a List with URL Parameters]], [[Configure a List Layout and List Control]] |
| User administration (users, self-registration, companies, normalization data services, departments, groups, roles, role delegation, time-limited roles, read-only role, impersonation, sessions, non-interactive users) | `ServiceNow Australia Platform Administration PDF`, pp. 346-459 | Australia | 2026-10-01 | [[Users, Groups and Roles Overview]], [[Base System Roles]], [[Role Management]], [[Impersonation]], [[User Sessions and Timeouts]], [[Non-Interactive Users]], [[Companies and Normalization Data Services]], [[sys_user]], [[sys_user_group]], [[Create a User]], [[Create a Group and Add Members]], [[Assign Roles to Users and Groups]] |
| Email Administration (accounts, own servers, OAuth, Microsoft Graph, properties, filters, bounce management, S/MIME, size limits) | `ServiceNow Australia Platform Administration PDF`, pp. 2391-2484 | Australia | 2026-10-01 | [[Email Architecture and Accounts]], [[Email Properties Reference]], [[Email Filters, Address Filters and Bounce Management]], [[S-MIME Email Encryption]], [[Set Up Email with Your Own Mail Servers]] |
| System notifications (email notifications, variables, mail scripts, baseline notifications, dashboards, templates, layouts, calendar, retention, watermarks, digests, translation, troubleshooting, email log, push, Slack and Teams) | `ServiceNow Australia Platform Administration PDF`, pp. 2485-2616 | Australia | 2026-10-01 | [[Email Notifications]], [[Notification Variables and Links]], [[Mail Scripts]], [[Baseline Email Notifications and Events]], [[Email Templates, Layouts and Calendar Invitations]], [[Email Watermarks, Digests, Retention and Translation]], [[Push and Messaging App Notifications]], [[sys_email]], [[Create an Email Notification]], [[Notification Email Not Sent or Not Received]] |
| Provider notifications | `ServiceNow Australia Platform Administration PDF`, pp. 2617-2630 | Australia | 2026-10-01 | [[Provider Notifications]] |
| Email client | `ServiceNow Australia Platform Administration PDF`, pp. 2631-2654 | Australia | 2026-10-01 | [[Email Client]], [[Enable the Email Client for a Table]], [[Create an Email Client Template]] |
| Inbound email | `ServiceNow Australia Platform Administration PDF`, pp. 2655-2685 | Australia | 2026-10-01 | [[Inbound Email Actions]], [[Create an Inbound Email Action]], [[Inbound Email Flow or Inbound Email Action]] |
| Notification Preferences | `ServiceNow Australia Platform Administration PDF`, pp. 2686-2706 | Australia | 2026-10-01 | [[Notification Preferences and Channels]], [[Make a Notification Mandatory or Forced]] |
| Notification agent and agentic workflows | `ServiceNow Australia Platform Administration PDF`, pp. 2707-2723 | Australia | 2026-10-01 | [[Email Agentic Workflow and Notification Agent]] |
| System Events | `ServiceNow Australia Platform Administration PDF`, pp. 2724-2741 | Australia | 2026-10-01 | [[Events and the Event Queue]], [[sysevent]], [[Create and Register an Event]] |
| State Management | `ServiceNow Australia Platform Administration PDF`, pp. 2741-2746 | Australia | 2026-10-01 | [[State Models and State Transitions]] |
| Metrics | `ServiceNow Australia Platform Administration PDF`, pp. 2746-2749 | Australia | 2026-10-01 | [[Metric Definitions and Metric Instances]] |
| Instance Scan | `ServiceNow Australia Platform Administration PDF`, pp. 2750-2786 | Australia | 2026-10-01 | [[Instance Scan]], [[Scan an Update Set or Record with Instance Scan]] |
| System Events and Scheduled Jobs dashboards | `ServiceNow Australia Platform Administration PDF`, pp. 2786-2794 | Australia | 2026-10-01 | [[System Events and Scheduled Jobs Dashboards]] |
| Platform performance, System Diagnostics | `ServiceNow Australia Platform Administration PDF`, pp. 2794-2838 | Australia | 2026-10-01 | [[Transaction Quotas, Application Quotas and Operational Toggles]], [[Monitoring and Troubleshooting Instance Performance]], [[Transaction Cancelled - Maximum Execution Time Exceeded]] |
| Upgrade Center, Upgrade Console | `ServiceNow Australia Platform Administration PDF`, pp. 2839-3006 | Australia | 2026-10-01 | [[Upgrades - Process, Upgrade Center and Upgrade Console]], [[Skipped Records in Upgrades]], [[Process the Skipped Records List after an Upgrade]] |
| Additional resources | `ServiceNow Australia Platform Administration PDF`, pp. 3007-3011 | Australia | 2026-10-01 | none (list of external links only) |
| Getting started, How the platform works, Experimentation, Feature Preview | `ServiceNow Australia Platform Administration PDF`, pp. 7-14 | Australia | 2026-10-01 | [[ServiceNow AI Platform Overview]] |
| ServiceNow plugins, Find components installed | `ServiceNow Australia Platform Administration PDF`, pp. 15-20 | Australia | 2026-10-01 | [[Plugins]] |
| Available system properties | `ServiceNow Australia Platform Administration PDF`, pp. 21-132 | Australia | 2026-10-01 | [[System Properties Reference]] (curated subset) |
| Add a system property, properties module, join limits, Web proxy | `ServiceNow Australia Platform Administration PDF`, pp. 133-139 | Australia | 2026-10-01 | [[System Properties]], [[Add a System Property]] |
| Admin Center, Store, Application Manager, Legacy Application Manager | `ServiceNow Australia Platform Administration PDF`, pp. 139-253 | Australia | 2026-10-01 | [[Admin Center, Store and Application Manager]] |
| Multi-instance Management, Otto for Setup | `ServiceNow Australia Platform Administration PDF`, pp. 254-300 | Australia | 2026-10-01 | [[Otto for Setup and Multi-Instance Trust]] |
| Subscription Management, Now Support administration | `ServiceNow Australia Platform Administration PDF`, pp. 300-345 | Australia | 2026-10-01 | [[Subscription Management]] |
| Time configuration | `ServiceNow Australia Platform Administration PDF`, pp. 2040-2121 | Australia | 2026-10-01 | [[Schedules and Schedule Entries]], [[Define a Schedule]], [[Scheduled Jobs]], [[Create a Scheduled Script Job]], [[Date and Time Fields, Formats and Time Zones]], [[Set the System Time Zone and Date Format]], [[Business Calendars and Fiscal Calendars]], [[Timeline Pages and Schedule Pages]] |
| Currency administration | `ServiceNow Australia Platform Administration PDF`, pp. 2122-2153 | Australia | 2026-10-01 | [[Currency and Price Fields]] |
| Dynamic Translation, Localization Framework, Localization Workspace | `ServiceNow Australia Platform Administration PDF`, pp. 2154-2316 | Australia | 2026-10-01 | [[Localization Framework, Workspace and Dynamic Translation]] (summary depth) |
| System Localization | `ServiceNow Australia Platform Administration PDF`, pp. 2317-2364 | Australia | 2026-10-01 | [[Languages, Translation Tables and Locale]], [[Translate a Field Label and a Choice]] |
| Platform integrations | `ServiceNow Australia Platform Administration PDF`, pp. 2365-2390 | Australia | 2026-10-01 | [[Integration Options and Interfaces Overview]] |
| Search administration, Search Suggestions, Search signals, Zing | `ServiceNow Australia Platform Administration PDF`, pp. 1027-1137 | Australia | 2026-10-01 | [[Zing Text Search and Global Search]], [[Text Search Returns No Results]] |
| AI Search, AI Search Admin console, Advanced AI Search Management Tools, External Content Connectors | `ServiceNow Australia Platform Administration PDF`, pp. 1138-1999 | Australia | 2026-10-01 | [[AI Search Overview]] (summary depth; connector procedures not transcribed) |
| Contextual search, Intelligent Search for CMDB | `ServiceNow Australia Platform Administration PDF`, pp. 2000-2039 | Australia | 2026-10-01 | [[Contextual Search]], [[Configure Contextual Search on a Form]] |

## To read

| Page | URL | Why |
|---|---|---|
| IT Service Management guide (incident, problem, change, request) | Australia PDF or docs site | the ITSM, Service-Catalog folders are almost empty; the admin guide only touches task tables |
| Service Catalog and record producers | Australia PDF or docs site | variables, variable sets, flows behind items |
| Service Level Management (SLA definitions) | Australia PDF or docs site | schedules and relative durations are documented, SLA definitions are not |
| Workflow Studio / Flow Designer | Australia PDF or docs site | inbound email flows and notification-by-flow are only outlined in the admin guide |
| Scripting (business rules, client scripts, script includes, Glide API) | Australia PDF, developer site | the admin guide references these without explaining them; 04-Scripts-Automation is empty |
| Access control (ACLs), security and SSO | Australia PDF or docs site | roles are documented, ACL rules are not |
| Import sets, transform maps, REST and SOAP APIs, MID Server | Australia PDF or docs site | 05-Integrations-API has only the overview |
| Update sets and application scope | Australia PDF or docs site | referenced by upgrades, clone and Otto for Setup notes |
| CMDB and CSDM | Australia PDF or docs site | only companies and the SCCM import are covered |
| Knowledge Management | Australia PDF or docs site | contextual search and translation notes assume it |
| Reporting / Platform Analytics | Australia PDF or docs site | 06-Reporting has database views, metrics and timelines only |

## Fetching notes

- **Platform Administration PDF (Australia)**: `servicenow-australia-platform-administration-enus.pdf`, 3,011 pages, kept outside the vault (the user's Downloads folder; too large for git). Read by extracting text per outline section with Python `pypdf` (`PdfReader`, `outline`, `extract_text`), stripping the three footer lines of each page, then reading the text files in chunks. Tables in the PDF come out as broken lines, so column alignment has to be inferred. Rows in the Processed table give the PDF section title and page range instead of a URL.
