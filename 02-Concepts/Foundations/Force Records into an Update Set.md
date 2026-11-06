---
type: concept
tags: [concept, update-sets, scripting, ui-action, javascript]
status: unverified
source: Team notes shared by the user's manager, 2026-10-30, files UI Actions.md and Attachments.md. Not from official docs and not tested.
sn-release:
verified:
verified-by:
updated: 2026-11-06
---

# Force Records into an Update Set

**In one line:** `GlideUpdateManager2.saveRecord()` writes one record to the current update set, even on a table that is not captured by default, such as an attachment or a reference data row.

Unverified team notes. Check both scripts on a personal instance first. `GlideUpdateManager2` has no page in the Brazil API reference (its table of contents checked 2026-11-06), so it is undocumented, and its behaviour and availability are unconfirmed. Captured and uncaptured tables are in [[Update Sets]], which also warns never to add `update_synch` to a table yourself. These scripts do not add it.

## UI action

Runs on the server as a form UI action, in global scope.

```javascript
forceToUpdateSet(current);
action.setRedirectURL(current);

function forceToUpdateSet(current) {
    current.update();

    var table = current.getTableName();
    var tableIsSync = table.startsWith('wf_')
        || table.startsWith('sys_ui_')
        || table === 'sys_choice'
        || current.getED().getBooleanAttribute('update_synch')
        || current.getED().getBooleanAttribute('update_synch_custom');

    if (tableIsSync) {
        gs.addErrorMessage('Updates are already being recorded for this table.');
        return;
    }

    var updateManager = new GlideUpdateManager2();
    updateManager.saveRecord(current);

    var currentUpdateSet = gs.getPreference('sys_update_set');
    var updateSet = new GlideRecord('sys_update_set');
    updateSet.get(currentUpdateSet);

    var infoMessage = 'Record included in the update set <a href="sys_update_set.do?sys_id=$1">$2</a>.'
        .replace('$1', currentUpdateSet)
        .replace('$2', updateSet.getValue('name'));

    gs.addInfoMessage(infoMessage);
}
```

Things to check when testing (inference, not from the notes):

- The script calls `current.update()` first, so unsaved form changes are saved, and any business rules run.
- `startsWith` may not exist in every scripting mode. The notes do not say which mode they used.
- The tables `wf_`, `sys_ui_` and `sys_choice` are treated as already captured by name, not by reading a dictionary attribute.

## Attachment

A background or fix script in global scope. It saves the Attachment (`sys_attachment`) row, then each of its Attachment Document (`sys_attachment_doc`) chunks. See [[Attachments]].

```javascript
var targetAttachment = '<attachment_sys_id>';
var updateManager = new GlideUpdateManager2();

var attachmentGR = new GlideRecord('sys_attachment');
attachmentGR.addQuery('sys_id', targetAttachment);
attachmentGR.setLimit(1);
attachmentGR.query();

if (attachmentGR.next()) {
    updateManager.saveRecord(attachmentGR);

    var attachmentDocGR = new GlideRecord('sys_attachment_doc');
    attachmentDocGR.addQuery('sys_attachment', targetAttachment);
    attachmentDocGR.query();

    while (attachmentDocGR.next()) {
        updateManager.saveRecord(attachmentDocGR);
    }
}
```

## Example

On *Example Test Instance*, make *Example Update Set* current. Add the UI action to *Example Reference Table* as *Force to Update Set*, open a record, click it, then check that the record appears in the set's Customer Updates.

## Related

- [[Update Sets]] · [[Attachments]] · [[Copying Records Between Instances]] · [[Move an Update Set between Instances]]
