---
type: concept
tags: [concept, platform, access-control, security, scripting, forms-lists, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Learning about developing > Contextual development environment and Creation restrictions across application scopes (read 2026-10-08 through the docs site): Contextual development environment, Application context, Application access settings, Application design and runtime settings, Runtime access tracking, Cross-scope privilege record, Application design access record, Table design and runtime settings, Runtime access to application tables (defaults, set, examples), Design-time access to application tables (defaults, set, examples), Restricted caller access privilege settings (activate, define cross-scope access, set scope / resource / event access, the four setting combinations), Requested restricted caller access (RCA), Application list, Application picker, Lists and forms in scoped applications (layout and design actions, visual indicators, default form design permissions), Contextual development edit messages, Creation restrictions across application scopes. https://www.servicenow.com/docs/r/application-development/c_ContextualDevelopmentEnvironment.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Application Access Settings and Cross-Scope Privileges

**In one line:** ACLs decide what *users* may do; application access settings decide what one *application scope* may do to another, at design time (creating configuration on its tables) and at run time (scripts and web services touching its data).

From the Brazil docs. Scope basics: [[Application Scope and Namespace Identifiers]].

## Application context

New records go to the application selected in the **application picker** (Unified Navigation > picker icon > *Application scope*; the icon shows a red ring outside Global). Opening a record of another scope makes every field read-only and shows a message offering to open that application, or to switch to it temporarily for this one edit (you return to your scope on save or cancel).

**System Applications > Applications** (or *My Company Applications*): tabs **Developed** (create, edit, share, delete), **Downloaded** (install, view or edit installed files, uninstall), **Updates**.

## Three layers of cross-scope control

| Layer | Set on | Owned by | Answers |
|---|---|---|---|
| Application design and runtime settings | the **calling** application's record | caller | may my scripts reach out, and is it logged or gated? |
| Table application access | the **target** table | target | what may other scopes do to this table? |
| Restricted caller access (RCA) | the **target** resource | target | which specific callers may use this resource? |

### 1. Settings on the calling application

| Field | Options |
|---|---|
| **JavaScript Mode** | ECMAScript 2021 (ES12), ES5 Standards Mode, Compatibility Mode |
| **Runtime Access Tracking** | *None*: no log, no gate. *Tracking*: each cross-scope access during development creates a Cross scope privilege record with status **Allowed**. *Enforcing*: the record is created as **Requested** and the operation is blocked until an administrator sets Allowed |
| **Restrict Table Choices** | ticked = only the application's own tables can be picked at design time, unless an **application design access record** (source scope, target package) opens another application's tables |

Cross scope privilege (`sys_scope_privilege`): **Source Scope**, **Target Scope**, **Target Name**, **Target Type** (table, script include, script object), **Operation** (read, write, create, delete for tables; execute API for scripts), **Status** (requested, allowed, denied).

- Tracking happens only **during development**. After installation nothing new is recorded and only requests with a valid record run, so exercise every script path while testing.
- Administrators can create the records in advance to tell developers what they may use.
- A privilege never exceeds what the target table itself allows.

### 2. Application access on the target table

On the table record (`sys_db_object`), section **Application Access**:

| Field | Effect |
|---|---|
| **Accessible from** | *All application scopes* or *This application scope only* |
| **Can read** | other scopes' scripts may query. Prerequisite for the next three |
| **Can create**, **Can update** (also labelled Can write), **Can delete** | other scopes' scripts may insert, modify, delete |
| **Allow access to this table via web services** | inbound REST / SOAP may reach the table (the user still needs ACL rights). A blocked call returns 403 |
| **Allow configuration** | other scopes may create configuration on the table: business rules, client scripts, UI actions, new fields. When off, the table is simply not offered in their **Table** pickers |

**Defaults for a new table**: all scopes, read on, create / update / delete off, web services on, configuration off. So other applications can read your data but neither change it nor attach logic to it. To seal a table: *This application scope only* with everything off.

Granting access to configuration: ACLs need *all scopes* + read; business rules, client scripts, UI actions and new dictionary entries also need **Allow configuration**.

### 3. Restricted caller access

Finer control, per caller. Needs plugin *Scoped Application Restricted Caller Access* (`com.glide.scope.access.restricted_caller`); already on with HR Service Delivery and Security Incident Response, and for flows by a property ([[Flow Administration, Execution Details and Access]]).

On the resource (table, script include, event registration ...), with **Accessible from** = All application scopes, set **Caller Access**:

| Caller Access | Behaviour |
|---|---|
| None | only *Accessible from* decides |
| **Caller Tracking** | calls allowed and recorded as Allowed |
| **Caller Restriction** | first call denied and recorded as **Requested**; an admin (or the application's administrator when application administration is on) sets Allowed or Denied. Once allowed, later calls pass |

Records: Restricted Caller Access Privileges (`sys_restricted_caller_access`), under **System Applications > Application Restricted Caller Access** or the application's tab. Fields: **Operation** (Read, Write, Create, Delete, Execute API), **Source**, **Source Scope**, **Source Table**, **Source Type** (Scope, ACL, Business Rule, Flow, Flow Action, Script Include, UI Action, UI Page, UI Macro, Scheduled Script, Record Producer Script, Inbound Email Script, Service Portal Widget, Workflow Activity ...), **Target**, **Target Scope**, **Target Table**, **Target Type** (Scope, Table, Script Include, Event), **Status** (Requested, Allowed, Denied, **Invalidated**).

- The record must live in the **target** application's scope.
- When the calling source changes (a business rule's script is edited), its record becomes **Invalidated** and must be decided again.
- Four shapes: *scope-to-scope* (everything to everything), *scope-to-target* (a whole application to one resource), *source-to-scope* (one caller to a whole application), *source-to-target* (one to one). An **Event** target lets another scope queue that event; caller access None on the event registration blocks cross-scope queuing.

**Requested RCA** (for applications that ship): the calling application packages, in its own scope, records describing the access it needs (`sys_scope` differs from `target_scope`). After installation and Upgrade Summary, a scheduled job creates the real records in the target application with status Requested, and its application pages show a pending-review message. Developer side: related link **Generate RCA Privileges in Current App** builds them from the real records gathered during development and keeps them in sync.

## Restrictions that always apply across scopes

Even with configuration allowed, on a table of another scope:

| Record type | Limit |
|---|---|
| ACLs | only field-level, role-based. No table-level, no "all fields", no condition, no script |
| Business rules | *async* (insert, update, delete; set values and script) or *before* (insert, update, delete; set values only, no script, no abort). Never query ([[Business Rules]]) |
| Calculated fields, field styles | not allowed |
| Data policies, UI policies | no rules on the other scope's fields; cannot make a field mandatory |
| Form sections, views | create new ones; cannot change existing ones |
| Record producers | need create access to the table |
| UI scripts | no global UI script from a scoped application |

## Lists and forms

Always allowed: creating a list view, a form view, a form section. Only in the scope that owns the view or section (administrators cannot bypass this): choosing its fields, reordering, changing columns, deleting a section. Creating new fields also needs **Allow configuration**. In the form designer, sections of another scope are grey without grips or delete button; the layout slushbucket is grey with a warning. The message offers: edit by switching scope temporarily, create a new section, or create a new view in your scope.

## Related

- [[Application Scope and Namespace Identifiers]] · [[Application Administration and Collaboration Descriptors]] · [[Business Rules]] · [[Form Layout, Sections and Views]] · [[sys_db_object]]
