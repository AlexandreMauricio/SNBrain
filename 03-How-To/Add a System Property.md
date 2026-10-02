---
type: how-to
tags: [how-to, instance-admin, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Add a system property" and "Create a system properties module" (pp. 133-135), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Add a system property

**Goal:** create a property that a feature documents but that is not yet in the table, or one for your own configuration.
**Prerequisites:** role admin. Outside business hours if possible (cache flush).
**Navigation:** type `sys_properties.list` in the navigation filter

## Steps

1. Open `sys_properties.list` and search **Name** for the property to confirm it does not exist.
2. Select **New**.
3. Fill **Name** (exact), **Type**, **Value**, a **Description**. Leave **Ignore cache** clear unless you know you need it. Tick **Private** if the value must differ per instance.
4. Submit.

## Result / how to check it worked

The property appears in the list; the feature it controls behaves accordingly. In a background script, `gs.getProperty('<name>')` returns the value as a string.

## Example

| Field | Value |
|---|---|
| Name | `glide.quota.manager.debug` |
| Type | true \| false |
| Value | `true` |

Optional: add a module *All Properties* under an admin-only application menu (**System Definition > Application Menus** > the menu > Modules > New; **Link type** List of Records, **Table** `sys_properties`).

## Tables / fields involved

- `sys_properties`: **Name** (`name`), **Value** (`value`), **Type** (`type`), **Ignore cache** (`ignore_cache`), **Private** (`is_private`)

## Gotchas

- Each change flushes caches on every node (1 to 10 minutes of slower response).
- Properties travel in update sets unless **Private**.
- Background: [[System Properties]].
