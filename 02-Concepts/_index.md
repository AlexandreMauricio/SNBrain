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
- [[Update Sets]] - what is captured, states, default set, transfer, preview problems, collisions and coalesce strategies, commit, back out, batches, properties (documented, Brazil)

## ITSM (`ITSM/`)

- [[Assignment Rules and Data Lookup Rules]] - when each runs and what it can set (documented)
- [[Many-to-Many Task Relations]] - typed relationships between tasks and with knowledge articles (documented)
- [[Time Cards and Time Sheets]] - time card management, policies, states, approvals (documented)
- [[State Models and State Transitions]]: allowed state moves on task tables
- [[Incident Management Overview and Lifecycle]] - channels, states, priority matrix, assignment, promotion to problem/change/request, resolve, close, reopen, roles
- [[Incident Properties Reference]] - auto-close, copy, child, impacted services, major incident and notification-redirect properties
- [[Major Incident Management]] - major incident state, propose/promote, trigger rules, workbench, post incident report, roles
- [[Parent and Child Incidents]] - copy and child incidents, what is copied, parent-to-child state synchronisation
- [[Incident Communications Management]] - communication plans and tasks, contacts and responsibilities, channels, closure cascade
- [[Problem Management Overview and Lifecycle]] - guided states, roles, communicating workaround and fix to incidents, known errors, properties, models, migration utility
- [[Change Management Overview and Lifecycle]] - types and state paths, processing actions, on hold, CIs, unauthorized changes, roles, flows, key properties
- [[Change Models and Change Templates]] - model states, transitions and conditions, model properties, template life cycle
- [[Standard Change Catalog]] - proposing, approving, modifying and retiring standard change templates; catalog properties
- [[Change Approval Policies]] - approval definitions, decisions, policy inputs, flow action and workflow activity
- [[Change Conflict Detection and Maintenance Schedules]] - conflict types, blackout and maintenance schedules, conflict properties, scheduling assistant
- [[Change Risk Calculation and Assessment]] - risk conditions, risk assessment questionnaire, success score, calculated risk score, risk intelligence
- [[CAB Workbench]] - CAB definitions, meetings, agenda items, running a meeting
- [[Change Schedules Timeline]] - change schedule definitions, related definitions, style rules
- [[On-Call Scheduling]] - shifts, rosters, rotation, escalation policies, trigger rules and subflows, tracking, roles, tables
- [[Task Outages]] - outage records and the task_outage link, Create Outage UI action
- [[Release Management]] - product, release, phase, task tables; state categories; scoping
- [[Continual Improvement Management]] - improvement initiatives, states, goals and KPIs, workbench, integrations, properties
- [[ITSM Application Suite Overview]] - map of every application in the ITSM guide to its vault note; short summaries of Benchmarks, Coaching, DEX, DPM, DPR, dashboards, Workforce Optimization
- [[DevOps Change Velocity and DevOps Config]] - pipeline-driven change requests, integrations, data model, properties (overview)
- [[Change Management Plugins, Tables and Workspace Configuration]] - which plugin installs what, logging properties, legacy state-model scripts, workspace overview containers, legacy dashboards
- [[Simplified IT Service Management]] - AI-first packaging: configuration console, simplified change models and roles, employee and fulfiller views, setup AI agents, shipped catalog items
- [[Coaching]] - coaching opportunities, assessments, virtual coach, surveys, skills awarded; tables, roles, properties
- [[Walk-up Experience]] - tech lounge queues: location settings, appointment booking, kiosks, badge readers, roles and tables
- [[Workforce Optimization for ITSM]] - WFO (deprecated path noted): channels, shift scheduling, adherence, demand forecast, work scheduler, teams
- [[Workforce Optimization Learning, Skills and Reference]] - WFO learning content and integrations, skill matrix, review, determination and prediction, roles, domain separation, mobile shift requests, landing pages, filters
- [[DevOps Change Velocity Setup and Onboarding]] - personas, adoption phases, supported tools, install, roles and tasks, integration user, playbook onboarding pattern, pipeline step fields
- [[DevOps Applications, Change Acceleration and Approval Flows]] - DevOps applications, change control and change receipt, the three approval flows, policies, default change handler, partial data, callback timeout
- [[DevOps Change Models]] - type compatibility property, DevOps and DevOps Simplified models and flows, presets and attribute precedence, callback, pull requests, import based evidence
- [[DevOps Artifacts, Packages, Commits and Pipeline UI]] - artifact versions and packages, staging codes, which commits a change shows, Pipeline UI, changeRequestDetails and auto close
- [[DevOps Change Velocity Administration and Data Management]] - bulk onboarding, imports and polling, throttling and retries, cloning preservers, deletion rules, table cleanup and archiving
- [[DevOps Change Velocity Reference]] - roles, jobs, tables, all properties, system health, common errors, health scan checks
- [[DevOps Config Data Model and Changesets]] - CDM and PaCE, components / collections / deployables, uploads and XML / CSV parsing, variables, file nodes, changeset conflicts, CDM properties
- [[DevOps Config Snapshots, Policies and Exporters]] - snapshot states, static and dynamic policy mapping, CdmPolicyUtil, exporters, component libraries, alert investigation, Insights
- [[DevOps Config Reference]] - roles, CDM APIs, contextual variables, domain separation, shipped generic / Kubernetes / OpenShift policies, shipped exporters
- [[Digital End-User Experience Overview and Architecture]] - DEX: what it monitors, components (ACC agent, browser extension, shared services), roles, limits; map of the DEX notes
- [[DEX Agent Deployment and Connectivity]] - installing ACC MID-less on Windows and macOS, sudoers, connectivity tests, Intune and Jamf, proxy, switching instance, non-persistent VDI
- [[DEX Monitoring Configuration, Alert Rules and Remedial Actions]] - application and page monitoring, metric and event rules, alerts and grouping, agent policies, remedial actions, custom PowerShell action, user and location mapping
- [[DEX Reference]] - DEX tables, shipped remedial actions, check definitions, collected metrics, policies, event configurations, properties, reporting tables
- [[Proactive Engagement]] - sn_pren: experience issues, resolution types, engagement settings, throttling properties, workbench, roles and tables
- [[Digital Experience Score]] - DEX Score hierarchy and weights, normalization formulas, metric definitions, surveys, dashboard, demo data
- [[Digital Product Release]] - DPR: release life cycle, timeline and stage processes, states, multi-product releases, restricted access, bundles, dashboards, risk score, AI release notes, GRC and SOW integration
- [[Digital Product Release Configuration and Templates]] - install, external tools, release calendars and readiness targets, approval definitions, PaCE policies, release templates, product-level settings
- [[Working a Digital Product Release]] - products, features, enhancements, planning board, creating releases, running phases, CIs, changes, artifacts, approvals, retarget, hold, close
- [[Digital Product Release Reference]] - DPR roles, tables, scheduled jobs, properties, notifications, shipped policies and data collectors

