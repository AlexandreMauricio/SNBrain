---
type: concept
tags: [concept, knowledge, integrations, import-sets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Configuring > Integration with external knowledge sources (Activate the External Content Integration plugin, Define an external knowledge source, Import content from an external knowledge source, Open knowledge search results in source system, Sample configuration for integrating external knowledge content), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/knowledge-external-content-integration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge External Content Integration

**In one line:** plugin **Knowledge Management - External Content Integration** (`com.snc.knowledge.external_integration`, not active by default) pulls files from a **WebDAV** source (e.g. SharePoint) into a knowledge base on a schedule: one article per file, with the file attached, so all knowledge is searched in one place.

From the Brazil docs; not tested. Activating it also activates Centralized Connection and Credentials, Knowledge Management V3 and Knowledge Management Advanced Installer, and adds **Knowledge > Administration > External Knowledge Sources** and **External Knowledge Jobs**. For indexing external content in AI Search instead, see [[AI Search Overview]].

## Limits

- **Basic authentication only**; the endpoint must be publicly reachable (**no MID Server**).
- Each imported article is blank except the attachment; short description = file name. Infected files trigger a notification to `knowledge_admin` users and base owners.

## Setup

1. Basic auth on the external account; **Connections & Credentials > Credentials > Basic Auth Credentials** (invented example: *Example_Auth*); **Connection & Credential Aliases** with an HTTP connection whose URL is the WebDAV endpoint, optionally with a folder path appended ([[Connections, Credentials and Aliases]]).
2. **External Knowledge Sources > New**: name, **Target Knowledge Base**, **Connection Alias**; Save.
3. **Parameter** related list:

| Parameter | Default |
|---|---|
| Maximum size limit (in MB) for this source | 400 MB (processing stops when reached) |
| Maximum size limit (in KB) per file/content | 4000 KB (bigger files skipped) |
| Open search results in the original source system | false |
| Include / Exclude folders with names that match these regex patterns | comma-separated regex, e.g. `a.*,b.*` |
| Create / Do not create articles when file names match these regex patterns | e.g. `.*\.docx,.*\.pdf` |
| Maximum retry limit | e.g. 5 |

4. **Handler** tab: schedule the **Acquire** handler (WebDAV client) and the **Process** handler (customise it to set categories or metadata); **Run Scheduled Job**; follow progress under **Jobs** (`admin` or `knowledge_admin`).
5. Opening results in the source: parameter true, then override `getFileURL(fileObj)` in script include `KBWebDAVContentHandler` (server-side). `fileObj` offers `getName()`, `getPath()`, `getAbsolutePath()`, `getCreationDate()`, `getModifiedDate()`, `getContentType()`, `getSize()`.

## Example

Source **Example External KB** → base *Example IT Knowledge*, alias *Example_Account* pointing at `https://<external_site>/KnowledgeIT`, include files `.*\.pdf`, size limit 250 MB, run weekly.

## Related

- [[Knowledge Bases and Categories]] · [[Knowledge Management Overview]]
