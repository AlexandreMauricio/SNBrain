# SN Brain: ServiceNow Knowledge Vault

Personal knowledge base about ServiceNow (the Now Platform and its applications), written in Markdown and edited with Obsidian, kept in git. It exists because the UI shows **labels** while scripts, queries, imports and the API need **table and column names**, and because neither the user nor Claude knows everything about the product. **Check this vault first when answering any ServiceNow question**, then say whether the answer came from a note (and its `status`) or from general knowledge.

This file holds the rules that always apply and says which procedure in `_meta/Procedures/` to **read before** each kind of task. Sister vault: `HALO ITSM` (same structure and rules, for Halo ITSM). Keep the two consistent when changing a shared convention.

## Start of every session (Claude)

1. `git status -sb`: be on `main`. Then `git pull --rebase`. If local changes block the pull: `git stash`, pull, `git stash pop`, and tell the user which files were set aside.
2. Setup check: `git config user.name`, `git config user.email`, `git remote -v`. If anything is missing, walk the user through `_meta/Procedures/New Contributor Setup.md` before writing notes.
3. Before guiding work in an instance, **ask which instance it is** (if not said) and look it up in `_meta/Instances.md`. If its **release** is missing or old, ask the user to read it and record it with the date.
4. Then answer.

## What to read before each task

| The user... | Read first |
|---|---|
| asks for steps, a guide or an answer, or works along in an instance | `_meta/Procedures/Guiding Work in an Instance.md` |
| learns something that changes, corrects or contradicts a note, at any moment (mid-exercise included), or a test passes or fails | `_meta/Procedures/Improvement Loop.md` |
| has an instance open and asks what to test or verify | `_meta/Test Queue.md` (regenerate first with `test-queue.ps1`) |
| tells a story or scenario ("A client wants X, how do I do it in ServiceNow?") | `_meta/Procedures/Stories and Exercises.md` |
| reports a result ("I did X this way and it worked"), shares knowledge from a colleague, manager, forum or support, or says "Process the inbox" | `_meta/Procedures/Recording Results and Inbox.md` |
| gives a docs URL, asks to read a guide or the API reference, or shares release notes or a PDF | `_meta/Procedures/Ingesting ServiceNow Docs.md` |
| shares screenshots, or images are in `00-Inbox/` | `_meta/Procedures/Screenshots.md` |
| needs a note describing a flow (flow, workflow, approval, multi-record build) | `_meta/Procedures/Diagrams.md` |
| is about to push, hits a conflict, works in a cloud session, or asks for a health check ("Check the vault") | `_meta/Procedures/Git and Several Contributors.md` |
| is new, or the machine isn't set up | `_meta/Procedures/New Contributor Setup.md` |

## Answering and guiding (always)

- **Reference every vault note used.** When answering a question or guiding work, link each note the answer drew on (e.g. `02-Concepts/ITSM/Change Management Overview and Lifecycle.md`) with its `status`, next to the step it supports or in a "Vault notes used" list at the end. Mark anything else as general knowledge or inference.
- **When the work changes the vault** (docs ingestion, team notes, results), report instead which notes were **created** and **updated**, with their status. Notes merely searched for overlap are not listed.
- Say plainly when a step comes from a `documented` note nobody has tested, and give every recorded variant when a name or setting is unconfirmed.
- **Never assume something exists in the user's instance** because a note says so: a `verified` note proves it worked where it was tested. Write "a note from another instance built X, does this one have it?"
- Guide one stage at a time; ask for screenshots or what the screen shows whenever unsure. Suggest a name for every object the user creates.
- **Stay within the acceptance criteria.** In a story or exercise, build and propose only what the criteria ask. Requester answers and side observations are recorded in the exercise note, not turned into extra build steps.
- **Open questions for the requester go in every reply** while an exercise has anything to confirm: end each reply with an **Open with the requester** list, kept the same in the exercise note.
- **Record what to undo.** Any change made only for testing goes, when made, into the exercise's **To undo after testing** table with the value to put back.
- **Capture as you go:** any field, label, default or behaviour the user shows that no note holds goes into the matching note (`documented` ones included) and the exercise during the task, marked `(observed <instance> <date>)`, not `verified` until the user confirms; add the instance label to the note's `observed-in:`. When it settles a recorded variant, say so in the note.
- **Close the session with what it learned:** list each finding and where it went (note, exercise, Findings Log); anything without a home gets one or goes into the test queue.

## How the vault improves itself

