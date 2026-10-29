---
type: concept
tags: [concept, automation, integrations, scripting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > Classic Orchestration > Orchestration activity designer (introduction to credentials, connections and aliases; create custom activities; general properties; input variables; data encryption; pre-processing; post-processing; auto-map outputs; output variables; parsing rules; conditions; custom activity templates JDBC, SOAP, JavaScript Probe, PowerShell, REST, SFTP, probe, SSH, run script, JMS; activity scoping; publish; copy) and Orchestration databus, read 2026-10-29; per-template field tables skimmed. https://www.servicenow.com/docs/r/servicenow-platform/orchestration/c_WorkflowActivityDesigner.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Orchestration Activity Designer and Databus

**In one line:** the **Activity Designer** (Classic Orchestration, since Fuji) builds reusable, versioned custom activities (**activity elements**) for the Classic Workflow Editor from a protocol **template**, with typed inputs, a test run against the real target, parsing rules into outputs, and exit conditions; outputs land on the workflow **databus** for later activities.

From the Brazil docs; not tested. Needs Classic Orchestration ([[Classic Orchestration Overview and Activity Packs]]). The modern equivalent is the Action Designer in Workflow Studio ([[Custom Actions, Dynamic Inputs and Error Evaluation]]); the stages are similar (inputs, step, outputs).

## Why use it instead of core activities

Reuse across many workflows, Store upload, parsing of standard formats, input testing with payload inspection, auto-mapping of outputs, data sharing through the databus instead of the workflow **scratchpad**, version history. Activity elements cannot read the scratchpad directly; pass scratchpad values in as inputs. Keep core activities such as **Run Script** for cases that need the scratchpad (e.g. a counter).

## Building an activity

**Orchestration > Workflow Editor** > **Custom** tab > **+** > pick a template. Stages (indicator at the top): **General** > **Inputs** > **Pre Processing** > **Execution Command** > **Outputs** > **Conditions**. Roles: `workflow_admin`, or `activity_creator` (with `workflow_creator`); REST and SOAP also `web_service_admin`; JDBC `activity_admin` or `activity_creator`.

| Stage | Content |
|---|---|
| General | Name (unnamed activities show only an index number in the Data tab), Description, Icon, Template, **Application** (current scope, where it runs), **Accessible from** (*All application scopes* or *This application scope only*), **Category** |
| Inputs | variables (strings up to 255 characters), types including arrays and **encrypted** (`password2` style: never stored in clear text, decrypted only by the MID Server on the target; an encrypted output encrypts the ECC payload; stays encrypted when passed downstream) |
| Pre Processing | script for validation or transforming inputs (not in Run Script) |
| Execution Command | template-specific (below); **Test Inputs** runs it against the target and shows the payload in **Raw Output** |
| Outputs | output and **local** variables (local = temporary source for cascaded parsing, e.g. XML inside JSON); **parsing rules** per variable: Parsing source, type (*Direct* default, XML, JSON, regex and others), expression built by clicking the sample payload; or **auto-map** (whole payload as a JSON object on the databus, or outputs generated; no parsing rules then) for REST, SOAP, JDBC, probe |
| Post Processing | script after execution |
| Conditions | exits by **Order** (lowest first, first true wins); conditions with **Else** = true are evaluated last; at least one default exit or the activity hangs; e.g. Success (order 100), Retry, default Failure |

## Templates

| Template | Executes |
|---|---|
| JDBC | ANSI SQL or stored procedures (IN, OUT, INOUT parameters) on a database through the MID Server |
| SOAP | an Outbound SOAP message; endpoint override; JavaScript arrays; post-processing parameters |
| REST | an Outbound REST message (create one first); endpoint override |
| JavaScript Probe | server-side JavaScript on the MID Server, including `Packages` calls into Java and your own JAR files |
| PowerShell | inline script or a MID Server script file on a target host |
| SSH | command on the target in a working directory, may call a MID Server script |
| SFTP | file and directory operations or server-to-server copy, streamed through the MID Server (not stored on its disk) |
| Probe | a probe from the probe list with parameters |
| Run Script | any script |
| JMS | send or receive messages with a JMS provider through JNDI lookups of the ConnectionFactory and destinations |

Connection data comes from connections, credentials and **aliases** (`sys_alias`, ID `<scope>.<alias>` or just the name in global; types *Credential* or *Connection and Credential* with connection type HTTP, JDBC or JMS), so the same activity resolves to QA or production endpoints by environment: [[Connections, Credentials and Aliases]], [[Create a Connection and Credential Alias]].

## Versions, publishing and scope

- A saved activity is visible only to its author until **Publish** (then usable by `workflow_admin` and `activity_creator`, and uploadable to the Store). Editing needs **Checkout**; other users see it read only; publishing again adds a version. A version left checked out: menu > **Versions** > open it > **Force Checkout** (`admin`, `activity_admin`, `activity_creator`).
- **Used In** (form menu) lists the workflows using an activity; a change to a versioned activity reaches all of them unless the activity is **pinned** ([[Classic Workflow Activities Reference]]).
- **Scoping**: an activity runs in its own scope even inside a workflow of another scope; a private one can only reach artifacts in its scope or open to all scopes. Store uploads must be accessible from all scopes. Published activities appear in **Packs** only for the current scope.
- **Copy** (right-click in Custom tab, global only; private-scope activities cannot be copied): *Copy into global scope as new activity* (new name, same version) or *as new version* (same name, version +1, overwrites a same-name same-version activity).

## Databus

The workflow's store of activity outputs, shown in the Workflow Editor **Data** tab (`workflow_creator`), grouped by application. Drag an output onto a later activity's input to link them. Each dropped custom activity gets an **index** in brackets that is never reused, so deleting and re-adding an activity cannot silently rewire subscriptions; designer updates propagate to the canvas. The Data tab does not check order: make sure the producing activity has run before its output is consumed. Hover an activity to see its **Databus Output**.

## Example

REST template activity *Example Get Ticket Status*: input `ticket_id` (string), execution on REST message *Example Ticketing API* via an alias, test inputs, auto-map outputs, conditions Success (`status` 200, order 100) and default Failure; published in category *Example Tools*.

## Related

- [[Classic Workflow Overview]] · [[MID Server Overview and Architecture]] · [[Credential Types Reference]]
