---
type: how-to
tags: [how-to, integrations, api, users, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Identity (chapter read in full 2026-10-08) - Activating the SCIM plugin, Tutorial - Configure SCIM for user provisioning with a Provider, Provisioning user using Basic Authentication, Provisioning user using OAuth, SCIM Troubleshooting, Exploring SCIM Provider. https://www.servicenow.com/docs/r/platform-security/identity/configure-scim-for-user-provisioning-with-azure-ad.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Set Up SCIM Provisioning into the Instance

**Goal:** let the company identity provider create, update and deactivate users and groups in the instance through the SCIM API.
**Prerequisites:** role `admin` to install; an integration user with role `scim_admin`; administrator access to the identity provider.
**Navigation:** All > System Applications > All Available Applications > All; All > System OAuth > Application Registry; All > System Web Services > REST API Access Policies

Background: [[SCIM Provider - Provisioning Users and Groups into the Instance]].

## Steps

1. Install the plugin **SCIM v2 - ServiceNow Cross-domain Identity Management** (`com.snc.integration.scim2`). OAuth 2.0, REST API Provider and REST API Access Policy must be active too.
2. Create the integration user and give it `scim_admin` (a powerful role: treat the account like an administrator).
3. **OAuth:** open **System OAuth > Application Registry > SCIM API**. Note the client id, set the client secret and the **Redirect URL** the identity provider will use.
4. **REST API Access Policies > SCIM API Policy**: in *Authentication Profiles* confirm *SCIMAPIOAuthOnly* is present and its **OAuth Entity** is the *SCIM API* record. (For basic authentication instead, confirm *SCIM API Basic Auth*, type Basic Auth.)
5. In the identity provider, configure its ServiceNow or generic SCIM provisioning with the instance's SCIM base URL, the client id, secret and endpoints (or the integration user's credentials for basic authentication).
6. Run the provider's **test connection**, then provision one test user and one test group before switching on the full scope.

## Result / how to check it worked

The test user appears in **User Administration > Users** with the attributes sent; changing the user in the identity provider updates the record; what happens when the assignment is removed depends on the provider's settings (not described on these pages).

## Example

Identity provider *Example IdP*, integration user `scim.integration` with `scim_admin`, OAuth through the *SCIM API* application registry with redirect URL `https://idp.example.com/oauth/callback`, base URL `https://<instance>.service-now.com/api/now/scim`. Assigning *Test User* and *Example Group* to the ServiceNow application in the provider creates both in the instance within the provider's sync cycle, and *Test User* is a member of *Example Group*.

## Tables / fields involved

- User (`sys_user`), Group (`sys_user_group`), Group Member (`sys_user_grmember`)
- Application Registry (`oauth_entity`; table name from earlier notes, not from these pages)

## Gotchas

- A redirect URL, client id or secret that differs by a character between the two sides is the usual cause of failure.
- The enterprise SCIM schema (`urn:ietf:params:scim:schemas:extension:enterprise:2.0:User`) is accepted but not stored: map such attributes through the ServiceNow or a custom extension schema.
- Attributes with no matching column need an extension schema and ETL mapping, or scripts.
- With more than one identity source, create source definitions so external ids do not collide.
- Decide which system owns users: running SCIM and an LDAP import for the same population makes them overwrite each other (my caution, not from the docs). See [[LDAP Integration]].
