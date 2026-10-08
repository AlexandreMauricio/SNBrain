# SN Brain: ServiceNow Knowledge Vault

Personal knowledge base about ServiceNow (the Now Platform and its ITSM applications), written in Markdown and edited with Obsidian. It exists because the UI shows **labels** while scripts, queries, imports and the API need **table and column names**, and because neither the user nor Claude knows everything about the product. **Check this vault first when answering any ServiceNow question**, then say whether the answer came from a note (and its `status`) or from general knowledge.

Sister vault: `HALO ITSM` (same structure and rules, for Halo ITSM). Keep the two consistent when changing conventions.

## Folder layout

| Folder | Purpose |
| --- | --- |
| `00-Inbox/` | Raw drops (pasted docs, exports, XML, screenshots, rough notes). Nothing here is trusted. Process into proper notes, then delete or move to `_processed/` |
| `01-Data-Dictionary/Tables/` | One note per table, named with the exact table name (`incident.md`, `task.md`, `sys_user.md`, `cmdb_ci.md`), plus the occasional overview spanning a family of tables (`type: reference`, e.g. the task hierarchy) |
| `01-Data-Dictionary/Fields/` | Only for fields worth their own note (tricky references, choice lists with coded values, fields shared across the task hierarchy, dot-walking traps). Ordinary columns live in the table note |
| `01-Data-Dictionary/Queries/` | Reusable discovery queries: encoded queries, GlideRecord / GlideAggregate snippets, Table API calls, lookups against `sys_db_object`, `sys_dictionary` and `sys_choice` |
| `02-Concepts/` | What things are, how they relate, and the properties and settings that control them. **Subfolders by topic:** `Foundations/` (platform architecture, tables and extension, dictionary, sys_id, update sets, application scopes, instances, UI-label-to-name glossary), `ITSM/` (incident, problem, change, request, the task model, states, assignment), `Service-Catalog/` (catalog items, variables, variable sets, record producers, order guides, REQ/RITM/SCTASK), `CMDB-and-Assets/` (CI classes, relationships, CSDM, Discovery, asset management), `SLA-and-Schedules/` (SLA definitions, schedules, timers, breach data), `Users-Groups-and-Access/` (users, groups, roles, ACLs, delegation, domain separation), `Forms-and-Lists/` (form layout, views, UI actions, dictionary overrides, choice lists), `Scripting/` (Glide APIs, business rules, client scripts, UI policies, script includes, order of execution), `Flows-and-Automation/` (Flow Designer, legacy Workflow, scheduled jobs, IntegrationHub actions), `Notifications-and-Email/` (notifications, events, templates, inbound actions), `Knowledge/` (knowledge bases, articles, workflows), `Portals-and-Workspaces/` (Service Portal, Employee Center, workspaces, UI Builder), `Security/` (authentication, SSO, encryption, instance hardening), `AI/` (Now Assist, Virtual Agent, Predictive Intelligence), `Data-Management/` (archiving, table cleaner, update and delete jobs, table rotation, exporting data, rollback and delete recovery), `Instance-Administration/` (plugins and applications, system properties, instance clone, upgrades, instance scan, performance, subscriptions), `Search/` (Zing text search, AI Search, search suggestions, contextual search), `Localization/` (time zones, currency, translation and localization), `Application-Development/` (application scope and namespaces, cross-scope access, application administration, builder tools such as Creator Studio, App Engine Studio and ServiceNow Studio, delegated and team development, testing with ATF, deployment). File new notes in the matching subfolder, and create a new subfolder only for a clearly new topic. Keep `02-Concepts/_index.md` grouped the same way |
| `03-How-To/` | Step-by-step procedures, in one flat folder. Its `_index.md` is grouped into topic sections (mirroring `02-Concepts/`); add lines with `add-index-line.ps1 -Section` |
| `04-Scripts-Automation/` | Reserved for **verified** hands-on recipes from a real instance (scripts, flows, business rules built and tested). Documented concepts go in `02-Concepts/Scripting/` or `02-Concepts/Flows-and-Automation/`, documented procedures in `03-How-To/` |
| `05-Integrations-API/` | REST (Table API, Scripted REST), SOAP, import sets and transform maps, IntegrationHub spokes, MID Server, auth, payloads |
| `06-Reporting/` | Reports, dashboards, Performance Analytics, database views |
| `07-Troubleshooting/` | Symptom, cause, fix |
| `08-Approaches/` | Comparisons where there are several ways to do the same thing (e.g. business rule or flow, UI policy or client script) |
| `09-Exercises/` | Task briefs (training/assessment/client asks) paired with the notes that solve them |
| `Templates/` | Note templates. Copy the matching one when creating a note |
| `_attachments/` | Screenshots used in notes. Descriptive lowercase-hyphen names. Check for real customer data before adding |
| `_meta/` | Tag vocabulary, docs reading list, tools |

