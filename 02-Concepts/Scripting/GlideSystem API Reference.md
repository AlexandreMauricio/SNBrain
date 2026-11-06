---
type: reference
tags: [reference, scripting, glide-api, javascript]
status: documented
source: ServiceNow Brazil docs, API reference > Server API reference > GlideSystem - Global and GlideSystem - Scoped (method lists and notes), read 2026-10-30. Parameter tables and examples not copied. https://www.servicenow.com/docs/r/api-reference/server-api-reference/c_GlideSystemScopedAPI.html ServiceNow Brazil docs, API reference page(s) GlideSession - Global, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA).
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# GlideSystem API Reference

**In one line:** the `gs` object, server side: user, messages, properties, logging, events and date helpers.

From the Brazil docs; not tested. Date helpers return values for the **user's session time zone as UTC timestamps**, usable in queries: `gs.daysAgoStart(7)`.

| Purpose | Methods |
|---|---|
| Current user | `getUser`, `getUserID`, `getUserName`, `getUserDisplayName`, `getUserNameByUserID`, `hasRole`, `hasRoleInGroup`, `isLoggedIn`, `getInitials`, `getAvatar`, `getPreference`, `getImpersonatingUserName`, `getImpersonatingUserDisplayName` |
| Session | `getSession`, `getSessionID`, `isInteractive`, `isMobile`, `getCurrentScopeName`, `getDateFormat`, `getDateTimeFormat`, `getTimeFormat` |
| Messages | `addInfoMessage`, `addErrorMessage`, `addSuccessMessage`, `addMessage`, `addHighMessage`, `addModerateMessage`, `addLowMessage`, `getInfoMessages`, `getErrorMessages`, `flushMessages` |
| Translation | `getMessage`, `getMessageS` (escapes ticks), `getMessageLang`; from `sys_ui_message` |
| Properties | `getProperty`, `getEscapedProperty`, `setProperty` (take care) |
| Logging | `log`, `logError`, `logWarning`, `print` |
| Events | `eventQueue`, `eventQueueScheduled` |
| Tables and fields | `tableExists`, `getDisplayColumn`, `getDisplayValueFor`, `getStyle`, `nil` |
| Redirect | `setRedirect`, `setReturn` |
| XML and scripts | `getXMLText`, `getXMLNodeList`, `getNodeName`, `getNodeValue`, `getScriptError` (syntax check only) |
| Now | `now`, `nowNoTZ`, `nowDateTime`, `nowGlideDateTime`, `yesterday`, `lastWeek` |
| Date math | `dateDiff`, `calDateDiff`, `dateGenerate` |
| Period ago | `minutesAgo`, `hoursAgo`, `daysAgo`, `monthsAgo`, `quartersAgo`, `yearsAgo`; most with `Start` and `End`; `daysAgoLocal` |
| Period edges | `beginningOf` and `endOf` + Today, Tomorrow, Yesterday, ThisWeek, LastWeek, NextWeek, ThisMonth, LastMonth, NextMonth, ThisQuarter, ThisYear, NextYear; `endOfLastYear` |
| Day checks | `isFirstDayOfMonth`, `isFirstDayOfWeek`, `isFirstDayOfYear`, `isLastDayofMonth`, `isLastDayOfWeek`, `isLastDayOfYear` |
| Workflow | `workflowFlush` |

## Scoped differences

By comparing the two pages' lists; test before relying on them.

- **Only on the scoped page:** `info`, `warn`, `error`, `debug`, `isDebugging` (scoped logging); `base64Encode`, `base64Decode`, `urlEncode`, `urlDecode`, `xmlToJSON`; `generateGUID`, `getCallerScopeName`, `getCurrentApplicationId`, `getEscapedMessage`, `getSessionToken`, `getTimeZoneName`, `getUrlOnStack`, `getCssCacheVersionString`, `include`, `executeNow`.
- **Not on the scoped page:** `log`, `logError`, `logWarning`, `print`, `now`, `nowDateTime`, `nowNoTZ`, `nowGlideDateTime`, `dateDiff`, `calDateDiff`, `beginningOfToday`, `endOfToday`, `getXMLText`, `getXMLNodeList`, `getPreference`, `hasRoleInGroup`, `getMessageS`, `getUserNameByUserID`, the impersonation methods, and others.

So in a scoped application log with `gs.info()`, not `gs.log()`.

## GlideSession (gs.getSession())

From the Brazil API reference (global page, documented): `getLanguage()`, `getTimeZoneName()`, `getRoles()`, `isInteractive()`, `isLoggedIn()`, and session values for the client: `putClientData(name, value)`, `getClientData(name)`, `clearClientData(name)`. The values set by `putClientData` can be read in client scripts (`g_user.getClientData()`, general knowledge). A scoped page exists and was not read.

## Example

```javascript
// Server side: script include in a scoped application
if (gs.getUser().isMemberOf('Example Group'))
    gs.info('Example check for ' + gs.getUserName());
gs.eventQueue('x_example.record.closed', current, gs.getUserID(), '');
```

## Related

- [[GlideRecord API Reference]] · [[GlideDateTime API Reference]] · [[GlideElement and GlideUser API Reference]]
