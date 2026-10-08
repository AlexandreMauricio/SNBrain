---
type: concept
tags: [concept, security, data-management, ai, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy > Data Discovery (chapter read in full 2026-10-08) - Data Discovery landing, Exploring Data Discovery (Classic), Activating Data Discovery, Classify data, Data Discovery jobs, Configure a job, Attachment scanning, Configure patterns, Default data patterns, Default NER data patterns, Using Text to RegEx (classic UI and discovery UI), Text to RegEx error handling and licensing prerequisites, Configure target tables, Activate parallel jobs, Data Discovery roles, Data Discovery job results, supported data types, Scanning with Granular Configuration, Granular Findings, Data Discovery policies, Create a policy, and the Data Discovery Store pages (overview, policy, sources, new data pattern, active patterns, target tables, scheduled discovery, create job, review discovery, attachment and granular findings, create granular job). https://www.servicenow.com/docs/r/platform-security/data-discovery/data-discovery.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Data Discovery - Patterns, Policies, Jobs and Findings

**In one line:** Data Discovery scans tables (and optionally attachments) for **data patterns**, regular expressions or AI models that recognise things like card numbers and email addresses, and lists where they were found so the columns can be classified and protected.

From the Brazil docs. Part of [[Data Privacy Overview]]; separate subscription, free evaluation on a non-production instance on request. Steps: [[Find Sensitive Data with a Data Discovery Job]].

Two interfaces over the same data:

| | Classic | Store app (`sn_data_discovery`) |
|---|---|---|
| Menu | **System Security > Data Discovery (Classic)**: Dashboard, All Data Patterns, Active Data Patterns, Target Tables, Data Discovery Policies, Data Discovery Job, Data Discovery Findings, Granular configuration, Granular findings | **All > Data Discovery**: **Overview**, **Policy**, **Sources** (All Patterns, Active Patterns, Target Tables), **Scheduled Discovery** (Discovery Jobs, Discovery Findings, Attachment Findings, Granular Configuration, Granular Findings) |

## Data patterns

| Field | Notes |
|---|---|
| **Name**, **Description**, **Application** | |
| **Type** | **Local** = regular expression; **Model** = AI/ML service (named entity recognition) |
| **Expression** | the regular expression, under 1,000 characters; **Test** button |
| **Keyword**, **Keyword Proximity** | optional, used together: words that must appear near the match (tells a date of birth from a hire date); proximity default 30, maximum 64 |
| **Privacy technique configuration** | how a match is masked when the pattern is used for anonymization or AI prompts: synthetic replacement, static replacement, selective replacement with x, remove |
| **Synthetic Value** | the substitute values |

- A pattern is used only when it is in **Active Data Patterns** (**Edit**, move it to the selected side). The **order** of active patterns is also the order in which their techniques are applied in data pattern anonymization.
- Default regex patterns: Visa, American Express, Mastercard, Diners Club and Discover card numbers, US social security number, email address, US phone number.
- Default NER patterns (*Model* type): Address, City, Country, Crime, Date and Time, Job position, Location, Nationality or religious or political group, Organization, Password, Person, Salary, State. They need the extra zero-cost SKU and the latest Generative AI Controller, and can be used in discovery jobs, anonymization jobs (with the data pattern technique), real time anonymization and AI prompt masking.

### Text to RegEx

A **Generate Regex** button on the pattern record: describe the pattern in words, an LLM returns an expression and an explanation; in the store interface a three-step generate, test, accept flow. Needs a Vault licence **and** a Pro Plus SKU plus the *Now Assist for Vault* plugin (a standalone Data Privacy licence is not enough; the button is greyed out otherwise). Each accepted expression consumes assists.

## Target tables and policies

- **Target Tables**: only listed tables are scanned; all their columns unless a policy narrows it.
- Not supported: tables whose names start with `sr`, `sysx`, `v`, `sh$`, `syslog`, `ua`, `usageanalytics`, `ecc`, `clone`, `jrobin`, `pa`, `sla_repair_log`, `scan`, `gcf`, `fm_log`, `log`, `np$`, `sn_data_discovery`, and the data privacy and classification tables (list as printed; prefix matching is my reading).
- A **policy** bundles data patterns with tables and, optionally, columns, so several scan definitions can coexist instead of one global one. Classic fields: **Name**, **Target Table**, **Target Column(s)**, **Data Pattern**, **Active** (default on). Store app: **Policy > Create new policy**, pick patterns, tick tables, expand a table to pick columns; new policies are active.
- Supported field types: the same list as for anonymization ([[Data Privacy Overview]]).

## Jobs

| Field | Notes |
|---|---|
| **Scan Type** | **Sample** (10,000 entries per table per pattern), **Full** (everything), **Incremental** (new or modified records; recurring) |
| **Policy** | the discovery policy |
| **Start Date**, **Time window start/end** | UTC, 24-hour; an unfinished job pauses and resumes in the next window |
| **Scan attachments** | scheduled scans only; files under 10 MB; PDF, DOC(X), TXT, XLS(X), CSV, XML, EML, MSG, JPG, JPEG, PNG. **The content is sent to a ServiceNow-controlled environment** and extra terms must be accepted |
| **Scan embedded images** | standalone images and images inside documents; slow |
| **Track granular findings** | also list the individual records; slower |

- States: Ready to Schedule, Scheduled, In Progress, Completed, Error, Canceled, Paused. Buttons **Schedule Job**, **Cancel Job**, **Pause**, **Resume**.
- Running the same job twice in quick succession can report 0 scanned rows the second time.
- `com.glide.data_discovery.max_concurrent_item_workers` (create it, integer, up to 5; start with 2 or 3): parallel threads for full scans. Default is one thread.

## Findings

One row per table column and pattern: **Dictionary Entry**, **Table**, **Data Pattern**, **Data Pattern Match Count**, **Total Row Scan Count**, **Percentage of Matching Rows**, **Data Discovery Job**, **Status** (New, then Classified or Ignored).

- **Classify**: tick findings, choose data classes; this feeds [[Data Classification]] and so makes the column eligible for anonymization.
- **Available Protections**: which protection covers the column; since Xanadu only Field Encryption is reported.
- **Consolidate Findings**: merges the results of finished full scans under the most recent job.
- **Attachment Findings**: record, attachment, job, discovered pattern, status (No data, Data discovered, Failed discovery, Retry failed).

## Granular configuration

Scans **one column** continuously and reports per **record** instead of per column.

- Fields: **Table**, **Column label**, **Scan start point** (empty = all entries; changing it restarts the scan), **Active**; child tables selectable for extended tables. Uses the active data patterns.
- **Granular Findings**: record, table, column, pattern, **Action** (Review, Ignore, Anonymize) and **Status** (New, Processed, Manual Review).
- At **500** findings scanning pauses until someone acts. Processed findings are deleted after 3 days; findings in Manual Review (the action failed) must be deleted by hand.
- Anonymize needs `data_privacy_admin` and **cannot be rolled back**.

## Roles

| Role | Access |
|---|---|
| `sn_data_discovery.data_discovery_admin` | everything above; on granular findings only the Ignore action. Contains `data_classification_admin`, `data_classification_auditor`, `sn_data_discovery.data_discovery_api_processor`. Given to admins on installation |
| `sn_data_discovery.data_discovery_auditor` | read only |

The task pages print the admin role in several spellings (`data_discovery_admin`, `sn_data_discovery_admin`, and `discovery.admin` on the store app pages); the role reference is the one in the table.

## Related

- [[Data Privacy Overview]] · [[Data Classification]] · [[Data Anonymization - Techniques, Policies and Jobs]] · [[Real Time Protection - Alerts, Blocking and Attachment Quarantine]] · [[Find Sensitive Data with a Data Discovery Job]] · [[Security Center]]
