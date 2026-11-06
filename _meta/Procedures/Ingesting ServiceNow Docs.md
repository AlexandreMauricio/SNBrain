---
type: meta
tags: [meta]
status: documented
source: own, adapted from the sister vault HALO ITSM and the earlier SN Brain CLAUDE.md (2026-11-06)
updated: 2026-11-06
---

# Ingesting ServiceNow docs

Read when the user gives a ServiceNow docs URL, a guide is to be read, or release notes, team notes or a PDF are shared. Run the "Check before you write" loop in [[CLAUDE]] first, in particular the [[Docs Reading List]] lookup, so nothing is ingested twice.

## Fetching

1. **Prefer the docs site API**, which answers plain HTTP without a browser: guides at `https://www.servicenow.com/docs/api/khub/maps`, a guide's table of contents at `.../maps/<mapId>/toc`, a topic's HTML at `.../maps/<mapId>/topics/<contentId>/content` (strip the tags). Map IDs of the guides already used are in [[Docs Reading List]] ("Fetching notes").
2. If that fails, use the **built-in browser**, not WebFetch: the docs and developer sites render with JavaScript, so WebFetch returns only a title. Open the URL, wait a few seconds, read the page text.
3. Note the **release family** (from the URL or the page's "Release version") for `sn-release`. Behaviour changes between releases.
4. Large guides: read overviews, administration, roles and reference pages, then the rest on demand, and name the skipped pages in `source:`.

## Writing

1. **Summarise in our own words** (never paste the article), one topic per note, `status: documented`, page titles, URL or map and read date in `source`. Community posts and blogs are `unverified`.
2. **Prefer editing an existing note.** Check names against the vault first (tables, roles, properties), and write only what is missing.
3. **Discrepancies** (two spellings, two defaults, two roles, docs that disagree with themselves) are recorded side by side as unconfirmed variants, each with its source, and mentioned to the user. Never call one a typo.
4. **If the docs contradict a `verified` note**, flag it and keep both. Never overwrite verified with documented.
5. **Propagate:** run `impact.ps1 -Range "<first commit>~1..HEAD"` on the batch, check every exercise and recipe it lists, add *Since written* lines where affected, and [[Findings Log]] lines for anything that changed or contradicted a note ([[Improvement Loop]]).
6. **Record the pages** in [[Docs Reading List]] (processed table, and linked pages still to read).

## Release notes and PDFs

The same loop applies. A file with no URL goes in `source` and in [[Docs Reading List]] by its title and read date; don't commit the file itself.

## Reporting a batch

Say what was read and what was skipped, which notes were **created** and **updated** (with status), and which variants or contradictions were found. During ingestion nothing is answered from notes, so there is no "used" list.
