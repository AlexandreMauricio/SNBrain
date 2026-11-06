---
type: meta
tags: [meta]
status: documented
source: own, adapted from the sister vault HALO ITSM and the earlier SN Brain CLAUDE.md (2026-11-06)
updated: 2026-11-06
---

# Recording results and inbox

Always run the "Check before you write" loop in [[CLAUDE]] first.

## When the user reports "I did X this way and it worked"

1. Search the vault for notes on the same task or tables (grep tags, names, keywords).
2. Create or update the notes. Set `status: verified`, today's date in `verified:` (with what the test did not cover), the contributor's name in `verified-by:`, the instance label in `observed-in:`, and the release in `sn-release:`. If the note is an exercise, also write its generalised recipe or how-to ([[Stories and Exercises]]).
3. **If a different approach already exists, don't overwrite it.** Compare both in an `08-Approaches/` note (`Templates/Approach.md`) and link the how-tos to it. Flag actual contradictions to the user instead of silently picking one.
4. Update the relevant `_index.md` and the table notes touched.
5. If the result changed, corrected or contradicted a note: mark the old claim `(contradicted: ...)` (never delete a verified one), run `impact.ps1`, add *Since written* lines and a [[Findings Log]] line ([[Improvement Loop]]).
6. Summarise what changed, and list open questions.

If it did **not** work, record that too: symptom, cause, fix in `07-Troubleshooting/` or the note's Gotchas.

## Knowledge from somewhere other than the docs

A colleague, a manager's notes, ServiceNow support, the Community, a course, another instance: record it like any other fact, in the matching note, with the origin in `source` (e.g. `team notes shared by the user's manager, 2026-10-30`) and a marker such as `(team notes 2026-10-30)` beside the claim. Status: `unverified` unless someone tested it (`verified`) or it comes from an official written source (`documented`). Content whose purpose is cheating (for example extracting exam answers) is not recorded.

## Verified scripts

A script, business rule or flow the user built and tested becomes a recipe in `04-Scripts-Automation/` (`Templates/Script.md`), with where it runs, its scope, and what was tested. Documented scripts go in `02-Concepts/Scripting/` or `03-How-To/`.

## When processing `00-Inbox/`

- Extract facts into proper notes with sources, mark `status` by origin, flag anything wrong or contradicting existing notes, and report what was created or changed.
- Images: [[Screenshots]].
- Then delete the processed files, or move them to `_processed/`.
