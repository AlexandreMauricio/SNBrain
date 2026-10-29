---
type: concept
tags: [concept, integrations, flows, api, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > Document Services > Multi Provider Document Services Framework (landing, Explore, Activate, Integrate with Document Services, Microsoft OneDrive integration, Document Services Framework for Microsoft OneDrive, Setup Microsoft OneDrive for Document Services, Register Microsoft OneDrive as an OAuth provider, Google Drive integration, Document Services Framework for Google Drive, Set up Document Services framework for Google Drive, Personal authentication and its 3 tasks, Using (provider details, document actions, provider permissions, configure permissions), Installed with, Framework roles), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/document-management-services/mp-document-services-framework-landing.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Multi Provider Document Services Framework

**In one line:** plugin **Multi Provider Document Services Framework** (`com.snc.multiprovider_documents`, MPDSF) that links documents in the instance with **Microsoft OneDrive / SharePoint** and **Google Drive**: copy, version, restore, delete, upload and co-author, with every provider operation done by an Integration Hub **subflow** that the framework maps to a **document action**.

From the Brazil docs; not tested. Used by [[Document Management]] (Connect With External Provider, Attach from Provider, Upload to Cloud) and by the Document Viewer collaboration options ([[Document Viewer, PDF Generation and Document Conversion]]).

## Tables and roles

| Label | Name | Holds |
|---|---|---|
| Multi Provider Document | `mp_document` | documents connected to a provider |
| Multi Provider Document Version | `mp_document_version` | their versions |
| Multi Provider Document Activity | `mp_document_activity` | log of actions on documents and versions (troubleshooting) |
| Multi Provider Collaborators | `mp_collaborators` | provider users (synced from Azure / the Google domain) |
| Multi Provider Detail | `mp_provider_detail` | configured providers |
| Multi Provider Document Action | `mp_document_action` | action ↔ subflow |
| Multi Provider Permission | `mp_provider_permission` | permissions the provider offers |
| Multi Provider Permission Configuration | `mp_permission_configuration` | role or group mapped to provider permissions (the page says "from the `mp_permission` table"; unconfirmed whether that is a separate table or means `mp_provider_permission`) |

Roles: `mp_document_admin` (providers, document actions, subflows; contains nothing) and `mp_document_user` (create, update, delete provider documents).

## Setup

1. `admin` activates `com.snc.multiprovider_documents` in **System Applications > All Available Applications > All** (global domain when domain separation and delegated admin are on).
2. Install the provider spoke from the Store (Integration Hub subscription required):
   - **Microsoft OneDrive Spoke for Document Services Framework** (latest v1.2.2; "built for" V1.1). Depends on Complex Object, IHUB Spoke Util Pack, MPDSF, Remote Directory Sync, Flow Designer Dynamic Inputs, IntegrationHub Action Step REST and Runtime. Also set up the **Microsoft Entra ID** spoke (older pages: Azure AD spoke) and the OneDrive spoke.
   - **Document Services Framework for Google Drive** (built for V1.0, "may be compatible with Utah and later"): needs the Google Drive, Google Directory and Google Docs spokes set up first.
3. OneDrive OAuth ([[OAuth 2.0 Outbound - The Instance as OAuth Client]]): register a custom app in Azure (redirect `https://<instance>.service-now.com/oauth_redirect.do`), keep the application ID, add a client secret, grant Microsoft Graph permissions `Files.Read`, `Files.Read.All`, `offline_access`, `Files.ReadWrite`, `Files.ReadWrite.All`, `AuditLog.Read.All`, `Directory.AccessAsUser.All`, `Directory.Read.All`, `User.Read`. Then **System OAuth > Application Registry > New > Connect to a third-party OAuth Provider**: Client ID `<CLIENT_ID>`, Client Secret `<CLIENT_SECRET>`, grant **Authorization Code**, authorization URL `https://login.microsoftonline.com/common/oauth2/v2.0/authorize` (unlock, edit, lock), token URL `.../oauth2/v2.0/token`; save and add the five `Files.*` / `offline_access` scopes in **OAuth Entity Scopes** (the registry step lists only those five, the Azure step nine).
4. Optional **personal authentication** (each user's own OneDrive or Google account instead of one shared connection): activate the Personal Authentication Dashboard ([[Personal OAuth Authentication and Web Embeddables Sessions]]); users with `sn_personal_auth.personal_auth_user` go to **IntegrationHub > Personal Authentication > Personal Integrations** and select **Authenticate** on the *Microsoft OneDrive Spoke Credential* or *Google Drive Spoke Credential* tile.

## Configuration (`mp_document_admin`)

Under **Multi Provider Document > Admin**:

- **Provider details**: name, provider, attributes (name/value). Saving creates the document actions and provider permissions automatically. (The page's navigation step says *Permission Configurations*; unconfirmed, probably the Provider Details module.)
- **Document Actions**: action name, provider permission, **Subflow**, provider details, description.
- **Provider permissions**: permission name, description, provider details, attributes.
- **Permission configuration**: entity type and entity (role or group), documents role, provider group attributes, permissions granted.

## Subflows (samples, in the spoke scope)

- **OneDrive V1**: Add Collaborator To Group, Collaborate Document (also With Recipient Type), Connect Document From OneDrive Using Path, Copy OneDrive Document Version, Create Document (creates `mp_document` and a version), Create Group, Delete Document, Delete Document Version, Get All Document Version, Get Document from OneDrive, Restore Document Version, Sync Collaborators (scheduled job **Sync Collaborators**, default On Demand), Delete Collaborator Record, Update Document Content, Upload Large File (max **60 MB**), Get Latest URL, Reconnect Document. **V2** versions of most of these plus Remove / Update Document Collaboration; V2 subflows only work on documents attached through Create Document V2 or Connect Document V2.
- **OneDrive actions**: Delete document (and versions), Look up Target Record Existence, Look Up Incremental Files and Folders (hierarchical search), Look up Sites Based On Query String Stream, **Update Delta Token** (system property `deltaToken`).
- **Google Drive**: Create Document (folder ID) and Create Document V1 (shareable folder URL; for shared drives trim it to `https://drive.google.com/drive/folders/<folder ID>`), Create Group, add collaborator, add permission (user, group, domain or anyone), Connect Document using ID or V1 (shareable URL), Copy version, Delete, Get All Versions, Get Document, Get Document Latest URL, Get Oldest Document Version, Reconnect, Sync Collaborator, update content. Actions include Look Up Files and Folders (no hierarchical search), Copy File Revision as Attachment, Copy Doc File / Revision to Attachment, Get File Type Info.

Connections use Integration Hub aliases ([[Connections, Credentials and Aliases]]); the alias properties are listed in [[Document Management]].

## Related

- [[Document Management]] · [[Spoke Generator]] · [[Personal OAuth Authentication and Web Embeddables Sessions]]