## Service Catalog (`Service-Catalog/`)

- [[Request Management Data Model and Process]] - REQ, RITM, SCTASK, cart and variable tables, checkout sequence, requests from incidents, Universal Request
- [[Service Creator]] - legacy departmental services: category request, generated table and role, editors and fulfillers, template notifications

## CMDB and Assets (`CMDB-and-Assets/`)

- [[Companies and Normalization Data Services]] - company records and normalized company names (documented)
- [[Service Portfolio Management]] - services, offerings, commitments, availability, portfolios, lifecycle mapping to CSDM, Service Builder
- [[Models, Model Categories and the Product Catalog]] - how model categories link CI and asset classes; models, bundles, vendor and product catalog items
- [[Asset Management Common Applications]] - contract management states and tables, procurement flows and tables, software asset basics
- [[Expense Lines and Allocations]] - expense line sources and fields, allocation rules
- [[Service Offerings, Commitments and Availability]] - taxonomy nodes, service and offering fields, outages, availability calculations, SLA results, Service Builder detail
- [[Contract Management]] - contract form, states and substates, nightly compliance checks, terms, rate cards, renewal workflow
- [[Procurement]] - sourcing a request (consume, transfer, purchase), purchase order statuses, receiving, consumable merge, Coupa integration
- [[Software Asset Management Foundation Plugin]] - discovery models, normalisation, entitlements, reconciliation results, migration from the legacy plugin
- [[Legacy Software Asset Management Plugin]] - software counters, licence calculation types, suites, upgrades and downgrades, IBM PVU and Oracle packs
- [[Service Builder]] - guided editor for services and offerings: roles, draft / approval / publish, fields per step; the SNC script include rule
- [[Digital Portfolio Management]] - DPM workspace: solutions through plan / build / run, home page cards and thresholds, personal and enterprise portfolios, templates, lists
- [[DPM Solution Pages and Needs Attention]] - Plan, Build, Run, Risk and Info tabs per solution type, KPI inheritance for service instances, how records reach the Needs attention panel
- [[DPM Administration, KPI Groups and Reference]] - Admin Center, properties, CSDM life-cycle mapping, KPI groups and mappings, Process Mining, roles, tables, plugins per view

