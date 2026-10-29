---
type: concept
tags: [concept, security, scripting, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > Policy as Code Engine (PaCE) (70 topics: understanding, personas and roles, life cycle, install, administer policies (view, create, activate, duplicate, edit, delete, map with static and dynamic mapping, request exception, templates), versions (states, create, low-code and policy logic fields, copy, duplicate, edit script, publish, edit draft and archived, compare, delete), passing parameters (variables, data types, data collectors, nested policies), Test Playground, execute and review, categories and tags, write and test policies (script structure, invocation API and parameters), policy exceptions, integrations), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/policy-as-code-engine-pace/pace-managing-policies.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Policy as Code Engine (PaCE)

**In one line:** **PaCE** (scope `sn_pace`) stores versioned **policies** (rules written in low-code conditions or JavaScript) that a calling application runs against a record (**document**: table + sys_id) to get a decision: **compliant**, **non_compliant**, **compliant-exception** or a custom one, with results, warnings and failures, all logged for audit.

From the Brazil docs; not tested. It is not installed alone: it comes bundled with the applications that use it, e.g. **Digital Product Release** ([[Digital Product Release Configuration and Templates]]), **DevOps Config** (policies on snapshots, [[DevOps Config Snapshots, Policies and Exporters]]), **Cloud Account Management**, **SecOps SBOM** (stale or abandoned components, scheduled job *Run PaCE policies for SBOM Response*, off by default), **Social Benefits Playbook**. Menus and role prefixes can differ per calling application (DevOps Config uses `cdm_policy_editor` and others).

## Life cycle

Create policy > (new) version > variables and mappings > edit logic > test in **Test Playground** > **Publish** the version (becomes *Current*) > **Activate** the policy > it runs when invoked.

- **Policies** (**Policies > My Policies** or **All Policies**): Name (unique, the identifier), Document type (table it applies to), Category (one), calling service, Description, tags; State Active or Inactive; Source *User* or *ServiceNow* (shipped content, copy to change). Tabs: Details, Policy builder, Version management, Mappings, Executions. Create from a blank tile or a **template** (`sn_pace.code_editor`; test a template draft in the Playground, then activate it; template edits do not change policies already made from it).
- **Activate** needs a Current version; mapping inputs are validated at activation (invalid ones send you to Mappings). Inactive = maintenance mode: mappings kept, nothing runs; changes are audited. Bulk **Activate** can also *Publish the latest versions* (content-based policies only).
- **Delete**: only policies never used (not mapped, never run in Standard mode, no Current or Archived version).

## Versions

| State | Meaning |
|---|---|
| Draft | editable, numbered 0.1, 0.2...; a draft made from version N is N.1, N.2... |
| Current | the published one (named V1.0, V2.0...); one per policy; script read only |
| Archived | a former Current; can be republished; read only |

Edit Current or Archived by copying to a new draft (several drafts in parallel are fine). **Compare** shows differences in details, script and mapping inputs. Only never-published, never-run drafts can be deleted. Publishing re-checks mandatory mapping inputs; if API variables changed, update the callers.

**Low-code** (*Is low code* ticked by default): if / else if / else condition sets on data sources, then **Decision** (Compliant, Non-compliant) or **Run policy** (nest a child policy; two levels: child and grandchild), log message and output types, arithmetic on numeric variables. **Switch to code editor** is one way only.

## Inputs to a policy

| Kind (old name) | Script variable | Set when |
|---|---|---|
| **API Variables** (Caller Inputs) | `apiVars` | passed by the caller at invocation; one fixed variable `SnapshotId` (immutable; no others can be added) |
| **Config Parameters** (Mapped Inputs) | `configParams` | given per mapping (e.g. different limits per group); mandatory ones missing = mapping inactive, no decision |
| **Record References** | `recordRefs` | queries on any table, with aggregate (average, count, maximum, standard deviation and others) and match criteria (first match or all) |
| **Data collectors** | `dataCollectors` | scripted collectors (inputs and outputs, from the instance or external sources); publish with *Activate this data collector* (inputs and outputs then fixed); throw `PaCEExecutionError` to report an error |

Variables for every policy: **Variable Definition** on the main page.

## Mapping (`sn_pace.mapping_admin`)

A policy only runs for documents it is mapped to. **Static**: document type + one or more policies against a specific record (e.g. a change request or deployable). **Dynamic**: a saved condition (Short description, Table, conditions; **Run** previews up to 10,000 matches) evaluated at run time. **Request Exception** on a mapping appears with GRC installed (deployable, reason type, justification, dates).

## Script (Draft versions; server side, runs in the policy's application scope)

```javascript
(function(logger, currentRecord, documentRecord, apiVars, configParams, recordRefs, dataCollectors, childrenOutputs, output) {
    var port = configParams.dbPort;                  // from the mapping
    if (documentRecord.getValue('state') == 'new') { // the record being validated
        logger.info('checking port ' + port);        // goes to sn_pace_execution_log
    }
    output.decision = (port < 30000) ? 'compliant' : 'non_compliant';
    output.failures = [];                            // also results, warnings
})(logger, currentRecord, documentRecord, apiVars, configParams, recordRefs, dataCollectors, childrenOutputs, output);
```

`currentRecord` = the executing policy version record; if `output.decision` is not set it defaults to compliant (per the source, sentence partly cut off); invocation state Complete or Pending. Script Debugger available.

**Invocation** (server script in the caller's scope): `var api = new sn_pace.InvocationAPI(); var res = api.execute(request);` with the calling service, `documentIds` (array of table and sys_id), API variables, options `verboseResponse` (default false; true lists each mapped policy's ids and names), stop on first failure (default false), log level, `timeout` (default 3600 s), `waitForResult`. All mapped policies run concurrently; overall decision: compliant (all), non_compliant (any), compliant-exception, other.

## Test and review

**Test Playground**: set test parameters, evaluate, read the decision, warnings and failures, duration, JSON output, custom output, and the **execution log** (filterable); test data collectors there too. **Executions** tab: number, inputs, JSON output, script and version used, execution type (test or standard), start, duration, decision, state, application, object. Categories (e.g. PCI, HIPAA, FedRAMP) and tags group policies.

## Exceptions (GRC)

With **Governance, Risk, and Compliance 14.1+** and Policy and Compliance Management: **Enable** exceptions on a policy and link it to a **control objective**; then exceptions can be requested on mappings (reason, business justification, start and end dates); approved ones turn non-compliant results into compliant-exception. **Disable** stops new requests and control-objective links.

## Roles

| Role | Can |
|---|---|
| `sn_pace.execution_reader` | view policies, categories, executions |
| `sn_pace.code_reader` | review versions and code, run tests |
| `sn_pace.code_editor` | plus create versions and templates |
| `sn_pace.policy_reader` | review policy details and mappings |
| `sn_pace.policy_editor` | plus create policies and mappings (contains `policy_reader` and `code_editor`) |
| `sn_pace.mapping_admin` | map policies, edit config parameters on mappings |
| `sn_pace.admin` | all of the above plus categories |
| `sn_pace.super_admin` | admin across all calling services (internal, default content) |

All roles except super admin are assigned per **calling service**, which sets their scope. Some pages write `sn_pace_code_reader` and `sn_pace_policy_reader` (underscore instead of dot): unconfirmed variant spelling.

## Example

Policy *Example Port Limit* on document type `sn_cdm_deployable`, config parameter `dbPort` (integer, mandatory), low-code logic *if dbPort less than 30000 then Compliant else Non-compliant*, statically mapped to deployable *Example Web Prod* with `dbPort` = 5432, published as V1.0 and activated.

## Related

- [[DevOps Config Data Model and Changesets]] · [[Digital Product Release]]
