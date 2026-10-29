---
type: concept
tags: [concept, knowledge, forms-lists, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Using (Knowledge Management guide for users, Using the homepage of Knowledge Management v3, Search using Knowledge Management v3, Import a Word document (v3 and current), Request a knowledge base, Knowledge content migration from v2 to v3) and Creating and maintaining articles (Create, Edit, HTML editor functions and its 9 pages, Map related articles, Map catalog items, Move, Comment, Create knowledge from incident or problem, Create an article version by importing a Word document, Human readable URLs, Select a category, Associate with a taxonomy category, Authoring in Agent Workspace and its 17 pages, Create from a customer service case, Provide feedback), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/create-knowledge-article.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Create and Edit Knowledge Articles

**In one line:** contributors (any user with a role and contribute access to an active base) create articles from **Knowledge > Articles > Create New** (pick base, then template), fill the **Knowledge** form (`kb_knowledge`), and **Publish**, which follows the base's publish flow.

From the Brazil docs; not tested. States and approvals: [[Knowledge Workflows and Article Lifecycle]]. Versions: [[Knowledge Article Versioning]].

## Who

All users can read (subject to criteria); `knowledge`, `knowledge_manager`, `knowledge_admin`, `knowledge_coach`, `knowledge_domain_expert`, `knowledge_group_member`, `admin` or any fulfiller role (e.g. `sn_customerservice_agent`) can contribute where the base allows. Only `admin` can **delete** a published article. Anyone may ask for a new base: **Self-Service > Service Catalog > Can We Help You? > Request Knowledge Base**; if approved the requester becomes owner and the base starts **inactive**.

## Ways in

**Knowledge > Articles > Create New**, **Self-Service > Knowledge** (*Create an Article*), portal homepage overflow > **Create Article**, Agent Workspace (**Lists > Knowledge > All Articles > New**, `agent_workspace_user`), Microsoft Word ([[Knowledge Management Add-in for Microsoft Word]]), from a task (below), or Word import.

## Knowledge form

| Field (label, name where known) | Notes |
|---|---|
| Number (`number`) | auto; see duplicates in [[Knowledge Logs, Numbering and Extension Points]] |
| Knowledge Base (`kb_knowledge_base`), Category (`kb_category`) | one base per article; change base only if the template exists there; no category → shown under *(empty)* |
| Ownership Group | only with ownership groups on; with none set and approvals required, approval goes to the base owner/managers (the workspace page says knowledge administrators; unconfirmed) |
| Language, Parent | with i18n; Parent holds the first version of the base-language article |
| Scheduled publish date | approvals must finish before it |
| **Valid to** (`valid_to`) | default created + base Article Validity, else 2100-01-01; not shown in search after it (or, per the page, when empty); monthly expiry email. Two-digit year date formats cause trouble here |
| Confidence, Governance | KCS plugin only |
| Version, Workflow (`workflow_state`, read-only) | Draft, Review, Scheduled for publish, Published, Pending retirement, Retired, Outdated |
| Article type | HTML or wiki (Standard template only; wiki not in workspace, no blocks) |
| Source (`source`) | task the article came from |
| Attachment link | open the first attachment instead of the article from search links (zip several files) |
| Display attachments | list attachments under the text |
| Short description (`short_description`), Article body (`text`), Meta (`meta`, SEO keywords) | similar articles appear in **Knowledge results** if contextual search is on |

Related links and lists: **View Article** (preview, does not count a view), **Search for Duplicates**, an *SEO suggestions* message (h1, anchor and img fixes), related lists Feedback, Feedback Tasks, Approvals, Article Versions, Translated Versions (New only when translation tasks are off), Translation Tasks, **Related Articles** (`kb_2_kb`, manual order, shown before ML predictions), **Related Catalog Items** (`kb_2_sc`), Affected Products, Assigned Topics (taxonomy, Employee Center). Publishing an article readable by guests asks for confirmation ("may be visible to unauthenticated users").

## Editing rules

- **Knowledge > Articles** > Published or Unpublished > **Edit** (versioning: **Checkout**; only the latest version). Word-authored articles can only be edited in Word (**Open in Word**).
- With translation tasks on, the base of existing articles cannot be changed.
- Valid to on a new version or after a move: base Article Validity empty → keep the old date; otherwise updated date + validity. A changed dictionary default on Valid to overrides this.
- **Move**: change Knowledge Base (contributor access); an **Apply Default Values** dialog offers the new base's *Set default knowledge field values*. With versioning only the latest version moves; retire the old ones. The docs advise creating a new article instead.
- **Categories**: category picker; add (+) or rename (pen) if the base allows; Cancel does not undo renames.
- **Human readable URLs** (on by default from Brazil; upgrades enable them): `kb_article_view` page field **Human readable url structure** = `%short_descr` (also `%category`), property `glide.service_portal.enable_human_readable_urls` (`admin`, `sp_admin`).

## HTML editor (TinyMCE)

Spell check, word count, formatting (fonts, colours, lists, styles, **collapsible sections**, bookmarks, Word auto-format), **paste as text**, tables, images (upload), links, video (library, attachment or URL), source code view, full screen, **code sample** with syntax highlighting, **table of contents** from Heading 1-3 (standard template only; default Verdana 8pt, edit in source), find and replace (match case, whole words), **accessibility checker** (Repair / Ignore), undo/redo. The toolbar is configurable through TinyMCE attributes.

## From tasks

- Incident or problem: tick **Knowledge** on a resolved record and close it → draft article in the base named by `glide.knowman.task_kb`. With `glide.knowman.submission.workflow` = true a **submission** is created instead; someone with `knowledge` approves it in **Knowledge > Articles > Open Submissions** > **Create Article**. Problems: create a known error ([[Problem Management Overview and Lifecycle]]).
- Templates and table maps for incidents, CSM cases and HR cases: [[Knowledge Feedback, Ownership Groups and Article Quality]].

## Word import

- **Knowledge > Articles > Import Articles** (default since Madrid; role `knowledge`, contribute access): base, category, files (`.doc`/`.docx`, lowercase extension, several at once, not from mobile). Kept: titles, default headings (numbering dropped), images (attached and embedded), links (.docx only), bold, italic, underline, lists (bullets become dots), tables (no styling or borders). **Publish** check box only if *Show publish checkbox on the knowledge import pop-up* is on: then Review or Published per flow, otherwise Draft (v2 bases always Draft). Language = current session language.
- Old KM v3 homepage: drag files onto **Self-Service > Knowledge**; `glide.knowman.import.hide_import_functionality` hides its Import button.
- **Upload New Version** related link (`admin`, KM Advanced; Draft or Published standard HTML articles only, not templates or wiki): replaces the body with the file, optional **Copy Attachments**, creates a draft version for approval.

## Comments and feedback

- Portal: **Post a comment** / Reply with links, images, attachments (not for unauthenticated or `snc_external`-only users; virus scanned if antivirus is on); authors can delete their comment and its replies. Live Feed shows no HTML or hierarchy; KM v3 no HTML. With *Use Live Feed for Knowledge Feedback* on, comments show only in Live Feed. Pre-New York comments are not hierarchical.
- Workspace: **Flag Article** (creates a feedback task), 1-5 stars (`glide.knowman.feedback.enable_actionable_feedback_for_rating`), comments with likes and replies; owners and knowledge admins may delete any comment.

## Agent Workspace

Plugin `com.glide.core-ui-components` (brings `sn-component-workspace-knowledge`). Lists > Knowledge > All Articles / My Articles - Published / Unpublished; Create Article dialog (base + template, when versioning and templates are on); Agent Assist side panel to check for duplicates; attachments panel; Copy link, Download as Word, language and version pickers; article page shows base, category, read time, last updated, views (over `glide.knowman.view_age.days`), weighted average rating (carried to the next version). Not possible in workspace: wiki articles, creating categories (and, per the overview page, creating blocks, though the blocks pages describe doing it; unconfirmed).

## KM v3 homepage (legacy)

**Self-Service > Knowledge**, not customisable, published and unexpired only; sort by recent or views; `glide.knowman.show_number_on_categories` shows counts; attachment display in results by `glide.knowman.search.attachment` (snippet, link, none); wildcards via **Contextual Search > Search Contexts > Knowledge Base Search > Enable wildcard searches**; multi-language with `glide.knowman.enable_multi_language_search`. Moving v2 content to v3: change each article's base away from the default base and pick a category; old feedback is copied to `live_message`.

## Example

Contributor *Test User* creates *How to reset the Example VPN client* in **Example IT Knowledge**, category *Software*, How To template, Valid to one year ahead, maps related article *Example VPN Guide* and catalog item *Example VPN Access*, then Publish (Approval Publish sends it to the base managers).

## Related

- [[Knowledge Bases and Categories]] · [[Knowledge Article Templates and Knowledge Blocks]] · [[Knowledge Portal and Search]]
