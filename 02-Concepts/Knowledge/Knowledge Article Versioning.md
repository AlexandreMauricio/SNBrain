---
type: concept
tags: [concept, knowledge, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Exploring > Article versioning; Using > Use article versioning (Manually update customized files, Check out a published article and create a new version, Revert an outdated article to the current state, View all versions, Compare two versions, Retire a versioned article, Disable the article versioning feature), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/article-versioning.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Article Versioning

**In one line:** with Knowledge Management Advanced and `glide.knowman.versioning.enabled` = true (default), editing a published article means **Checkout**: a new `kb_knowledge` record with the **same number** and a version +0.01 in Draft; publishing makes it the next whole version and turns older ones **Outdated**.

From the Brazil docs; not tested. Lifecycle around it: [[Knowledge Workflows and Article Lifecycle]].

## Actions on the Knowledge form

| Action | Who | Effect |
|---|---|---|
| **Checkout** (from Knowledge > Articles > Published) | owner, knowledge manager, knowledge admin | new Draft version (+0.01), attachments copied with relative paths updated (older versions may need a fix script; name not given); Valid to reset from the base's Article Validity. Not offered while another version is checked out |
| **Publish** | | version becomes next whole number (e.g. 2.02 → 3.0), listed in **Article Versions** |
| **Make this current** (on an Outdated version) | `knowledge_admin` or the base's `knowledge_manager` (ownership group rules may apply) | copies it as a new Draft numbered latest + 0.01 (e.g. current 3.0, revert 1.0 → 3.01) |
| **Recall** | | pulls back an article in review or scheduled for publish |
| **Compare** (Article Versions list action) | `knowledge_manager`, `knowledge_admin` | side-by-side fields incl. body; Agent Workspace has a better compare |
| **Retire** | knowledge admin, manager and the latest publisher (not `kcs_candidate` / `kcs_contributor`) | no new version; state **Pending retirement** (if approval retire) then Retired, older versions Outdated. Not while checked out. Retired articles are not searchable by external users; reuse = new article with the same content |

Only the author who checked it out, the base owner and `knowledge_admin` can edit a Draft version (base managers cannot edit other authors' drafts). Readers see major versions; contributors see minor ones too. Outdated articles attached to incidents still open by `sys_id`.

**Replacement on retire** (since Utah, `glide.knowman.enable_article_replacement_on_retire`, default true): pick a replacement article; opening the retired one shows "retired and replaced with KB…" (HTTP 301), without a replacement "not found" (404).

## Properties

- `glide.knowman.versioning.enabled`: **Knowledge > Administration > Properties**, *Article Versioning Properties*. Turning it off removes the Version field, Article Versions list, Recall / Checkout / Make this current buttons, Outdated rows and version history; articles still get versioned in the background (minor numbers until publish).
- Minor edits without a new version: `glide.knowman.versioning.enable_minor_edit` (name cut off on the page; unconfirmed) plus `glide.knowman.versioning.minor_edit_fields` (e.g. Valid to, Meta).
- Articles imported from an instance without versioning need the fix script **Initialize Versions on Articles** before checkout works.
- The article number shown includes the version; references by number open the latest version.

## After activating KM Advanced on a customised instance

Customised files are skipped by the installer; by hand: add **Version** to the Knowledge form and list, add choice value `outdated` to the **Workflow** field (keep that value), add *Revised by is (dynamic) me* to the filters of **Knowledge > My Flagged** and **Self-Service > My Knowledge Articles**, and fix any customised Knowledge Management Overview dashboard reports.

## Related

- [[Knowledge Workflows and Article Lifecycle]] · [[Knowledge Article Templates and Knowledge Blocks]] (blocks version the same way)
