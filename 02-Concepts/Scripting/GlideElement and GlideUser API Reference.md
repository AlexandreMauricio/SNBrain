---
type: reference
tags: [reference, scripting, glide-api, javascript, users]
status: documented
source: ServiceNow Brazil docs, API reference > Server API reference > GlideElement - Global and GlideUser - Global (method lists and notes), read 2026-10-30. Scoped pages, parameter tables and examples not read. https://www.servicenow.com/docs/r/api-reference/server-api-reference/
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# GlideElement and GlideUser API Reference

**In one line:** **GlideElement** is a field on a GlideRecord (`current.short_description`), **GlideUser** is what `gs.getUser()` returns. Both server side; global method lists below.

From the Brazil docs; not tested.

## GlideElement

| Purpose | Methods |
|---|---|
| Value | `getValue`, `setValue`, `toString`, `nil`, `hasValue`, `setInitialValue` |
| Display | `getDisplayValue`, `setDisplayValue`, `getDisplayValueExt`, `getDisplayValueLang`, `getHTMLValue`, `getXMLValue`, `getEscapedValue`, `getTextAreaDisplayValue`, `getLabel`, `getName`, `getTableName`, `getBaseTableName` |
| Changes | `changes`, `changesFrom`, `changesTo` |
| Reference | `getRefRecord` (empty record if no value), `getGlideRecord` |
| Date and duration | `getGlideObject`, `dateNumericValue`, `setDateNumericValue` |
| Journal | `getJournalEntry` (latest or all), `setJournalEntry` (record must exist or be initialized) |
| Choice | `getChoices`, `getChoiceValue`, `getDependent`, `getDependentTable` |
| Dictionary | `getED`, `getAttribute`, `getBooleanAttribute`, `hasAttribute` |
| Access | `canRead`, `canWrite`, `canCreate`, `hasRightsTo` |
| Error | `setError`, `getError` |

## GlideUser

| Purpose | Methods |
|---|---|
| Identity | `getName` (login name), `getDisplayName`, `getFirstName`, `getLastName`, `getEmail`, `getCompanyID` |
| Roles | `hasRole`, `getRoles`, `getUserRoles` (explicit only) |
| Groups | `isMemberOf`, `isExplicitMemberOf`, `getMyGroups` (active groups only) |
| Domain | `getDomainID`, `getDomainDisplayValue` |
| Time zone | `getTimeZoneLabel`, `getTimeZoneLabelLang` |

Use `hasRole()` rather than `getRoles()` when roles may change in session, for example through masking or delegation.

## Example

```javascript
// Server side: before update business rule, global
if (current.state.changesTo('6') && gs.getUser().isMemberOf('Example Group'))
    current.work_notes.setJournalEntry('Example note', gs.getUserName());
```

## Related

- [[GlideRecord API Reference]] · [[GlideSystem API Reference]] · [[Business Rules]]
