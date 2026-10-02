---
type: approach
tags: [approach, ui-policy, client-script, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topic "Using UI policies" (pp. 790-794), read 2026-10-01. Only the UI policy side is described in this guide; the client script side is limited to what the guide says in passing
sn-release: Australia
verified:
updated: 2026-10-01
---

# Mandatory, read-only or hidden fields: UI policy or client script

**Problem:** change how fields behave on a form depending on other field values.

## Options

### A. UI policy
- **How:** see [[Create a UI Policy]]
- **Pros:** no scripting for the common cases; the guide says to prefer UI policies "for faster load times"; reverse-if-false built in; can be view-specific and inherited.
- **Cons:** conditions come only from the condition builder; rechecked only on manual field changes.
- **Status:** documented
- **Best when:** the rule is "when these conditions hold, make these fields mandatory, read-only or hidden".

### B. Client script
- **How:** an onLoad or onChange client script using `g_form` (not covered in this guide; to be documented from another source).
- **Pros:** the condition can be scripted; can do things other than the three field states.
- **Cons:** code to maintain; slower form load according to the guide.
- **Status:** unverified here
- **Best when:** the condition cannot be expressed in the condition builder.

### C. UI policy with scripts
- **How:** **Run scripts** with **Execute if true / false** on the UI policy.
- **Best when:** mostly declarative, plus a small extra such as a message.

## Recommendation

Start with **A**. Move to **B** only when the condition needs code. Neither is a security control: use ACLs, data policies or dictionary read-only options ([[Read-Only Field Options]]) for rules that must hold outside the form.
