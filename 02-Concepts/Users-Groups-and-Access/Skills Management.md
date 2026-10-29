---
type: concept
tags: [concept, users, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage people and work capabilities > Skills Management (landing, Exploring, Configuring: skill taxonomy, sample data, skill level type, add a skill; Using: dashboard, Assigning and managing skills, assign proficiency levels, assign skills to tasks, Routing work items based on skills: how skill determination works, business rule, determination rules, qualify and rank users; Translate text; Reference: quick start tests, domain separation, extension points), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/skills-management/skills-management.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Skills Management

**In one line:** plugin **Skills Management** (`com.snc.skills_management`) keeps a central catalogue of **skills** (`cmn_skill`) with categories and proficiency levels, assigns them to users and groups, attaches required skills to tasks, and lets routing (Skill Determination, Advanced Work Assignment, Field Service dynamic scheduling) send work to people who have them.

From the Brazil docs; not tested. The ITSM manager views (skill matrix, skill review requests, shipped determination rules, skill recommendation) are in [[Workforce Optimization Learning, Skills and Reference]]. Used by ITSM, CSM, FSM, HR and PPM.

## Model

| Piece | Table | Notes |
|---|---|---|
| Skill | `cmn_skill` | **Display Skill Name** and **Description** are translated text fields; tabs **Contains Skills** (sub-skills, `cmn_skill_contains`), **Users**, **Model** (CIs) |
| Skill category | `cmn_skill_category` | hierarchy; skills only in the **lowest** category; **Add Skills** check box enables adding skills |
| Skill level type | `cmn_skill_level_type` | e.g. *Language*, *Programming*; each new type gets a *Default* level of value 1 |
| Skill level | `cmn_skill_level` | name and **value**; the value measures gaps (Expert 25 minus Proficient 10 = gap 15) |
| User skill | `sys_user_has_skill` | with level; fields **Inherited**, **Skill level inherited** |
| Group skill | `sys_group_has_skill` | members inherit the skill and its contained skills; in several groups a user gets the **highest** level |
| Task skill | `task_m2m_skill` | required skill, level, **Mandatory** |
| Product to skill | `cmn_m2m_skill_model` | *Skill Required for Model Maintenance*: add skills to a case from its product |

A parent skill implies its child skills (a user with *Network* also has *Router* if *Network* contains it).

## Roles

| Role | Can |
|---|---|
| `skill_admin` | create, update, delete skills, levels, level types, categories (contains `skill_manager`, `skill_user`) |
| `skill_manager` | read all of that, assign skills to users and groups (contains `skill_user`) |
| `skill_user` | read skills, levels, level types |

## Menus

- **Skills > Skill Taxonomy**: categories (Name, Parent), child categories and skills related lists. Sample taxonomy (about 150 records): plugin **Skills Library Data for Skills Management** `com.snc.skills_management.seed_data`, then set **Add skills** true on the categories you want.
- **Skills > Skill Level Types**, **Skills > All Skills**.
- **Skills > Manage IT Skills** (Next Experience page; `skill_manager` or `skill_admin`): by department or group, a **skill matrix** with coverage bars; **Add** a level for a user (up to five levels shown; no level = *Acquired*), **Add Skill** (name, level type, categories; admins only). Filters Users, Skills, Location. Custom group types through extension point `sn_skill_cfg_page.ManageSkillsExtnPt` (constants in script include `sn_skill_cfg_page.ManageSkillsConstants`).
- **Skills > Dashboard** (`skill_manager`): Skills Matrix pivot, top 10 skills used in six months, tasks with skills, users with skills per category, skills in category, users per skill.
- On any task: related list **Task Skills** (add *Task Skill->Task* to the form) with Skill, Skill level, Mandatory (admin).

## Skill determination (skills on incoming work)

Plugin **Skill Determination** `com.snc.skill_determination`. Two parts: a **Skill Determination Rule** (**Skills > Skill Determination Rules**: Name, Active, Source table, condition, Type) and a **business rule** on the source table that applies the rules. Shipped business rules such as *Skill determination for interaction* must be active. Rule types:

| Type | Adds skills |
|---|---|
| Simple | listed in the Skills related list (Mandatory, Skill Level) when the condition matches |
| Lookup | from another table joined by reference fields (Lookup table, Skills Field, Field Mappings) |
| Advanced | by script |

If two rules add the same skill, one mandatory and one optional, the page's wording on which wins is cut off. Business rule body for a new source table (server-side, global scope, Advanced business rule):

```javascript
(function executeRule(current, previous /*null when async*/) {
    var skillUtils = new sn_skill_rule.SkillDeterminationUtils();
    skillUtils.assignSkillsToWorkItem(skillUtils.determineWorkItemSkills(current), current);
})(current, previous);
```

**Qualify and rank**: the `UserSkillAnalyzer` API decides whether a user is qualified (all mandatory skills, and mandatory levels) and measures level gaps; `UserSkillRanking` ranks the qualified users; FSM dynamic scheduling then assigns (add the *Matching Skill Level Gap* criterion to the task filter).

## Domain separation (Basic)

No set-up; all skill tables have Domain and Domain Path. Users see skills in their domain, parents see children; creating a skill for someone needs the same domain as that user. See [[Domain Separation Support Levels by Application]].

## Translation

Activate the language and Localization Framework, add the skill, load the translation into `sys_translated_text` (written as `sys_translated.text` on the page) for **Display Skill Name** and **Description**, set the session language; repeat for every new skill. See [[Languages, Translation Tables and Locale]].

ATF quick start tests (New York, Orlando) cover inheritance from groups, lowest-category rule and the Manage IT Skills page: [[ATF Quick Start Tests by Application]].

## Example

Level type *Example Language* with levels *Familiar* (10), *Proficient* (20), *Expert* (30); skill *Example French* in category *Example Languages*; group *Example Service Desk* gets *Example French* at *Proficient*, so *Test User*, a member, inherits it; a Simple determination rule on `incident` with condition *Short description contains French* adds *Example French* as mandatory.

## Related

- [[Assignment Rules and Data Lookup Rules]] · [[Users, Groups and Roles Overview]]
