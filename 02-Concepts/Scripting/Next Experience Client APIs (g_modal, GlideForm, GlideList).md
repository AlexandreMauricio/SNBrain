---
type: reference
tags: [reference, scripting, client-script, ui-action, workspace, glide-api]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Client Next Experience API reference, pages g_modal (Next Experience) - Client, GlideForm (Next Experience) - Client, GlideList (Next Experience) - Client, GlideModal (Next Experience) - Client, GlideNavigation (Next Experience) - Client, GlideUser (Next Experience) - Client, StopWatch (Next Experience) - Client, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA). Per-parameter detail of g_modal field types not read in full.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Next Experience Client APIs (g_modal, GlideForm, GlideList)

**In one line:** the browser APIs for configurable workspaces (Service Operations Workspace and others): `g_modal` for dialogs, `g_form` and `g_list` adapted to the Next Experience framework.

From the Brazil docs, not tested. Core UI equivalents: [[GlideModal, GlideModalForm and g_navigation Client API Reference]] and [[GlideForm and GlideAjax Client API Reference]]. Workspace setup: [[Service Operations Workspace for ITSM]].

## g_modal (workspaces)

Each method takes one object and returns a promise:

| Method | Shows |
|---|---|
| `alert({title, message, ...})` | a message with OK |
| `confirm({title, message, ...})` | OK and Cancel |
| `confirmDestroy({title, message, ...})` | a confirmation styled for destructive actions |
| `richText({title, richText, ...})` | formatted content |
| `showFields({title, fields, size, ...})` | input fields; the promise returns `fieldValues.updatedFields` |
| `showFrame({title, url, ...})` | a UI page or external link in a frame |

Common options: `size`, `cancelTitle`, `confirmTitle`, `cancelType`, `confirmType`, `resizableConfig`, `instruction`. A field in `showFields` takes `type` (for example `textarea`, `choice`, `reference`), `name`, `label`, `mandatory`, `value`, `autoFocus`, `choices` (`displayValue`, `value`) for choice fields, and `referringTable`, `referringRecordId` for reference fields.

## GlideForm (Next Experience)

`g_form` keeps nearly all Core UI methods. Compared with the Core UI page:

- Only on the Next Experience page: `addAdditionalParams(name, value)` (a hidden input sent with the form).
- Absent from the Next Experience page: `getOption`, `isSectionVisible`, `setRelatedLinksDisplay`, `isLiveUpdating`, `refreshSlushbucket`, `getDisplayBox`, `showTemplateBar`, `hideTemplateBar`. Whether they fail in workspaces is an `(inference)` from their absence; test before relying on them.
- `getControl`, `getHelpTextControl`, `getElement` and `getFormElement` are deprecated for mobile devices.

## GlideList (`g_list`, workspaces)

Used in a **list action**'s client script. `setFilter`, `addFilter`, `setOrderBy`, `setGroupBy`, `setRowsPerPage` and the other setters must be followed by **`refresh()`**; `sort()` and `sortDescending()` refresh by themselves. Readers: `getChecked()` (selected rows), `getQuery()`, `getTableName()`, `getView()`, `getTitle()`, `getParentTable()`, `getRelated()`, `getListName()`, `getFixedQuery()`. Unsupported GlideList2 methods (`isUserList`, `setFirstRow`, `showHideGroups`, `showHideList`) log a console error.

## Smaller APIs

- **GlideModal (Next Experience):** the Core UI methods plus `getID()`, `getPreferences()`, `setDialog(name)` and `type()`.
- **g_navigation:** only `refreshNavigator()`, in the `nowapi` namespace.
- **g_user:** only `getRoles()` is documented on this page.
- **StopWatch:** `new StopWatch()`, `getTime()`, `restart()` and `toString()`, for timing client code.

## Example

```javascript
// Workspace form action (declarative action, client script), on Incident (incident)
function onClick(g_form) {
    g_modal.showFields({
        title: 'Example reason',
        fields: [{ type: 'textarea', name: 'work_notes', label: getMessage('Reason'), mandatory: true }],
        size: 'lg'
    }).then(function(fieldValues) {
        g_form.setValue('work_notes', fieldValues.updatedFields[0].value);
        g_form.save();
    });
}
```

Adapted from the docs' own example.

## Related

- [[GlideModal, GlideModalForm and g_navigation Client API Reference]] · [[GlideForm and GlideAjax Client API Reference]] · [[Service Operations Workspace for ITSM]] · [[UI Actions]]
