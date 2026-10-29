---
type: concept
tags: [concept, scripting, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Password Reset > Customizing Password Reset processes, Password Reset script includes, Example custom scripts for Password Reset, Password Reset extension script categories, Password Reset extension scripts, Create a Password Reset extension script, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/password-reset/pw-reset-extension-script.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Password Reset Extension Scripts

**In one line:** Password Reset logic (enrollment check, identification, verification, password generation, account lookup, post-processing) lives in **script includes** with a `category: 'password_reset.extension.<category>'` line; you customise by writing your own extension script of the right category and selecting it on the type, store or process.

From the Brazil docs; not tested. **Server-side script includes, global scope** (the Password Reset application), called by the platform through `SNC.PwdExtensionPoint`. Concepts: [[Password Reset Application Overview]], [[Script Includes and GlideAjax]].

## Create one

**Password Reset > Extensions > New extension script** (`password_reset_admin` or `admin`), never from **System Definition > Script Includes**. Name in CamelCase without spaces (e.g. `PwdEnrollmentCustom`), choose the category, fill in the generated `process` or `processForm` body (extra helper functions are fine), keep the `category:` line ("DO NOT REMOVE THIS LINE"), and make sure it is **Active**.

## Categories

| Category (`password_reset.extension.`) | Where it is selected | Function | Inputs | Returns | Shipped scripts |
|---|---|---|---|---|---|
| `enrollment_check` | verification type, Enrollment check | `process(params)` | `params.userId`, `params.verificationId` | boolean enrolled | `PwdAlwaysEnrolled`, `PwdMockIsEnrolled`, `PwdQuestionsEnrollmentCheck`, `PwdSMSEnrollmentCheck` |
| `enrollment_form_processor` | verification type, Enrollment processor | `processForm(params, request)` | `userId`, `verificationId`, `enrollmentId`, form `request` | boolean; also session properties `result.status`, `result.message`, `result.value` | `PwdEnrollQuestionsProcessor`, `PwdEnrollSampleProcessor`, `PwdEnrollSMSProcessor` |
| `identification_form_processor` | identification type, Identification processor | `processForm(params, request)` | `params.processId`, `request.getParameter('sysparm_user_id')` | user sys_id or null | `PwdIdentifyViaEmail`, `PwdIdentifyViaUsername` |
| `password_generator` | credential store, Auto-generate password | `process(params)` | `params.credentialStoreId` (one page says the process sys_id) | string password | `PwdDefaultAutoGenPassword` (word + 4 digits) |
| `user_account_lookup` | credential store, User account lookup | `process(params)` | `params.userId` | store account ID | `PwdDefaultUserAccountLookup` (user name) |
| `verification_form_processor` | verification type, Verification processor | `processForm(params, request)` | `resetRequestId`, `userId`, `verificationId`, `request` | boolean verified | `PwdVerifyPersonalDataConfirmationProcess`, `PwdVerifyPersonalDataProcessor`, `PwdVerifyQuestionsProcessor`, `PwdVerifySimpleProcessor`, `PwdVerifySMSProcessor` |
| `post_reset_script` | process, Advanced tab, Post reset script | `process(params)` | `params.resetRequestId`, `params.wfSuccess` | nothing | `PwdPostProcessor` |

The **Create extension script** list on the page shows six categories (no post reset), while the categories table has seven. Business rule *Verify Account Lookup Script* checks the lookup script has the right function name.

## Shape (own example)

```javascript
// Script include, global scope, created from Password Reset > Extensions > New extension script
var ExampleIdentifyByEmployeeId = Class.create();
ExampleIdentifyByEmployeeId.prototype = {
    category: 'password_reset.extension.identification_form_processor', // keep this line
    processForm: function(params, request) {
        var gr = new GlideRecord('sys_user');
        if (gr.get('employee_number', request.getParameter('sysparm_user_id')))
            return gr.getUniqueValue();
        return null; // not identified
    },
    type: 'ExampleIdentifyByEmployeeId'
};
```

To test an extension from a background script the docs look the script include up by name and category, then call `new SNC.PwdExtensionPoint(<sys_id>).process(params)` or `.processForm(params, request)`, with `new SNC.PwdExtensionPointParameter()` as both the parameter and a simulated request object (`request.setParameter('sysparm_user_id', ...)`). Note the docs' sample mixes `now_GR` and `gr` variable names, so it would not run as printed.

## Related

- [[Password Reset Verifications and Enrollment]] · [[Password Reset Credential Stores]] · [[Password Reset Reference - Properties, Tables and Components]] (UI macros and scripts)
