---
type: meta
tags: [meta]
status: documented
source: own, adapted from the sister vault HALO ITSM (2026-11-06)
updated: 2026-11-06
---

# Stories and exercises

Read when the user tells a story: a scenario, a client ask, a training task. Explain ServiceNow terms the first time they appear.

1. **Restate the goal in ServiceNow terms** (applications, tables, records, scripts involved) and ask only the questions that change the answer.
   **Scope = the acceptance criteria.** Tie every proposed step to a criterion. Requester answers and side observations go into the exercise note, never as new build steps.
   **Look for a matching pattern first:** the Patterns list in `09-Exercises/_index.md` and the **Reuse it for** sections of exercises.
2. **Build the solution from the vault**, staged, each note linked with its `status` ([[Guiding Work in an Instance]]). List the gaps: what no note covers and which docs page would fill it. Suggest a name for every object the user creates.
3. **Save the story as an exercise** in `09-Exercises/` from `Templates/Exercise.md` (Brief, Pattern, solution map, gaps, outcome, **Reuse it for**; no client names). If it involves a flow or approval, give it a **Flow** diagram ([[Diagrams]]).
4. **Record the options** in **Options considered** as they come up; two working routes get an `08-Approaches/` note ([[Improvement Loop]]).
5. **Findings travel during the exercise:** when the instance shows something that changes or contradicts a note, update the note at once, run `impact.ps1`, and add *Since written* lines to other affected exercises and recipes.
6. **Track what the requester must confirm:** keep an **Open with the requester** list in the note and repeat it, current, at the end of **every** reply while the exercise is open.
7. **Track what must be undone:** every test-only change (system properties, shortened timers, test users and groups, notifications enabled) goes into **To undo after testing** at once, with the value to put back. Walk through it when the exercise ends.
8. **When the user comes back with what worked**, follow [[Recording Results and Inbox]] and update the exercise.
9. **When the exercise becomes `verified`, promote the build** into a generalised `verified` note with placeholder names: a recipe in `04-Scripts-Automation/` for scripts, business rules and flows (with a **Flow** diagram when it is a flow), otherwise a how-to in `03-How-To/` or `06-Reporting/`. Link it from the exercise. `audit.ps1` lists verified exercises that link no verified how-to or recipe.

**Exercise notes belong to their author.** Others add their own exercise rather than rewriting it.
