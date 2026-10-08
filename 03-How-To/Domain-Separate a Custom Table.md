---
type: how-to
tags: [how-to, domain-separation, schema, business-rule, scripting, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Domain separation for service providers (chapter read in full 2026-10-08) - Domain-separate a custom table, Add a domain field to a table, Domain assignment, Installed with domain separation (the Domain business rules on task). The docs give the business rule logic only as pseudo-code; the script in the example is our own sketch of it and is untested. https://www.servicenow.com/docs/r/platform-security/bp-ds-custom-table.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Domain-Separate a Custom Table

**Goal:** make the records of a custom table belong to domains, so tenants see only their own rows.
**Prerequisites:** role `admin`; domain separation active with a default domain defined; a way to derive the right domain for each record (usually a company or user reference on the record).
**Navigation:** `<table name>.list` > list header > Configure > List Layout

Concepts: [[Domain Separation Overview]]. Do **not** do this to base system tables that ship without a domain field.

## Steps

1. Open the table's list, right-click the header > **Configure > List Layout**. Under *Create new field* enter name `sys_domain` (type **Domain ID**) > **Add** > **Save**. The name is reserved: the platform creates the column without a `u_` prefix, labels it **Domain**, and adds `sys_domain_path` automatically.
2. Decide how the domain is set. With no business rule, a record simply takes the current domain of the user who creates it. For anything better, add a *before* insert/update business rule modelled on *Domain - Set Domain - Task*: take the domain from the record's company.
3. Add a second rule with a higher **Order**, modelled on *Domain - Default - Task*: if the domain is still empty (global), take it from the user the record is for; failing that, the default domain.
4. If the table has child or related records (attachments, emails, approvals, your own child tables), add an *after* update rule modelled on *Domain - Cascade Domain - Task* that copies a changed domain to them, so they stay visible in the new domain.
5. For a table holding configuration that should flow down to child domains and be overridable, also add `sys_overrides`.

## Result / how to check it worked

Create a record as a user of one tenant domain: **Domain** shows that tenant. A user of another tenant does not see it; a provider user above both does. Create one with no company: it lands in the default domain, not in global. The table appears under **Domain Separated Tables**.

## Example

Table *Example Requests* (`u_example_request`) with **Company** (`u_company`, reference to Company) and **Requested for** (`u_requested_for`, reference to User). Business rule *Example - Set Domain*, table `u_example_request`, when *before*, insert and update, order 100; runs server side, global scope:

```javascript
(function executeRule(current, previous) {
    // sketch of the logic described in the docs; untested
    if (!current.u_company.nil() && !current.u_company.sys_domain.nil()) {
        current.sys_domain = current.u_company.sys_domain;
    } else if (!current.u_requested_for.nil() && !current.u_requested_for.sys_domain.nil()) {
        current.sys_domain = current.u_requested_for.sys_domain;
    }
    // otherwise leave it to a later rule that assigns the default domain
})(current, previous);
```

*Test User* of company *Example Customer* creates a request: its domain becomes *TOP/Example Customer*.

## Tables / fields involved

- The custom table: **Domain** (`sys_domain`, type Domain ID), `sys_domain_path` (generated), optionally `sys_overrides`
- Company (`core_company`), [[sys_user]]: source of the domain
- Model rules on [[task]]: *Domain - Set Domain - Task*, *Domain - Default - Task*, *Domain - Cascade Domain - Task* (check their **Order**)

## Gotchas

- Use the column **name** `sys_domain`, not a label; any other way of creating the field gives `u_sys_domain`, which does nothing.
- Never script against `sys_domain_path`: it changes when the hierarchy changes ([[Domain Separation Recommended Practices]]).
- A table can instead inherit its domain from a referenced record through the dictionary attribute `domain_master=<reference field>` (seen in the Domain Separated Tables list; the pages read do not describe how to set it up (?)).
- Existing rows are global until something sets their domain; plan a controlled back-fill in small batches.
- How the default domain's sys_id is obtained in a script is not shown in the pages read (?): copy the technique from the shipped *Domain - Default - Task* rule.
