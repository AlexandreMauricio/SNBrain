---
type: concept
tags: [concept, integrations, flows, security, admin, scripting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Connections and Credentials (read in full 2026-10-08 through the docs site) - Connection & Credential configuration templates, Configure a template for OAuth JWT Bearer grant type (Docusign example), Create a configuration template, Set up OAuth integration via MID Server. The long JSON samples are reduced to their structure. https://www.servicenow.com/docs/r/platform-security/connections-and-credentials/spoke-configuration-template.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Connection and Credential Configuration Templates

**In one line:** a template attached to an alias turns the many records an integration needs (OAuth provider, profile, scopes, JWT key and provider, credential, connection, plus rows in the spoke's own tables) into **one dialog** that an admin or flow designer fills in.

From the Brazil docs. Aliases, connections and credentials themselves: [[Connections, Credentials and Aliases]]. The OAuth records a template creates: [[OAuth 2.0 Outbound - The Instance as OAuth Client]].

- Table: Connection & Credential Templates (`sys_alias_templates`); shipped examples for the common authentication types.
- Create: `admin`, **IntegrationHub > Connections & Credentials > Configuration Templates > New**. Use: `admin` or `flow_designer`, on the alias: **Create New Connection & Credential** (or the Connections Dashboard: alias > **View Details** > **Configure**).

## Template types

| Type | For |
|---|---|
| HTTP Connection with OAuth Authorization Code grant type | registers the other system as OAuth provider; the dialog can also fetch the token |
| HTTP Connection with OAuth JWT Bearer grant type | signed-token exchange, no user |
| HTTP OAuth with Client Credentials grant type | client id and secret |
| HTTP Connection with OAuth Client Credentials grant type (External Storage) | the same with the secret in a vault, sent through a MID Server ([[External Credential Storage and CyberArk]]) |
| HTTP Connection with Basic Auth Credential | |
| HTTP Connection with API Key Credential | |
| Other Configuration | blank, for custom authentication |

## Parts of a template

| Field | Purpose |
|---|---|
| **Default Data Template** | JSON of fixed values. Each top-level object creates a record: `credential` (required; nested objects such as `oauth_entity` with `oauth_entity_profile` and `oauth_entity_scope`, `jwt_provider` with `jwt_keystore_aliases` and `jwt_claim_validation`; `table` names the credential table, for example `oauth_2_0_credentials`), `connection` (required; `table` for example `http_connection`, `connection_url`, `use_mid`, and `extended_attributes` for connection attributes), `additional` (optional data for custom tables) |
| **Dynamic Data Schema** | JSON describing what the user is asked: arrays `connection_fields`, `credential_fields`, `additional_fields`; each entry has `name` (dot-walked path into the default data, for example `connection.connection_url` or `credential.oauth_entity.client_id`; array items by zero-based index, for example `credential.jwt_provider.jwt_claim_validation[0].value`), `label`, `type`, optional `defaultValue` and `hint` |
| **Post Processing Script** | server-side script run after the connection and credential exist, typically inserting rows in the spoke's own tables. Available variables: `aliasId` (sys_id in `sys_alias`), `connectionSysId`, `jsonDefaultData`, `jsonDynamicData` (both JSON strings) |
| **Pre-Edit Script** | server-side script run when an existing connection is edited; returns an array of `{name, value}` objects that pre-fill the additional fields. Same four variables |
| **Test Action** | an action definition used to test the alias from Workflow Studio |

Field types in the schema: text, boolean, number, date (`yyyy-mm-dd`), choice, reference, file, and **radio** groups (a `groups` array, each with its own `fields`; one group may be `default_group`; only the selected group's fields are shown).

Rule for the authorization code template: the values under `oauth_entity_profile_scope` and `oauth_entity_scope` must match.

Then attach it: open the alias, set **Configuration Template**, update.

If pre-filled values do not appear when editing: **System Diagnostics > Session Debug > Debug Log**.

## Example: post-processing script

Server side, runs in the template's application scope after the records are created. Invented table and field names:

```javascript
(function execute(aliasId, connectionSysId, jsonDefaultData, jsonDynamicData) {
    var input = JSON.parse(jsonDynamicData);
    var account = new GlideRecord('x_example_spoke_account');
    account.setValue('alias', aliasId);
    account.setValue('account_name', input['additional.account_name']);
    account.insert();
})(aliasId, connectionSysId, jsonDefaultData, jsonDynamicData);
```

## OAuth token requests through a MID Server

When the authorization server is only reachable from inside the network (Integration Hub standard pack needed):

1. Template of type **HTTP Connection with OAuth Client Credentials grant type**; put the scope in `oauth_entity_profile_scope` and `oauth_entity_scope`.
2. An alias of type *Connection and Credential* using that template.
3. **IntegrationHub > Connections Dashboard**: find the alias > **View Details** > **Configure**: **Connection URL**, **Use MID** with the MID selection, **OAuth Client ID**, **OAuth Client Secret**, **Connect to Auth Server via MID Server**, **OAuth Token URL**; then **Configure and Get OAuth Token**.

## Related

- [[Connections, Credentials and Aliases]] · [[Create a Connection and Credential Alias]] · [[External Credential Storage and CyberArk]] · [[OAuth 2.0 Outbound - The Instance as OAuth Client]] · [[Spoke Generator]]
