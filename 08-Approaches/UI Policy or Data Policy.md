---
type: approach
tags: [approach, ui-policy, data-integrity, fields]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration" (pp. 790-794) and "Field administration" (pp. 802-803, 847-851), read 2026-10-01. Comparison built from the guide's statements; none tested
sn-release: Australia
verified:
updated: 2026-10-01
---

# Mandatory or read-only fields: dictionary, UI policy or data policy

**Problem:** make a field mandatory or read-only, reliably.

## Options

### A. Dictionary (Mandatory, Read only option)
- **How:** [[Dictionary Entry Form]], [[Read-Only Field Options]]
- **Pros:** one setting, everywhere the field appears; from Australia, read-only can be made strict against scripts and APIs.
- **Cons:** unconditional. **Mandatory in the dictionary is not enforced for web services or background scripts.**
- **Status:** documented
- **Best when:** the field is always mandatory or always read-only.

### B. UI policy
- **How:** [[Create a UI Policy]]
- **Pros:** conditional; can also hide fields; view-specific; scripts.
- **Cons:** browser form only. Imports, web services and scripts bypass it.
- **Status:** documented
- **Best when:** guiding users on a form.

### C. Data policy
- **How:** [[Create a Data Policy]]
- **Pros:** conditional and enforced for every GlideRecord operation, imports, REST; can also act on the form (*Use as UI Policy on client*).
- **Cons:** cannot hide fields; no scripts; rejects non-compliant integration data, which must then be handled.
- **Status:** documented
- **Best when:** the rule must hold however the data arrives.

## Recommendation

For a business rule that must always hold, use **C** with *Use as UI Policy on client*, and add **B** only for visibility. Use **A** for unconditional cases. A UI policy can be converted to a data policy (and back) from a related link when it has no scripts, is global and does not set Visible.