## SLA and Schedules (`SLA-and-Schedules/`)

- [[Schedules and Schedule Entries]]: business hours, holidays, child schedules, relative durations
- [[Business Calendars and Fiscal Calendars]]: named periods for filters, reporting and job scheduling
- [[SLA Definitions and Task SLAs]] - definition fields, start/pause/stop/reset conditions, evaluation order, actual vs business time, retroactive start, notifications
- [[SLA Engine, Repair, Timeline and Breakdowns]] - recalculation jobs, engine properties, repair, timeline, breakdowns, timer configuration

## Users, Groups and Access (`Users-Groups-and-Access/`)

- [[Users, Groups and Roles Overview]] - the three objects, how users are created, identity types, group facts (documented)
- [[Base System Roles]] - what each base role allows and contains (documented)
- [[Role Management]] - create, nest, assign, delegate, time-limit, read-only role, auditing (documented)
- [[Impersonation]] - how it works, limits, logging and auditing (documented)
- [[User Sessions and Timeouts]] - terminate, lock out, deactivate, timeout properties (documented)
- [[Non-Interactive Users]] - web service access only accounts for integrations (documented)
- [[ITSM Granular Roles]] - sn_incident/problem/change/request read and write roles, service desk agent, business stakeholder
- [[Access Control Lists (ACLs)]] - parts of an ACL, operations, evaluation and processing order, deny by default, query, datatype and function field ACLs, scopes, properties, Role Management V2 additions (documented, Brazil)
- [[Explicit Roles and Elevated Privilege Roles]] - snc_internal and snc_external (plugin behaviour, mutual exclusion), elevated roles, security_admin, forcing admins to elevate (documented, Brazil)
- [[External User Self-Registration]] - registration configuration, form fields, verification and onboarding subflows, portal link, reCAPTCHA (documented, Brazil)
- [[Domain Separation Overview]] - tenants in one instance: data, process and UI separation, global / TOP / default domains, parent-child vs contains vs visibility, session and record scope, when it fits
- [[Domain Separation Administration]] - plugins, domain records, properties, process overrides, application properties, migration and cleanup tools, Domain Separation Center
- [[Domain Separation Recommended Practices]] - 80/15/5, default domain, hierarchy changes, contains and visibility cost, before-query rules, no domain paths in scripts
- [[Domain Separation Support Levels by Application]] - No support / Basic / Standard / Enhanced and which application is at which level

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
- [[Application Menus and Modules]] - navigator menus (sys_app_application) and modules (sys_app_module): fields, link types, encoding of arguments (documented, Brazil)

## Scripting (`Scripting/`)

- [[Order of Execution for Rules, Engines and Notifications]] - before rules, engines, database operation, after rules, notifications (documented)
- [[UI Policies]] - conditions, actions, order, inheritance, scripts, limits (documented)
- [[Mail Scripts]] - template, email, event objects; examples (documented)
- [[Business Rules]] - when they run, form fields, current / previous / g_scratchpad, recursion and abort rules, query rules, scope limits

## Flows and Automation (`Flows-and-Automation/`)

