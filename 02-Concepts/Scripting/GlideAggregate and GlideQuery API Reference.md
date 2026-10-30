---
type: reference
tags: [reference, scripting, glide-api, javascript]
status: documented
source: ServiceNow Brazil docs, API reference > Server API reference > GlideAggregate - Global and GlideQuery (method lists and notes), read 2026-10-30. Parameter tables, examples and the Stream and Optional classes not copied. https://www.servicenow.com/docs/r/api-reference/server-api-reference/
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# GlideAggregate and GlideQuery API Reference

**In one line:** **GlideAggregate** for counts, sums and trends without loading records; **GlideQuery** is a newer, chainable wrapper around GlideRecord. Both server side.

From the Brazil docs; not tested.

## GlideAggregate

Extends GlideRecord.

| Purpose | Methods |
|---|---|
| Aggregate | `addAggregate`, `getAggregate`, `getTotal`, `orderByAggregate` |
| Group | `groupBy`, `setGroup`, `orderBy` |
| Having | `addHaving` |
| Trends | `addTrend`, `addBizCalendarTrend`, `setIntervalYearIncluded` |
| Run | `addEncodedQuery`, `query`, `getQuery`, `getRowCount`, `getValue`, `setAggregateWindow`, `setCategory`, `setAggregateWorkflow` |

```javascript
// Server side: background script, read only
var ga = new GlideAggregate('incident');
ga.addActiveQuery();
ga.addAggregate('COUNT');
ga.groupBy('priority');
ga.query();
while (ga.next())
    gs.info(ga.getValue('priority') + ': ' + ga.getAggregate('COUNT'));
```

## GlideQuery

Scoped and global. Reads return a **Stream** or **Optional**: end a Stream with a terminal method.

| Purpose | Methods |
|---|---|
| Filter | `where`, `orWhere`, `whereNull`, `whereNotNull`, `orWhereNull`, `orWhereNotNull`, `GlideQuery.parse` (encoded query) |
| Read | `get`, `getBy`, `select`, `selectOne` |
| Aggregate | `count`, `avg`, `sum`, `min`, `max`, `aggregate`, `groupBy`, `having` |
| Shape | `orderBy`, `orderByDesc`, `limit` |
| Write | `insert`, `update`, `updateMultiple`, `insertOrUpdate`, `deleteMultiple` |
| Control | `withAcls` (uses GlideRecordSecure), `disableWorkflow`, `disableAutoSysFields`, `forceUpdate`, `toGlideRecord` |

```javascript
// Server side
new GlideQuery('incident')
    .where('active', true)
    .where('priority', 1)
    .select('number')
    .forEach(function (r) { gs.info(r.number); });
```

`forEach` is general knowledge here: the Stream page was not read.

## Related

- [[GlideRecord API Reference]] · [[GlideSystem API Reference]]
