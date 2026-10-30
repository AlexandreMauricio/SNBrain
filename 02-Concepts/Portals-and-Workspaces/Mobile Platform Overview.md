---
type: concept
tags: [concept, portal, roles, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, Mobile Configuration and Navigation (635 topics; Exploring, Base system functionality, Tested devices, Mobile admin role, EMM, Terminology changes start, Mobile hierarchy start, builder headings), read at overview depth 2026-10-30. Configuration detail (170), Mobile app components (203), security pages, Otto for Mobile (34) and Using the mobile apps not read. Docs site API, map tUzwYwZFS~YHxHIxxytj0A.
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Mobile Platform Overview

**In one line:** two native apps, **Now Mobile** for employees and **Mobile Agent** for fulfillers, each shaped by configurations on the instance rather than by code on the phone.

From the Brazil docs; not tested. ITSM detail is in [[ITSM Mobile Agent]].

| App | For | Offers |
|---|---|---|
| **Now Mobile** | employees | requests, knowledge, tasks, My Locker, Agent Chat, Virtual Agent |
| **Mobile Agent** | agents | triage and resolve, offline mode, location tracking; needs extra plugins per product |

## Structure

- **Mobile app config:** decides a user's experience, by conditions, when they log in.
- **Navigation bar:** at the bottom, up to five tabs; beyond that a More tab. Notification and settings tabs come by default.
- **Tabs** open a screen or launcher screen.
- **Screens**, cards, data items and functions build the content.

**Old names:** from Rome, terms changed, and older pages and many table names keep them: *applet* became *screen*, *form screen* became *record screen*, *applet launcher* became *launcher screen*, *chart* became *analytics preview*. So tables are still `sys_sg_applet_launcher`, `sys_sg_form_screen`.

## Tools and tables

**Mobile App Builder** and **Mobile Card Builder**; **Mobile Publishing** (Store) for custom branded apps.

Tables: `sys_sg_native_client`, `sys_sg_navigation`, `sys_sg_screen`, `sys_sg_form_screen`, `sys_sg_list_screen`, `sys_sg_master_detail_screen`, `sys_sg_applet_launcher`, `sys_sg_button`, `sys_sg_data_item`, `sys_sg_view_config`, `sys_sg_item_view`, `sys_sg_icon`. Meanings are inferred from the names.

## Administration

- **Role:** `mobile_admin`: all mobile tables, mobile properties, builders. It does **not** give access to application scopes, so a scoped app such as Field Service Mobile needs that scope's permission too.
- **Supported OS:** latest two iOS and latest four Android versions. Mobile app versions have minimum and maximum instance versions.
- **Device management:** an EMM suite distributes apps; AppConfig pre-configures the default instance or browser. Microsoft Intune is the mobile application management integration.
- The guide also covers mobile security, authentication, impersonation, deep and universal links, theming, and domain separation.

## Example

Create mobile app config *Example Agent Config* for users with *Example Field Role*, with navigation tabs *Example My Work* and *Example Knowledge*. *Test User* logs in on Mobile Agent and sees those tabs.

## Related

- [[ITSM Mobile Agent]] · [[Push and Messaging App Notifications]] · [[Next Experience UI and Unified Navigation]]
