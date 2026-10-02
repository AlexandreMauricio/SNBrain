---
type: how-to
tags: [how-to, instance-admin, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Configuring Instance Clone" (pp. 712-718), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Configure clone exclusions, preservers and cleanup scripts

**Goal:** decide what a clone leaves out, what the target keeps, what runs afterwards, and bundle it in a profile.
**Prerequisites:** role `clone_admin` (cleanup scripts: admin; profiles: `clone_admin` or `clone_profile_admin`). **Work on the source instance.**
**Navigation:** All > Clone Admin Console > Clone Home > Configuration

## Steps: exclude a table

1. **Configuration > Exclusions > New.**
2. Enter the table **Name** and **Save**.

## Steps: create a preserver

1. **Configuration > Preservers > New.**
2. Give a descriptive **Name**, select the **Table**.
3. Tick **Theme** if the data is a UI property.
4. Limit the records with the condition builder and **Save**.

## Steps: create a cleanup script

1. **Configuration > Cleanup scripts > New.**
2. Enter a name and an **order** number, write the **Script**, tick **Active**, **Save**.

## Steps: create a clone profile

1. **Configuration > Clone Profiles > New**, fill the form.
2. To change what a profile contains, select the number under Exclusions, Preservers or Scripts and use **Edit**. Profiles can be duplicated.

## Result / how to check it worked

The items appear in the lists and in the counts on the clone request form. After a clone, check **Cleanup Script Execution** (on the target, or from the source with Multi-Instance View): states per script, and **Resume all remaining scripts** to rerun failed ones.

## Example

A cleanup script *Disable emails*, order 100, active:

```javascript
gs.setProperty("glide.email.read.active", false);
gs.setProperty("glide.email.smtp.active", false);
```

A preserver *Example User Preferences* on `sys_user_preference` with a condition limiting it to the preferences that matter.

## Tables / fields involved

- the excluded and preserved tables; `sys_properties` for property preservers

## Gotchas

- The **System Profile** cannot be modified. A new custom profile starts with the default exclusions, preservers and scripts and all existing custom exclusions and preservers.
- In the legacy UI (**Instance Clone > Clone Definition**), a new preserver, exclusion or script is **not** added to existing profiles automatically.
- A parent table exclusion empties its children; a preserver does not cover children.
- Preserving a lot of data lengthens the clone. Unpublished application content must be preserved separately by the developers.
- Without error handling, one failing cleanup script stops the rest.
- More in [[Instance Clone Overview]].
