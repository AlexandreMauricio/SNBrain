---
type: how-to
tags: [how-to, security, data-management, users, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy (chapter read in full 2026-10-08) - Create anonymization techniques, Create anonymization policies, Assign data anonymization techniques, Create anonymization job, Roll back a data privacy job, Classify data. https://www.servicenow.com/docs/r/platform-security/data-privacy-classic/dps-create-anonymization-job.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Anonymize a User with a Data Privacy Job

**Goal:** replace the personal data of chosen users with meaningless values (a right-to-be-forgotten request), with a preview first and a way back for a few days.
**Prerequisites:** the Data Privacy store app and its licence ([[Data Privacy Overview]]); roles `admin` plus the elevated roles `data_privacy_admin` (policy) and `data_privacy_processor` (job).
**Navigation:** All > System Security > Data Privacy > Anonymization

Background: [[Data Anonymization - Techniques, Policies and Jobs]].

## Steps

1. **Classify the columns.** The user columns to change must carry a data class ([[Data Classification]]). The demo data already marks the main User (`sys_user`) columns as *Personally Identifiable Information*.
2. Elevate to `data_privacy_admin`. Open **Anonymization** > **View techniques**; add a custom technique only if the built-in ones do not fit.
3. **Create new policy** > **User specific data** > **Create**. Give it a name, choose the data class in **Data to process**, complete the user reference step, then **Continue**.
4. Assign a technique to every column (or **Bulk Assign Techniques** per field type). Use *DoNothing* for columns to leave alone, never an empty technique.
5. **Save**, then **Publish**.
6. Elevate to `data_privacy_processor`. On the policy select **Schedule job**: description, **Start time** and **End time**, **Type of user selection** and the users or groups (up to 1,000).
7. Switch on **Dry run** (sample preview) and **Schedule job**. Read the preview.
8. Schedule the job again from the same policy, without dry run. A job runs only once.

## Result / how to check it worked

The job appears in the Jobs pane and ends in *Completed*; its summary shows users, tables and records processed and the time left to roll back. Open the user record: the fields hold the replacement values.

To undo within the rollback period (three days by default): open the job as `data_privacy_processor` > **Rollback**.

## Example

*Test User* has left *Example Company* and asks for erasure. Policy *Erase departed user*, type *User specific data*, data class *Personally Identifiable Information*: **Static Replace** on first and last name, **Remove** on the phone numbers and the photo, **Selective Replace** on the email, *DoNothing* on country. Dry run for *Test User* shows the ten sample values per column as expected. The real job, scheduled for the night window, completes with one user processed.

## Tables / fields involved

- User (`sys_user`): the classified columns
- `dp_configuration` (policy), `dp_job` and `dp_job_summary` (job), `m2m_dictionary_dataclass` (classification)

## Gotchas

- The job is destructive; after the rollback period the old values are gone.
- A directory or single sign-on synchronisation can write the personal data back: stop the user being provisioned first ([[LDAP Integration]]).
- Logs and audit history are not anonymized ([[Auditing and Record History]]), and free text is covered only by the data pattern technique.
- Pausing and resuming a job loses the ability to roll it back.
- Dry run does not work on encrypted columns, and a real job decrypts and re-encrypts them unless the technique is *No Action*.
- Anonymizing a whole data class is meant for non-production instances.
