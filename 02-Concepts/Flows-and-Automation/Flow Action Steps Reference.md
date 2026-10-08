---
type: reference
tags: [reference, flows, automation, integrations, api, scripting, powershell, javascript]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Reference > Workflow Studio steps (read 2026-10-08 through the docs site): Workflow Studio steps and each step page - Ask for Approval, Call Now Assist Skill, Create Record, Create or Update Record, Create Task, Delete Multiple Records, Delete Record, Get Connection Info, Get Latest Response Text From Email, JDBC (and Test JDBC step), JSON Builder, Kafka Producer, Log, Look Up Record, Look Up Records, Map and Transform Data, Notification, Payload Builder, PowerShell, REST, Script, Send Email, SFTP (Copy File, Copy Directory, Create Directory, Get File List, Remove File, Remove Files, Delete Directory, Rename File or Directory, Set File Attributes, Copy Attachments To SFTP Server, Copy Files To This Instance), SSH, SOAP, Update Multiple Records, Update Record, Wait For Condition, ZIP (Zip, Unzip, Get Zip file details). https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/steps.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flow Action Steps Reference

**What it is:** a *step* is one operation inside a custom action. Steps are added by users with `action_designer`; the step picker groups them as **ServiceNow Data**, **Utilities** and **Integrations** (search needs three characters). Building actions: [[Custom Actions, Dynamic Inputs and Error Evaluation]].

Every step has **If this step fails** (go to error evaluation, or continue with the next step) and returns **Step Status** (**Code** 0 success / 1 error, **Message**), neither customisable.

## ServiceNow Data steps

These mirror the core actions of the same name ([[Flow Core Actions Reference]]) with the same inputs and outputs: **Ask for Approval**, **Create Record**, **Create or Update Record**, **Create Task**, **Delete Record**, **Look Up Record**, **Look Up Records**, **Update Record**, **Update Multiple Records**, **Wait For Condition**, **Get Latest Response Text From Email**, **Send Email**, **Log**. Differences and extras:

| Step | Note |
|---|---|
| **Look Up Record** | conditions can be static or an input of type Conditions dropped into the field. The step page gives **Status** as 1 = found, 0 = error, the reverse of the action page (0 = found). Unresolved: check on an instance before branching on it |
| **Update Multiple Records** | extra options **Run Business Rules and Workflow** and **Update System Fields** (Updated by and so on) |
| **Delete Multiple Records** | Table, Conditions, Order by, Sort Type, **Run Business Rules and Workflow**, Don't fail on error; outputs Count, Error Message, Status (0 / 1). No core action equivalent is listed |
| **Notification** | Record (leave empty for notifications tied to no table), Notification. The notification's **Send when** must be *Triggered* ([[Email Notifications]]) |
| **Look Up Records** | inside an action, loop the result in a Script step instead of For Each |

## Utilities

### Script

Server-side JavaScript, in the action's scope, in the domain the flow was started from.

| Field | Meaning |
|---|---|
| **Required Runtime** (only with Integration Hub) | *Instance* (default; Glide APIs and data), *MID* (MID Server script files and APIs), *Vanilla* (core JavaScript only, either place) |
| **Select MID Server Using** | Any MID / Use Connection Alias (Basic type only) / Use Inline Selection (host, MID selection, application, capabilities) |
| **Input variables** | name + value (pill): read as `inputs.<name>` |
| **Output variables** | label, name, type: written as `outputs.<name>` |

```javascript
// Script step (server-side, instance runtime)
(function execute(inputs, outputs) {
    var payload = { short_description: inputs.summary, urgency: '2' };
    outputs.payload = JSON.stringify(payload);
})(inputs, outputs);
```

- Values pass through `inputs` and `outputs` as strings; return JSON as a string (stringify it, or pass a JSON input straight through).
- Variable names must not be `sys_id`, `sys_created_by`, `sys_created_on`, `sys_updated_by`, `sys_updated_on`, `sys_mod_count`, nor match any field name.
- At most 20 variables (`sn_flow_designer.max_script_variables`).

### Builders and mapping

