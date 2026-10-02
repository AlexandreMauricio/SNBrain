---
type: meta
tags: [meta]
status: documented
source: own
updated: 2026-10-01
---

# Tag Vocabulary

Only use tags from this list. To add one, add it here first, with a one-line meaning. Frontmatter form: `tags: [incident, scripting]`. Tags are lowercase, hyphenated, singular-topic.

## Area
- `platform`: core platform behaviour (tables, dictionary, sys_id, properties, plugins, instances)
- `task`: the task table and behaviour shared by everything that extends it
- `incident`: incident management
- `problem`: problem management
- `change`: change management, CAB, change models
- `request`: request fulfilment (REQ, RITM, SCTASK)
- `service-catalog`: catalog items, variables, variable sets, record producers, order guides
- `cmdb`: configuration items, CI classes, relationships, CSDM
- `assets`: hardware and software asset management
- `discovery`: Discovery, Service Mapping, MID Server probes and patterns
- `sla`: SLA definitions, schedules, timers, breaches
- `users`: user records, groups, departments, companies, locations
- `roles`: roles and role inheritance
- `access-control`: ACLs, data policies, who can see or change what
- `domain-separation`: domains, visibility and process separation
- `forms-lists`: form layout, views, lists, UI actions, dictionary overrides, choice lists
- `flows`: Flow Designer flows, subflows, actions, triggers
- `workflow`: legacy Workflow editor
- `automation`: scheduled jobs, events, anything that acts automatically
- `notifications`: notifications, events that fire them, templates
- `email`: inbound and outbound email, inbound actions, mail accounts
- `knowledge`: knowledge bases, articles, article workflows
- `portal`: Service Portal, Employee Center, widgets
- `workspace`: workspaces, UI Builder, Next Experience
- `api`: REST and SOAP APIs, authentication, endpoints
- `integrations`: IntegrationHub, spokes, third-party integrations, MID Server
- `import-sets`: import sets, data sources, transform maps
- `reporting`: reports, dashboards, Performance Analytics, database views
- `security`: authentication, SSO, encryption, instance hardening
- `ai`: Now Assist, Virtual Agent, Predictive Intelligence
- `fields`: field administration: creating, labelling, defaults, dependencies, numbering, field types
- `data-integrity`: data policies, data lookup, field normalization and transformation, dynamic schema
- `data-management`: archiving, table cleaner, bulk update and delete jobs, table rotation, data export, rollback and recovery
- `instance-admin`: plugins and applications, system properties, instance clone, upgrades, instance scan, performance, subscriptions
- `update-sets`: update sets, application scopes, moving changes between instances
- `admin`: configuration and setup in the admin area

## Technical
- `scripting`: any script (pair with one of the kinds below)
- `business-rule`, `client-script`, `ui-policy`, `script-include`, `ui-action`, `fix-script`: where the script lives
- `glide-api`: GlideRecord, GlideAggregate, GlideSystem, GlideDateTime and the other Glide classes
- `encoded-query`: encoded query strings and list filters
- `schema`: table and column structure
- `reference-field`: reference fields and dot-walking
- `choice-list`: choice fields and their coded values
- `javascript`, `powershell`, `python`: language of a script or client

## Note kind (mirrors `type`)
- `how-to`, `reference`, `concept`, `troubleshooting`, `approach`, `table`, `query`, `script`, `exercise`, `meta`

## Release notes
- `release-specific`: behaviour differs by release family. Record the release in `sn-release`

## Purpose
- `example`: worked, generalised examples
- `glossary`: term mappings (UI label to table or column name)
