---
type: meta
tags: [meta]
status: documented
source: own, adapted from the sister vault HALO ITSM and the earlier SN Brain CLAUDE.md (2026-11-06)
updated: 2026-11-06
---

# Git and several contributors

Repo `https://github.com/AlexandreMauricio/SNBrain.git` (remote `origin`, branch `main`). "The user" means whoever is running the session. **Push only when the user asks.**

## Who verified what

- A `verified` note carries `verified:` (date), `verified-by:` (first name from `git config user.name`; several separated by commas) and `observed-in:` (instance labels from [[Instances]]).
- **Never downgrade or overwrite someone else's `verified` finding.** Record yours next to theirs with your name and date, or as a second approach in `08-Approaches/`, and flag it. When you confirm someone else's verified note in your instance, add your name and instance.
- Exercise notes belong to their author.

## Pull, compare, push

1. **Pull at the start of a session and before a push:** `git pull --rebase`. Never force-push `main`. Start on `main`. If local changes block the pull: `git stash`, pull, `git stash pop`, and tell the user which files were set aside; never commit another person's unfinished edits.
2. **Compare before pushing**, even without a conflict: `git fetch`, then `git log --oneline HEAD..origin/main` and `git diff --stat HEAD...origin/main`. If something arrived, read the incoming notes on the same topics and decide per overlap: merge duplicates into one note, combine complementary facts keeping every `source` and `verified-by`, keep both sides of a contradiction, keep one set of notes for a page ingested twice. Audit again, then push.
3. Commit in small logical chunks. Don't commit `.obsidian/workspace*.json`, `.obsidian/graph.json` (both ignored) or anything that breaks the no-secrets rule.

## Conflicts in shared files

`_index.md` files, [[Docs Reading List]], [[Tag Vocabulary]], [[Findings Log]]: keep **both** sides' lines, then run the audit. A conflict inside a note's body: stop and ask the user.

## Large batches

Restructuring, tool or template changes, or many guides at once may go on a branch and merge through a pull request. Without the GitHub CLI, push the branch and give the user `https://github.com/AlexandreMauricio/SNBrain/pull/new/<branch>`, then switch back to `main`.

## Automatic audit on GitHub

`.github/workflows/audit.yml` runs `audit.ps1 -Strict` on every push and pull request. A red cross means a structural error: pull, run the audit locally, fix, push.

## Windows PowerShell 5.1 hazards

- Never use `Set-Content -Encoding utf8` or `Out-File` for notes: they add a UTF-8 **BOM**. Use the Write/Edit tools, or `[IO.File]::WriteAllText(path, text, (New-Object Text.UTF8Encoding($false)))`.
- When patching frontmatter with regex, anchor to the frontmatter block only. A bare 4th argument to `[regex]::Replace` sets *IgnoreCase*, not a count.
- **Note filenames:** no apostrophes, quotes or other shell-special characters. Parentheses, commas and underscores are fine.
- **Commit messages:** no double quotes. Don't hide git's error output on commit. After committing, confirm with `git log --oneline -1` and `git status -sb`.

## Cloud sessions

PowerShell may be missing, so do the tool checks by hand. `git config user.name` may read `Claude`, which is not a contributor: ask the user's first name for `verified-by:`. Push to the branch the session is given.

## Periodic maintenance

Regenerate [[Test Queue]] and [[Docs vs Reality]], run `impact.ps1 -Range` over what arrived since the last pull, run `audit.ps1`, and look for stale "not read" statements, open questions answered by later pages, `source:` lines that miss a page the note draws on, and duplicated sections.
