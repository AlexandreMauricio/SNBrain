---
type: concept
tags: [concept, platform, update-sets, admin, roles, instance-admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Planning your application > Team Development (read 2026-10-08 through the docs site; whole section except the Versions pages, which are in Update Versions and the Merge Tool): Team Development, Exploring Team Development, When to use Team Development, Local changes, Local change lists, Pull exceptions, Team dashboard, Approve or reject a push, Back out a local change, Cancel a code review request, Change the parent instance, Check the review status of a pushed change, Compare a pushed version to a local version, Compare to peer instances, Ignore a local change, Pull a version, Push a version, Back out a push, Queue a local change for a push, Reconcile changes, Resolve a collision in Team Development, Resolve multiple collisions, Configuring Team Development, Access rights for developers, Create an exclusion policy, Define a remote instance, Enable a code review, Select the parent instance, Set up an instance hierarchy, Administer Team Development, Code reviews, Code review notifications, Code review workflow, Exclusion policies, Instance hierarchies, Pulls and pushes, Team Development process, Team Development roles, Versions and local changes. https://www.servicenow.com/docs/r/application-development/team-development/team-development-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Team Development

**In one line:** a branching scheme between **non-production** instances: each development instance has one *parent*; developers **pull** the parent's versions, resolve collisions, and **push** their queued changes up.

From the Brazil docs. It moves version records ([[Update Versions and the Merge Tool]]); a push lands on the parent as a completed local update set, so the rest of the route to production can be update sets.

## Never with test or production

- Never use a test or production instance as parent; production never has a parent.
- Backing out a change backs it out down the whole chain, including the source instance.
- Parent and child must be on the **same release family** (different family: error, no pull or reconcile; different patch: warning only).

## Vocabulary

| Term | Meaning |
|---|---|
| Parent | the one instance you pull from and push to; saved in property `glide.apps.hub.current` |
| Peer | another instance with the same parent; can be compared with, not pushed to |
| Remote instance | any other instance registered locally (**Team Development > Remote Instances**) |
| Local change | a customized record whose current version exists here but not on the parent; one per record, always pointing at the current version |
| Queue / Ignore | mark a local change for the next push, or keep it out of all pushes (for example a colour scheme that marks the instance). One queue per instance, whoever made the change |
| Reconcile | full comparison with the parent: rebuilds the local changes list and the count ready to pull. Automatic when a parent is chosen; run by hand after a clone or failover of the parent. Queue and ignore marks survive |
| Collision | pulled version and local current version both modify the same record |

## Setup

1. Provision a parent development instance on the release of production and clone production over it (recommended). Provision sub-development instances on the same release; optionally clone the parent over them.
2. On each sub-development instance, **Remote Instances > New**: **Name**, **Type** (development, test, UAT), **Active**, **URL** (unique: duplicates cause errors), **Username** / **Password** of an account on the remote instance, **Short description**. If the remote instance uses IP address access control, add this instance as an exception first.
3. **Team Dashboard** > choose the parent (a reconcile starts) > **Pull**.
4. Grant access.

| To | Needs |
|---|---|
| open the Team Development application | `admin` on that instance |
| register a remote instance, push to the parent, compare with a peer | the remote account has `admin` **or** `teamdev_user` there (`teamdev_user` gives no access to the application itself: it exists so the stored account need not be admin) |
| see **Code Review Requests** on the parent | `admin` or `teamdev_code_reviewer` (held by group *Team Development Code Reviewers*) |

**Exclusion policy** (**Team Development > Exclusion Policy**): **Name**, **Policy** (Push only, Pull only, Push and Pull), **Remote Instance** (blank = all), **Table**, **Conditions** (push-only policies). Matching changes produce no local change record (versions and update set entries are still written). Applied at reconcile time: a new policy takes effect at the next reconcile.

## Team dashboard

**Team Development > Team Dashboard**. Indicators refresh only on reload or **Refresh**.

| Control | Does |
|---|---|
| **Parent** / **Change** | connection status (hover for errors); pick another parent, which triggers a full reconcile: choose one freshly cloned to limit collisions |
| **Reconcile** | compare with the parent; results list *On Remote and not Local* (ready to pull) and *On Local and not on Remote* (to queue or ignore) |
| **Ready to Pull** / **Pull** | count on the parent not yet here; pull them |
| **Ready to Push** / **Push** | queued count; open the review page |
| **Local changes**, **Ignored**, **Collisions** | counts opening the lists |
| **Compare to** | compare with a peer |

Lists below: Local Changes, Pushes and Pulls (history; expand for the records), Instance Comparisons, Collisions, Ready to Push, Ignored. On a local change row: open the record, *Show Changes Since Last Pull* (can revert from the comparison; errors for a new record), *Show Application File*, *Show Version*.

## Working

| Action | How | Notes |
|---|---|---|
| Queue | filter Local Changes > **Queue All For Push**; undo with *Do Not Push* or switch with *Ignore This Change* | |
| Ignore | filter (for example everything in the Default update set) > **Ignore All**; undo with *Do Not Ignore* or *Queue for Push* | ignoring a record deletes its queued or under-review change; a later pull for it is a collision |
| Pull | **Pull** > *Show Results* | brings **all** user-made versions not yet pulled, history included (state History), no choice; never versions from upgrades. Logged in Push or Pull (`sys_sync_history`) |
| Push | queue, pull, resolve collisions, **Push** > name, comments, drop rows with *Do Not Push* > **Push Changes** | sends only the **current** version. A pull runs first and cancels the push on a collision. The parent validates and commits in dependency order (table before its fields) and creates a completed local update set carrying the name |
| Back out local changes | filter > **Back Out All**, or right-click > **Back Out** | restores the version of the last reconcile |
| Back out a push | **Pushes and Pulls** > the push > **Back Out** | |
| Compare with a peer | **Compare to** > peer > *Show Results*; per record *Compare to Current* or *Load This Change* | nothing is committed automatically; shares code without going through the parent |

- One application per push or pull: if changes of several applications are queued, unqueue the others, push, and repeat.
- No push while this instance has a change awaiting code review, or on a version conflict between the instances.
- Push results: **Pushed** = committed; **Skipped** = not committed and still queued here (read the log: table missing because a plugin is not active on the parent, an invalid version, an error on the parent).

Pulls leave out: records matching an exclusion policy, private properties (never in update sets either), collisions until resolved, corrupt or missing versions (*Skipped*); earlier collision decisions are remembered and reapplied.

### Collisions

All must be resolved before any pull or push. **Collisions** > right-click > **Resolve Collision**: **Use Local Version** (the pulled one goes into history), **Use Pulled Version**, or merge field by field with **>** and **Save Merge and Resolve Collision**. Several at once: tick rows > Actions > *Use Pulled Version* / *Use Local Version*. Some record and field types cannot be merged: [[Update Versions and the Merge Tool]].

## Code review

On the parent: **Team Development > Properties** > `com.snc.teamdev.requires_codereview` = Yes. This adds module **Code Review Requests** and holds every incoming push in stage **Awaiting Code Review**.

- Workflow *Team Development Code Review* (legacy workflow; change with care): starts on a push, checks the property, sets the stage, notifies the reviewers group, then loads the changes or sets *Code Changes Rejected*.
- Reviewer: **Code Review Requests** > the push > related list *Push or Pull Versions* (right-click > *Compare to Current*) > **Approve** or **Reject** with comments. The whole push, not single versions. **URL** and **Remote Instance** show where it came from.
- While a review is pending the child cannot push, pull, reconcile, change parent, or delete the parent's remote instance record.
- Developer: **Pushes and Pulls** on the pushing instance shows the stage; related list *Reviews* shows who decided and the comments. **Cancel Code Review** while still awaiting: the parent keeps nothing.

| Stage | Meaning |
|---|---|
| Awaiting Code Review | waiting |
| Complete | approved and applied on the parent |
| Collided | rejected because of a collision |
| Code Changes Rejected | rejected by a reviewer |
| Code Review Request Cancelled | cancelled by the developer |

Notifications (email must be enabled on the parent), both on `sys_sync_history`: *Code review update for developer* (push name, outcome, link; needs a user record with email on the parent) and *Notify code reviewer of canceled review*. The reviewers group is also told when a push needs review.

## Related

- [[Update Versions and the Merge Tool]] · [[Delegated Development and Deployment]] · [[Application Development Tools and Lifecycle]] · [[Clone Options and States]] · [[Personal Developer Instances]] (cannot link to customer instances)
