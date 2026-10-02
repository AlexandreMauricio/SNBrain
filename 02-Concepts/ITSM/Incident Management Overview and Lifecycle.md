---
type: concept
tags: [concept, incident, task, cmdb, knowledge]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management" (pp. 2420-2499, 2530-2587), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Incident Management overview and lifecycle

**In one line:** an incident is a task record ([[incident]]) logged to restore a service; it is categorised, prioritised from impact and urgency, assigned, worked through states until Resolved, then Closed by the caller or automatically.

## How incidents arrive

| Channel | Mechanism |
|---|---|
| Service desk agent | **Incident > Create New** (roles itil or `sn_incident_write`) |
| Self-service | record producer **Create Incident** in the catalog category *Can We Help You?* |
| Email | inbound email actions ([[Inbound Email Actions]]) |
| Chat, Virtual Agent, walk-up, SMS (Notify) | create the record with the matching **Channel** |
| Monitoring | alerts (Event Management); **Origin** shows the source |
| Other systems | Table API, SOAP, import sets |
| Scripts | business rules |

Users without a role see only incidents where they are the caller, opener or on the watch list (business rule *incident query*). They can edit **Watch list**, **Short description** and add comments.

## States

| State | Meaning |
|---|---|
| New | logged, not yet worked |
| In Progress | assigned and being investigated |
| On Hold | waiting on someone else; requires **On hold reason**: Awaiting Caller, Awaiting Change, Awaiting Problem, Awaiting Vendor |
| Resolved | fix or workaround given; SLA timers stop; caller can confirm or reopen |
| Closed | final; set by the caller, an agent with `itil_admin`, or auto-close |
| Canceled | duplicate, unnecessary or not an incident |

- **Awaiting Caller** makes **Additional comments** mandatory. When the caller updates the incident, the hold reason clears and the state returns to In Progress, with a notification to the assignee and watch list.
- The guide's tip: track with **State**, not the older **Incident state** field ([[State Fields and Task State Values]]).

## Priority

**Priority** is read-only and calculated from **Impact** and **Urgency** by priority data lookup rules (**System Policy > Rules > Priority Lookup Rules**, role `data_lookup_admin`):

| Impact \ Urgency | 1 High | 2 Medium | 3 Low |
|---|---|---|---|
| 1 High | 1 Critical | 2 High | 3 Moderate |
| 2 Medium | 2 High | 3 Moderate | 4 Low |
| 3 Low | 3 Moderate | 4 Low | 4 Low |

To change it: edit the lookup rules, or disable the UI policy *Priority is managed by Data Lookup - set as read-only* and add your own logic. See [[Data Lookup and Record Matching]].

## Categories

Base categories and subcategories: Inquiry / Help (Antivirus, Email, Internal Application), Software (Email, Operating System), Hardware (CPU, Disk, Keyboard, Memory, Monitor, Mouse), Network (DHCP, DNS, IP Address, VPN, Wireless), Database (DB2, MS SQL Server, Oracle). Maintained with **Configure Choices** on the field ([[Choice Lists]]). They feed assignment rules, notifications and reports.

## Assignment

- Business rule *Populate Assignment Group based on CI/SO*: on insert or update, when **Assignment group** and **Assigned to** are both empty, takes the support group of the **Configuration item**, else of the **Service offering**. Override which field is used with properties `com.snc.incident.ci_assignment_group.field_name` and `com.snc.incident.service_offering_assignment_group.field_name`.
- Otherwise assignment rules: [[Assignment Rules and Data Lookup Rules]], [[Approaches to Auto-Assigning Tasks]].
- Changing the group clears **Assigned to**.
- An itil user cannot assign to a group that holds the admin or security_admin role (group read ACL).

## CIs and services on an incident

- **Configuration item**: the one CI that is the cause. **Affected CIs** related list (`task_ci`): everything else touched. **Impacted Services/CIs** (`task_cmdb_ci_service`): services depending on them.
- **Refresh Impacted Services** (context menu) recalculates impacted services, service offerings and business applications from the affected CIs; governed by properties in [[Incident Properties Reference]].
- The dependency view icon next to the CI opens the map; **View Related Tasks** there shows other tasks on the CI.
- With Hardware Asset Management, **Asset Action** on an affected CI (Update/Repair, Swap, Retire) must be filled before a non-caller resolves the incident.

