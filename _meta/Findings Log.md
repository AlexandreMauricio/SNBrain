---
type: meta
tags: [meta]
status: documented
source: own, kept by every contributor (started 2026-11-06)
updated: 2026-11-06
---

# Findings log

One line per finding that **changed, corrected or contradicted** a note, or that other contributors should know, newest first. How and when: [[Improvement Loop]]. Instance labels come from [[Instances]]; no client names.

| Date | Who | Source / instance | Note | Finding | Evidence | Propagated to |
|---|---|---|---|---|---|---|
| 2026-11-06 | Claude | Brazil API reference | [[Flow Administration, Execution Details and Access]] | Quick flow runs: the Workflow Studio guide says they always run as System; the API reference adds `asUser()` and `withRoles()` for `quick()` | docs, two pages disagree | kept as unconfirmed variants in the note |
| 2026-11-06 | Claude | Brazil API reference | [[GlideDateTime Formatting Recipes]] | Team notes' `gdt.localTime` is on no API page; `GlideFilter` is documented and case-sensitive; `GlideUpdateManager2` and `SNC.UserCriteriaLoader` have no API page; `GlideDate.getByFormat()` time zone still unsettled | docs | [[Force Records into an Update Set]], [[GlideRecord API Reference]], [[Service Catalog Overview, Item Types and Roles]], [[Attachments]] |
