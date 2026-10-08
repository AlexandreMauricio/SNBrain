---
type: concept
tags: [concept, instance-admin, security, portal, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Custom instance URLs (whole section, 7 topics, 301 cleaned lines, read in full 2026-10-08 through the docs site) - overview, activate, set as the instance URL, identity provider per URL, datacenter job information, SP metadata for SAML/SSO, errors and fixes. https://www.servicenow.com/docs/r/platform-security/authentication/custom-url.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Custom Instance URLs

**In one line:** an instance can answer on company-branded host names (for example `support.example.com`) besides `<instance>.service-now.com`; each custom URL can open a specific Service Portal and send users to a specific identity provider, and one of them can become **the** instance URL used in links the instance generates.

From the Brazil docs.

- Plugin **Custom URL** (`com.snc.customurl`; not the *Custom URL - Internal* one) and property `glide.customurl.enabled` = true. Role `custom_url_admin`.
- Not available on-premise or on developer instances. The URL must be public. At most 100 domains per instance.
- Only the owner of the domain can set it up: at the DNS provider, create a **CNAME** record pointing the custom host name to the instance's `service-now.com` name.

## Setting one up

**Custom URL > Custom URLs > New**:

| Field | Meaning |
|---|---|
| **Domain Name** | the fully qualified host name (the CNAME) |
| **Status** | *Active* once provisioned (certificate included). Usually about 30 minutes, up to six hours |
| **Service Portal** | portal opened for this host name |
| **Identity Provider** | identity provider users are redirected to (since Tokyo) |
| **Is Instance URL** | set with **Set as Instance URL**: this host name is then used in outbound links such as notifications. Only one at a time; the base URL keeps working |

Portal and identity provider together:

| Service Portal | Identity Provider | User opening the custom URL |
|---|---|---|
| empty | set | goes straight to that identity provider |
| set | set | opens that portal and is sent to that identity provider |
| set | set, but the user opens a different portal | is sent to the instance's auto-redirect identity provider, if any |

Each custom URL has a datacenter job (certificate provisioning): job id, last run, payload of domains, poll count, result, status.

## With SSO and OAuth

- SAML: the identity provider needs the service provider metadata for the custom host name: **Multi-Provider SSO > Identity Providers** > the provider > **Generate Metadata**. Some providers need a separate application per URL (one for the base URL, one for the custom URL).
- **Test Connection** on an identity provider record must be run while logged in through the URL that record belongs to.
- OAuth: register every custom URL as a redirect URL of the client application.
- Web Embeddables require a dedicated custom URL ([[Personal OAuth Authentication and Web Embeddables Sessions]]).

## Rules and errors

- **Removing: delete the custom URL record on the instance first, then the DNS entry.** Deleting DNS first blocks deletion of the records. Same order when changing a CNAME.
- `glide.servlet.uri` and `glide.proxy.host` are controlled by the feature once a custom URL is the instance URL: they cannot be edited, and must be empty before setting it.
- Only one request at a time: check **Custom URL Jobs** before submitting another.
- "CNAME record ... does not point to ..." or "Missing CNAME record": fix the DNS entry first.
- Removing the instance URL setting reverts links to the base URL; the host name keeps resolving while the CNAME exists.

## Related

- [[Email Architecture and Accounts]] · [[Adaptive Authentication]] · [[System Properties]]
