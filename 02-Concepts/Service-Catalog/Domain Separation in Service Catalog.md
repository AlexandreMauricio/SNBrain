---
type: concept
tags: [concept, service-catalog, domain-separation]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Reference, topics "Domain separation and Service Catalog", "Request for domain separation in Service Catalog", plus "Service catalog workflows" and "Catalog Builder" notes on domains, https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/domain-separation-service-catalog-management.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Domain separation in Service Catalog

**In one line:** with the Service Catalog domain separation plugin, catalog items are data in a domain and can be requested only in that domain (and global); catalogs, categories and variables stay global.

## Support level and activation

- Support level **Standard** (see [[Domain Separation Support Levels by Application]]).
- Plugin **Service Catalog - Domain Separation**, requested from Now Support (**System Applications > All Available Applications > All > Request plugin**). The page gives two IDs: `com.glideapp.servicecatalog.domain_separation` and `com.glideapp.servicecatalog.domainseparation`; the first appears twice and is probably right.
- Activate only to isolate items per domain regardless of hierarchy. It can override a home-made catalog domain setup.

## What is separated

- Items (catalog items, record producers, content items, order guides) are domain-separated **as data**: `sys_domain` and `sys_domain_path` on `sc_cat_item`, `sc_item_option`, `sc_multi_row_question_answer`, `question_answer`.
- Catalogs, categories and variables are **global**. Items shared across domains must be in global and restricted with user criteria.
- Catalog client scripts and catalog UI policies are separated **as process**: a child domain can override a parent's script; the version for the item's or target record's domain runs, even for a fulfiller from the parent domain. Overriding is not recommended.

## Rules in practice

- **Effective domain** = the user's domain, or the one chosen in the domain picker for users who see several.
- Items are created in the effective domain and edited only there (also items published from Item Designer or Catalog Builder). For maintenance, visibility follows the normal hierarchy.
- For **requesting**, an item is visible only in its own domain, not in parent, child or peer domains, plus global items. Fulfillers switch domain in the picker to order for another domain.
- Order guides with items from several domains order only the effective-domain and global items. Items from several domains cannot share a cart.
- Requests, RITMs and produced records are created in the effective domain (or, from a parent record such as an incident, in the parent's domain). Edits by fulfillers from other domains stay in the record's domain. Reports follow the reporter's effective domain.
- User criteria must be visible in the item's domain, otherwise they are ignored.
- Workflows: point items at domain-specific workflow copies explicitly.
- Applies in Core UI, Service Portal, Agent Workspace, mobile and APIs.

## Related

- [[Domain Separation Overview]] · [[Domain Separation Errors]] · [[User Criteria and Catalog Access]]
