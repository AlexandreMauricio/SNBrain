---
type: how-to
tags: [how-to, integrations, flows, security, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Connections and Credentials (read in full 2026-10-08) - Create a Connection & Credential alias, Create an HTTP(s) connection, Create connection attributes for IntegrationHub, Create and test your credentials, Basic authentication credentials. https://www.servicenow.com/docs/r/platform-security/connections-and-credentials/connection-alias.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Create a Connection and Credential Alias

**Goal:** give an integration (a flow action, a REST step, a spoke) one named alias that resolves to the right endpoint and login on each instance.
**Prerequisites:** role `admin` for the alias and the credential; `connection_admin` for the connection. The application scope selected in the application picker is the one the alias will belong to.
**Navigation:** All > Connections & Credentials > Connection & Credential Aliases

Background: [[Connections, Credentials and Aliases]].

## Steps

1. Pick the application scope first (the alias **ID** becomes `scope_name.alias_name`, or just the name in Global).
2. **Connection & Credential Aliases > New**: **Name** (letters, digits, underscores), **Type** = *Connection and Credential*, **Connection type** = HTTP. Right-click the header > **Save**.
3. **Connections & Credentials > Credentials > New**, choose the type (for example **Basic Auth Credentials**), fill **Name** and the login fields, submit.
4. **Connections & Credentials > Connections > New > HTTP(s) Connection**: **Name**, **Credential** (from step 3), **Connection alias** (from step 2), **Connection URL**, **Active**; tick **Use MID Server** if the target is only reachable from inside the network. Submit.
5. Optional: on the alias, related list **Connection Attributes > New** (label and type); then set the value on the connection's *Attributes* tab.
6. In Workflow Studio, open the action, and in the integration step's *Connection Details* choose the alias instead of typing the URL and credential inline.

Shortcut when the alias has a **Configuration Template**: related link **Create New Connection & Credential** creates the credential and connection from one dialog ([[Connection and Credential Configuration Templates]]).

## Result / how to check it worked

The alias shows the connection in its **Connections** related list. Testing the action in Workflow Studio reaches the endpoint. On another instance, only the connection and credential differ; the action is unchanged.

## Example

Alias `example_api` in scope `x_example_app` (ID `x_example_app.example_api`). Credential *Example API Basic* of type basic auth with an invented service account. Connection *Example API - Dev* with **Connection URL** `https://api.example.com/v1`, linked to both. Connection attribute *Page size* (integer) = 100, used as a query parameter data pill in the REST step. On the test instance a connection *Example API - Test* points at `https://api-test.example.com/v1` with its own credential.

## Tables / fields involved

- Connection & Credential Aliases (`sys_alias`): **Name**, **ID**, **Type**, **Connection type**
- Connection (`sys_connection`; here `http_connection`): **Credential**, **Connection alias**, **Connection URL**, **Active**
- Credentials (`discovery_credentials`)

## Gotchas

- Only **one active connection per alias** unless **Support Multiple Active Connections** is ticked; a credential can belong to only one active connection.
- Credentials and connections are data, not configuration: they are **not captured in update sets**, so create them on every instance (this is the point of the alias, which does travel with the application). The pages read do not say this in these words; it follows from the DevOps and clone notes in the vault that list these tables as preserved data (confirm on an instance).
- Never leave **Connection Timeout** at 0.
- In protected scopes (HR, Security Operations) the records are invisible from Global, even to `admin`.
- Passwords cannot be read back after saving.
