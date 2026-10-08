---
type: how-to
tags: [how-to, security, data-management, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy > Data Discovery (chapter read in full 2026-10-08) - Create new data pattern, Select active data patterns, Select target tables, Create new policy, Create discovery job, Review discovery findings, and the Classic equivalents (Configure patterns, Configure target tables, Create a policy, Configure a job, Classify data). https://www.servicenow.com/docs/r/platform-security/data-discovery/dds-create-new-job.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Find Sensitive Data with a Data Discovery Job

**Goal:** find out which columns of chosen tables contain card numbers, email addresses or another pattern, and classify them.
**Prerequisites:** the Data Discovery store app (`sn_data_discovery`) and its licence or trial; role `sn_data_discovery.data_discovery_admin` (admins get it on installation).
**Navigation:** All > Data Discovery (Classic equivalent: System Security > Data Discovery (Classic))

Background: [[Data Discovery - Patterns, Policies, Jobs and Findings]].

## Steps

1. **Sources > All Patterns**: check that a pattern for what you look for exists; otherwise **Create new** (name, **Expression**, optional **Keyword** and **Keyword Proximity**), **Test** it, **Submit**.
2. **Sources > Active Patterns > Edit**: tick the patterns to use, **Save**.
3. **Sources > Target Tables > Edit**: tick the tables to scan, **Save**.
4. **Policy > Create new policy**: name, the data patterns, the tables; expand a table to restrict the scan to some columns. **Save** (the policy is active).
5. **Scheduled Discovery > Discovery Jobs**: new job with name, **Scan Type** = *Sample* for a first look, the policy, **Start Date** and the time window (UTC). Leave **Scan attachments** off unless the extra terms have been accepted. **Schedule**.
6. When the job is *Completed*: **Scheduled Discovery > Discovery Findings**. Tick the findings that are real, **Classify**, choose the data classes, **Classify**. Leave false positives alone (they become *Ignored*).

## Result / how to check it worked

Findings list table, column, pattern, match count, rows scanned and percentage of matching rows. Classified columns then show in the classification dashboards and can be used by anonymization policies.

## Example

Pattern *Email* and *Credit Card- Visa* active; target table *Example Requests* (`u_example_request`); policy *Example free text scan* limited to the columns `u_description` and `u_notes`. A *Sample* job finds *Email* in 12% of the rows of `u_notes`. That column is classified as *Personally Identifiable Information*; a *Full* job is then scheduled for the weekend window to get exact counts.

## Tables / fields involved

- Dictionary (`sys_dictionary`): the columns found
- `m2m_dictionary_dataclass`: the classification created by **Classify**

## Gotchas

- A *Sample* scan reads 10,000 entries per table per pattern: a sample, not an inventory.
- Running the same job twice in a short time can report 0 scanned rows.
- Log, analytics and several system table families are not scannable.
- Attachment scanning sends file content to a ServiceNow-controlled environment and is limited to files under 10 MB of listed types.
- For a single column that must be watched continuously, with findings per record, use a granular configuration instead.
- Full scans run on one thread unless `com.glide.data_discovery.max_concurrent_item_workers` is created.
