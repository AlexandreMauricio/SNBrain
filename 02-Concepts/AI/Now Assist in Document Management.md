---
type: concept
tags: [concept, ai, workspace, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > ServiceNow Otto in Document Management (landing, Explore, Configure, Configure the smart documents skill, System property for Smart Documents skill, Use, Generate a document summary, Generate summary and ask questions, Generate an audio summary and interact through voice queries, Redact sensitive data from documents using AI, Add or modify redaction codes, Add or remove data patterns), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/now-assist-document-management.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Now Assist in Document Management

**In one line:** the **Smart Documents** generative AI skill: on an attachment opened in the document viewer of a workspace record, **Ask Otto** summarises it, answers questions, lists common questions, suggests redactions, and (with a separate Voice Assist skill) reads an audio summary and takes spoken questions.

From the Brazil docs; not tested. The Brazil pages brand it **ServiceNow Otto in Document Management**; the benefits table and older pages say **Now Assist in Document Management** (same feature, two names). Builds on [[Document Management]] and the [[Document Viewer, PDF Generation and Document Conversion]].

## Configure (`sn_nowassist_admin.nsa_admin`)

- From Zurich Patch 11 / Australia Patch 4 the skill is **on for all tables** by default; earlier patches had a different setup page (not given).
- **Now Assist Admin > Skills**, workflow **Platform**, **Smart Documents** skill > Edit: **Define Availability** (tables; empty = all tables), **Define access** (roles), **Select Display** (where it shows), Save and continue, Done.
- System property `glide.ui.seismic.attachment.dialog.renderInAppShell` = `true` to use the skill.

## Use

- Open a record in a workspace whose table has the skill (e.g. an incident), open the attachment in the viewer, select **Ask Otto** (the old Summarize button is now inside it): summary, key insights, questions and common questions, copy, thumbs up/down feedback.
- Limits for summary and Q&A: **10 MB**, **200 pages**; pdf, docx, pptx, xlsx, doc, ppt, xls, jpeg, png.
- **Voice Assist for docs** skill (role `sn_voice_doc.user` plus admin-defined roles): Ask Otto drop-down > **Show Voice-Assist**: **Generate audio summary** with transcript, **Start Voice Q&A** (consent check box, microphone access, mute, live captions, End). Max **30 pages**. Uses Google's Gemini API (its terms apply).

## AI redaction

- Needs the skill on the table and **write** access on the parent record. Limit **20 pages or 500,000 characters** by default; PDF only (the sentence is cut off on the page).
- Ask Otto > **Redact Document Content** (everything sensitive: e.g. passwords, dates, names) or a category search ("redact all the emails"); pick items; accept AI-suggested **redaction codes** (several per item allowed; verify them); preview; save. Audit: `ds_redaction_audit_log.list`.
- Redaction codes: **Document Management > Administration > Redaction Codes** (`platform_document_management_admin`): code, description, Active.
- Detection patterns: **System Security > Data Privacy > Privacy Policy Advanced Configuration** > *Document Redaction-sn_doc_gen_ai* > **Select Data Patterns** ([[Data Privacy Channel Policies - AI Prompts, Inbound Email and Virtual Agent]]).
- Manual redaction (no AI) is described in [[Document Management]].

Data leaves the instance for a central ServiceNow AI environment, and inputs and outputs are collected unless opted out (standard Now Assist terms).

## Related

- [[Document Management]] · [[Otto for ITSM Skills and Agentic Workflows]] · [[Agentic AI Security and Governance]]