- [[Events and the Event Queue]]: gs.eventQueue, registry, script actions, queues, states
- [[Scheduled Jobs]]: script, report and template jobs; run options; inactivity monitors
- [[Workflow Studio Overview]] - one builder for playbooks, flows, subflows, actions and decision tables; pages; when to use a flow or a playbook; updating
- [[Playbooks Overview and Components]] - process definitions, triggers, stages, activities, start rules, properties, runtime, test, restart, security and domains
- [[Playbook Activities, Decisions and Variants]] - activity definitions, UI layouts, questionnaire, AI agent and skill activities, delays, decisions, Go back, parallel branches, state mapping, variants
- [[Playbooks Administration, Roles and Access]] - plugins per trigger table, roles, content filtering, archiving process contexts, data definitions, AI generation, MCP tools, translations
- [[Flows, Subflows and Actions Overview and Architecture]] - what flows, subflows and actions are, engine architecture, limits, deployment (documented)
- [[Building Flows - Properties, Triggers, Stages and Error Handling]] - run as, flow roles, triggers, editing and locks, test, stages, error handler, design guidelines
- [[Subflows in Workflow Studio]] - inputs and outputs, publish, convert to subflow, dynamic flows, conversational skills
- [[Custom Actions, Dynamic Inputs and Error Evaluation]] - action anatomy, error conditions, retry policy, dynamic inputs and outputs, complex data in script steps
- [[Saved Triggers and External Event Sources]] - reusable record, scheduled, business calendar and webhook triggers; event source authentication; detach and delete
- [[Flow Authoring Aids - History, Variables, Inline Scripts and AI]] - flow variables, fd_data inline scripts, history and compare, template builder, generative AI skills
- [[Flow Administration, Execution Details and Access]] - execution details, reporting levels, retention tables, priority, roles, content filtering, FlowAPI, client callable flows
- [[Flow Core Actions Reference]] - every ServiceNow Core action with inputs, outputs and rules (approval, wait, records, catalog, email, attachments, AI)
- [[Flow Logic Reference]] - If, Make a decision, loops, Go back to, parallel, Try, Wait for a duration, End Flow, Dynamic Flow, Call a Workflow
- [[Flow Trigger Types Reference]] - record trigger run options and advanced options, other trigger types, inbound email order, pills per trigger
- [[Flow Action Steps Reference]] - Script, JSON Builder, REST, SOAP, JDBC, PowerShell, SSH, SFTP, ZIP, Kafka and data steps for custom actions
- [[Flow Data Types and Transform Functions]] - variable types, password2 pills, catalog variable mapping, transform functions, user preferences, flow or subflow
- [[Flow System Properties Reference]] - limits, logging, reporting, designer, stage and approval properties with defaults
- [[Flow Spokes Shipped with the Platform]] - ITSM, Connect, VTB, CSM, FSM, ML, RPA, SecOps spokes and their actions
- [[Decision Tables]] - inputs, condition and result columns, roles, draft authoring, Excel round trip, DecisionTableAPI, limits
- [[Classic Approvals]] - approval record, approval engines and rules, gating and process approvals, summarizer, e-signature, notifications
- [[Intelligent Approvals]] - AI evaluation of requests against an uploaded policy PDF; outcomes, roles, allowlist, build and publish
- [[Agentic Playbooks]] - AI agents performing playbook activities: shipped agents, collaborative or autonomous mode, instructions, runtime roles
- [[Classic Workflow Overview]] - legacy Workflow Editor: parts, start and run-as, checkout and publish, properties, variables, subflows, scope, roles, tables
- [[Classic Workflow Activities Reference]] - approval, condition, timer, task, notification and utility activities with variables, results and exits
- [[Classic Workflow Stages, Validation and Update Sets]] - stage fields, stage sets and renderers; the validators; how workflows and input variables travel in update sets
- [[Classic Workflow Administration and Troubleshooting]] - contexts, cancel, schedules, script error exits, run time metrics, pause utility, encrypted scratchpad, workflow events
- [[Playbook Activities Reference]] - shipped interactive and non-interactive activities with inputs and outputs; process and activity execution states
- [[Playbook Patterns and Runtime Use]] - nested, wizard, guided decision and guest-access playbooks; record generator, Reflow; restart, cancel, optional activities, ATF

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

