---
type: how-to
tags: [how-to, data-management, integrations, security]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Exporting data", topic "Exporting your table records to Google Sheets" (pp. 673-687), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Set up export to Google Sheets

**Goal:** make **Export > Google Sheets** on lists write straight to a spreadsheet in Google Drive.
**Prerequisites:** role admin. A Google business account with a domain and an email address on it.
**Navigation:** Google Cloud Console, then All > System OAuth > Application Registry and All > Connections & Credentials

## Steps

**In Google Cloud Console**

1. Create a project.
2. Enable the **Google Drive API** for it.
3. **Create credentials** for **User data**; fill the OAuth consent screen (app name, support email, developer contact).
4. Add the scope `.../auth/drive.file`.
5. Create an OAuth client ID of type **Web application** with the authorised redirect URI `https://<instance>.service-now.com/oauth_redirect.do`. Download the JSON with the client ID and secret.
6. Under **OAuth consent screen > Audience**, choose **External** and add the user who will get access.

**On the instance**

7. **System OAuth > Application Registry > New > Connect to a third party OAuth Provider.** Fill **Name**, **Client ID**, **Client Secret**, **OAuth API Script** (`OAuthGoogleSheetExport`), **Authorization URL**, **Token URL**, **Token Revocation URL** and **Redirect URL** (values from the downloaded JSON).
8. On the registry record, add the scope `https://www.googleapis.com/auth/drive.file` in **OAuth Entity Scopes** and in **OAuth Entity Profile Scopes** of the default profile.
9. **Connections & Credentials > Connection & Credential Aliases > New**: a name (letters, digits, underscores), type Connection and Credential, connection type HTTP.
10. **Connections & Credentials > Credentials > New > OAuth 2.0 Credentials**: name, active, the **OAuth Entity Profile** from step 8. Reopen it and set **Integration Type** to **Personal**.
11. **Connections & Credentials > Connections > New > HTTP(s) Connection**: name, the credential, the alias, active, and **Connection URL** `https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id`.
12. Copy the **sys_id of the alias** (header context menu, **Copy sys_id**).
13. In `sys_properties.list`, create the string property `glide.oauth.export.to.sheets.alias` with that sys_id as value.

## Result / how to check it worked

Right-click a list column header: **Export > Google Sheets** creates a sheet in Drive with the list's rows and columns.

## Example

Alias `Sheets_Alias`, credential *Example Sheets Credential*, connection *Example Sheets Connection*, registry *Sheets Integration*.

## Tables / fields involved

- `sys_properties`: `glide.oauth.export.to.sheets.alias`
- `sys_connection` (Connections), plus the alias and credential records

## Gotchas

- Store the client secret only in the registry record, never in a note.
- Only one connection is active per alias at a time.
- A connection timeout of zero can leave a stale connection.