| Step | Does | Notes |
|---|---|---|
| **JSON Builder** (Integration Hub) | name / value / **Type** rows (String, Object, Number, Boolean, Array; nest with +) to a JSON string | **In case of empty value**: leave as is, omit property, set as null, throw error. **Include Outer Structure**, **Omit Empty Structure**. **Add JSON for Payload** builds the rows from pasted JSON (replaces existing rows; last duplicate key wins; a root array is wrapped in an object; limit 65,000 bytes; no empty or invalid JSON) |
| **Payload Builder** | name-value pairs to JSON or XML | deprecated for JSON. XML options: **Namespace**, **Parent Node** (default `xml`), **Omit if empty**, **Send Empty Structure** |
| **Map and Transform Data** | maps a nested JSON object onto a target object | **Source Data**, **Target** (root label names the output; several source fields can feed one target field), **Script Field** (JavaScript per scripted field). **Automap** suggests mappings (role `sn_dm_connected.automap_user`, also needed by the system user `ih_import`); bulk *Clear all fields* / *Clear unmapped fields* |
| **ZIP** (Integration Hub) | attachments of a record | **Zip** (source attachment records, target zip file name, target record, optional *Delete Source Files*), **Unzip** (all files or those matching a file-name regular expression; optional delete of the archive), **Get Zip File Details** |
| **Call Now Assist Skill** (AI Skill Kit) | runs a published generative AI skill | inputs **Capability** (`sys_one_extend_capability`; can import its inputs as action inputs), **Payload** (JSON string), **Skill Config** (`sn_nowassist_skill_config`); outputs Error, Provider, Response, Result (JSON), Status |

## Integration steps (Integration Hub)

### Connection fields they share

| Field | Meaning |
|---|---|
| **Connection** | *Use Connection Alias* (preferred: the same action works on every instance, and connection changes need no action change) or *Define Connection Inline* |
| **Connection Alias** / **Credential Alias** | the credential appears in the data panel as a Password (2 Way Encrypted) pill |
| **MID Selection** | Auto-Select MID Server (by **MID Application** and **Capabilities**), Specific MID Server, Specific MID Cluster |
| **Connection Timeout** | never 0 (stale connections) |
| **Enable Retry Policy**, **Override Default Policy for Alias**, **Retry Policy** | see retry policy in [[Custom Actions, Dynamic Inputs and Error Evaluation]] |

**Get Connection Info** (Integration Hub Starter): choose a connection or credential alias; outputs Runtime Alias ID, Connection ID, Connection URL, Credential ID, Credential Value (password2 pill), for use in later steps.

### REST

| Field | Notes |
|---|---|
| **Use MID** | run through a MID Server; such calls are not in outbound web service logging, only in execution details |
| **Base URL** | from the alias (overridable with the lock icon) or typed |
| **Build Request** | *Manually*, *From OpenAPI specification* (**API Source**, **API Operation**; imports every parameter and header in the spec, so delete what you do not want, for example one of two content-type headers), *From REST Message* (**REST Message**, **REST Message Function**, **Import REST Message**) |
| **Resource Path**, **HTTP Method** | GET, POST, PUT, PATCH, DELETE |
| **Query Parameters**, **Headers** | duplicates allowed, sent in the order defined |
| **Request Type** | *Text* (**Request Body**), *Binary* (an **Attachment** record, which a Script step can build with the JSON / XML streaming builder APIs), *Multipart* (parts with name, type Text or File, value; file parts take an attachment sys_id), *Form URL-Encoded* (name-value pairs) |
| **Save As Attachment** | **Attachment File Name**, **Attachment File Record** |
| **Test REST Step** | run it alone with sample inputs |

Responses not saved as attachments are limited to 5 MB (`glide.pf.rest.response_payload_max_size`, up to 10240 KB). Parse the **Response Body** in a following Script step with `JSON.parse()` and expose the values as output variables, then as action outputs; an XML parser step exists for XML.

### SOAP

Needs `web_service_admin` to select or load a WSDL or pick a WS-Security policy. **Endpoint**; **Build Envelope** *From WSDL* (**Select a WSDL** or **Load New WSDL** by URL or pasted content, then **Operation**; fills **SOAP Action** and **SOAP Envelope**; **Reset Envelope** discards manual edits) or *Manually*; **Request Type** Text or Binary; **Enable WS-Security Policy** + **Policy**; HTTP **Headers** with *Omit if empty*; **Test SOAP Step**. Response limit 5 MB (`glide.pf.soap.response_payload_max_size`, up to 10 MB).

### JDBC

Runs on a MID Server with the JDBC capability.

- Inline connection: **Database Type** (MySQL, Oracle, SQLServer, Custom with **JDBC Driver** and **Connection URL**), **Connection Timeout**, **Query Timeout**.
- **SQL Statement**: one statement only; no stored procedures with output parameters. **Maximum Rows** (1000), **Maximum Payload Size** (5120 KB, up to 10 MB).
- Allowed operations: SELECT, INSERT, UPDATE, DELETE, SHOW, DESCRIBE; restrict them with MID Server property `mid.property.jdbc_operations`.
- **Sanitise every pill** used in the statement with the *Sanitize SQL* transform functions (offered automatically when a pill is dropped in).
- **Test JDBC Step** (admin) is mandatory before testing the action: for a SELECT it shows the first row and **Use Result** builds the output schema (ResultSet) from the columns.
- Timeouts: `com.snc.process_flow.datastream.payload.timeout.seconds` (600; 0-7200), `com.snc.process_flow.datastream.async_child.timeout.seconds` (60; 0-7200).

