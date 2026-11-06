---
type: meta
tags: [meta]
status: documented
source: own, adapted from the sister vault HALO ITSM and the earlier SN Brain CLAUDE.md (2026-11-06)
updated: 2026-11-06
---

# Guiding work in an instance

Read before giving steps, a guide or an answer, above all while the user works in a ServiceNow instance. Summary in [[CLAUDE]] ("Answering and guiding").

## Before starting

- **Ask which instance it is** (if the user hasn't said) and look it up in [[Instances]]. Its row and the exercises built there show what may already exist in it.
- **Know its release.** If the row has no release, or an old one, ask the user to read it (**System Diagnostics > Stats**, or `glide.buildtag` / `glide.war` in **sys_properties.list**, general knowledge) and record it with the date. Compare it with the `sn-release` of the notes you use, and say when a step comes from a newer release.
- A new instance gets a row: a PDI as `pdi-<n>`, a client instance under an alias (`client-A`, ...), never the client's name or URL.

## Building the answer

1. Search the vault first and build the answer from the notes found, linking each with its `status`.
2. Say plainly when a step comes from a `documented` note nobody has tested, give every recorded variant when a name or setting is unconfirmed, and say when a step is general knowledge or inference because no note covers it.
3. If no note covers the task, say so and offer to fetch the matching docs page ([[Ingesting ServiceNow Docs]]).

## While the user follows along

- **Guide one stage at a time**, and ask what they see when a step's result is uncertain.
- **Never assume something exists in the instance** because a note says so. A `verified` note proves it worked where it was tested. Write "a note from another instance built X, does this one have it?".
- **Labels can differ per instance:** give the label and the name (`assigned_to`), since names don't change.

## Capture as you go

- Whenever the user shares a screenshot or describes a screen, record any field, label, default, mandatory flag, choice list or behaviour no note has yet, in the matching note **and** the exercise, during the task.
- Mark it `(observed <instance> <date>)`, not `verified`, until the user confirms the procedure worked, and add the instance to the note's `observed-in:`. When it settles a recorded variant, say so in the note.
- When what you see **contradicts** a note or an earlier exercise, follow [[Improvement Loop]] straight away.
- Screenshots worth keeping: [[Screenshots]].

## Something to test

When the user has an instance open and time to spare, regenerate [[Test Queue]] (`test-queue.ps1`) and offer items from it, preferring features the instance has and its release supports.

## Ask for evidence freely

Whenever a step comes from a `documented` or `unverified` note, general knowledge, or you are unsure of a label, menu path, default or option list, ask for a screenshot or what the screen shows.

## When the user reports the outcome

Follow [[Recording Results and Inbox]]. If it did not work, record that too (symptom, cause, fix) in `07-Troubleshooting/` or the note's Gotchas.