Each content folder has an `_index.md` (map of content). Keep it up to date when adding notes: one line per note, `[[link]]` plus a short description.

## Note rules

1. **One topic per note.** Split rather than grow. Filenames are descriptive and unique, in Title Case with spaces for prose notes (`Configure an SLA Definition.md`). Table notes use the exact table **name**, lowercase with underscores as in `sys_db_object` (`incident.md`, `sc_req_item.md`), never the label.
2. **Every note has frontmatter** (see `Templates/`). Required keys: `type`, `tags`, `status`, `source`, `updated`. Optional: `sn-release`, `verified`. `type` is one of `concept` (what something is and how it works), `reference` (a settings page, property list or lookup list; `Templates/Reference.md`), `how-to`, `table`, `query`, `script`, `troubleshooting`, `approach`, `exercise`, `meta`.
3. **`status` is honest:**
   - `verified`: tested in a real instance (PDI or other) by the user (say when in `verified:`, and the release in `sn-release:`)
   - `documented`: taken from official docs or another reliable source, not tested
   - `unverified`: hearsay, a community post, an LLM answer, or a guess
   - `outdated`: known to be wrong or superseded for the current release (keep it, explain why)
4. **Tags come only from `_meta/Tag Vocabulary.md`.** If a new tag is really needed, add it there first.
5. **Link generously** with `[[wikilinks]]`, especially table to table (reference fields and parent/child extension) and how-to to the tables and concepts it touches.
6. **Never write secrets or real data:** no passwords, OAuth client secrets, API keys, instance names of real customers, customer names, real ticket contents. Use placeholders like `<instance>.service-now.com`, `<CLIENT_ID>` and invented sample data.
7. **Don't paste large chunks of official docs.** Summarise in our own words and record the URL in `source`.
8. **Uncertainty is stated in the note.** Unknown column meaning: write `?` or "meaning unconfirmed", never invent it.
9. **Every how-to gets a generalised `Example` section** with placeholder names (`Example Group`, `Test User`), never the exact names or settings from a specific exercise or client.
10. **Vault language is English.** The user may write notes in Portuguese. Translate them, and keep the original in the exercise note when useful.
11. **Always give both the label and the name** the first time a field or table appears in a note: **Assigned to** (`assigned_to`), **Requested Item** (`sc_req_item`). Labels can be changed per instance, names cannot.
12. **Say where a script runs and in which scope:** server or client, the record type (business rule, client script, script include, UI action, fix script, background script), and global or scoped application. Scoped APIs differ from global ones.

## Data dictionary specifics

- Table notes follow `Templates/Table.md`: label, what it stores, what it extends and what extends it, key columns (label, name, type, reference/choice, confidence), relations, choice values, example queries.
- Inherited columns are documented once, on the table that defines them (e.g. `task`), and linked from the child tables. A child table note lists only its own columns and any dictionary overrides.
- Column type/meaning claims need a source: a `sys_dictionary` result the user pasted, a script or query that ran, or docs. Note which one.
- Choice values are recorded as `value = label` and can differ per instance; say which instance and release they came from.
- Reusable discovery queries go in `01-Data-Dictionary/Queries/` and are linked from the tables they relate to. Note where each runs (list filter, Scripts - Background, Table API) and whether it only reads.

## When the user reports "I did X this way and it worked"

1. Search the vault for existing notes on the same task or tables (grep tags, names, and keywords).
2. Create or update the relevant notes. Set `status: verified`, today's date in `verified:` and the release in `sn-release:` for what the user confirmed worked.
3. **If a different approach already exists, don't overwrite it.** Compare and record both in a note in `08-Approaches/` (`Templates/Approach.md`), and link the how-to notes to it. Say what differs and when each fits. Flag actual contradictions to the user instead of silently picking one.
4. Update the relevant `_index.md` and any table notes touched.
5. Summarise what changed, and list any open questions.

