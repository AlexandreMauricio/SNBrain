---
type: concept
tags: [concept, security, access-control, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > ServiceNow access control (whole section, 5 topics, 190 cleaned lines, read in full 2026-10-08 through the docs site) - Explore, Activate, Configure, Audit logging. https://www.servicenow.com/docs/r/platform-security/c_SNCAccessControl.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# SNC Access Control (Support Staff Access to an Instance)

**In one line:** plugin `com.snc.snc_access_control` lets the customer decide which ServiceNow Customer Service and Support employees may log in to the instance and during which period; once active, **nobody from support can log in until a record allows it**.

From the Brazil docs.

## How support logs in at all

- Support staff have **no user record** on the instance. A technician asks for access through the support portal; a separate, locked-down security server checks the request and issues an encrypted **token** for that person and that instance, valid **4 hours**, not usable through impersonation.
- The instance decrypts the token, checks user, instance and time window, and creates a **synthetic user** in memory with the given roles. It disappears at logout, expiry or restart.
- Their user names end in `@snc`, so logins (event log) and every action (transaction log) are identifiable.
- With the plugin, the instance additionally requires the person to be **listed, active and inside the time window** of an SNC Access Control record.

The plugin does not stop ServiceNow operations staff from administering the underlying infrastructure (servers, databases).

**Cost:** support response and the Availability SLA are measured from the moment access is granted.

## Activating and configuring

Requested through Now Support: **System Applications > All Available Applications > All > Request plugin** (admin). Support staff already logged in at activation stay logged in.

**System Security > SNC Access Control > New** (admin):

| Field | Meaning |
|---|---|
| **Name** | `firstname.lastname`, lower case; several separated by commas; `*` = all support employees. To restrict, no asterisk anywhere in the field |
| **Reason** | optional text |
| **Start**, **End** | mandatory period |
| **Access type** | *Read-only* (default for new records): the login is allowed only if the support user also holds `snc_read_only`. *Read and write*: full access (the default of records created before this field existed). If both kinds exist for the same person, read and write wins |
| **Active** | |

## Related

- [[Explicit Roles and Elevated Privilege Roles]] · [[Impersonation]] · [[User Sessions and Timeouts]]
