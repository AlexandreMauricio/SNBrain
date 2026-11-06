---
type: meta
tags: [meta]
status: documented
source: own (started 2026-11-06)
updated: 2026-11-06
---

# Instances

Registry of the ServiceNow instances contributors have worked in, so a note or exercise can say where something was seen, and a later session can tell what an instance already holds.

**Naming:** use the **Label** in notes, never a URL. A personal developer instance is `pdi-<n>`; a client instance gets an **alias** (`client-A`, ...). Never write the client's name or instance URL anywhere in the vault; the contributor keeps the mapping privately.

**Release:** every row records the release family and patch in **bold** (e.g. **Brazil Patch 2**) with the date it was read. `test-queue.ps1` reads the bold value to find notes written for a newer release. Update it when the instance is upgraded.

Add a row the first time a contributor names a new instance. Under **Known state**, record what it has, lacks or labels differently when it matters for later work, with the exercises built there.

| Label | Kind | Release | Contributor | First seen | Known state | Exercises built there |
|---|---|---|---|---|---|---|
| `pdi-1` | personal developer instance from the ServiceNow Developer site, temporary (random, not kept) | **Brazil Patch 1** (build tag glide-brazil-08-25-2026__patch1-09-21-2026, build date 10-05-2026; read 2026-11-06) | Alexandre | 2026-11-06 | Next Experience on; used once to test keyboard shortcuts. Being temporary, it holds nothing to rely on later; a new PDI gets a new label | none |
