---
type: concept
tags: [concept, scripting, javascript, security, forms-lists]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > Write client-side scripts, topics "UI scripts", "UI pages and macros", "UI pages", "UI macros", "Jelly tags", "Jelly escaping types", "Extensions to Jelly syntax", "HTML syntax editor", https://www.servicenow.com/docs/r/api-reference/scripts/create-custom-ui-pages.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# UI scripts, UI pages, UI macros and Jelly

**In one line:** the Core UI's custom-page toolkit: **UI scripts** (`sys_ui_script`) hold reusable browser JavaScript, **UI pages** (`sys_ui_page`) are Jelly templates that render whole pages or dialogs, **UI macros** are reusable Jelly components; for new custom interfaces the docs point to Service Portal (and today UI Builder) instead.

## UI scripts

- **System UI > UI Scripts**: **API Name** (e.g. `x_custom_app.HelloWorld`), **Application**, **UI Type**, **Active**, **Global** (loads on every form; slows pages; not allowed in scoped apps), **Description**, **Script**.
- Not supported on mobile or in Next Experience.
- Use from: a formatter whose UI macro has `<g:requires name="<UI script>.jsdbx" />`; HTML `<script src="<API name>.jsdbx">`; client code through `g_ui_scripts` (not for Global UI scripts).

## UI pages

- **System UI > UI Pages**: **Name** (no spaces; URL `<name>.do`, or `x_<scope>_<name>.do` in a scoped app), **Direct** (no standard HTML, CSS and scripts), **HTML** (static XHTML or Jelly, can call script includes and macros), **Client Script** (browser), **Processing Script** (server, runs when a `<g:ui_form>` / `<g:form>` is submitted; form fields are available as variables), related lists **Access Controls**, **Versions**. Can be dashboard widgets.
- URL parameters become Jelly variables: `?sysparm_verbose=true` gives `${sysparm_verbose}`. `sys_id` is reserved for the page itself; use `sysparm_id`. Scripts passed by URL parameter are no longer evaluated (`glide.security.disable_ui_pages_sysparm_client_script` = false re-allows it temporarily).
- Security: protect with an ACL of type `ui_page`, operation read, name = page name (a role picker appears on save, needs security_admin elevation; `glide.ui_page.enable_acl_create_ux` turns it off). **High-risk** pages (no ACL, GlideRecord / GlideDBQuery instead of **GlideRecordSecure** in HTML or processing script, listed in `sys_public`) show a warning (`glide.script.ui_page.customer_scoped.security_msgs_enabled`).
- Processing script pattern for a dialog: update a record, then `response.sendRedirect(GlideSession.get().getStack().bottom())` (global apps only).

## UI macros

- **System UI > UI Macros** (`sys_ui_macro`, the docs also write `ui_macros`): **Name**, **Active**, **Description**, **XML** (Jelly). They power formatters, the catalog cart, field icons, CMS widgets.
- Use: `<g:macro_name attr="..."/>` in a page or macro (attributes arrive as `jvar_<attr>`), or dictionary attribute `ref_contributions=<macro>` to add an icon next to a reference field.
- `ui_`-prefixed macros imitate field types inside UI pages, e.g. `<g:ui_date_time name="due_date" value="..." onchange="..."/>`; they support only some features.
- If a new macro does not show, clear the cache with `<instance>/cache.do`.

## Jelly essentials

- Jelly turns XML into HTML on the server. Namespaces `j`/`g` run in **phase 1** and are cached (except in UI pages); `j2`/`g2` run in **phase 2**, never cached. `${...}` inserts a value in phase 1, `$[...]` in phase 2. Use `copyToPhase2="true"` on `g:evaluate` to pass a phase-1 result on.
- Tags: `j:if` (no else), `j:choose` / `j:when` / `j:otherwise`, `j:while`, `j:set`, `j:set_if`; `g:evaluate` (server JavaScript; last line is the value; `object="true"`, `jelly="true"` to read `jelly.` variables), `g:messages` (cache translations), `g:breakpoint` (dump variables to the log), `g:no_escape` (unescaped output: XSS risk), `g:macro_invoke`, `g:if_polaris` with `g:then` / `g:else` (Next Experience or not).
- Escaping: JavaScript strings with backslashes, HTML with entities; Jelly offers escape prefixes such as `$[NLBR:...]` and `$[AMP]` (see the docs' escaping table).
- The HTML field has its own syntax editor (HTML and Jelly).

## Related

- [[Client Scripts]] · [[Scripting Overview - Script Types and Where They Run]] · [[Cart, Checkout and Cart Layouts]] (cart macros) · [[UI Builder Overview and Concepts]]
