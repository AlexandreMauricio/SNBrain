---
type: troubleshooting
tags: [troubleshooting, data-integrity, fields]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Troubleshooting data lookup" (p. 856), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Data lookup rule not working

**Symptom:** a custom data lookup definition does not set the field, or sets it at the wrong moment.
**Cause:** usually one of the conditions below.
**Fix:**

1. Check the definition runs on the right events (**Run on form change**, **Run on insert**, **Run on update**) and is **Active**.
2. Check the matcher field is not **read-only**: users cannot change it, so no form-change event fires.
3. Check whether a **client script** changes the field: client scripts do trigger *Run on form change*, even on read-only fields, which can cause unexpected runs.
4. Check the **data in the matcher table**.
5. With **Exact lookup match**, make sure a row exists for **every** combination, including blanks. No matching row means the lookup fails.
6. Look for a **recursive rule**: if A = 1 then B = 2, and if B = 2 then A = 2.
7. Check the definition is on the actual table of the record: definitions are not inherited from a parent table.

## How to confirm the cause

Reproduce on a form while changing one matcher field at a time, and compare with the rows of the matcher table.

## Related

- [[Data Lookup and Record Matching]] · [[Create a Custom Data Lookup]]