- [[Service Operations Workspace for ITSM]] - users, applications, UI16 redirection, plus Simplified ITSM, Mobile Agent, Walk-up (overview)
- [[Service Operations Workspace Access and Landing Page]] - SOW roles, tier 1 and tier 2 audiences, login redirection, landing page sections and how each is configured
- [[Service Operations Workspace Admin Center and Process Setup]] - what each Admin Center card sets; major incident, problem, notification, password reset and AI Search setup
- [[Service Operations Workspace Configuration and Customization Reference]] - lookup of optional SOW settings: UX page properties, views, Standard Record Page variants, chat tabs, Notify, CTI
- [[Working Records in Service Operations Workspace]] - what agents do in SOW on interactions, incidents, requests, changes, CAB, problems, major incidents, universal requests
- [[Investigation Framework, CI Actions and Remedial Actions]] - Investigate tab: metric definitions, CI actions, remedial actions, ACC and MECM providers, tables and roles
- [[Migrating from ITSM Agent Workspace to Service Operations Workspace]] - migration utility and which Agent Workspace table maps to which UX table
- [[ITSM Mobile Agent]] - mobile applets for agents and managers, AI Search setup, actionable and critical push notifications, migration notes
- [[DEX Desktop Assistant]] - tray app for employees: install, home page cards, notifications API and troubleshooting, tables, theme variables
- [[DEX Workspace Pages, Insights and Device Investigation]] - insights reports, bulk remediation, application and device pages, call quality, resolution strategies
- [[DEX Self-Service and Device Actions]] - Device health check for employees, issue configurations, device actions, execution states, health rating calculation
- [[DEX Incident Investigation for Service Desk Agents]] - Investigation tab for DEX devices: health checklist, top processes, suggested resolutions, playbook, automatic work notes
- [[Playbook Experience Design for Workspace, Portal and Mobile]] - UI Builder components and bundles, Guided view, Service Portal content items and widget, mobile embedding

## Security (`Security/`)

- [[Security Attributes, Security Data Filters and Field Query Controls]] - reusable user and session attributes, in-query row filters, field query dictionary attributes, machine identity access controls (documented, Brazil)
- [[Access Analyzer, Access Findings and Access Observer]] - evaluate and compare access, simulator, insights; daily access checks and the console; logging who reads a column
- [[Scripting Governance Tool]] - the second permission layer on script fields since Zurich: Conditional Script Writer group, datatype ACLs, jobs, scan and removal
- [[SNC Access Control (Support Staff Access to an Instance)]] - how support logs in (tokens, synthetic users) and how to restrict it by person and period
- [[Adaptive Authentication]] - filter criteria, policies and contexts (pre, post, MFA, account recovery, session validation), properties, trusted mobile app (documented, Brazil)
- [[Zero Trust Access - Session Access and Continuous Authentication]] - reduced roles for risky logins; re-authentication before protected tables, high assurance sessions
- [[Local Authentication - Login, Password Policy and Password Reset]] - landing pages, public pages, lockout, password policy presets and properties, self-service reset, Remember me, nonce for digest SSO
- [[Login Controls - IP Access Control, Session Limits and Installation Exits]] - allow and deny rules by address, concurrent session cap, the login, logout and password exits
- [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]] - smart card and API certificate login, basic auth on SOAP, outbound mutual TLS, per-host validation policies
- [[Personal OAuth Authentication and Web Embeddables Sessions]] - per-user outbound OAuth tokens in flows; embedded sessions with reduced roles
- [[Multi-Factor Authentication]] - default enforcement since Yokohama and its timeline, exemptions, factors and factor policies, who is asked, MFA with SSO, resetting a user, dashboard
- [[Login Links and Digest Tokens - Time Limited Authentication]] - one-time login links generated by script, digest token single sign-on
- [[Multi-Provider SSO - SAML and OIDC]] - which IdP handles a login, account recovery, SAML and OIDC provider records, certificates and keystores, provisioning, federation, redirects, e-signature, cloning rules (documented, Brazil)
- [[Authentication Console and Identifier-First Login]] - policy-based login: the user types an identifier, ordered IFL policies route to an SSO provider or the password page
- [[ServiceNow Vault and Otto for Vault]] - the data-protection bundle: Vault Suite contents, roles, guided setup, console metrics, default policies, AI skills and agentic workflows
- [[Security Center]] - hardening compliance score, security scanner, Customer Actions, event notifications, security metrics, posture dashboards, Security Tasks, roles
- [[Security Center Scan Checks and Best Practices]] - the Auditor suite checks and the best-practice list, as a review checklist
- [[Hardening Settings - Overview and Baseline Versions]] - how to read the 328 hardening settings, setting families, highest-scoring and non-default settings, baseline versions and what each added or removed
- [[Hardening Settings - Access Control]] - 101 settings: CSRF, ACL evaluation, scopes, roles and impersonation, public access, MID Server
- [[Hardening Settings - Authentication and Session Management]] - 73 settings: MFA and basic authentication restriction, lockout, password reset, SSO, timeouts, concurrent sessions, cookies
- [[Hardening Settings - API, Architecture, Communications and Configuration]] - 67 settings: authentication per inbound processor, IP allow lists, query ACLs, outbound TLS checks, HTTP headers
- [[Hardening Settings - Validation, Files, Logging and Other]] - 87 settings: sanitizing and escaping, script sandbox, XML parsing, attachments, static analysis, audit and logging