### PowerShell

Runs through a MID Server. Versions 3.0 to 7.4; by default 3.0-5.1, and MID Server property `mid.property.ihub.prefer_powershell6Plus` = true prefers 6+ (which you install on the MID host yourself).

| Field | Notes |
|---|---|
| **Host**, **Port** | inline connection; FQDN; default port when empty |
| **Remoting Type** | *Explicit Remoting* (run on the remote server), *Implicit Remoting* (run on the MID Server importing modules from a remote server: **Remote name prefix**, **Modules to import**), *Run on a MID Server or have your script establish a remote session* (default) |
| **Script type** | *MID Server Script File* (default; a record of `ecc_agent_script_file`, so the script can change without republishing the action) or *Inline script* (**Command**) |
| **Input variables** | name, type (plain text, encrypted, boolean), value. An encrypted value is shown in clear in the designer and encrypted only on its way to the ECC queue |
| **Test PowerShell Step** | tests the credential |

```powershell
# Inline Command of a PowerShell step: an input variable named message is read as $message
# (or $env:SNC_message when MID parameter mid.powershell.command.script.parameter_passing is false)
Write-Output "Received: $message"
```

Functions called with parameters must declare a `param` block. With the default remoting type the script also gets `$computer` (host from the connection), `$cred` (credential object, for cmdlets with `-Credential`) and `$log_info`. Names not allowed for input variables: `script`, `useCred`, `isMid`, `isDiscovery`, `debug`, `user`, `password`, `executingScriptDirectory`, `midScriptDirectory`, `hresult`.

### SSH

Runs commands on a Unix-like host through a MID Server with the SSH capability; credential must be SSH or SSH private key. **Host**, **Port** (1-65535, otherwise 22), **Working Directory**, **Command**, **Long Running** (no 120-second timeout; the engine detaches until completion), **Sudo Mode**. Sanitise pills with the *Sanitize shell arguments* transform. A MID Server script file is pushed to the host and run with `${syncFile("<name>")}`:

```bash
# Command of an SSH step: sync and run a MID Server script file, passing three arguments
bash ${syncFile("example_script.bash")} one two three
```

Every file the script sources or includes must be synced the same way; cleaning up copies is your job. Script files: **MID Server > Script Files**.

### SFTP

MID Server with SSH capability; plugin *Managed File Transfer Extensions for the SFTP Step* (`com.glide.hub.action_step.sftp_mft`); SSH credentials. At most 10,000 files per command.

| Command | Specific fields |
|---|---|
| Copy File | source and target connection, **Source Path**, **Target Path** (full file paths) |
| Copy Directory | plus **Include Files** / **Exclude Files** (semicolon-separated, wildcards), **Include Subfolders**; managed file transfer options (plugin `com.glide.hub.action_step.mft`): target file and directory name, date-time suffix format, **Preserve File Attributes**, **Apply Move Conditions** (min / max size, newer / older than, move order, sort order, duplicate file action), clean-up on failure (remove from target) and on success (remove from source) |
| Create Directory | path |
| Get File List | path, include / exclude, subfolders. Returns files with their attributes |
| Remove File, Remove Files | path; for several: remove conditions, include / exclude, subfolders |
| Delete Directory | path; **Include Subfolders** off deletes only empty subfolders |
| Rename File or Directory | source path, target path |
| Set File Attributes | **User ID** and **Group ID** (set together), **Permissions** (octal, for example 755), **Modified** and **Accessed Timestamp** (epoch, set together). Typical after a copy, with values from Get File List |
| Copy Attachments To SFTP Server | **Attachment Records**, **Target Path** |
| Copy Files To This Instance | source path, include / exclude, **Maximum File Size (KB)**, **Maximum Number of Files**, **Target Record**, **Table** |

### Kafka Producer

Stream Connect subscription, plugin `com.glide.hub.stream_connect.installer`. **Topic Alias**, **Message**, **Key** (same key = same partition), **Headers**, **Wait For Completion**, **Schema** (the message must match it).

## Related

- [[Custom Actions, Dynamic Inputs and Error Evaluation]] · [[Flow Core Actions Reference]] · [[Flow Data Types and Transform Functions]] · [[Flow System Properties Reference]]
