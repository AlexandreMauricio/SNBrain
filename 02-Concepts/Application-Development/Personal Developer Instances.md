---
type: concept
tags: [concept, platform, instance-admin, email, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Learning about developing > Personal developer instance guide (read 2026-10-08 through the docs site; whole section): Personal developer instance guide, Understanding PDIs, Get a development instance, Obtaining a PDI, Accessing your PDI, Activating a plugin from your PDI, Activating a PDI plugin from the developer site, Managing email properties for your PDI, Releasing your PDI, Changing your instance user role, Removing demo data from your PDI, Resetting your PDI to its initial state, Upgrading your PDI, Getting instance assistance. https://www.servicenow.com/docs/r/application-development/personal_developer_instance_guide.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Personal Developer Instances

**In one line:** a PDI is a free, admin-level sandbox instance from the ServiceNow Developer Program, one per member, for learning and experiments only; it sleeps when idle and is taken back after ten days without activity.

This is where anything marked `verified` in this vault would normally be tested. From the Brazil docs.

## Rules

- One PDI per member; not for business or production (a breach of the program agreement).
- **Hibernation**: idle instances shut down database and application server; data is kept. Signing in to the Developer Site wakes it (a couple of minutes) and resets the countdown.
- **Reclaim**: after ten days of inactivity (the period can change) the instance is unassigned, wiped and given to someone else. Activity = signing in to the Developer Site or developer work on the instance (creating an application, a table, a field, a script include).
- **Save work outside the instance**: commit to source control or export update sets.
- Not possible on a PDI: being a clone source or target for a customer instance; Team Development links to customer instances; publishing to the application repository or the Store; Machine Learning, Instance Data Replication, MetricBase; many Store applications.
- Maintenance can make it unreachable for a while; data is not affected. "Instance offline" usually means waking up or restarting after a patch: wait five minutes, then check **My Instance**.

## Actions (Developer Site > Account menu > My Instance)

| Action | Notes |
|---|---|
| **Request Instance** | choose a release; none free = **Join Waitlist**. The first sign-in gives the latest release; for an older one release the PDI and request again |
| **Start building** | opens the instance |
| **Activate plugin** | for plugins that normally need ServiceNow staff; with or without demo data; an email confirms. Other plugins: on the instance, **System Definition > Plugins** > **Install** |
| **Manage Email Properties** | toggle *Enable email sending and receiving*. To stop spam, PDIs can only **send to the domain guerrillamail.com**; they receive from any domain except that one |
| **Change User Role** | *Admin* or *App Engine Studio Creator*; close the instance tabs and reopen |
| **Remove demo data** | 20 to 30 minutes, cannot be undone |
| **Reset and wipe instance** | keep the instance name (hours) or give it up for a fresh one at once. Everything is lost |
| **Upgrade instance** | apply a patch or a newer release (hours). Patches are also applied automatically about monthly |
| **Release** | hand it back; a later request gives a different name and URL |

The docs site's release selector marks your PDI's release with a server icon: read the docs for that release.

## Related

- [[Application Development Tools and Lifecycle]] · [[Plugins]] · [[Email Architecture and Accounts]] · [[Upgrades - Process, Upgrade Center and Upgrade Console]]
