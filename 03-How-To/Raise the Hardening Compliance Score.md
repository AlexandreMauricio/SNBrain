---
type: how-to
tags: [how-to, security, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Security Center (chapter read in full 2026-10-08) - Security hardening, All settings, Hardening settings details, Filter hardening settings, Increase hardening compliance score, Hardening score comparison, Automatic Security Task generation, Best Practices (Monitor your instance's Hardening Compliance level). https://www.servicenow.com/docs/r/platform-security/security-center/increase-hardening-comp-score.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Raise the Hardening Compliance Score

**Goal:** bring the instance's security settings in line with the recommended values, starting with the changes that count most.
**Prerequisites:** role `admin` (or `sn_vsc.security_center_admin`); a non-production instance to try changes on first.
**Navigation:** All > System Security > Security Center > Security configuration console > Security hardening > All settings

Background and the score formula: [[Security Center]].

## Steps

1. Open **All settings**. Filter **Compliance Status** to non-compliant.
2. Sort by **Score Impact**, largest first.
3. Open a setting. Read **Functional impact** (what may stop working), the description, and **Setting configuration** (which property or plugin is wrong and the value expected). One setting can involve several properties.
4. Decide: comply, or accept the risk for a stated reason. For work to hand over, **+Create task** makes a Security Task.
5. Make the change on a non-production instance, test the affected feature, then move it to production through your normal change route.
6. Back on the security hardening page, select **Update score** (otherwise the score is recalculated only on the first of the month).
7. Compare: **Hardening score comparison** with an older and a recent date shows which settings changed and by how much.

## Result / how to check it worked

The setting shows *Compliant*, the percentage rises, and the trend chart gains a point. No Security Task of type *Hardening score deviation* is generated (those appear when the score drops by 3 points or more from one day to the next).

## Example

The instance shows 78%. Sorted by impact, the top non-compliant setting is one about session behaviour with priority *High*. On the test instance the administrator sets the property named in *Setting configuration* to the recommended value, has *Test User* log in and work through a normal form, sees nothing break, and promotes the change. After **Update score** the instance shows 81%. A saved filter *Example Group review* (non-compliant, priority Critical or High, shared with *Example Group*) becomes the team's working list.

## Tables / fields involved

- Hardening settings (table name not given in the pages read (?)): **Compliance Status**, **Score Impact**, **Priority**, **Security category**
- [[System Properties Reference]] (`sys_properties`): most settings are properties

## Gotchas

- The score is rounded **up** (86.75 shows as 87).
- The docs' guidance: as close to 100% as possible without breaking functionality, never below 83%.
- Some settings are plugins that need activation, not properties.
- Filters saved in the list can be shared with everyone or a group, but the people must also have access to Security Center.
