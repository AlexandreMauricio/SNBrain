---
type: concept
tags: [concept, admin, workspace, domain-separation, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > Document Services > Document Management (Explore, plugin, Activate, Document security and access and the four sharing pages, Use, Document repository, Create a document record, Document versions, Compare versions, Download, Share a document link, Modify shared link access, Configure document permissions, Delete, Approval and publish process with its 7 tasks, Digital signature with CAC/PIV smart cards and its 6 tasks, Document references, Linking documents to a parent record, Document lists, Activity stream, Redaction, External content providers, Document Management in Workspace, References: components, roles, domain separation, granular admin roles), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/document-management-services/doc-management-landing.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Document Management

**In one line:** plugin **Document Management** (`com.snc.platform_document_management`, built on `sys_attachment`) that keeps **document** records with **versions** (file or URL), sharing permissions, review and approval before publishing, links to any other record, and optional sync with OneDrive, SharePoint or Google Drive.

From the Brazil docs; not tested. Part of **Document Services** with [[Document Viewer, PDF Generation and Document Conversion]], [[Managed Documents]] and Multi Provider Document Services Framework. AI summaries of documents: Now Assist in Document Management.

## Records

| Table | Holds |
|---|---|
| **Documents** (`ds_document`, extendable) | metadata: name, owner, reviewers, **Template** flag, department, type (guideline, policy, procedure, contract), classification (public, restricted, confidential), audience (internal / external, hidden by default), state (Draft, Submit, Review, Complete), **Default Version** (latest by default) |
| **Versions** (`ds_document_version`, extendable) | the file (attachment) or a URL, notes, version state |
| **References** (`ds_document_references`) | many-to-many link from a document to any record (the "parent" or "target" record) |
| **Lists** (`ds_document_lists`) and **List Entries** (`ds_document_list_entry`) | groups of **template** documents that get copied and linked to a target record together (e.g. new-hire paperwork); only through the `DocumentListService` API, not the UI |
| Permissions | `ds_document_user_can_access_mtom`, `_ug_` (groups), `_ur_` (roles), `_uc_` (user criteria) |
| **Permalinks** (`ds_document_permalink`) | public share links with expiry |

Modules under **All > Documents**: Documents, References, Lists, List Entries, Approval and Revision Rules, Administration > Document Configurations.

## Access

- The **owner** can do everything; changing the owner moves all rights (the old owner loses access unless shared).
- Ways in: **by referenced record** (whoever can see the parent record can see the document, if inherited access is on), **admin access**, **shared permissions** as Reader, Writer or Owner to users (any user can share with users), groups (`dm_user_group_read`), roles (`dm_user_role_read`) or user criteria (`dm_user_criteria_read`); sharing needs write access and the matching role (`dm_sharing_levels_user` contains all three).
- **Share** button (owner or writer, needs a default version): a **permalink**, permanent or expiring, publicly reachable **regardless of classification**; a property `com.snc.documents.perm...` (name cut off on the page) restricts which classifications may get permalinks. Deactivate or re-date links in the Permalinks related list.
- External cloud permissions per provider and table: **Documents > Administration > Document Configurations** (conditions, user fields, internal and external permissions).

## Versions, review and publishing

- Versions tab: new version (Attachment or URL), **Submit Version** starts review and approval, **Publish Version** after approval; publishing a new revision retires the previous published one.
- **Approval and Revision Rules** (`platform_document_management_admin` or `admin`): name, description, **Document Conditions**, Active; **Reviewers** tab and **Approvers** tab with **Sequence**. Reviewers/approvers added straight on the document are not added to the rule.
- Review: any one reviewer acting decides (a reject cancels; the others become No Longer Required). Approval: sequences in ascending order; within a sequence the first to act decides; no approvers = approval skipped. Approve in **Self-Service > My Approvals** (`approver_user`) or by email links.
- **Compare versions** (only `.doc`/`.docx`, same format): property `glide.documents.compare.enabled = true`, a UI Builder page from the template in a workspace, Versions tab **Compare**; redline summary and download.

## Linking and activity stream

- Add the **Documents** related list to a form (Configure > Related Lists) to create, upload versions, link existing, unlink (keeps the document), download (attachment versions only) or delete from the record.
- Activity stream: `glide.documents.journal.enabled = true` and `glide.documents.attach.fields` = journal fields such as `work_notes`.

## Workspace

A **Document Management** component in the workspace side panel: folders, file picker (workspace documents All / Owned by me / Shared with me, external cloud, local drive; one external file at a time), rename, edit metadata, track versions, manage permissions, send for approval (reviewers, approvers with sequence), publish. **Redaction** in configurable workspaces: Published or Draft PDFs, search a keyword or draw over an area, **Apply redaction**, **Save changes** (not text inside images; JBIG2 images not supported; split lines not caught).

## Smart card signing (CAC / PIV)

Store app **Document Template integration with Digital Signatures using Smart Cards** (`com.sn.dt-digital-signature-smart-card-integration`) with **Document Templates** (`sn_doc.admin`): PDF template with Signing type **Digital Signature Smart Cards**, participants, CA certificates in `sys_ca_certificate`, user certificates in `sys_user_certificate`, certificate-based authentication, Adobe Acrobat Reader opening downloads (download folder as Privileged Location). Signers use **Self-Service > My Document Tasks** or Employee Center: **Sign Document**, sign in Acrobat, send back, then **Validate Document**. Property `com.snc.pdfsigning.validation.method` = `common_name`, `email`, `any` (default) or `ignore`; optional `com.snc.pdfsigning.uri` for a custom signing domain.

## External providers

OneDrive, SharePoint, Google Drive through Multi Provider Document Services Framework (role `mp_document_admin`): tick **Connect With External Provider**, **Attach from Provider** (OneDrive folder path and file name; Google Drive file URL; or link the URL only), **Upload to Cloud** (optionally remove the file from the instance or do not store it), **Download from cloud** creates a version if changed. Properties `sn_docs_gdrive.google_drive.base_alias` / `current_alias`, `sn_docs_onedrive.one_drive.base_alias` / `current_alias` hold the personal and system connection aliases (`sys_alias`).

## Roles and domain separation

| Role | Gives |
|---|---|
| `platform_document_management_admin` | CRUD on documents and related tables, Lists and List Entries; contains `dm_sharing_levels_user` |
| `dm_sharing_levels_user` | `dm_user_role_read`, `dm_user_group_read`, `dm_user_criteria_read` |
| `document_admin` (granular admin) | properties, ACLs and ACL roles for PDF generation, conversion and viewer plugins, plus CRUD on documents, references, versions, lists, list entries |

Domain separation: **Standard** support per the Document Management page; *variant:* the domain separation support list puts "Document Services" under **No support** (unconfirmed which applies). Documents live in the creator's domain; parent-domain users see child-domain documents; versions, references and permissions follow the document's domain; known issue: a new owner from another domain may not see references to records they cannot access ([[Domain Separation Support Levels by Application]]).

## Related

- [[Document Viewer, PDF Generation and Document Conversion]] · [[Managed Documents]] · Multi Provider Document Services Framework · Now Assist in Document Management