## When processing `00-Inbox/`

Extract facts into proper notes with sources, mark `status` according to the origin, flag anything that looks wrong or contradicts existing notes, and report what was created or changed.

## Check before you write (mandatory, every time)

The vault will hold far more than fits in one session's context, and a new session remembers nothing. So **never write a note from memory of what the vault contains. Search first.** Any doc ingestion, "I did X" report, or edit follows this loop:

1. **Already processed?** Look up the page URL in `_meta/Docs Reading List.md`. If a row exists, don't re-ingest; only add what is new.
2. **Find related notes:** run `powershell -File _meta/tools/find-related.ps1 -Terms "<key setting|topic word|another>" -Doc "<distinctive part of the URL>"` (terms separated by `|`). Use several terms: the page title, exact UI labels, table and column names, property names, menu paths. Also glance at the relevant `_index.md`.
3. **Read the matching notes** before writing. Decide per fact: new (add), already covered (link, don't repeat), refines an existing note (edit that note), contradicts one (flag it, keep both, never overwrite `verified` with `documented`).
4. **Prefer editing an existing note over creating a new one.** Create a note only for a topic that has no home. Give every new note links to the notes it overlaps.
5. **Record discrepancies** (different names, releases, defaults across pages) in the note itself and mention them to the user.
6. **Audit before committing:** run `powershell -File _meta/tools/audit.ps1`. Fix missing frontmatter keys, tags outside the vocabulary, broken links, and notes missing from an `_index.md`.
7. Update `_index.md` (use `powershell -File _meta/tools/add-index-line.ps1 -Index 02-Concepts/_index.md -Section "ITSM" -Line "- [[Note]] - description"` so the line lands under the right topic heading; `03-How-To/_index.md` has sections too; indexes without `## ` sections take no `-Section`), update `_meta/Docs Reading List.md`, then commit.

**File-writing hazards (Windows PowerShell 5.1):**
- Never use `Set-Content -Encoding utf8` or `Out-File` for notes: they add a UTF-8 **BOM**, which can stop Obsidian reading the frontmatter. Use the Write/Edit tools, or `[IO.File]::WriteAllText(path, text, (New-Object Text.UTF8Encoding($false)))`. `audit.ps1` reports any BOM.
- When patching frontmatter with regex, anchor to the frontmatter block only. A bare `-replace '(?m)^source:.*'` also rewrites body lines, and passing a bare number as the 4th argument to `[regex]::Replace` sets *IgnoreCase*, not a count.
- **Note filenames: no apostrophes, quotes or other shell-special characters** (they break single-quoted PowerShell patch scripts). Parentheses, commas and underscores are fine.
- **Commit messages: no double quotes.** In Windows PowerShell 5.1 a `"` inside the message splits the argument and `git commit` fails. Don't hide git's error output (`2>$null`) on commit. After committing, confirm with `git log --oneline -1` and `git status -sb` before saying it is done.
- Periodically run the maintenance checks: `audit.ps1`, stale "not read yet" statements, open questions answered by later pages, `source:` lines listing every page a note draws on, duplicated sections inside one note.

## When the user gives a ServiceNow docs URL

(Run the "Check before you write" loop above first, then:)

1. Fetch it with the **built-in browser** if WebFetch returns only a title or an empty shell (the product docs and developer sites are rendered with JavaScript). Open the URL, wait a few seconds, then read the page text. If a way of extracting just the article works well, record it in `_meta/Docs Reading List.md`.
2. Note the **release family** the page belongs to (it is part of the docs URL or the version picker) and put it in `sn-release`. Behaviour changes between releases.
3. Summarise into notes in our own words (never paste the article), one topic per note, `status: documented`, and put the page title, URL and read date in `source`. Community posts and blogs are `unverified` until tested.
4. If the docs contradict a `verified` note, flag it to the user and keep both. Do not overwrite verified with documented.
5. Record the page in `_meta/Docs Reading List.md` (processed table, and any linked pages still to read).

## Git

Branch `main`, remote `origin` = `https://github.com/AlexandreMauricio/SNBrain.git` (same pull/push routine as the Halo vault). Run `git pull` at the start of a session, and push only when the user asks. Commit in small logical chunks with clear messages. Don't commit `.obsidian/workspace*.json` (ignored) or anything from rule 6.
