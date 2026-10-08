---
type: concept
tags: [concept, security, data-management, data-integrity, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy (chapter read in full 2026-10-08). This note draws on - Data privacy (Classic) configuration, Create a data privacy technique configuration, Create a data privacy policy, Configure a data privacy job, Data privacy job rollback, Roll back a data privacy job, Data privacy clone, Configure data privacy clone request, Data Privacy Job Logs, Installed with data privacy (Classic), and the store app pages Data anonymization, Create anonymization techniques, Create anonymization policies, Assign data anonymization techniques, Configure data anonymization clone request, Create anonymization job, Activate parallel jobs. https://www.servicenow.com/docs/r/platform-security/data-privacy-classic/dps-data-anonymization.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Data Anonymization - Techniques, Policies and Jobs

**In one line:** an anonymization **job** applies a **policy** (which data class or which users, and which **technique** per field) to stored records and overwrites the values; it can be rolled back only for a few days.

From the Brazil docs. Context and licensing: [[Data Privacy Overview]]. Data must be classified first: [[Data Classification]]. Steps: [[Anonymize a User with a Data Privacy Job]].

Two interfaces do the same thing:

| | Classic | Store app |
|---|---|---|
| Menu | **System Security > Data Privacy (Classic)**: Privacy Technique Configuration (?), **Privacy Policy Configuration**, **Data Privacy Job**, **Data Privacy Job Logs** | **System Security > Data Privacy > Anonymization**: **View techniques**, **Create new policy**, **Schedule job**, Jobs pane |
| Words | technique configuration, privacy policy, data privacy job | anonymization technique, policy, job |

## Techniques

| Technique | Effect | Parameters (default) |
|---|---|---|
| **Selective Replace** | masks the characters of a string between two positions | `start_index` (first character), `end_index` (last character), `exclude_char` (one character left unmasked; only the first is used if several are typed), `replacement_char` (`*`; the Classic page calls it `char_to_replace`) |
| **Static Replace** | swaps the value for a fixed one; strings, numbers, dates | `string_value` (`TEXT123`), `number_value` (`1234567`), `date_value` (`1988-11-11`), `date_time_value` (`1988-11-11 10:10:10`); Classic also lists `preserve_data_length` and `use_random_generated_value` |
| **Random Replace** | random value; strings and numbers | `preserve_data_length` (true) |
| **Remove** | empties the field | none |
| **No Action** (*DoNothing*) | placeholder, leaves the field alone | none |
| **Selective Replace with X** | masks characters with the letter X; the default technique of discovery data patterns | |
| **Data pattern anonymization** | inside free text, replaces only the matches of the active data patterns, each with the technique set on its pattern, leaving the rest of the text | settings come from [[Data Discovery - Patterns, Policies, Jobs and Findings]] |

Custom techniques (**Add custom technique**) are a base technique plus a name and parameter values. Role `data_privacy_admin` (elevated) and `admin`.

## Policies

A policy can only target classified data. Store app policy types:

| Type | Anonymizes |
|---|---|
| **Data tables or columns** | every record of the columns in a data class |
| **User specific data** | the records of chosen users or groups (needs the user reference selection step) |
| **Catalog variable** | sensitive data in catalog item variables; scope *Service catalog request* or *Record producer*; uses data pattern anonymization |
| **Real time data** | entries as they arrive, for chosen columns or a channel ([[Data Privacy Channel Policies - AI Prompts, Inbound Email and Virtual Agent]]) |

Steps: *Define details* (name, description, activation channels and priority, the data class in **Data to process**; for real time, columns and child tables), then *Assign techniques*, either **Bulk Assign Techniques** per field type or one technique per column; optional child tables (a parent job fails if a child job fails), the ordering of data patterns, and a **Test** with sample input. **Save**, then **Publish**: only published policies can be scheduled.

Classic policy fields: **Data Class**, **Apply to All Data in Class**, **Apply when Cloning**, **Application Order**, **Supports Rollback**, and the technique per field.

- Never leave a field's technique empty: choose *DoNothing*. A policy with an empty technique cannot run.
- Every table involved needs a correct dictionary (`sys_dictionary`) entry.

## Jobs

Role `data_privacy_processor` (elevated) and `admin`. Two uses: the data of specific users, or of a data class.

| Field | Notes |
|---|---|
| **Policy used** / **Privacy Configuration** | the published policy |
| **Start time**, **End time** | daily window (Classic: **Time window start/end**, in UTC). A job that does not finish pauses and resumes at the next window |
| **Type of user selection**, **Select users/groups** | for user policies; up to 1,000 users |
| conditions | optional filter on the records (not for clone policies); recurring jobs with conditions do a full scan each run |
| **Dry run** | preview without changing data, deleted after 72 hours. *Sample preview* (up to 1,000 records) or *Detailed preview* (all records in scope). Limits: 200,000 records per table, 10 preview records per column in a sample; not for encrypted columns |
| **Frequency** | Classic field (?) |

- States: Scheduled, Completed, Cancelled, Error, Paused, Rollback in progress, Rollback complete.
- Buttons after scheduling: **Cancel job** (before the start time), **Pause** (between start and end), **Resume**, **Export** (PDF). The summary shows estimated record count, records, tables and users processed, and time remaining to roll back.
- **A job runs once**, dry run included. To repeat, schedule a new job from the same policy.
- Jobs are destructive. On an encrypted column a job decrypts and re-encrypts the values; choose *No Action* for such columns to avoid that.

## Rollback

- A policy with rollback support makes the job record a rollback context (type `REDACT`), at most one per job.
- Kept **three days** by default; `glide.rollback.expiration_days_redact` changes that. After expiry there is no way back.
- Available for jobs in Completed, Canceled or Error. Open the job (elevated `data_privacy_processor`) > **Rollback**.
- A job that was paused and resumed cannot be rolled back.
- No rollback for anonymization started from granular or attachment findings.

General mechanism: [[Rollback and Delete Recovery]].

## After a clone

- A policy marked to apply when cloning (Classic: **Apply to All Data in Class** + **Apply when Cloning**; store app: *Data tables or columns* policy with the activate-during-cloning option and an order) is run on the **target** by a post-clone script installed with the application.
- The script creates one federated job (`dp_federated_job`), which creates and runs one job (`dp_job`) per policy in **Application Order**. Jobs on unrelated tables run in parallel, so a higher order can start before a lower one.
- The `dp_` tables are in the clone data preservers by default; excluding them raises a warning.
- Procedure: activate the application on the source, create and publish the policy, back up the data privacy configuration, request the clone as the data privacy admin; afterwards watch `dp_federated_job.list` and `dp_job.list` on the target (role `data_privacy_clone_processor`).
- Not available on self-hosted instances. One page says only ServiceNow support can install the store app for this; the installation page describes a normal installation (discrepancy).

Clone mechanics: [[Instance Clone Overview]], [[Clone Options and States]].

## Performance

| Property | Meaning |
|---|---|
| `com.glide.data_privacy.max_parallel_workers` | create it (integer) to run data class and user jobs on several threads; up to 5, start with 2 or 3 per node. Default is one thread |
| `dp.max_concurrent_clone_item_workers` | workers of the post-clone federated job; 3 by default |

## Logs and tables

**Data Privacy Job Logs** list failed discovery, classification and anonymization jobs: level, message, source, type, code, job table and id, target table, column and record. Roles: any of the four data privacy roles.

| Table | Holds |
|---|---|
| `dp_job`, `dp_job_summary` | jobs and their summaries |
| `dp_federated_job` | post-clone federated jobs |
| `dp_configuration` | privacy policies |
| `dp_technique`, `dp_technique_with_params`, `dp_technique_with_parameter`, `dp_technique_with_parameter_value` | techniques and their parameters |
| `dp_field_technique` | technique per classified field |
| `dp_primary_reference` | primary reference links |

## Related

- [[Data Privacy Overview]] · [[Data Classification]] · [[Tokenization of Sensitive Data]] · [[Anonymize a User with a Data Privacy Job]] · [[Rollback and Delete Recovery]] · [[Instance Clone Overview]]
