---
type: concept
tags: [concept, security, data-management, schema, domain-separation, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy > Data Classification (chapter read in full 2026-10-08) - Data Classification landing, Exploring Data Classification, Installing plugin demo data (and components installed), Creating data classifications, Assigning data classifications to dictionary entries, Analyzing data classifications, Domain separation and Data Classification; and the store app pages Data classification, Create data classifications, Classify data. https://www.servicenow.com/docs/r/platform-security/data-classification/exploring-data-classification.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Data Classification

**In one line:** a data classification is a label (Public, Internal, Confidential, Restricted, PII, or your own) attached to **dictionary entries**, that is to table columns, so you can see where sensitive data lives and so that anonymization knows what to act on.

From the Brazil docs. Part of [[Data Privacy Overview]]. The plugin Data Classification (`com.glide.data_classification`) is active automatically from Brazil; nothing is classified until you do it or load the demo data.

## How it works

- Classification is **manual**: you pick columns and assign one or more classes. [[Data Discovery - Patterns, Policies, Jobs and Findings]] can propose columns (its findings have a **Classify** action).
- Classes live in Data Classification (`data_classification`) and can form a hierarchy through **Parent**.
- Each assignment is a row in Dictionary-Data Class (`m2m_dictionary_dataclass`), linking a Dictionary (`sys_dictionary`) entry to a class.
- **Inherited columns cannot be classified separately**: `incident.description` is the same dictionary entry as `task.description`, so it carries the same class. On a child table the inherited fields are not offered.
- Classification is metadata only; it protects nothing by itself. Anonymization policies select data by class ([[Data Anonymization - Techniques, Policies and Jobs]]).
- APIs for using the labels in your own logic: the Data Classification REST API, `DCManager` (global) and `ScopedDCManager` (scoped). Not documented in these pages.

## Demo data

Loaded by hand: **System Applications > All Available Applications > All**, find the plugin, the three-dot menu > **Repair** > tick **Load demo data** > **Repair** (role `admin`).

| Class | Meaning |
|---|---|
| Public | may be disclosed freely |
| Internal | not meant for the public |
| Confidential | compromise would hurt operations |
| Restricted | compromise would create financial or legal risk |
| Personally Identifiable Information | could identify a person |

It also assigns *Personally Identifiable Information* to these User (`sys_user`) columns: `name`, `first_name`, `middle_name`, `last_name`, `email`, `gender`, `photo`, `street`, `city`, `state`, `zip`, `country`, `home_phone`, `mobile_phone`.

## Doing it

| Task | Platform pages | Data Privacy store app |
|---|---|---|
| Create a class | **System Security > Data classification > Data classes > New**: **Classification Name**, **Description**, **Parent**, **Application** | **System Security > Data privacy > Classification > +Add data class**: **Class Name**, **Parent Class**, **Description** |
| Assign | `sys_dictionary.list`, tick the entries > **Actions on selected rows > Classify** (or **Clear classification**) > choose classes > **Classify** | **New**, choose the class, tick the table columns > **Classify data**; export to Excel, CSV, JSON or PDF |

- Assigning from the dictionary list **overwrites** the existing classes of the selected entries.
- Roles: `data_classification_admin` (set up and assign; contains the auditor role) and `data_classification_auditor` (review assignments). Both exist whether or not demo data is loaded.

## Overview dashboard

For administrators and auditors: a *Tables and columns* tab and a *Users* tab.

| Report | Source |
|---|---|
| Breakdown of classified data (donut, by class) | `m2m_dictionary_dataclass` |
| Total tables, Total columns, User reference columns | `sys_dictionary` |
| User count, User location count, Users by country (map) | `sys_user`, from each user's **Location** |

The user reports show which privacy regimes apply to your population.

## Domain separation

Supported at the **Enhanced** level: the class table is process separated, `m2m_dictionary_dataclass` is data separated. The domain separation page names the class table `sys_data_classification`, every other page `data_classification` (discrepancy; check `sys_db_object` on an instance). See [[Domain Separation Support Levels by Application]].

## Related

- [[Data Privacy Overview]] · [[Data Discovery - Patterns, Policies, Jobs and Findings]] · [[Data Anonymization - Techniques, Policies and Jobs]] · [[Dictionary Entry Form]]
