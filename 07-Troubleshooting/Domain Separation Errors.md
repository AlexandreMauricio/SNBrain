---
type: troubleshooting
tags: [troubleshooting, domain-separation, access-control, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Domain separation for service providers (chapter read in full 2026-10-08) - Troubleshoot domain separation errors, Enable verbose domain logging and debug messages, View a real-time domain message, View a historical domain message, Checking domain logs for errors and warnings, Slow queries and SQL debugging, Domain Separation Center, Importance of the Default domain. https://www.servicenow.com/docs/r/platform-security/r_TroubleshootDomainSeparationError.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Domain Separation Errors

**Symptom:** users see records they should not, or cannot see records they should; records pile up in the default domain or in global; lists are slow; a Domain Separation Center audit reports errors after a hierarchy change.
**Cause:** a record's domain value or path is wrong, the hierarchy or its extra relationships are inconsistent, or assignment logic is missing.
**Fix:**

| Problem | Cause | Fix |
|---|---|---|
| A domain sys_id points to a domain that does not exist | the domain was deleted, or the value refers to an older domain table | list the table, filter on the invalid **Domain** value, and set the right one or clear it. Can also occur in `sys_user_visibility`, `sys_user_group_visibility`, `domain_contains` |
| A domain path points to the wrong domain | paths out of step with the hierarchy (after re-parenting, or from the old numbering conversion) | check the Domain Separation Center results and rerun; if it persists, correct `sys_domain_path` on the records by hand |
| The domain tree is corrupt | *contains* relationships forming a loop | edit the contains relationships on the domain records to break the loop |
| Records appear in the **Default** domain | nothing assigned a domain (no company, no rule) | move them; fix the assignment logic ([[Domain-Separate a Custom Table]]) |
| Tenant data visible to everyone | records are global because no default domain exists, or the table is not domain-separated | define a default domain; assign the records |
| User sees too much | a visibility domain (direct or through a group), a *contains*, the `admin` role, or the user's home domain is too high | review the user's and groups' *Visibility domains*, the domain's *Contains Domains*, and the user's company and domain |
| Header shows one domain, results come from another | session timed out and fell back to the home domain | reload the page completely |
| An override does not take effect | tested from global, or the record's domain is not the one assumed | test inside the domain; remember the **record's** domain selects the process |
| Slow lists and reports | many OR conditions from contains or visibility; missing index | **System Diagnostics > Stats > Slow Queries**, search `domain_path`; simplify relationships ([[Domain Separation Recommended Practices]]) |
| Orphan records reported (for example in `sys_ui_list`) | rows whose domain no longer exists | fix or remove them, then rerun the audit |

## How to confirm the cause

- **Which domains a query used:** turn on verbose logging (Domain Separation Center > **Configure Domain Center** > **Enables detail domain logging**, or property `glide.sys.domain.verbose` = true), then **System Diagnostics > Session Debug > Enable All**, reproduce, and look for lines such as `[Domain Paths] Query against table incident restricted by domain values [...]`: the list in brackets is exactly what the user was allowed to see.
- **Later, for other users:** leave debugging on for a period, then **System Logs > Utilities > Node Log File Download**, open `localhost_log.<yyyy-mm-dd>.txt` and search for `Query against table`.
- **After hierarchy changes:** Domain Log (`syslog_domain`): errors and warnings from the path recalculation, and `DWR execution completed.` when it has finished.
- **Health audits:** Domain Separation Center tiles *Errors* and *Warnings*; copy an audit's **Detail ID** and filter `syslog_domain` on **Source** `=<Detail ID>` to list each offending record. Errors need action; warnings are advice (for example a domain name that is too long).
- Turn verbose logging off afterwards: it costs performance.

## Related

- [[Domain Separation Administration]] · [[Domain Separation Overview]] · [[Domain Separation Recommended Practices]] · [[ACL Not Working as Expected]]
