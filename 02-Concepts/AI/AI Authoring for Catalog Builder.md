---
type: concept
tags: [concept, ai, service-catalog]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > AI Authoring for Catalog Builder, topics "AI Authoring for Catalog Builder", "Exploring", "Install", "Configuring AI in Catalog Builder", "Using AI conversation to create and edit catalog items", "Creating a catalog item conversationally using AI", "Edit already published catalog items using AI", "Things to know while creating items using AI" and children, "Suggestions to describe catalog items", "Catalog item standards for catalog item generation" and children, "Catalog item generation", "Refine content", "Standard Ticket Page Summarization", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/now-assist-for-catalog-generation.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# AI Authoring for Catalog Builder

**In one line:** in [[Catalog Builder]], a catalog builder editor can describe an item in plain language and Otto drafts it (details, questions, UI policies, location, access, fulfilment, portal settings), then refine it in the same chat.

## Setup

- Request and install **ServiceNow Otto for Creator** (`sn_now_creator`) from the Store; it installs AI Authoring for Catalog Builder (`com.snc.text2catalog`).
- **AI Admin Hub > Features > Creator > Service Catalog** card: skill **Catalog item generation** active. Optional skill **Refine content** (shorten, elaborate, rephrase descriptions, instructions and conversational labels).
- Users need `catalog_builder_editor`; AI-written client scripts need `catalog_builder_developer`.
- Not available in FedRAMP, NSC DoD IL5, Australia IRAP-Protected, self-hosted and some regions (KB0743854). Data goes to a central ServiceNow environment and possibly Azure; inputs and outputs are collected unless the customer opts out. Review everything the AI writes.

## What it can and cannot generate

| Can | Cannot |
|---|---|
| title, descriptions, all Catalog Builder question types, UI policies (multi-action), location (catalogs, categories, topics), access (user criteria), fulfilment flow, portal settings, catalog client scripts (onLoad, onChange, onSubmit; UI type All) | item image, variable attributes, advanced reference qualifiers, UI policy scripts, scripted default values |

Catalog Builder's own limits apply. Fields filled by AI carry a sparkle icon until edited.

## Behaviour worth knowing

- Catalogs, categories, topics, user criteria and flows are matched to **existing** records only; with several or no matches the chat asks you to choose. A category needs a catalog already on the item; a topic needs a taxonomy. Template-locked values are left alone and reported.
- An item with an execution plan cannot get a fulfilment flow.
- UI policies: several condition/action pairs with the same condition go into one policy; "also" or "add to the same policy" appends; a new condition makes a new policy; contradictions are flagged for confirmation.
- Client scripts: generated only when asked or when a UI policy cannot express the rule; existing equivalent logic is reported instead of duplicated; a missing question of obvious type is created.
- Describe questions fully (type, mandatory, choices, defaults), give exact table names for references and exact field names for producer mappings. Example prompt pattern: "Standard mobile; color Black, Space Grey, Silver; storage 512 GB and 256 GB; if color is Black or Silver set storage to 256 GB read-only".
- Edit published items with **Edit > Edit with AI** (variables and UI policies).

## Catalog item standards

- Knowledge base **Catalog Item Standards**, article **Catalog Best Practices** (catalog admins edit it). The latest **published** version, plain text only, first **4,500 characters**, is sent to the LLM when the **Catalog item standards** property is on (default on, admin only).
- The item is still created; the user is then told about deviations (e.g. mandatory question without help text, radio questions with too many choices, jargon in labels). Rules needing role or runtime knowledge are out of scope.

## Related AI skills on the catalog

- **Standard Ticket Page Summarization** (portal ticket page Summarize button).
- **Catalog item form slot-fill** and conversational requests: see [[Conversational Catalog Requests and Virtual Agent]].
- Broader picture: [[Otto for Creator and Otto for App Engine]].

## Related

- [[Catalog Builder]] · [[Create a Catalog Item in Catalog Builder]]
