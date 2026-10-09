---
type: concept
tags: [concept, integrations, api, users, roles, import-sets, scripting, script-include, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Identity (whole chapter, 61 topics, 2,131 cleaned lines, read in full 2026-10-08 through the docs site). This note draws on - System for Cross-domain Identity Management (SCIM), SCIM Provider, Exploring SCIM Provider, Activating the SCIM plugin, Tutorial - Configure SCIM for user provisioning with a Provider (Basic Authentication, OAuth), SCIM Troubleshooting, SCIM customization, SCIM customization properties and schemas, Create a SCIM Extension schema, Create a SCIM ETL definition, Handling unmapped fields, Creating a source definition. The SCIM API reference itself is in the API documentation and was not read. https://www.servicenow.com/docs/r/platform-security/identity/scim-provider.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# SCIM Provider - Provisioning Users and Groups into the Instance

**In one line:** as a SCIM *provider* the instance exposes standard SCIM 2.0 REST endpoints that an identity provider (Entra ID, Okta and the like) calls to create, update, read and delete users and groups, an alternative to LDAP imports for keeping User (`sys_user`) and Group (`sys_user_group`) in step with the corporate directory.

From the Brazil docs. The opposite direction (the instance pushing identities out): [[SCIM Client - Provisioning from the Instance to Other Systems]]. Steps: [[Set Up SCIM Provisioning into the Instance]]. Directory import by LDAP: [[LDAP Integration]].

## Setup facts

- Plugin **SCIM v2 - ServiceNow Cross-domain Identity Management** (`com.snc.integration.scim2`); it relies on OAuth 2.0, REST API Provider and REST API Access Policy.
- Base path as shown in the docs' examples: `https://<instance>.service-now.com/api/now/scim` (the discovery endpoints `/ResourceTypes` and `/Schemas` are named in the docs; `/Users` and `/Groups` are the standard SCIM resource paths, not listed on these pages).
- The calling account needs role **`scim_admin`**. The docs warn it is equivalent to `admin` for this purpose: it can add and change personal data.
- Authentication is governed by the REST API access policy *SCIM API Policy* (**System Web Services > REST API Access Policies**), which carries two authentication profiles ([[Inbound API Authentication and API Access Policies]]):

| Profile | Use |
|---|---|
| *SCIM API Basic Auth* (type Basic Auth) | user name and password of the integration user |
| *SCIMAPIOAuthOnly* | OAuth; its **OAuth Entity** points to the application registry record *SCIM API* (**System OAuth > Application Registry**), whose client id, secret and redirect URL are given to the identity provider ([[OAuth 2.0 Inbound - The Instance as OAuth Provider]]) |

## Schemas

| Schema | Prefix | Content |
|---|---|---|
| `urn:ietf:params:scim:schemas:core:2.0:User` | none | core attributes, for example `name.middleName` |
| `urn:ietf:params:scim:schemas:extension:servicenow:2.0:User` | `servicenow` | ServiceNow-specific, for example `servicenow.manager.value` |
| `urn:ietf:params:scim:schemas:extension:servicenow:custom:2.0:User` | `custom` | your own attributes, for example `custom.socialId` |
| `urn:ietf:params:scim:schemas:extension:enterprise:2.0:User` | | **not persisted**: accepted without error but mapped to nothing |

## Customising the mapping

Role `scim_config_admin` (also warned as equivalent to admin: it can insert records past business logic and ACLs).

1. **SCIM > SCIM Extension schemas > New**: **Name**, **Resource Type** (User or Group), **Schema JSON**, **Active**, **Validate**. One active custom schema per resource type.
2. **ETL definition.** The shipped *SCIM User* and *SCIM Group* definitions do the mapping through the Robust Transform Engine (RTE; no vault note yet). In a definition: an entity `scim-user` for the incoming attributes and one for the target table, each with entity fields (path or column, coalesce, coercion action Create, Reject or Ignore), then an RTE entity mapping with field mappings between them.
   - An underscore in an incoming path is an equality filter: `email.type_work.value` means the value of the email whose type is *work*.
   - `[*]` collection fields are not supported in SCIM mapping.
   - RTE can also write to tables other than user and group.
3. Send the custom attributes in the request payload.

| Property | Meaning |
|---|---|
| `com.snc.integration.scim2.user.etl.definition.id`, `com.snc.integration.scim2.group.etl.definition.id` | which ETL definitions are used |
| `com.snc.integration.scim2.provider.customization.script.id` | script include that customises responses |
| `com.snc.integration.scim2.resolve.externalid.conflict` | with several identity sources, answer an external-id filter only with resources of the requesting source |
| `com.snc.integration.scim2.max.member.count` | maximum members |
| `com.snc.integration.scim2.string.field.length.validation.enabled` | reject over-long strings instead of truncating |
| `com.snc.integration.scim2.rte.verbose.logging.enabled` | verbose RTE logging |

## Attributes with no column to land in

Both scripts are server side.

**On write** (POST, PUT, PATCH): the RTE definition's `onBefore` / `onAfter` scripts. `sn_auth.SCIM2Util.getScimProviderCustomizationContext()` returns a context whose `scimResource` is the resource as sent (POST), as replaced (PUT) or as it stands after the patch (PATCH).

Adapted from the docs' sample with invented table and field names; not run.

```javascript
// RTE onAfter script of the SCIM User ETL definition (server side)
(function onAfter(source, target, importLog) {
    var ctx = sn_auth.SCIM2Util.getScimProviderCustomizationContext();
    var urn = new global.SCIMProviderCustomization().getCustomExtensionUrn('User');
    var badge = ctx.scimResource[urn].badgeNumber;
    if (!badge) return;
    var gr = new GlideRecord('u_example_badge');
    gr.addQuery('u_user', target.sys_user[0].sys_id);
    gr.query();
    if (gr.next()) {
        gr.setValue('u_badge_number', badge);
        gr.update();
    } else {
        gr.initialize();
        gr.setValue('u_user', target.sys_user[0].sys_id);
        gr.setValue('u_badge_number', badge);
        gr.insert();
    }
})(source, target, importLog);
```

**On read** (GET): a script include (global scope; only `admin` can create or view it) extending `SCIMProviderCustomization` and overriding `customizeUserResponse(context)` and `customizeGroupResponse(context)`; its sys_id goes into the customization property.

- Helpers: `getCustomExtensionUrn(type)`, `getServiceNowExtensionUrn(type)`, `getCustomExtensionNodeValue(type, context)`, `getServiceNowExtensionNodeValue(type, context)`, `setCustomExtensionNodeValue(type, context, value)`.
- Return the context when you changed it; if nothing is customised, leave the property empty.
- Whatever an `onAfter` script stored elsewhere must also be put back into `scimResource` by the response script, or PUT and PATCH see a stale resource and the client's response lacks it.

The docs' sample replaces a user's roles from the payload by deleting all `sys_user_has_role` rows first; weigh that against inherited roles before copying it (my caution).

## Several identity sources

**SCIM > Source Definition > New**: **Name**, **OAuth Entity** (the application registry the source authenticates with), **Identity Source** (its name). OAuth sources only. Every resource provisioned by that source is tagged with it, which lets two sources use the same external id without colliding (with the conflict property on).

## Troubleshooting

| Error at the identity provider | Check |
|---|---|
| invalid REST API URL | the URL against the REST API Explorer |
| no redirect URL / redirect URL differs | the redirect URL on the *SCIM API* application registry must equal the one the provider sends |
| invalid client secret or client id | must equal the application registry's values |
| connection test fails | the integration account's permissions |

## Related

- [[SCIM Client - Provisioning from the Instance to Other Systems]] · [[Set Up SCIM Provisioning into the Instance]] · [[LDAP Integration]] · [[Inbound API Authentication and API Access Policies]] · [[OAuth 2.0 Inbound - The Instance as OAuth Provider]] · [[Multi-Provider SSO - SAML and OIDC]]
