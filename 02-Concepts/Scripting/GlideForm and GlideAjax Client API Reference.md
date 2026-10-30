---
type: reference
tags: [reference, scripting, glide-api, javascript, client-script, forms-lists]
status: documented
source: ServiceNow Brazil docs, API reference > Client API reference > GlideForm (g_form) - Client and GlideAjax - Client (method lists and notes), read 2026-10-30. Next Experience GlideForm, parameter tables and examples not read. https://www.servicenow.com/docs/r/api-reference/client-api-reference/
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# GlideForm and GlideAjax Client API Reference

**In one line:** `g_form` controls the open form in the browser, and **GlideAjax** calls a client-callable script include. Both client side, in [[Client Scripts]], UI policy scripts and client UI actions.

From the Brazil docs; not tested. A separate *GlideForm (Next Experience)* page exists, not read.

## g_form

| Purpose | Methods |
|---|---|
| Value | `getValue`, `setValue` (field, value, display value), `clearValue`, `getBooleanValue`, `getIntValue`, `getDecimalValue`, `getReference`, `getUniqueValue`, `getTableName`, `isNewRecord` |
| State | `setMandatory`, `isMandatory`, `setReadOnly`, `setDisabled`, `setVisible`, `setDisplay`, `isVisible`, `setLabelOf`, `getLabelOf`, `setVariablesReadOnly` |
| Choices | `addOption`, `removeOption`, `clearOptions`, `getOption`, `getOptions`, `getChoice`, `enableChoice`, `disableChoice`, `setChoiceLabel` |
| Field messages | `showFieldMsg`, `hideFieldMsg`, `hideAllFieldMsgs`, `showErrorBox`, `hideErrorBox`, `flash` |
| Form messages | `addInfoMessage`, `addErrorMessage`, `addSuccessMessage`, `addHighMessage`, `addModerateMessage`, `addLowMessage`, `addFormMessage`, `clearMessages`, `clearFormMessages`, `clearAllFormMessages` |
| Sections and lists | `getSections`, `getSectionNames`, `setSectionDisplay`, `isSectionVisible`, `getRelatedListNames`, `showRelatedList`, `hideRelatedList`, `showRelatedLists`, `hideRelatedLists`, `setRelatedLinksDisplay` |
| Decoration | `addDecoration`, `removeDecoration`, annotation methods, `showTemplateBar`, `hideTemplateBar` |
| Attachments | `enableAttachments`, `disableAttachments` |
| Save | `save`, `submit`, `submit(verb)`, `getActionName` |
| Other | `onUserChangeValue`, `isLiveUpdating`, `refreshSlushbucket`, `getControl`, `getElement`, `getFormElement`, `getDisplayBox` (Core UI), `getDisplayValue` (Service Portal) |

- `setMandatory`: **prefer a UI policy** ([[UI Policies]]).
- `setDisplay`: not supported by Service Catalog per its page.
- `setValue` does not change strict read-only fields; a warning is logged in the browser console.
- `getReference`: **always use a callback**; it calls the server.
- Pass display value in `setValue` for reference fields, to avoid an extra lookup (general knowledge).

## GlideAjax

1. `new GlideAjax('ScriptIncludeName')`.
2. `addParam('sysparm_name', 'methodName')`, then other `sysparm_` parameters.
3. `getXML(callback)` or `getXMLAnswer(callback)`.

`getXMLWait()` blocks the browser and is **not available to scoped applications**; avoid it. `getAnswer()` reads the result. See [[Script Includes and GlideAjax]].

## Example

```javascript
// Client side: onChange client script on Assigned to
var ga = new GlideAjax('ExampleUserUtils');
ga.addParam('sysparm_name', 'getManager');
ga.addParam('sysparm_user', newValue);
ga.getXMLAnswer(function (answer) {
    g_form.setValue('u_example_manager', answer);
});
```

## Related

- [[Client Scripts]] · [[Script Includes and GlideAjax]] · [[UI Policies]]
