---
type: concept
tags: [concept, platform, scripting, business-rule, flows, update-sets, import-sets, notifications, access-control, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Building pro-code applications > Exploring professional development (read 2026-10-08 through the docs site): Exploring professional development, Plan your application development, Plan before you build, Manage app development, Build your application, Define and build the data model, Build the data model, Secure data, Manage data, Create design elements, Primary interfaces, Self service, Virtual Agent as an application design element, Notifications, Translations, Overview of reporting and analytics for developers, Build form and business logic, Form logic, Business rules and script includes, Flow Designer, Validate app functionality, Deploy your app. These pages are older guidance republished in the Brazil guide: they still name Guided App Creator, legacy Studio, the Orlando subscription model and the HI portal. https://www.servicenow.com/docs/r/application-development/exploring-professional-development.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Application Development Good Practices - Plan, Build, Validate, Deploy

**In one line:** ServiceNow's own advice for a custom application, stage by stage: decide scope, instance and name before building; model data with the right field types and secure it first; prefer configuration and flows to script; test with ATF; move up the instance stack through the application repository or disciplined update sets.

From the Brazil docs. The advice is general and partly dated (see `source`); where a tool name is obsolete the current one is in [[Application Development Tools and Lifecycle]].

## Plan

| Good fit for the platform | Poor fit |
|---|---|
| simple forms; task and request management; spreadsheet-driven or repeatable processes; integrations and orchestration of several systems; one experience over several systems; web and mobile on the same data | unstructured data; unrepeatable processes; graphics processing; streaming audio or video; heavily customised UI |

**Scope.** Build in a private scope unless the application must delete global data, change application access settings on several base tables, or use APIs that exist only in global scope and that a *global passthrough* cannot cover (a passthrough = a global script include, accessible from the scoped application, that wraps the global API). Global applications cannot use delegated development. Detail: [[Application Scope and Namespace Identifiers]].

**Instance.** Proofs of concept go on a sandbox or a personal developer instance ([[Personal Developer Instances]]). Their scope prefix differs from the company's, so **rebuild** a proof of concept on the company development instance, do not import it. Real applications start on the company development instance.

**Names.** The suggested scope comes from the application name: `x_<company code>_<name>`, 18 characters at most (*Legal Request* gives `x_acme_legal_reque`). The **scope and the table names can never be changed**; the application name and table labels can. Users see internal names only in URLs: keep them close to the labels.

**Governance.** Use source control (limits named: no branch merging, and repositories behind a firewall need extra network setup) and delegated development ([[Delegated Development and Deployment]]).

## Build: data

- Every new table gets **Created by** (`sys_created_by`), **Created** (`sys_created_on`), **Updated by** (`sys_updated_by`), **Sys ID** (`sys_id`) and **Updates** (`sys_mod_count`). (The page says five and omits **Updated** (`sys_updated_on`), which also exists.)
- Extend an existing table when it fits (Task, `task`, most often); before adding a field to an extended table look for an inherited one and override its label instead ([[Dictionary Overrides]]). Check the exempt tables in the Custom Table Guide ([[Custom Tables and Entitlements]]).
- Do not change a field's type after creation.

| Type | Use for |
|---|---|
| Reference | anything that exists as a record elsewhere (never a string for a person's name) |
| Choice | fewer than ten fixed options |
| Integer, Currency, Phone number (E164), Date, Date/Time | typed, validated data |
| String | only when nothing else fits: free text gives inconsistent data |

Choose a **reference table instead of a choice list** when there are more than ten options, they change regularly, a non-administrator maintains them, the value drives decision logic (decision tables), there are multi-level dependencies, more than a name and value is needed, or a table with the data already exists. See [[Choice Lists]], [[Reference Fields]].

## Build: security (do it before interfaces and logic)

- Table creation sets up access controls for the chosen role; add table and column rules and know their evaluation order. Protect UI pages and property pages too.
- Keep GlideRecord queries out of ACL scripts.
- Make auto-populated fields read-only.
- Subscriptions count the tables a user **can** access, used or not: restrict with ACLs.

| | ACL | Before-query business rule |
|---|---|---|
| Controls | all operations | read only |
| Server-side GlideRecord | bypasses read ACLs | is restricted |
| What the user sees | "rows removed by security" message | nothing: the count matches what is shown |
| Subscription counting | removes the table from the user's count | does not |

Use before-query rules only when necessary; the *user query* rule on User (`sys_user`) is the model. Detail: [[Business Rules]].

## Build: loading and receiving data

- Import sets with transform maps; scheduled imports for recurring loads.
- Performance: split loads into sets of about 100,000 rows; stagger large imports; untick **Run business rules** and do calculations once in an `onComplete` script; use built-in coalesce rather than scripts; no GlideRecord queries in transforms; index coalesce fields; import only the history that is needed.
- From another system, push into a **web service import set**, not straight into the table through the Table API. For more than a simple write, look for a purpose-built API, or build a Scripted REST API.

## Build: interfaces

| Element | Advice |
|---|---|
| Forms | few fields (load time); sections, most-used on top; logical order (start date before end date); views for different situations ([[Form Layout, Sections and Views]]) |
| Lists | seven columns or fewer by default; never a reference field first (its link leaves the list) |
| Mobile | the Agent app with focused applets, securable by role and usable offline |
| Self-service | a record producer in the existing portal; a separate portal only for different branding, navigation or needs. Do not reuse existing portal pages: build pages, reuse widgets |
| Widgets | clone a baseline widget (they are read-only); test on a real page; `$rootScope.$emit()` rather than `$broadcast()`; option schema for reuse (extension table for unsupported option types); Angular providers for shared data and logic |
| Virtual Agent | narrow topics; read them aloud; build iteratively |
| Reports | filter large tables by date; avoid grouping on high-cardinality fields; schedule recurring exports. "Report" = Core UI, "visualization" = Platform Analytics |

**Notifications**: trigger from an **event** when conditions are complex, when fired from a workflow or flow, or to ease debugging; simple cases can use the send-email action. Use `${field}` variables and dot-walking, `${URI_REF}` for the record link, and **separate** email scripts included as `${mail_script:<name>}` (inline `<mail_script>` is unreliable): [[Notification Variables and Links]], [[Mail Scripts]]. A group receives individually only with **Include members**. **Subscribable** lets users opt in; **Mandatory** overrides preferences. Omit the watermark only when no reply is expected.

**Translations**: language plugins translate the base system, not your customisations. Export the translation table (for example `sys_choice`), have **Label** translated, set **Language**, keep **Value**, and import back with table, element, language, label, value and sequence filled.

## Build: logic

- Order of preference: configuration, then no-code (flows, UI policies, Virtual Agent), then script. Script is right for custom flow actions, Scripted REST APIs, script includes of a scoped application, portal widgets.
- **Change a baseline artifact in place; do not copy it and deactivate the original.** The copy never receives upgrades, both must be maintained, and a record where only **Active** changed is upgraded silently without appearing in the skipped list. An edited original is reported as skipped with the new version in its history ([[Update Versions and the Merge Tool]]).

| Need | Tool |
|---|---|
| Suggest (show, hide, message) | UI policy ([[UI Policies]]) |
| Enforce (mandatory whatever the entry path) | data policy or business rule ([[Data Policies]]) |
| Validate input with feedback | client script, after policies are exhausted |

Client scripts: asynchronous GlideAjax instead of client GlideRecord or repeated `getReference()`; keep the `isLoading` check and add `newValue != oldValue` in `onChange`; no global client or UI scripts; no DOM manipulation outside your own pages.

| Business rule **When** | Runs | Use |
|---|---|---|
| Before | synchronously before the write | set or validate values on the record; abort |
| After | synchronously after | events, notifications, related records that need `previous` or sequence |
| Async | later, separate process | slow work, outbound calls, bulk updates |
| Display | when the form loads | hand server data to the client in `g_scratchpad` |

Keep rules small and conditional; never `current.update()` in one; put reusable code in a script include and call it from every place that needs it.

**Flow or business rule**: use a flow unless the logic must run in a precise order among other rules, must run in the same thread right before or after the write, or only calls a script include. Flows: one purpose each, reusable subflows, clear labels; pass records rather than sys_ids, and only the data used. Actions: in the spoke's scope, accessible from all scopes, protection read-only, typed inputs with mandatory flags and defaults. Integrations: one spoke per system, connection aliases instead of inline connections, validate step outputs, fail early when inputs are missing.

## Validate

| Stage | Who | Notes |
|---|---|---|
| Unit (story) | developer, then the process owner | also retest stories sharing components |
| System | QA with the developers | whole application and integrations |
| Acceptance | users or stakeholders | fitness for the business need |

ATF advice: parameterised tests; names like `<app>: <function tested>`; describe each test and suite; write on development, run on test; **clones wipe tests** (keep them in a scoped application under Git, or export first); never execute tests on production; self-contained tests that start with **Impersonate**; prefer server-side steps when screenshots do not matter; group suites by feature.

## Deploy

Prefer the application repository (publish once, install on test, then production). Otherwise update sets:

- Always move changes **up** the stack from development, including production fixes and choice-list tweaks; a change made mid-stack is overwritten later.
- Review an update set before moving it: stray records from other work or testing, system properties, integration endpoints. Move unwanted records to a scrap update set rather than deleting them; the page also says the only acceptable manual move is to the Default update set, with the reason written in its comments.
- Never work in the Default update set, never delete an update set that was not merged, never move data with update sets (use exports or import sets).
- Write the story numbers and every manual step in the description. Not captured: plugin activation, data in tables, database indexes.
- **Batching**: a parent update set with children; previewing or committing the parent processes all in the right order, and a child can still be pulled out at the last moment (unlike merging).

## Related

- [[Application Development Tools and Lifecycle]] · [[Application Scope and Namespace Identifiers]] · [[Business Rules]] · [[Delegated Development and Deployment]] · [[ServiceNow IDE and ServiceNow SDK]]
