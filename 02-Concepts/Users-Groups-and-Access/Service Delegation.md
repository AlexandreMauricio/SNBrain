---
type: concept
tags: [concept, users, notifications]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Self-service > Service Delegation, Add the Delegates related list to a user profile, Delegate approvals and tasks to another user, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/self-service/c_ServiceDelegation.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Delegation

**In one line:** a user names another active user as **delegate** for a date range; the delegate can then act on the user's approvals and/or assigned tasks and get copies of their emails.

From the Brazil docs; not tested. Users overview: [[Users, Groups and Roles Overview]].

## Rules

- The delegate sees **all** pending tasks and approvals of the user, whatever the delegation dates.
- No cascading: a delegate cannot delegate onwards; only the original delegate gets the assignments and emails.
- Delegation gives no access to tasks where the delegating user is the **caller** or **requester**.
- To approve from a Service Portal the delegate needs `approval_admin` or `approver_user`.

## Set it up

1. Show the **Delegates** related list on the profile (`personalize_list` or `admin`): **Self-Service > My Profile** > form context menu > **Configure > Related Lists** > add *Delegate->User*. Or switch to a view that has it (ITIL or Default).
2. **Self-Service > My Profile** > Delegates > **New** (no role needed): **Delegate** (active user), **Starts** / **Ends**, and check boxes:

| Check box | Effect |
|---|---|
| Approvals | approves on the user's behalf |
| Assignments | sees and works tasks assigned to the user |
| All notifications | copies of the user's emails except Meeting Invitations; without it, a delegate with only Approvals gets **no** approval emails |
| Meeting invitations | copies of Meeting Invitation emails |

The emails are identical to the user's ("Incident assigned to you"), so tell the delegate. Notifications can opt out with **Exclude delegates** ([[Email Notifications]]).

## Example

*Test User* goes on leave and adds *Example Delegate* with Starts and Ends covering the leave, Approvals and All notifications ticked, so approvals reach the delegate by email too.

## Related

- [[Delegated Requests and Requests from Other Records]] (requesting on behalf of someone, a different feature) · [[Classic Approvals]] · [[Granular Admin Roles]] (role delegation, also different)