Every finding, whatever its source (a docs page, a release, an instance screen, a passed or failed test, a colleague, Claude's own reasoning), runs through one loop, **during the work and not only at the end** (`_meta/Procedures/Improvement Loop.md`):

1. **Record** it in the matching note with an evidence marker: `(verified <instance> <date>)`, `(observed ...)`, `(docs <page>)`, `(colleague ...)`, `(team notes ...)`, `(inference)`, `(contradicted: ...)`, `(outdated from <release>: ...)`.
2. **Propagate** it: `impact.ps1` lists the exercises and recipes that rely on the changed notes; each affected one gets a dated `## Since written` line.
3. **Keep the alternatives:** a contradiction keeps both sides until a test settles it; exercises record *Options considered*; two working routes get an `08-Approaches/` note; a failure becomes a troubleshooting note.
4. **Validate:** the test queue collects open, unconfirmed, inferred and contradicted claims, verified notes seen in only one instance, and notes written for a newer release than any recorded instance. A newer release retires a claim with `(outdated from ...)`, never by deleting it.
5. **Surface:** a line in `_meta/Findings Log.md` for every finding that changed or contradicted a note; regenerate `_meta/Docs vs Reality.md` and `_meta/Test Queue.md`.

## Folder layout

Each content folder has an `_index.md` (map of content): one line per note, `[[link]]` plus a short description. Keep it up to date.

| Folder | Purpose |
| --- | --- |
| `00-Inbox/` | Raw drops (pasted docs, exports, XML, screenshots, rough notes). Nothing here is trusted. Process into proper notes, then delete or move to `_processed/` |
| `01-Data-Dictionary/Tables/` | One note per table, named with the exact table name (`incident.md`, `task.md`, `sys_user.md`, `cmdb_ci.md`), plus the occasional overview spanning a family of tables (`type: reference`) |
| `01-Data-Dictionary/Fields/` | Only fields worth their own note (tricky references, choice lists with coded values, fields shared across the task hierarchy, dot-walking traps). Ordinary columns live in the table note |
| `01-Data-Dictionary/Queries/` | Reusable discovery queries: encoded queries, GlideRecord / GlideAggregate snippets, Table API calls, lookups against `sys_db_object`, `sys_dictionary` and `sys_choice` |
| `02-Concepts/` | What things are, how they relate, and the properties and settings that control them. **Subfolders by topic:** `Foundations/` (platform architecture, tables and extension, dictionary, sys_id, update sets, application scopes, instances, UI-label-to-name glossary), `ITSM/` (incident, problem, change, request, the task model, states, assignment), `Service-Catalog/` (catalog items, variables, variable sets, record producers, order guides, REQ/RITM/SCTASK, catalog scripting APIs), `CMDB-and-Assets/` (CI classes, relationships, CSDM, Discovery, asset management), `SLA-and-Schedules/` (SLA definitions, schedules, timers, breach data), `Users-Groups-and-Access/` (users, groups, roles, ACLs, delegation, domain separation), `Forms-and-Lists/` (form layout, views, UI actions, dictionary overrides, choice lists), `Scripting/` (Glide APIs and API reference notes, business rules, client scripts, UI policies, script includes, order of execution), `Flows-and-Automation/` (Workflow Studio, legacy Workflow, scheduled jobs, IntegrationHub actions), `Notifications-and-Email/` (notifications, events, templates, inbound actions), `Knowledge/` (knowledge bases, articles, workflows), `Portals-and-Workspaces/` (Service Portal, Employee Center, workspaces, UI Builder), `Security/` (authentication, SSO, encryption, instance hardening), `AI/` (Now Assist, AI agents, Virtual Agent, Predictive Intelligence), `Data-Management/` (archiving, table cleaner, update and delete jobs, table rotation, exporting data, rollback and delete recovery, auditing), `Instance-Administration/` (plugins and applications, system properties, instance clone, upgrades, instance scan, performance, subscriptions), `Search/` (Zing text search, AI Search, search suggestions, contextual search), `Localization/` (time zones, currency, translation and localization), `Documents/` (Document Services), `Surveys-and-Assessments/` (surveys, assessments, quizzes), `ITOM/` (Event Management, AIOps, Agent Client Collector), `Application-Development/` (scope and namespaces, cross-scope access, builder tools, delegated and team development, ATF, deployment). File new notes in the matching subfolder; create a new subfolder only for a clearly new topic, and add it as a section in `02-Concepts/_index.md` |
| `03-How-To/` | Step-by-step procedures, in one flat folder. Its `_index.md` has topic sections mirroring `02-Concepts/` |
| `04-Scripts-Automation/` | **Verified** recipes from a real instance (scripts, flows, business rules built and tested). Documented material goes in `02-Concepts/Scripting/`, `02-Concepts/Flows-and-Automation/` or `03-How-To/` |
| `05-Integrations-API/` | REST (Table API, Scripted REST), SOAP, import sets and transform maps, IntegrationHub spokes, MID Server, auth, payloads |
| `06-Reporting/` | Reports, dashboards, Performance Analytics, database views |
| `07-Troubleshooting/` | Symptom, cause, fix |
| `08-Approaches/` | Comparisons where there are several ways to do the same thing (e.g. business rule or flow, UI policy or client script) |
| `09-Exercises/` | Task briefs (training, assessment, client asks) paired with the notes that solve them; Patterns list in its `_index.md` |
| `Templates/` | Note templates. Copy the matching one when creating a note |
| `_attachments/` | Screenshots embedded in notes, descriptive lowercase-hyphen names, checked for real data (`_meta/Procedures/Screenshots.md`) |
| `_meta/` | Tag vocabulary, instances (with releases), Findings Log, test queue and Docs vs Reality (both generated), docs reading list, procedures, tools |
| `.github/workflows/` | `audit.yml`: runs the audit on GitHub for every push and pull request |

**Tools** (`_meta/tools/`, run as `powershell -ExecutionPolicy Bypass -File _meta/tools/<name>.ps1`): `find-related` (search before writing), `add-index-line` (index lines), `audit` (structure checks; `-Strict` fails on errors), `impact` (what relies on a note or on a git range of changes), `test-queue` (rebuilds `_meta/Test Queue.md`; release families in order are listed in the script), `docs-vs-reality` (rebuilds `_meta/Docs vs Reality.md`).

## Note rules

1. **One topic per note.** Split rather than grow. Filenames are descriptive and unique, in Title Case with spaces for prose notes (`Configure an SLA Definition.md`). Table notes use the exact table **name**, lowercase with underscores as in `sys_db_object` (`incident.md`, `sc_req_item.md`), never the label. No apostrophes, quotes or shell-special characters in filenames.
2. **Every note has frontmatter** (see `Templates/`). Required: `type`, `tags`, `status`, `source`, `updated`. Optional: `sn-release`, `verified`, `verified-by`, `observed-in` (labels from `_meta/Instances.md` of every instance where anything in the note was seen or tested, e.g. `[pdi-1, client-A]`). `type` is one of `concept`, `reference` (a settings page, property list or lookup list), `how-to`, `table`, `query`, `script`, `troubleshooting`, `approach`, `exercise`, `meta`.
3. **`status` is honest:**
   - `verified`: tested in a real instance by a contributor (when in `verified:`, who in `verified-by:`, which instance in `observed-in:`, the release in `sn-release:`, and what the test did not cover)
   - `documented`: from official docs or another reliable written source, not tested
   - `unverified`: hearsay, team or colleague notes, a community post, an LLM answer, or a guess
   - `outdated`: known to be wrong or superseded for the current release (keep it, explain why)
4. **Tags come only from `_meta/Tag Vocabulary.md`.** If a new tag is really needed, add it there first.
5. **Link generously** with `[[wikilinks]]`, especially table to table (reference fields and parent/child extension) and how-to to the tables and concepts it touches.
6. **Never write secrets or real data:** no passwords, OAuth client secrets, API keys, real customer or instance names or URLs (use the alias from `_meta/Instances.md`), real ticket contents. Use placeholders like `<instance>.service-now.com`, `<CLIENT_ID>` and invented sample data. This applies to screenshots and exercise notes too.
7. **Don't paste large chunks of official docs.** Summarise in our own words and record the URL (or the document's title or map, for a file or API source) in `source`. Images from ServiceNow docs or training are described, not copied.
8. **Uncertainty is stated in the note.** Unknown column meaning: write `?` or "meaning unconfirmed", never invent it. Reasoning nobody has seen confirmed is marked `(inference)`.
   - **Everything not `verified` is unconfirmed, and variants are kept.** When sources disagree (two spellings of a table or property, two roles, two defaults, two ways to do a task), record **all** variants side by side, each with its source. Never call one a typo or drop it on judgement alone. Only a test settles which is right; then mark the winner `verified` and keep the others as `(contradicted ...)` or `(outdated from ...)`. A note is never final.