## AI (`AI/`)

- [[Email Agentic Workflow and Notification Agent]]: intent to action on inbound email
- [[Otto for ITSM Skills and Agentic Workflows]] - generative AI skills on incidents, changes and requests; agentic workflows; setup in AI Admin Hub (overview)
- [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]] - Predictive Intelligence solution definitions for incident and the Task Intelligence console (models, wizard, monitoring)
- [[Recommended Actions for ITSM]] - contexts, rules, recommendations, resource generators and guidances behind the SOW Recommendations panel
- [[Otto for ITSM Skill Inputs, Triggers and Customization]] - per generative skill: fields read, triggers, what can be customised; AI risk data sources; Virtual Agent LLM topics
- [[Otto for ITSM Agentic Workflows and AI Agents Reference]] - each ITSM agentic workflow: agents, triggers, roles, prerequisites; change policy documents and quality scores
- [[ITSM Virtual Agent Topics and Setup]] - pre-built NLU topics and blocks, actionable notifications, Issue Auto Resolution, deflection patterns, Lite, Employee Slate for Moveworks
- [[L1 IT Service Desk AI Specialist]] - autonomous worker on a team: execution modes, task settings, monitoring
- [[Authentication Factors for AI Voice Agents and Human-Assisted SMS OTP]] - identifying and verifying callers (KBA, Soft PIN, TOTP, push, SMS, email, step-up); API for human agents to verify by texted code (documented, Brazil)

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
- [[Custom Instance URLs]] - company host names for the instance, portal and identity provider per URL, the instance URL, DNS order, errors (documented, Brazil)
- [[System Logs, Log Files and Protected Tables]] - the log tables and their fields, retention and rotation, node log files, log attribution, protected tables, log roles

## Search (`Search/`)

- [[Zing Text Search and Global Search]]: keyword search syntax, text indexes, stop words, relevance, global search setup
- [[AI Search Overview]]: indexed sources, search profiles, query language, security, external content
- [[Contextual Search]]: related search results on forms and record producers

## Localization (`Localization/`)

- [[Languages, Translation Tables and Locale]]: language resolution, the five translation tables, translating custom content
- [[Currency and Price Fields]]: reference vs session currency, price types, FX Currency
- [[Localization Framework, Workspace and Dynamic Translation]]: machine translation and managed translation projects

## Application Development (`Application-Development/`)

Notes in this section come from the Brazil release of the Building applications guide unless they say otherwise.

