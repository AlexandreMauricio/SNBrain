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
| 2026-11-06 | Claude | Brazil docs, Service Portal guide | [[Service Portal Overview and Configuration]] | CSS order: one page puts theme above Branding Editor colours, others put branding above theme; Usage Insights portal tracking: enabled by default on one page, not enabled on another; Sitemap Generator: plugin to activate vs in the base system (Knowledge note); search source pagination example declares `now_GR` but uses `gr` | docs, pages disagree | kept as variants in [[Service Portal Portal Record, Branding and Themes]], [[Usage Insights]], [[Service Portal SEO, Announcements and Usage Analytics]], [[Service Portal Search Configuration]] |
| 2026-11-06 | Claude | Brazil docs, Service Portal | [[Service Portal Widget Development]] | `$sp.log()`: troubleshooting page says it writes to `sp_log` for sp_admin/admin, option schema example says browser console; `$sp.getWidget()` first parameter is named sysID but every example passes the widget ID; team-note *nested widgets* = Brazil *embedded widgets* (inference) | docs, pages disagree | kept as variants in [[Service Portal Widget Misbehaves or Loads Slowly]] and the development note |
| 2026-11-06 | Claude | Brazil API reference | [[Flow Administration, Execution Details and Access]] | Quick flow runs: the Workflow Studio guide says they always run as System; the API reference adds `asUser()` and `withRoles()` for `quick()` | docs, two pages disagree | kept as unconfirmed variants in the note |
| 2026-11-06 | Claude | Brazil API reference | [[GlideDateTime Formatting Recipes]] | Team notes' `gdt.localTime` is on no API page; `GlideFilter` is documented and case-sensitive; `GlideUpdateManager2` and `SNC.UserCriteriaLoader` have no API page; `GlideDate.getByFormat()` time zone still unsettled | docs | [[Force Records into an Update Set]], [[GlideRecord API Reference]], [[Service Catalog Overview, Item Types and Roles]], [[Attachments]] |
