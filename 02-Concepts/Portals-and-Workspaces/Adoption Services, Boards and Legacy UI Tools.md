---
type: concept
tags: [concept, portal, instance-admin, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Adoption services (67 topics), Visual Task Boards (55), Timeline Visualizations (13), Content Management System (82), landing and section overviews only, read 2026-10-30. Step pages not read. Configurable Workspace UI (122), Working in Core UI (165) and Personalize your experience (69) compared by name only. https://www.servicenow.com/docs/r/platform-user-interface/next-experience-readiness-checker.html All four chapters read in full 2026-11-06; details moved to their own notes (see the top of the body).
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# Adoption Services, Boards and Legacy UI Tools

**In one line:** a short map of smaller UI features: help for users, visual boards, timelines, and the older Content Management System.

From the Brazil docs; not tested. Now a map: full details in [[Guided Tours, Embedded Help and Help Center]], [[Visual Task Boards and Timeline Visualizations]] and [[Content Management System (CMS)]].

## Adoption services

| Feature | What it is |
|---|---|
| **Dynamic Guidance** | AI assistant giving voice or text step-by-step guidance, from Help Center and the Otto panel |
| **In-product help** | Embedded Help and Help Center |
| **Onboarding modals** | wizard introducing a new experience in Next Experience |
| **Guided Tours** | interactive step-by-step walkthroughs |
| **Guided Setup** | groups configuration activities into categories |

**Guided Setup** has been being prepared for future deprecation since Australia: hidden on new instances, still supported. Yet RPA Hub setup still points to it; see [[RPA Unattended and Attended Robots]].

## Visual Task Boards

A visual, card-based view of work; active by default on new instances, plugin on upgraded ones.

- Types: **freeform**, **flexible**, **guided**.
- Members share a board, move and assign cards, add checklists.
- Tables: `vtb_board`, `vtb_board_member`, `vtb_lane`, `vtb_card`, `vtb_card_history`, `vtb_task`.

## Timeline Visualization

A high-level view of an organisation's activities over time, for leaders. Plugin `com.snc.timeline_visualization`. A **view** sets which details appear when a panel is clicked. Plan what to show first.

## Content Management System

The older way to build a custom interface. Plugins `com.glide.cms` and `com.glide.cms.extensions` are **being prepared for future deprecation**: hidden, not available to activate, still supported. The full Brazil chapter (read 2026-11-06) is firmer: CMS can no longer be activated, is deprecated in the **C release** and support ends then (security fixes until then); see [[Content Management System (CMS)]]. Tables include `content_page`, `content_type`, `content_link`, `content_block_programmatic`.

For new work the docs point to [[Service Portal Overview and Configuration]].

## Example

Create flexible board *Example Team Board* with lanes *To Do*, *Doing*, *Done*, add *Test User* as a member, and move card *Example Task* across.

## Related

- [[Next Experience UI and Unified Navigation]] · [[Service Portal Overview and Configuration]] · [[Flow Spokes Shipped with the Platform]]
