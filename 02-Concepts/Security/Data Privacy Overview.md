---
type: concept
tags: [concept, security, data-management, roles, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy (whole chapter, 100 topics, 4,229 cleaned lines, read in full 2026-10-08 through the docs site). This note draws on - Platform Privacy landing, Exploring Data Privacy, Data Privacy landing, Data privacy (Classic), Activate data privacy (Classic), Installed with data privacy (Classic), Data privacy (store app), Data privacy overview (dashboard), Activate data privacy, Domain separation and data privacy, Supported field types for anonymization, Data privacy roles, Default data privacy configurations, Default alerting policy (and monitoring it), Default data discovery job (and reviewing it). https://www.servicenow.com/docs/r/platform-security/data-privacy.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Data Privacy Overview

**In one line:** Data Privacy is the family of applications that finds sensitive data in an instance (Data Discovery), labels the columns holding it (Data Classification) and then anonymizes, tokenizes, masks or blocks it; it is licensed separately, mostly through ServiceNow Vault.

From the Brazil docs. The parts in detail:

| Part | Note |
|---|---|
| Finding sensitive data | [[Data Discovery - Patterns, Policies, Jobs and Findings]] |
| Labelling columns | [[Data Classification]] |
| Rewriting stored data | [[Data Anonymization - Techniques, Policies and Jobs]] |
| Reversible masking | [[Tokenization of Sensitive Data]] |
| Alerting or blocking on entry, quarantining attachments | [[Real Time Protection - Alerts, Blocking and Attachment Quarantine]] |
| Masking in AI prompts, inbound email and chat | [[Data Privacy Channel Policies - AI Prompts, Inbound Email and Virtual Agent]] |

The licence and the other Vault features: [[ServiceNow Vault and Otto for Vault]].

## Two purposes

- **Production:** remove the personal data of specific users (the GDPR right to be forgotten).
- **Non-production:** anonymize whole classes of data after a clone, so developers work with realistic but harmless data. The docs say anonymizing whole data classes belongs only on non-production instances.

## The applications

| Application | Id | Notes |
|---|---|---|
| Data Privacy (Classic) | `com.glide.data_privacy` | plugin; a family release whose last family update was Tokyo |
| Data Privacy (store app) | `sn_dp_store_app` | Next Experience interface for classification and anonymization; Utah and later |
| Data Discovery (store app) | `sn_data_discovery` | |
| Data Discovery APIs | `com.glide.data_discovery` | plugin |
| Data Classification | `com.glide.data_classification` | plugin, active automatically from Brazil |

Installing the Data Privacy store app installs Data Discovery, Data Privacy (Classic) and Data Classification; installing the Data Discovery store app installs the Data Discovery APIs; installing the latest Generative AI Controller installs the Data Privacy store app. Install from **All > System Applications > All Available Applications > All** (role `admin`). Demo data can only be loaded at installation.

- Separate subscription. A **30-day trial** of Data Privacy (Classic) and Data Discovery exists; after it, discovery and anonymization jobs stop without a licence.
- With domain separation and delegated admin, the installing administrator must be in the global domain.

## Limits to know first

- Only **classified** data can be anonymized by a job.
- Personal data in logs and audit data is not anonymized.
- The overview page says only structured data is anonymized (not journal fields, comments, attachments). The field type table below nevertheless lists journal types as available, and the *data pattern anonymization* technique exists precisely for patterns inside free text. Treat free text as covered only by that technique (discrepancy within the docs).
- A single sign-on or directory integration can write the personal data back to `sys_user`: nothing makes the de-identification of users permanent.
- **Domain separation: no support** for Data Privacy (Data Classification, by contrast, is at the Enhanced level). See [[Domain Separation Support Levels by Application]].

## Field types that can be anonymized

| Available by default | Not available by default |
|---|---|
| `currency`, `decimal`, `due_date`, `float`, `glide_date`, `glide_date_time`, `glide_time`, `integer`, `journal`, `journal_input`, `journal_list`, `longint`, `phone_number_e164`, `price`, `string`, `string_full_utf8` | `audio`, `condition`, `condition_string`, `glide_duration`, `html`, `icon`, `ip_addr`, `ip_address`, `name_values`, `percent_complete`, `translated_html`, `translated_text`, `url`, `user_image`, `video`, `wiki_text` |

The same list applies to Data Discovery. How the "not by default" types are switched on is not stated (?).

## Roles

| Role | Does | Elevated |
|---|---|---|
| `data_privacy_admin` | creates techniques and policies; real time protection and tokenization policies. Granting it requires `security_admin` | yes |
| `data_privacy_processor` | creates and runs jobs on the User (`sys_user`) table | yes |
| `data_privacy_clone_processor` | creates and runs data class (post-clone) jobs | yes |
| `data_privacy_auditor` | read only | no |
| `now_assist_data_privacy_admin` | AI prompt channel policies | ? |
| `virtual_agent_data_privacy_admin` | Virtual Agent sensitive data detection | ? |

Elevation: [[Explicit Roles and Elevated Privilege Roles]]. Discovery and classification roles are in their own notes.

## The store app dashboard

**All > System Security > Data Privacy > Overview** (path as far as the pages show; the store app's sections are Overview, Classification, Anonymization, Tokenization, Real time protection).

- Top metrics, for the last 7, 30 or 90 days or all time: records anonymized by job, records anonymized in real time, alert submissions, blocked submissions, quarantined attachments.
- Classification charts: classifiable data (classified against unclassified) and classified data per class.
- Anonymization per data pattern (real time and job based; only counted when the data pattern technique is used).
- Most frequent alerted and blocked patterns.

## What is switched on by default

For licensed Vault customers the store app arrives with two things already running:

| Default | What it does |
|---|---|
| **Alerting policy** | active on installation; watches **Work notes** (`work_notes`) and **Additional comments** (`comments`) on Task (`task`) for seven patterns (email, US social security number, date of birth, and Visa, Discover, American Express, Mastercard numbers). It only alerts and logs: nothing is blocked or changed, existing data is not scanned, and the patterns and fields cannot be changed (create your own policy for more) |
| **Discovery job** | runs once, automatically (trial activation, licence activation, or upgrade of the store app); a hidden *Sample* scan of journal and free-text fields on incident, requested item variables, catalog tasks, customer service cases, interactions and HR cases; read only; cannot be triggered or disabled by the customer; its policy is in the global scope and can be edited |

- Discrepancy: the summary page says the default job scans 10,000 random records; the job's own page says the first 1,000 records or the last 30 days, whichever comes first.
- Review both under **Data Discovery > Scheduled Discovery > Discovery Findings**, filtered by the default policy or job (role `data_privacy_admin`). Expect false positives; use the results as a sample, not an inventory.

## Related

- [[ServiceNow Vault and Otto for Vault]] · [[Security Center]] · [[Instance Clone Overview]] · [[Auditing and Record History]] · [[Find Sensitive Data with a Data Discovery Job]] · [[Anonymize a User with a Data Privacy Job]]
