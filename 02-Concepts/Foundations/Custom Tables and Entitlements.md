---
type: concept
tags: [concept, platform, schema, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 463-464, 473, 479, 521), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Custom tables and entitlements

**In one line:** a custom table is one an administrator created (not part of the base system or a plugin); the number you may create is limited by the custom table entitlements in your subscription.

## How it works

- Custom table names start with `u_` in the global scope and with the scope namespace (`x_...`) in a scoped application. Remote tables add `st_` (`u_st_` in global).
- Entitlements for custom tables come with certain subscription licences. Some free Store applications also consume unallocated entitlements; the listing says how many.
- Custom tables in the global scope must be **mapped to a product subscription** in Subscription Management to stay compliant.
- **Many-to-many tables are not custom tables** and do not count toward the allotment.
- Create only the tables you need: extra tables add administration work and lengthen upgrades.
- Extending Choice (`sys_choice`) is not supported.

## Related

- [[Create a Table]] · [[Delete a Custom Table or All Records in a Table]] · [[Tables, Records and Table Relationships]]
