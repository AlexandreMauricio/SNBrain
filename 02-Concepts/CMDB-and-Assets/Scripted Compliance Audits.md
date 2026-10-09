---
type: concept
tags: [concept, cmdb, data-integrity, scripting, javascript]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Compliance, topics "Scripted audits" and "Create a scripted audit" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_Compliance.html), read through the docs site API 2026-10-09. The script below is the docs sample rewritten with placeholder values; not run
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Scripted Compliance Audits

**In one line:** a compliance audit whose pass / fail logic is a script instead of template conditions: a certification filter picks the records, the script judges each one and writes results and follow-on tasks through the `SNC.CertificationProcessing` API.

For when template conditions (all ANDed, fixed operators) are too limited. Background: [[CMDB Compliance - Desired State, Architecture Compliance and Audits]].

**Where:** **All > Compliance > Scripted Audits > Audits** > **New** (the **Run this script** field appears only from this module). Available with the Desired State plugin. Role `certification_admin`.

The form is the audit form ([[Create and Run a Compliance Audit]]) with **Filter** instead of **Template**. **Last run date** is not filled for scripted audits, and `glide.allow.new.cert_follow_on_task` does not apply.

## Script

**Kind:** audit script (field **Run this script** on Audit, `cert_audit`). **Runs:** server side, global scope. `current` is the audit record.

```javascript
// Audit: flag records whose value is below the desired minimum
var desiredMinimum = 30;                           // value to audit against
var assignToUser = '<SYS_ID_OF_USER>';             // must hold the certification role
var taskMsg = 'See the audit results below for the discrepancies to address';

var cert = new SNC.CertificationProcessing();
var gr = cert.getFilterRecords(current.filter);    // records selected by the audit's filter

while (gr.next()) {
    var sysId = gr.getValue('sys_id');
    var actual = gr.getValue('floor_space_in_use');          // field being audited

    if (actual < desiredMinimum) {
        var label = gr.floor_space_in_use.getLabel();
        // createFollowOnTask(auditId, ciId, assignedTo, assignmentGroup, shortDescription) -> task sys_id
        var task = cert.createFollowOnTask(current.sys_id, sysId, assignToUser, '', taskMsg);
        // logAuditResultFail(auditId, recordId, followOnTask, columnLabel, operatorLabel,
        //                    desiredValue, discrepancyValue, isCI [, domain])
        cert.logAuditResultFail(current.sys_id, sysId, task, label, 'greater than',
                                desiredMinimum, actual, true);
    } else {
        // logAuditResultPass(auditId, recordId, isCI [, domain])
        cert.logAuditResultPass(current.sys_id, sysId, true);
    }
}
```

## API as described in the sample

| Call | Arguments | Returns |
|---|---|---|
| `getFilterRecords(filter)` | the audit's filter | a GlideRecord over the filtered records |
| `createFollowOnTask(auditId, ciId, assignedTo, assignmentGroup, shortDescr)` | `ciId` empty if the record is not a CI; assignee, group and description may be empty | sys_id of the task |
| `logAuditResultFail(auditId, recordId, followOnTask, columnDisplayName, operatorLabel, desiredValue, discrepancyValue, isCI, domainToUse)` | task, labels and values may be empty; domain optional | |
| `logAuditResultPass(auditId, recordId, isCI, domainToUse)` | domain optional | |

## Notes

- The script decides whether to create tasks; the form's **Create tasks** box can be read by the script as true or false.
- The docs sample audits a datacenter zone field (`floor_space_in_use`) and hard-codes a user and a group sys_id. Replace with your own field and sys_ids; never store real names here.
- Not tested in this vault.

## Related

- [[Create and Run a Compliance Audit]]
