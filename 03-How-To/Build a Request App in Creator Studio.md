---
type: how-to
tags: [how-to, platform, service-catalog, flows, workspace, request]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Creator Studio > Creator Studio quick start (parts 1 to 6) and Creator Studio tutorial (parts 1 to 9), with the task pages Create an app, Add a form, Customize your form, Publish a form, Add an automated playbook, Add activities, Activate a playbook, Test one of your forms, Request deployment (read 2026-10-08 through the docs site). https://www.servicenow.com/docs/r/application-development/creator-studio/creator-studio-quick-start.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Build a Request App in Creator Studio

**Goal:** create a no-code request application: a form in the catalog, an approval playbook, a fulfiller list, then hand it to an admin for deployment. Concepts: [[Creator Studio Overview, Setup and Roles]]; all options: [[Creator Studio Administration, Building and Reference]]. Not tested on an instance.

**Needs:** membership of group *Creator Studio Users* (role `sn_creatorstudio.user`) on a non-production instance; a deployment pipeline configured by an admin before step 8; an admin for step 9. No script is involved.

## Steps

1. **All > App Engine > Creator Studio** > **Create app** > type *Service Desk* > **Continue** > **Name**, **Description** (optional *Advanced settings* for the scope) > **Create app**.
2. **+ Add form** > pick a catalog template (the *Creator Studio Default Template* if nothing fits) > **Apply template and continue** > tab **Build on your own**: **Form name**, **Short description**, **Long description** > **Save and edit form**.
3. Select each question and fill the *Question details* panel: **Question label**, **Content type**, *Show question on form*, *Mark as required*; for a record choices question the **Source table**. Drag more question types or layout elements from *Form elements*. **Save** each.
4. **Mark as ready** (this publishes the form on this instance). When prompted, **Edit location setting**: choose the catalog and category, and the Employee Center topic > **Save all settings**.
5. **+ Add automation** on the form > **Playbook name**, **Description**, **Trigger** = *Form submitted* > **Create**.
6. On the connector select **+** > **Add an activity** > choose the activity, give it a **Label**, complete its settings, set **When to start** > **Save and close**. Repeat; then **Activate**.
7. **List configurations** > select a list > **Manage columns** to add or reorder columns > **Apply** > **Save**. Optionally **Add a filtered list**.
8. Select the form > **Try it**, fill it in, **Submit**: check the created record (answers on *Details*, playbook results on *Automations*). Then **Submit for review** > **Continue** > tick *Visible to others* for the forms to release > **Continue** > tick *Run on production* for the playbooks > **Continue** > check **New version**, write **Release notes** > **Submit for review**. This cannot be cancelled.
9. Admin: **App Engine > App Engine Management Center** > pending request > **Approve** > **Approve and deploy app** > **Deploy** ([[AEMC Pipelines and Deployments]]). Then on production give fulfillers the role `<scope>.agent`.
10. Check: submit the form from Employee Center or the catalog; a fulfiller opens **Workspaces > Request App Workspace** and finds the request. The fulfiller closes it by hand when done.

## Example

A manager wants a way to ask for a small reward for a colleague.

- Application **Example Reward Request**.
- Form **Reward request** with four questions: *Internal store?* (Yes or no, required), *Amount* (single-line text, required), *Recipient* (record choices, source table User `sys_user`), *Justification* (multi-line text).
- Playbook **Reward approvals**, trigger *Form submitted*:
  1. *Request approval*, label "Manager approval", approver *Requester's manager*, *Anyone approves*, start *When playbook starts*.
  2. *Request approval*, label "Finance approval", approver group **Example Group**, *Anyone approves*, start *After specific activity* = Manager approval.
- List change: add column **Assignment group** to the *Open* list.
- Test with **Try it** as **Test User**: amount 20, any recipient.
- Version 1.0.0, release notes "First version".

## Related

- [[Creator Studio Overview, Setup and Roles]] · [[Creator Studio Administration, Building and Reference]] · [[Create and Test a Playbook]]
