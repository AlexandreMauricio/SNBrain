---
type: concept
tags: [concept, knowledge, integrations, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Configuring > Configure Knowledge Management - Add-in for Microsoft Word (Activate, Deploy, Configure the security, Enable downloading of the source Microsoft Word document), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/configure-km-add-in-word.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Management Add-in for Microsoft Word

**In one line:** an Office add-in (plugin `com.snc.knowledge.ms_word`, scope *Knowledge Management - Add-in for Microsoft Word*, prefix `sn_km_word`) that lets authors write and publish knowledge articles from inside Word.

From the Brazil docs; not tested. Importing Word files into articles without the add-in is a separate feature (Word document importing).

## Setup

1. `admin` activates `com.snc.knowledge.ms_word` (it activates its dependencies).
2. **Deploy** (`admin` or `sn_outlook_addin.outlook_addin_setup`, plus Office 365 administrator): **ServiceNow Add-Ins for Office > Office Add-In-Manifests** > *Knowledge Management* > **Download Manifest**. The steps on the page then install it from **Outlook** (Get Add-ins > My add-ins > Add a custom add-in > Add from file > `manifest.xml` > Install, tile *ServiceNow for Knowledge Management*), which reads like text copied from the Outlook add-in page; how it reaches Word is unconfirmed.
3. **Security**: property `sn_km_word.glide.knowman.word.xframe` = comma-separated parent domains of Word Online, e.g. `https://<site>.sharepoint.com,https://<site>-my.sharepoint.com,https://word-edit.officeapps.live.com`. Used for the `X-Frame-Options` and `Content-Security-Policy` headers; wrong values = the add-in does not load (KB0860916).
4. Optional: `sn_km_word.glide.knowman.enable_document_download` = true lets readers download the source `.docx` from the article view page in portals and workspaces; the file may then show in search as an attachment and affect relevance.

## Authoring in Word

- Works with Word Online (Office 365; SharePoint, OneDrive, Box and similar). Users need contribute access; the login page says role `agent` (unconfirmed for others). An admin must create a **Restricted Caller Access Privileges** record for the add-in to publish (detail cut off on the page).
- Log in: open Word from the Microsoft 365 launcher, **Home > Knowledge** icon, **Log in to ServiceNow** (new tab with instance login). Re-login when the session expires.
- Knowledge Management pane: search by number or description, browse bases (read or contribute access), open articles. Template-based articles open in the instance instead (they cannot be edited in Word).
- **Create Article**: base, category, ownership group, title (100 characters), **Document URL** (generated only for SharePoint and OneDrive business accounts; otherwise paste the sharing link, e.g. a Box Shared Link, not the browser address), Valid to, scheduled publish date; write in the document; **Submit** (then publish per the base flow). Share the document URL for co-authoring. Page headers and footers are copied into the article; conversion time grows with document size.
- **Edit** (latest version only): pick the article, **Replace** (load article into the document) or **Retain** (keep the document; it overwrites the article on save); edit online or in desktop Word (then save from the online version), **Save**, **Publish**. Scheduling and **Recall** (Review → Draft, +0.01) work from the pane too.
- Word-authored articles can only be edited through Word (Open in Word). If the document is moved or deleted, enter the new **Document URL** or use **Unlink from Word** (related link, `admin`), which may disturb the HTML formatting.

## Related

- [[Knowledge Management Overview]] · [[Knowledge Workflows and Article Lifecycle]]
