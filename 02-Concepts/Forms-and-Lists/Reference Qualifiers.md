---
type: concept
tags: [concept, reference-field, encoded-query, scripting, script-include]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Reference qualifiers" (pp. 981-988), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Reference qualifiers

**In one line:** a reference qualifier filters the records a reference field offers (in the lookup and in type-ahead), e.g. only active users or only groups the assignee belongs to.

## Three kinds

| Kind | What you enter | Use when |
|---|---|---|
| **Simple** | conditions in a condition builder (up to 13) | plain AND/OR filters: active is true, role is X |
| **Dynamic** | a **dynamic filter option** (stored, reusable filter: encoded query, JavaScript or script include) | the same filter is needed on several fields, or for people who do not write code. Changing the option changes every qualifier using it. List them: **System Definition > Dynamic Filter Options**, filter *Available for ref qual is true* |
| **Advanced** | an encoded query string, or `javascript:` returning one | a one-off filter that conditions cannot express |

Rules:

- **One qualifier per field per table.** Defined on the dictionary entry, it applies to the table and all its children; a [[Dictionary Overrides|dictionary override]] changes it for a child table and below only.
- **Not a security control.** To restrict what users may access, use ACLs.
- Not applicable to condition builders.
- Simple is available in the default view of the dictionary form; Dynamic and Advanced only in the Advanced view.

## Advanced qualifier forms

```text
vendor=true
```

```javascript
javascript:"company=" + current.company
javascript:'u_active=true^' + "u_hr_service=" + current.hr_service
javascript:new ExampleScriptInclude().exampleRefQual()
```

- `current` is the record open in the form; dot-walk through it (`current.assigned_to.email`).
- A function used as a qualifier must **return an encoded query string**.
- The guide's good practice: call a **script include**, not a global business rule.

## The INSTANCEOF operator

`sys_class_nameINSTANCEOFcmdb_ci_server` matches the class **and all its subclasses**. It replaces long OR lists of `sys_class_name=...`:

```text
u_active=true^sys_class_name=cmdb_ci_acc^ORsys_class_nameINSTANCEOFcmdb_ci_computer^ORsys_class_name=cmdb_ci_appl
```

## Related lists

When the same field is edited from several related lists on one form, give each list a **List edit tag** in its list control. The tag is available to the qualifier script as `listEditRefQualTag`:

```javascript
if (listEditRefQualTag == "application") return "sys_class_name=cmdb_ci_appl";
if (listEditRefQualTag == "database") return "sys_class_name=cmdb_ci_database";
```

## Related

- [[Configure a Reference Qualifier]] · [[Reference Fields]] · [[Dictionary Entry Form]]
