---
type: concept
tags: [concept, security, access-control, roles, scripting, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Scripting Governance Tool (whole section, 6 topics, 360 cleaned lines, read in full 2026-10-08 through the docs site) - Explore, Use, Scan for users who have scripted, Remove users from the Conditional Script Writer group, Manage (enable and disable). https://www.servicenow.com/docs/r/platform-security/scripting-governance.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Scripting Governance Tool

**In one line:** since Zurich, editing **any script field** needs two things: passing the field's usual ACL **and** holding role `snc_required_script_writer_permission`, which comes from membership of the group **Conditional Script Writer**; the tool is the dashboard that shows and trims that group. **Admins are not exempt.**

From the Brazil docs. Mechanism used: datatype ACLs in [[Access Control Lists (ACLs)]].

## Why it matters day to day

After an upgrade to Zurich or later, a user (or admin) who could edit business rules, script includes or client scripts and now finds script fields read-only is probably **not in the Conditional Script Writer group**. The role grants nothing by itself: it only unlocks what the field ACL already allows.

| Passes the field ACL | Holds the role | Can edit the script |
|---|---|---|
| yes | yes | yes |
| yes | no | no |
| no | yes | no |

## How it is enforced

Nine **Deny Unless datatype ACLs** requiring the role, on field types: `script`, `script_client`, `script_plain`, `script_server`, `email_script`, `html_script`, `html_template`, `xml`, `condition_string`.

The group is of type *Non-Assignable*: it does not appear in assignment group lookups on task tables.

`snc_external` and the script writer role are mutually exclusive: external users can never script ([[Explicit Roles and Elevated Privilege Roles]]).

## Who is put in the group

| Job | When | Does |
|---|---|---|
| *Add users to Conditional Script Writer group* | once, right after the upgrade | adds every eligible user so nobody loses access; then disables itself |
| *Update users in Conditional Script Writer group* | weekly | adds newly eligible users and removes those no longer eligible |

Eligible: with the Explicit Roles plugin, internal users holding `snc_internal` **plus at least one other role**; without the plugin, any user with at least one role. So by default **almost every fulfiller is a script writer**; the docs recommend turning auto-assignment off and trimming the group.

| Property | Meaning |
|---|---|
| `glide.security.scripting_role.auto_provisioning` | true (default): the weekly job runs. Created at run time, so its sys_id differs per instance: refer to it by name |
| `glide.security.scripting_role.provisioning_job_running` | true while the one-time job runs |
| `glide.security.scripting_governance.enabled` | the feature as a whole |

## The dashboard

**System Security > Scripting Governance Tool** (elevated `security_admin`).

| Card | Use |
|---|---|
| Users in Conditional Script Writer Group | count |
| **Auto-assignment** | switch for the weekly job |
| **Scan for scripting users** | finds, from the audit log, who wrote to tables with script fields in the last 7, 15, 30, 90, 120 or 180 days (default 180); now or scheduled. Result (`SGTSCAN...`): users who scripted (name, last scripted date, title, department) and members who did not: the candidates for removal |
| **Manage scripting access** | enter the **users to keep**; **Schedule removal** (immediately or in 1 to 13 hours) removes **everyone else** from the group and switches auto-assignment off. Other permissions of those users are untouched |
| Groups / Roles containing a scripting role | where else the role has been attached. Keep it only on the Conditional Script Writer group, or central control is lost |
| View scans, View removals | history |

## Turning it off or on

As elevated `security_admin`: **Scheduled Script Executions** (`sysauto_script_list.do`) > run **Disable Scripting Governance** (sets the three properties off, disables both jobs, and **empties the group**) or **Enable Scripting Governance** (sets them on and schedules the add-users job). Enabled by default. While disabled the ACLs are inactive and the dashboard's actions do nothing.

## Discrepancies in the docs

- The enabled and disabled state table says existing memberships "are preserved" when disabled, while the disable script is described as removing all users from the group.

## Related

- [[Access Control Lists (ACLs)]] · [[Explicit Roles and Elevated Privilege Roles]] · [[Business Rules]] · [[Role Management]]
