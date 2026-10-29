---
type: concept
tags: [concept, admin, instance-admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > Document Services > Document Viewer (overview, Enable, Plugins, Enable accessibility features for DOCX to PDF conversion, View attachments, Disable) and PDF generation and accessibility (overview, Export to PDF, Guardrails), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/document-management-services/Documentviewer.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Document Viewer, PDF Generation and Document Conversion

From the Brazil docs; not tested. Part of Document Services with [[Document Management]].

## Document Viewer

Shows attachments inside the platform instead of downloading them: Word (`.doc`, `.docx`), PowerPoint, Excel, PDF (UTF-8), PNG, JPEG (rotate, zoom), MP4. Max **50 MB**. Other types (zip, exe) just download; Office files are converted to PDF on first view (slower the first time). Toolbar: page thumbnails, download (PDF only), paging, rotate, zoom, fit width, search.

- Plugin **ServiceNow Document Viewer** (`com.snc.documentviewer`); "enabled by default" per the page, yet steps still say to install it (unconfirmed).
- Instance switch: system property `com.snc.documentviewer.enable_document_viewer` (true; create it with false to turn off).
- Per table: **System Definition > Dictionary**, the table's **Collection** record, attribute **Use Document Viewer** = true (false to turn off for that table).
- Use: **View** next to the attachment name. Falls back to download for platform- or Edge-encrypted files ([[Edge Encryption Overview]]), files over 50 MB, or password-protected non-PDFs.
- DOCX → PDF accessibility: `com.snc.document.conversion.accessibility_enabled = true`.
- Collaboration add-ons: Microsoft OneDrive Spoke, OneDrive document service spoke, Microsoft Azure AD Spoke and the [[Multi Provider Document Services Framework]] (edit in OneDrive / SharePoint, bi-directional; actions as subflows in the Document actions table). The page links the Rome plugin list.

## PDF generation and accessibility

- Accessible PDFs (tags for screen readers): add `com.snc.pdf.generation.accessibility = true`; then list or form **Export > PDF** offers an **Accessible PDF** check box (bigger files). Not for on-premise instances. API: `PDFGenerationAPI` (scoped and global).
- Orientations: Portrait, Landscape, Detailed Portrait, Detailed Landscape (detailed = list plus each record's form). See [[Exporting Data]] and [[Export Limits and Properties]].
- `com.snc.pdf.html2pdf.image_re...` (name cut off on the page): image retrieval timeout in seconds for HTML-to-PDF.
- **Static guardrail**: `com.snc.pdf.generation.maxsize_mb` (default 30); raising it too far can crash the node.
- **Dynamic guardrail**: `glide.robustness.memory_guard_enabled` (false), `glide.robustness.memory_guard_thresholdpercentage` (90, 1-100), `glide.robustness.memory_guard_time` (60, 1-900; unit not stated, likely seconds); above the threshold, running PDF exports are stopped and new ones refused until memory drops.

## Related

- [[Document Management]] · [[Managed Documents]] · [[Exporting Data]]
