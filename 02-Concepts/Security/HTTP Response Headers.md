---
type: concept
tags: [concept, security, admin, portal]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > HTTP Response Headers (overview and Configure HTTP response headers), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/http-response-header.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# HTTP Response Headers

**In one line:** the **HTTP Response Header** table (`sys_response_header`) adds name-value response headers (for example `Content-Security-Policy: frame-ancestors ...` or `Cache-Control`) to all pages or to one Service Portal, UI page or UX application, without code.

From the Brazil docs; not tested. Custom headers can weaken the security the platform otherwise applies, so add them with care. Check the result in the browser developer tools (Response Headers).

## Configure

Type `sys_response_header.list` in the navigator > New:

| Field | Meaning |
|---|---|
| Active, Application | |
| **Applies to** | **All Pages** (needs elevated `security_admin`) or **Specific Type** (`admin`) |
| **Type** | Service Portal (`sp_portal`), UI Page (`sys_ui_page`) or UX Application (`sys_ux_page_registry`) |
| **Document** | the specific record (keep the table name the Type set) |
| **Name**, **Value**, Description | the header pair |

The granular role `response_header_admin` also manages these records ([[Granular Admin Roles]]).

**Order and Add by** (list columns): all matching headers (all-pages and specific) are merged and sorted by **Order**. **Add by** = **Append** (default: same-name headers are all sent) or **Overwrite** (a higher-order header replaces a lower-order one with the same name). Use Overwrite with a higher order on a specific page when an all-pages header with the same name would otherwise be added too.

Kill switch: `glide.http.headers_config.enabled` (default true; hardening item, [[Hardening Settings - API, Architecture, Communications and Configuration]]); false ignores every record in the table.

## Framing (clickjacking) headers

- The platform normally sends `X-Frame-Options: SAMEORIGIN` (property `glide.set_x_frame_options`, default true, [[System Properties Reference]]).
- A page configured with `Content-Security-Policy: frame-ancestors 'self' <url1> <url2>` (to allow framing by named third-party sites) no longer gets the automatic `X-Frame-Options` header, so browsers are not confused.
- For Internet Explorer (no `frame-ancestors` support) the platform sends `X-Frame-Options: ALLOW-FROM <url>` instead: the referrer if it matches one of the listed hosts (full or `http://*.example.com` wildcard), else the first non-wildcard host.
- No trailing slash on the URLs: `frame-ancestors 'self' https://partner.example.com`, not `.../`.

## Example

Specific Type, Type UI Page, Document *example_status_page*, Name `Content-Security-Policy`, Value `frame-ancestors 'self' https://intranet.example.com`, Order 200, Add by Overwrite.

## Related

- [[High Security Settings]]
