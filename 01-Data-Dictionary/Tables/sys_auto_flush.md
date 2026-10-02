---
type: table
tags: [table, schema, data-management]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management", topic "Create a table cleanup rule in Core UI" (pp. 617, 635-636), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sys_auto_flush

**Label:** Auto Flush
**What it stores:** table cleanup rules: which table to clean, by which date field, after what age, under which conditions. List: `sys_auto_flush.list`.

## Key columns

Form labels from the guide; column names are not given.

| Label | Name | Meaning | Confidence |
|---|---|---|---|
| Tablename | ? | target table | documented |
| Matchfield | ? | date/time field measured against the age. Default `sys_created_on` | documented |
| Age in seconds | ? | record is deleted once the match field is older than this | documented |
| Active | ? | rule on or off | documented |
| Application | ? | scope | documented |
| Clean journals | ? | also delete `sys_journal_field` rows | documented |
| Clean audit | ? | also delete `sys_audit` and `sys_audit_relation` rows | documented |
| Cascade delete | ? | also delete records that refer to the deleted ones | documented |
| Conditions | ? | extra filter | documented |

## Related

- [[Table Cleaner]] · [[Create a Table Cleanup Rule]]
