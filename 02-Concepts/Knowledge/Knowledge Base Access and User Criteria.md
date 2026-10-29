---
type: concept
tags: [concept, knowledge, access-control, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Configuring > Managing access to knowledge bases and knowledge articles (Create user criteria, Control access at the knowledge base level, Control access at the knowledge article level), User criteria diagnostics for Knowledge Management (Diagnose user access to a knowledge base / an article, Configure access for unauthenticated users, Collect knowledge usage metrics, Modify the data retention policy for knowledge usage metrics), and Exploring > Scoped knowledge bases, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/user-access-knowledge.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Base Access and User Criteria

**In one line:** who may **read** or **contribute** (create, edit, retire) knowledge is set with [[user_criteria]] records in four lists on each knowledge base (**Can Read**, **Cannot Read**, **Can Contribute**, **Cannot Contribute**) and two fields on each article (**Can Read**, **Cannot Read**); roles on articles are the old KM v2 way.

From the Brazil docs; not tested. Knowledge base setup itself: [[Knowledge Bases and Categories]].

## Rules

- "Cannot" wins: matching both Can and Cannot denies. Can Read on the base plus Cannot Read on the article denies that article.
- Contribute access to a base includes read access to all its articles, **unless** `glide.knowman.apply_article_read_criteria` = true, in which case article-level Can/Cannot Read also limit contributors (knowledge base owners and managers then may not see such an article in portal search; ownership group members always can).
- **No criteria set** on a base: decided by `glide.knowman.block_access_with_no_user_criteria`:
  - `true`: nobody reads or contributes except special users (and contributors for read).
  - `false`: **everyone, including unauthenticated users, can read**; anyone with at least one role can contribute (with explicit roles: at least one role other than `snc_internal`).
- Article roles: with no contribute access, a user must meet **both** the article roles and the user criteria to read. Add the property `glide.knowman.search.apply_role_based_security` = false (not present by default) to rely on user criteria only.
- **Special users** (not evaluated by criteria): `knowledge_admin` (everything, except scoped knowledge bases), knowledge base **owner** and **managers** (that base; with versioning on, managers cannot edit other authors' drafts), **ownership group** members (their articles: read, edit, approve, retire).
- **Explicit roles** (`com.glide.explicit_roles`, e.g. with CSM): new knowledge bases get *Users with 'snc_internal' role* in Can Read and *Users with snc_internal and another role* in Can Contribute. Existing bases are not changed on upgrade; run the fix script **Fix unsecured knowledge bases** ([[Explicit Roles and Elevated Privilege Roles]]).

## User criteria for knowledge

**Knowledge > Administration > User Criteria** (`user_criteria_admin` plus a knowledge role): users, groups, roles, companies, locations, departments, **Match All** (all filled fields must match instead of any), optional **Advanced** script. Script tips from the page: it runs in the criteria's scope; results (and role evaluation) are cached per session, so a change needs a new login; use the predefined `user_id` variable, not `gs.getUser()`; scripts cost performance. Criteria do not apply to elevated privilege roles.

Attach: knowledge base form related lists (Edit to add existing as `knowledge_manager`/`knowledge_admin`/`admin`, New as `admin`); article form **Can Read** / **Cannot Read** fields (latest version only; may need form layout; then Update and Publish). Log out and in after changes.

## Scoped knowledge bases

A knowledge base created while an application is selected in the application picker gets that **Application** (scope). Only users with that application's admin role **and** `knowledge_admin` can administer it, and access comes from the app's own ACLs on the knowledge tables, so even `admin` and `knowledge_admin` are kept out unless criteria allow (e.g. payroll articles in an HR scope). Existing bases cannot change scope. The page mentions a `glide.enforce_security...` property (name cut off) needed for Scope Master tables to run scoped ACLs (unconfirmed full name). See [[Application Scope and Namespace Identifiers]].

## Diagnostics

- **Knowledge > Administration > User Criteria Diagnostics** (or the **Run User Criteria Diagnostics** related link on a base or article; `knowledge_manager`, `knowledge_admin` or `admin`; comes with `com.snc.knowledge3`): pick a user and a knowledge base or article, **Diagnose**: domain access (admins only see domain detail), which criteria grant read/contribute, which role grants it, what to change to grant access.
- Related link **View knowledge bases accessible to unauthenticated users**; fix with criteria or `glide.knowman.block_access_with_no_user_criteria` = true.
- Usage metrics: scheduled job **Knowledge Usage Metrics** (inactive; Periodically, 60 minutes, matching `glide.knowman.usage_metrics_duration`) fills `kb_usage_metrics` (article views, page views, portal searches); clean with **System Maintenance > Table Cleanup** on `kb_usage_metrics` (Age in seconds default 2,592,000 = 30 days; `maint` and `admin`) ([[Table Cleaner]]).

## Related

- [[user_criteria]] · [[Knowledge Bases and Categories]] · [[Knowledge Portal and Search]] · [[Access Control Lists (ACLs)]]