- [[Application Development Tools and Lifecycle]] - which builder for whom, tools by lifecycle stage, reporting options, UI experiences, licensing (documented, Brazil)
- [[Application Scope and Namespace Identifiers]] - private and global scope, x_ prefixes, custom application record, application files and sys_metadata, protection policy, fix scripts, fulfillment tables
- [[Application Access Settings and Cross-Scope Privileges]] - runtime access tracking, table application access, restricted caller access, restrictions across scopes, lists and forms in scoped apps
- [[Application Administration and Collaboration Descriptors]] - locking admins out of sensitive applications, application admin roles, collaboration descriptors and permissions, script protection policy
- [[Personal Developer Instances]] - PDI rules, hibernation and reclaim, instance actions on the Developer Site, email restriction
- [[App Engine Management Center]] - AEMC: governance types, pages, application intake setup, intake / app / collaboration requests, custom apps tabs, readiness and compliance report, developers (Brazil)
- [[AEMC Pipelines and Deployments]] - pipeline setup (credentials, environments, controller, scan suites, Change Management properties), deployment request workflow and states, ReleaseOps in AEMC and pipeline migration (Brazil)
- [[Delegated Development and Deployment]] - Manage Developers permissions per scoped application, deployment permissions and their display properties, instance-wide installer roles, system-managed roles; intake form and data model choices (Brazil)
- [[Team Development]] - parent / peer instance hierarchy, remote instances, local changes, queue and ignore, pull, push, reconcile, collisions, exclusion policies, code review (Brazil)
- [[Update Versions and the Merge Tool]] - sys_update_version fields and states, compare to current, revert, record and field types that cannot be merged, suppress-version property (Brazil)
- [[Agentic Development Overview, Tool Comparison and Governance]] - what agentic development means, Build Agent vs Otto for Creator vs SDK, governance checklist and tools, discrepancies in the docs, developer-oriented list of Otto skills (Brazil)
- [[Build Agent]] - AI agent in ServiceNow Studio and the IDE: editions and prompt limits, Studio vs IDE, tools, settings, custom skills and rules, MCP connections, built-in governance, limits (Brazil)
- [[Build Agent Usage, Checkpoints and Reference]] - tasks, in-app agents and skills, checkpoints and update set naming, deployment routes, troubleshooting, supported metadata and file types, prompt patterns, domain separation (Brazil)
- [[Autonomous Engineer and Test Agent]] - plan and work items built in parallel, dashboard and states, agent packs, resilience; Test Agent: ATF generation, auto-heal, UI Test Script, coverage (Brazil)
- [[Otto for Creator and Otto for App Engine]] - developer-side AI skills (UI generation in UI Builder, ATF troubleshooting agent, roles) and runtime AI for custom apps (skills vs agents vs agentic workflows, record summarization skill) (Brazil)
- [[Creator Studio Overview, Setup and Roles]] - no-code request apps: parts and lifecycle, customise vs configure vs build new, install and instance strategy, guided setup, roles and groups, installed tables and properties (Brazil)
- [[Creator Studio Administration, Building and Reference]] - artifacts created per app, admin tasks, changing the app table, custom activities, collaboration, forms and question types, playbooks and activities, Request App Workspace (Brazil)
- [[App Engine Studio Overview, Setup and Roles]] - low-code builder: what it is, AES vs Build Agent, install and guided setup, roles and groups, installed tables, Git link, cloning (Brazil)
- [[App Engine Studio Templates]] - the nine shipped app templates (tables, roles, main flows), custom templates: create, share, activate, publish, creation errors (Brazil)
- [[App Engine Studio Building Reference]] - data (tables, spreadsheet import, data integration mapping), experiences, flows / decisions / notifications, roles, collaboration, Git operations, submit and publish, properties, template-supported metadata (Brazil)
- [[ServiceNow Studio Overview, Access and Navigation]] - the unified developer workbench: who gets in, which role opens which tool, activity bar, search shortcuts, creating apps and files, builders, collaboration (Brazil)
- [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] - metadata vs Fluent Git integration, OAuth to a Git provider, source-code app structure, convert / build / sync, app summary agent, deployment routes, properties, sys_app form fields (Brazil)
- [[Metadata File Types and Primary Tables]] - label-to-table lookup for every application file type in the Studio Navigator, with its editor; code search tables (Brazil)
- [[Source-Code Development - Fluent, JavaScript Modules and React]] - applications as source: Fluent (.now.ts), JavaScript modules, npm libraries that work, React UI pages, now.config.json parameters
- [[ServiceNow IDE and ServiceNow SDK]] - the browser IDE (workspaces, sync, build and install, Git, npm, properties, roles) and the local SDK workflow (auth, init, transform, build, install, TypeScript, type definitions)
- [[ServiceNow SDK CLI Reference]] - now-sdk commands and parameters: auth, init, build, install (CI variables), dependencies, transform, move, download, clean, pack, explain, query
- [[ServiceNow Fluent API Reference]] - Fluent objects and their tables: constructs (Now.ID, Now.ref, Now.include, Now.attach), Acl, ApplicationMenu, ATF Test, BusinessRule, ClientScript, CrossScopePrivilege, Property, Record, Role, ScriptAction, ScriptInclude, RestApi, Table and columns, UiAction, UiPage, UiPolicy
- [[Fluent API - Dashboards, Notifications, Flows, Import Sets and Lists]] - Dashboard, EmailNotification, Flow and Subflow (triggers, actions, flow logic, data pills), ImportSet transform maps, List
- [[Fluent API - Service Catalog, SLA, Service Portal and Workspace]] - CatalogItem, record producer, catalog UI policy and client script, VariableSet, Sla, portal widgets and dependencies, Workspace and list menus
- [[VS Code Extensions - Lux Lab and ServiceNow Extensions for VS Code]] - Lux Lab (experiences, pages, preview, navigation, deploy) and the older Now extension (projects, sync, conflicts, update set, background scripts)
- [[Application Development Good Practices - Plan, Build, Validate, Deploy]] - ServiceNow's stage-by-stage advice: scope and naming, data model, ACL or before-query rule, imports, forms, notifications, script or flow, ATF, update set discipline
- [[Developer Sandboxes]] - isolated per-developer copies on one sub-production instance: licensing, table data modes (shared, full, zero, partial copy), allocate and retire, update sources, what upgrades and clones destroy, properties
- [[Builder Tools Overview and Custom UI Components]] - which builder makes what; custom Next Experience components with the CLI ui-component extension; Virtual Agent component properties and local testing
- [[Table Builder]] - one screen for columns, data (fields, spreadsheet, schema views), form views (Form Builder), UI policies and record flows; shortcuts (.builder, .sheet, .view, .flow), roles, field configuration, formula functions
- [[Workspace Builder]] - no-code workspace: creation fields, settings, home dashboard, list categories and filtered lists, record pages (form, related tabs, playbook, side panel), analytics; when UI Builder is required
- [[UI Builder Overview and Concepts]] - experiences, app shells, pages, variants, glossary, editor areas, experience settings, audiences, scope and domain separation
- [[UI Builder Pages, Variants and Layouts]] - page paths and parameters, templates, variant conditions and order, shared pages, preview, responsive authoring and breakpoints, column, flexbox and grid layouts
- [[UI Builder Components, Events and Styling]] - property modes, presets, tabs, forms, modals, popovers, modeless dialogs, viewports, page collections, event sources and handlers, UI interactions and their steps, styles, AI panel
- [[UI Builder Data Resources, Controllers and Client Scripts]] - binding syntax (@data, @state, @context, @payload, @item), data resource types, multi-table data, EVAM, controllers, client state, client script API, formulas, repeaters, Component Builder
- [[Automated Test Framework Overview]] - what ATF is, tests, steps and suites, rollback, roles, where it must not run (documented, Brazil)
- [[ATF Building and Running Tests]] - build, run and debug a test, client test runners, client errors, custom UI steps and sn-atf attributes, parameterised, reusable and mutually exclusive tests
- [[ATF Test Step Categories Reference]] - every step by category: inputs, assert types, outputs, limits (form, list, catalog, navigator, REST, email, server)
- [[ATF Test Suites, Schedules and Administration]] - suites, schedules, parallel runs, failure analysis, performance profiling, code coverage, retention, screenshots, REST profiles
- [[ATF Records, Properties and Custom Step Configurations]] - tables not rolled back, result records and statuses, property list, scripted step configurations, workspace component actions, worked examples
- [[ATF Quick Start Tests by Application]] - shipped suites and their plugins per application; ITSM tests in detail
- [[ATF Headless Browser (Legacy Docker Runner)]] - running UI tests without a visible browser through Docker (legacy)
- [[Performance Analyzer]] - page load times of UX framework pages by application, route and interaction; the other testing and debugging tools named
- [[ReleaseOps]] - pipelines, releases, deployment requests, analyzer rules, runbook tasks, states, setup, the release documentation AI agent
- [[Application Repository, Publishing and Administering Apps]] - repository, Store and update set publishing, entitlements, customizations, mode conversion, clones, air-gapped repository, queued CI/CD operations, ISV licensing
