---
type: concept
tags: [concept, knowledge, admin, instance-admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management (landing), Exploring Knowledge Management (overview, workflow, benefits, Migrate to Knowledge Management v3, Migration from workflow to flow, Enhancements to knowledge article view page), Configuring Knowledge Management (overview, guided setup), Activate the Knowledge Management Advanced plugin, Knowledge Management setup guide for admins, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/knowledge-management.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Management Overview

**In one line:** Knowledge Management (KM) stores **articles** (`kb_knowledge`) in **knowledge bases** (`kb_knowledge_base`) with categories, access by user criteria, publish and retire flows, feedback, versions and translations; users read them in the **Knowledge Portal**, agents attach them to tasks.

From the Brazil docs; not tested. Map of the Knowledge notes: [[02-Concepts/_index|Concepts index]] section *Knowledge*.

## The basic cycle

1. A user needs an article (or asks for one).
2. A **contributor** writes or updates it and submits it.
3. A **knowledge manager** of the base reviews: publish, or send back.
4. Users read, rate and share; managers keep reviewing relevance.
5. Outdated articles are proposed for **retirement**, approved or rejected by a manager.

Each base can have its own publish and retire process ([[Knowledge Workflows and Article Lifecycle]]).

## Plugins

| Plugin | Gives |
|---|---|
| Knowledge Management V3 (`com.snc.knowledge3`) | core; its old homepage (`$knowledge.do`) is being deprecated since Washington DC |
| Knowledge Management - Service Portal (`com.snc.knowledge_serviceportal`) | Knowledge Portal, on by default since Madrid ([[Knowledge Portal and Search]]) |
| **Knowledge Management Advanced** (`com.snc.knowledge_advanced`), via installer `com.snc.knowledge_advanced.installer` | article versioning, subscriptions, Article Quality Index, article templates, ownership groups, in-context article creation, translation management. **Auto-active for new customers since Xanadu** (demo data then not loaded: plugin record > **Load Demo Data Only**) |
| Knowledge blocks (`com.snc.knowledge_blocks`) | [[Knowledge Article Templates and Knowledge Blocks]] |
| I18N Knowledge Management Internationalization v2 (`com.glideapp.knowledge.i18n2`) | [[Knowledge Translation and Internationalization]] |
| Knowledge Management KCS Capabilities (`com.snc.knowledge_kcs_capabilities`) | KCS roles and article states ([[Knowledge Feedback, Ownership Groups and Article Quality]]) |
| Predictive Intelligence for Knowledge Management (`com.snc.knowledge_ml`) | [[Knowledge Demand Insights and Predictive Intelligence]] |
| External Content Integration (`com.snc.knowledge.external_integration`) | [[Knowledge External Content Integration]] |
| Knowledge Management - Add-in for Microsoft Word (`com.snc.knowledge.ms_word`) | [[Knowledge Management Add-in for Microsoft Word]] |
| Knowledge Document (`com.snc.knowledge_document`) | publish [[Managed Documents]] to articles |
| Self-Service Analytics Core (`com.snc.self_service_analytics_core`) | [[Self-Service Analytics and Case Deflection]] |

The KM Advanced installer checks two things first: no active **KM v2** knowledge bases, and **no unique index on Number** (a unique constraint makes it fail; see [[Knowledge Logs, Numbering and Extension Points]]). Activation: **System Applications > All Available Applications > All** (global domain with domain separation and delegated admin).

## Setup order

- Admin: agree requirements with stakeholders, assign knowledge roles, adjust flows and properties, activate languages, then hand over to knowledge managers. **Knowledge > Administration > Guided Setup** covers it.
- Knowledge managers: create and secure their bases ([[Knowledge Bases and Categories]], [[Knowledge Base Access and User Criteria]]).
- KM can also be embedded in an Adobe Experience Manager site (separate pages, not read).

## Release changes worth knowing

- **Zurich**: legacy Workflow replaced by **Flow** for publishing and retiring. New customers must fill **Publish flow** and **Retire flow** on the knowledge base; upgraded instances see both workflow and flow fields (the rest of the sentence on what they must do is cut off on the page).
- **Zurich**: mobile-responsive article view page; version, author and number moved for visibility.
- **KM v2 → v3**: review automatic changes before upgrading, then migrate customisations and content (multi-step; video on the page).

## Other notes in this area

[[Knowledge Logs, Numbering and Extension Points]] · [[Self-Service Analytics and Case Deflection]] · [[Now Assist in Document Management]] (documents, not articles)