## Investigating

- Icon next to **Caller** lists the caller's other incidents (dictionary attribute `ref_contributions=user_show_incidents`); VIP callers show a VIP icon (**VIP** on the user record).
- Related search results suggest knowledge ([[Contextual Search]]).
- **Incident tasks** ([[incident_task]]) pull in other groups.
- Templates prefill forms ([[Form Templates]]); response templates give canned replies.

## Promoting an incident

From the form context menu:

| Action | Result |
|---|---|
| **Create Problem** | problem linked in **Problem**; fields copied per `com.snc.problem.create_from_incident.attributes`. With the San Diego best-practice plugin the incident goes On Hold / Awaiting Problem |
| **Create Normal / Standard / Emergency Change** | change linked in **Change Request**; copies short description, description, CI, priority, company |
| **Create Request** | opens the catalog; the request is linked to the incident and the caller becomes **Requested for** |
| **Create Incident Task**, **Create Child Incident**, **Copy Incident** | see [[Parent and Child Incidents]] |
| **Propose Major Incident** | see [[Major Incident Management]] |
| **Create Knowledge** (resolved incidents, plugin `com.snc.incident.knowledge`) | draft article from the Incident KCS template |

Only one problem and one change can be created this way per incident.

A linked problem pushes updates back: **Communicate Workaround** and **Communicate Fix** on the problem write to the incident's work notes (or comments, see property) and notify assignee and lists.

## Resolving and closing

1. Fill **Resolution code** and **Resolution notes** (and **Resolved by**), select **Resolve** (roles itil, `sn_incident_write`, list_updater).
2. The caller gets the *incident.ess.resolve* notification with a **Reopen incident** link.
3. Closure: the caller closes, an `itil_admin` selects **Close Incident**, or the scheduled job **Autoclose Incidents** closes after `glide.ui.autoclose.time` days. See [[Configure Incident Auto-Close]].

After Closed or Canceled only admins can edit a few fields (subcategory, service, description, watch list, related record references).

## Reopening

- **Resolved** incidents: **Reopen** on the form or portal, or the link in the email, by the caller, the opener or an agent with write access. State returns to In Progress; **Reopen count**, **Last reopened by/at** are updated.
- **Closed** incidents cannot be reopened. A reply with *Please reopen* in the subject creates a **new** incident copying the fields listed in `com.snc.incident.clone_fields_on_reopen`.

## Escalation

- SLAs attached to the incident (response and resolution).
- Inactivity monitors ([[Scheduled Jobs]]).

## Roles

| Role | Can |
|---|---|
| itil | classic fulfiller role |
| `sn_incident_read` / `sn_incident_write` | granular read / write (plugin ITSM Roles) |
| `sn_service_desk_agent` | tier 1: write on incident, problem, change, request |
| `incident_manager` | incident properties, major incident trigger rules |
| `sn_incident_admin` | all incident configuration |
| `business_stakeholder` | read and approve across ITSM, comment on incidents and requests |
| `itil_admin` | close incidents |

## Integration notes from the guide

- One-way integration: the other system creates the incident and gets the number back. Two-way: needs field mappings, ownership of reference data, state mapping, error handling.
- Recommended pattern: receive into an **import set (interface) table** so every transaction is logged and transformation runs before the incident table; send outbound through business rules and the ECC queue or outbound web service. Use a dedicated integration user per interface.

## Reporting

**Incident > Overview** and many older dashboards are deprecated since Xanadu in favour of the *Incident management dashboard* (Platform Analytics). Indicators worth knowing: open incidents, backlog growth (new minus resolved), average age, percent resolved without reassignment, percent resolved same day, percent reopened. See [[Metric Definitions and Metric Instances]].

## Related

- [[incident]] · [[Incident Properties Reference]] · [[Major Incident Management]] · [[Create an Incident Record Producer]] · [[Resolved Incidents Are Not Closing Automatically]]
