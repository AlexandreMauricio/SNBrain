---
type: concept
tags: [concept, admin, workflow, knowledge, roles, schema]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > Document Services > Managed Documents (Features, Concepts, Defining Document Workflow, Defining Document Parameters and its five pages, Domain separation, Plugin, Install plugin, Knowledge Document plugin, Installed with Knowledge Document plugin, Link documents to Knowledge articles, Create a document and its 14 task pages, and the 6 tutorial pages from Create a new managed document record to Upload a document as an attachment), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/document-management-services/r_ManagedDocumentFeatures.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Managed Documents

**In one line:** the older, lightweight document-control plugin **Managed Documents** (`com.snc.document_management`): document records with numbered **revisions**, check-out / check-in, review then sequenced approval, publishing, collections, and an optional push to a knowledge article.

From the Brazil docs; not tested. Not the same plugin as [[Document Management]] (`com.snc.platform_document_management`, `ds_` tables); both sit under Document Services. Viewing attachments: [[Document Viewer, PDF Generation and Document Conversion]].

## Tables

| Label | Name | Holds |
|---|---|---|
| Document | `dms_document` | the managed document (number, name, owner, reviewers, type, classification, audience, state, checked out by, revision settings) |
| Revision | `dms_revision` | each revision with its file; *variant:* the e-signature page names the revision table `dms_document_revision` (unconfirmed which is right) |
| Audience | `dms_audience` | `internal = Internal` (code INT), `external = External` (EXT) |
| Classifications | `classification` (no prefix, per the plugin page) | `public` (P), `restricted` (R), `confidential` (C); does **not** control access |
| Type | `dms_type` | `policy` (POL, name format Default Policy), `guideline` (GUI, Default), `procedure` (PROC), `contract` (CON; adds a **Contracts** related list) |
| Component | `dms_component` | name components (dot-walk path from the revision record) |
| Name format | `dms_name_format` | separator plus ordered components |
| Approval sequence | `approval_sequence` | approver sequences |
| Approval Rule | `dms_approval_rule` | conditions on `dms_document` that add approvers |
| Collection | `dms_collection` | user-made groups of documents |
| Knowledge Records | `m2m_document_knowledge` | document ↔ article (Knowledge Document plugin) |

Server-side, global scope: business rules **Update Document** (document state from revisions) and **Add Approvers**; script includes `DocumentManagement`, `DocumentManagementDB`, `DocumentManagementSecurity`, `DocumentManagementAjax`, `DocumentAttachmentAjax`, `DocumentRevisionWorkflowHelper`, `DocumentManagementApprovalMatcher`, `DocumentApproverHelper`, `DocumentManagementUtils`, `DocumentReferenceQualifiers`. Client script **Document type change** sets the default name format when the type changes.

## Parameters (`document_management_admin`)

Under **Managed Documents > Administration**: **Type**, **Classification**, **Audience** (name, code, label, order), **Components**, **Name Formats**, **Approval Rules**. Parameters only organise documents; access comes from roles plus each document's user and group permissions.

- **Name components**: value is a path relative to the revision, e.g. `document.name`, `document.type.code`, `document.audience.code`, `document.classification.code`; `revision` is special and becomes the revision number (auto-incremented or latest, per the document's setting).
- **Name formats**: components in order with a separator, e.g. type code + name + revision with `-` gives `POL-<Document Name>-1.0.docx`. Base formats include Default (name and revision, `_`), Default Policy, Development documentation (no separator), Development Sources, Intranet Improvement.
- **Approval rules**: name, Active, Condition, description, **Approvers** related list. Base rules: Internal policy (`type=Policy ^ audience=Internal`), Development policy (`type=Policy ^ department=Development`).

## Life cycle

1. **Managed Documents > Create New**: number (number maintenance), name, requested by, owner, reviewers, department, type, classification, audience, state, short description; **Revision Settings**: name format, revision format `0.x` or `0.0.x`, **Auto increment revision**. Related lists **User Permissions** and **Group Permissions** with Reader, Editor (upload new versions) or Owner. Approvers: additional actions **Add Approver** with a sequence number.
2. **Upload/Check In Revision** related link uploads the file (first revision, e.g. `<Name>_POL_0.1`).
3. **Submit Revision** (right-click the revision): stage **Awaiting Review**, name and parameters go read-only, document state **Active**. No reviewers = review skipped.
4. Review: the first reviewer to act decides; reject cancels the revision and notifies author and owner; the others become **No Longer Required**.
5. Approval through the legacy workflow **Document Management Default** (the overview page calls it the "Managed Documents workflow"; unconfirmed whether these are one workflow): sequences in ascending order, first to act in a sequence decides. No approvers = approval skipped. Final approval sets stage **Ready for Publishing**.
6. **Publish Revision** (`document_management_admin` or `document_management_user`): optionally edit the revision number; earlier revisions become **Retired** and their running workflows are cancelled.
7. Changes: **Check Out Document** (optionally download; one editor at a time), then **Upload/Check In Revision** with Check in ticked.

Header actions: **Copy Document** (latest revision only, name gets "Copy"), **Deactivate Document** / **Reopen Document** (state Inactive), **Rollback** (needs not checked out, Editor or Owner; makes a new revision from the chosen one), **Cancel** (no confirmation; state Cancelled). **Managed Documents > Document > My Collections** groups documents.

Different workflows per type or classification: build them in the legacy workflow editor with the parameters as conditions ([[Classic Workflow Overview]]).

## E-signature

Plugin Approval with E-Signature ([[Classic Approvals]]): users retype user name and password on Approve/Reject; not stored on the document. Add the revision table in **System Definition > e-Signature Registry** with **Enabled** (the page names it `dms_document_revision`, label Document Revision; see the table variant above).

## Knowledge Document plugin

`com.snc.knowledge_document` (activates Managed Documents) plus `com.snc.knowledge_advanced`; script includes `KnowledgeDocument`, `KnowledgeDocumentDB`; UI action **Link to Knowledge**. On a published document, fill the **Knowledge Settings** related list: **Behavior** (Always create record / Update existing record; fixed once chosen), Knowledge Base, Type (article template; read-only once the article exists), Valid to, short description. Then **Link to Knowledge**: the latest published revision is attached to the article. One article per document; revising does not update the article, link again. Needs `document_management_user` and `knowledge` and contribute access to the base and article.

## Roles and domain separation

| Role | Gives |
|---|---|
| `document_management_user` | open the app, create and search documents (reviewers and approvers need it, though they can also reach a revision from the approval record); still only documents shared with them |
| `document_management_admin` | administrative settings and parameters |

Activation by `admin`: **System Applications > All Available Applications > All**, Managed documents (`com.snc.document_management`), optional demo data. Domain separation: **No support** ([[Domain Separation Support Levels by Application]]).

## Related

- [[Document Management]] · [[Document Viewer, PDF Generation and Document Conversion]] · [[Classic Approvals]]
