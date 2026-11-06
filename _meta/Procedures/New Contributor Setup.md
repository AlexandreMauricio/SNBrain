---
type: meta
tags: [meta]
status: documented
source: own, adapted from the sister vault HALO ITSM (2026-11-06)
updated: 2026-11-06
---

# New contributor setup

**Claude: at the start of a session, check the machine is set up** (`git config user.name`, `git config user.email`, `git remote -v`, `git status -sb`). If anything is missing, walk the user through it before writing notes.

1. **Access:** the repo owner invites them on GitHub (repo > Settings > Collaborators). Without it, clone and push fail with "repository not found".
2. **Git installed** (`git --version`); on Windows, Git for Windows.
3. **Clone, don't copy:** `git clone https://github.com/AlexandreMauricio/SNBrain.git`. A downloaded zip has no history and can never pull or push.
4. **Identify to git** once per machine: `git config --global user.name "FirstName"` (this goes into `verified-by:`) and `git config --global user.email "<GitHub email>"`.
5. **Open the folder in Obsidian** as a vault. `workspace*.json` and `graph.json` are personal and ignored.
6. **Claude Code:** open it in the cloned folder; CLAUDE.md loads by itself. Run the tools as `powershell -ExecutionPolicy Bypass -File _meta/tools/audit.ps1`. Python is optional, for one-off scripts.
7. **First session:** `git pull`, run the audit for a clean start, read [[Tag Vocabulary]] and the note rules in [[CLAUDE]].

| Symptom | Cause | Fix |
|---|---|---|
| `git config user.name` prints nothing, or "Author identity unknown" | git identity not set | step 4 |
| "repository not found" or 403 | invitation not accepted, or wrong GitHub account | step 1 |
| "not a git repository" | folder copied, not cloned | step 3 |
| script "is not digitally signed" | execution policy | `-ExecutionPolicy Bypass` |
| push rejected, "fetch first" | someone pushed since the last pull | `git pull --rebase`, compare ([[Git and Several Contributors]]), push |