9. **Every how-to gets a generalised `Example` section** with placeholder names (`Example Group`, `Test User`), never the exact names or settings from a specific exercise or client.
10. **Vault language is English.** The user may write in Portuguese: translate, and keep the original in the exercise note when useful.
11. **Always give both the label and the name** the first time a field or table appears in a note: **Assigned to** (`assigned_to`), **Requested Item** (`sc_req_item`). Labels can be changed per instance, names cannot.
12. **Say where a script runs and in which scope:** server or client, the record type (business rule, client script, script include, UI action, fix script, background script), and global or scoped application. Scoped APIs differ from global ones.
13. **Never overwrite or downgrade a `verified` finding** (yours with `documented`, or someone else's with yours). Keep both, flag the difference, and compare in `08-Approaches/` when there are two ways.
14. **Flows get a diagram.** Every flow, workflow, approval or multi-record recipe note starts with a Mermaid `## Flow` diagram and an *At a glance* line (`_meta/Procedures/Diagrams.md`).
15. **A verified exercise gets a verified, generalised note:** a recipe in `04-Scripts-Automation/` or a how-to in `03-How-To/` or `06-Reporting/`, linked from the exercise (`_meta/Procedures/Stories and Exercises.md`).

## Data dictionary specifics

- Table notes follow `Templates/Table.md`: label, what it stores, what it extends and what extends it, key columns (label, name, type, reference/choice, confidence), relations, choice values, example queries.
- Inherited columns are documented once, on the table that defines them (e.g. `task`), and linked from the child tables. A child table note lists only its own columns and any dictionary overrides.
- Column type/meaning claims need a source: a `sys_dictionary` result the user pasted, a script or query that ran, or docs. Note which one.
- Choice values are recorded as `value = label` and can differ per instance; say which instance and release they came from.
- Reusable discovery queries go in `01-Data-Dictionary/Queries/` and are linked from the tables they relate to. Note where each runs (list filter, Scripts - Background, Table API) and whether it only reads.

## Check before you write (mandatory, every time)

The vault holds far more than fits in one session's context, and a new session remembers nothing. **Never write a note from memory of what the vault contains. Search first.** Any doc ingestion, "I did X" report, or edit follows this loop:

1. **Already processed?** Look up the page URL or map in `_meta/Docs Reading List.md`. If a row exists, don't re-ingest; only add what is new.
2. **Find related notes:** `find-related.ps1 -Terms "<key setting|topic word|another>" -Doc "<distinctive part of the URL>"` (terms separated by `|`; use the page title, exact UI labels, table and column names, property names, menu paths). Also glance at the relevant `_index.md`.
3. **Read the matching notes** before writing. Per fact: new (add), already covered (link, don't repeat), refines a note (edit it), contradicts one (flag it, keep both, never overwrite `verified` with `documented`).
4. **Prefer editing an existing note over creating a new one.** Create a note only for a topic with no home, and link it to the notes it overlaps.
5. **Record discrepancies** (names, releases, defaults across pages or instances) in the note and mention them to the user. If the change affects what other notes rely on, run the propagation step of the improvement loop (`impact.ps1`, *Since written* lines, Findings Log).
6. **Regenerate and audit:** run `test-queue.ps1` and `docs-vs-reality.ps1`, then `audit.ps1` and fix every error it lists ("not read yet" is a warning: check each is still true). The same audit runs on GitHub with `-Strict`.
7. **Index and log:** add the `_index.md` line with `add-index-line.ps1` (`-Index 02-Concepts/_index.md -Section "ITSM" -Line "- [[Note]] - description"`; `03-How-To/_index.md` has sections too; indexes without `## ` sections take no `-Section`), update `_meta/Docs Reading List.md`.
8. **Keep this file current:** if the work added or changed a folder, subfolder, note type, template, tool, rule or workflow, update `CLAUDE.md` in the same commit, and make the same change in the sister vault when it is a shared convention.
9. **Commit** (below). Write files with the Write/Edit tools, never `Set-Content`/`Out-File` (BOM); no double quotes in commit messages; after committing, confirm with `git log --oneline -1` and `git status -sb`. Hazards in detail: `_meta/Procedures/Git and Several Contributors.md`.

## Git

Branch `main`, remote `origin` = `https://github.com/AlexandreMauricio/SNBrain.git`. `git pull --rebase` at the start of a session; **push only when the user asks**, after comparing what arrived (`_meta/Procedures/Git and Several Contributors.md`). Never force-push `main`. Commit in small logical chunks with clear messages. Don't commit `.obsidian/workspace*.json`, `.obsidian/graph.json` (both ignored) or anything from rule 6.
