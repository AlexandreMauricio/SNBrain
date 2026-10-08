---
type: how-to
tags: [how-to, platform, schema, service-catalog, flows, automation]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > App Engine Studio > Build > App creation tutorial (read 2026-10-08 through the docs site): Planning your application, Create an app, Building a data model (create, configure, share data between tables), Creating user experiences (add and configure a record producer), Adding logic and automation (build a decision table, create a flow: Ask for Approval, If, Make a decision, duplicate actions, Update Record, Else, Send Email, End Flow), Test your application. https://www.servicenow.com/docs/r/application-development/app-engine-studio/app-creation-example.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Build an App in App Engine Studio

**Goal:** build a small request-and-approval application with App Engine Studio: a table extending Task, a record producer, a decision table, an approval flow, and a test. Reference for every option: [[App Engine Studio Building Reference]]. Not tested on an instance.

**Needs:** admin or membership of *App Engine Studio Users* (`sn_app_eng_studio.user`) on a development instance; for the catalog part admin or `catalog_admin`; for the flow admin or `flow_designer`; for the decision table admin, `decision_table_admin` or delegated permission. No script is written; the flow runs server-side in the application's scope.

## Steps

1. **Plan**: the use case, the end-to-end sequence (with loops and exits), who does what, which data is collected, what is automated, which roles.
2. **Create**: **All > App Engine > App Engine Studio > Create app** > **Name**, **Description** > **Continue** > keep or add roles (admin and user are offered) > **Continue** > **Go to app dashboard**.
3. **Table**: **Data > Add > Create a blank table > Create from an extensible table** > Task (`task`) > **Table label**, tick **Auto-number** and give a **Prefix** > permissions per role (at least one with Read) > **Edit table**.
4. **Fields and form** (Table Builder, *Forms* view): delete inherited fields not wanted on the form; **+ Add a field in the table** for each new column (label, type); drag new and existing fields (for example Approval, Opened by) into *Default view*; choose one or two columns; **Save**.
5. **Reference data**: create a second table (for example by **Import a spreadsheet**); on its *Fields* page turn **Display** on for the column other tables should show; back on the main table add columns of type **Reference** pointing to it and place them on the form.
6. **Record producer**: **Experience > Add > Record producer** > name, short description > **Edit record producer**. In Catalog Builder: **Record submission table** = your table; location = a catalog; add containers and questions, each **mapped to a table field**; settings; access; **Submit**.
7. **Decision table**: **Logic and automation > Add > Decision** > name, *This application scope only* > **Edit decision table**: add an input (Reference to your table), a condition column on a dot-walked field, one row per case with operator *is one of*, a result column (Reference to User `sys_user`), a result per row > **Save**.
8. **Flow**: **Logic and automation > Add > Flow > Build your flow from scratch** > name > **Edit this flow**:
   - Trigger **Record > Created** on your table.
   - Action **Ask for Approval**: record = trigger record; rule *Approve or Reject* when *All users approve or reject*; approver = Opened by > Manager.
   - Flow logic **If** approval state is Approved; inside it **Make a decision** with your decision table (input = trigger record; untick *Use Branches* when all outcomes follow the same path).
   - Duplicate the approval action, move it under the decision, and set its approver to the decision's result pill.
   - A second **If** for that approval; inside it **Update Record** (approval, assignment group, state).
   - **Else** branches with **Send Email** to Opened by, another Update Record, and **End Flow**.
   - **Save**.
9. **Test**: **Activate** the flow. Impersonate an ordinary user, open **Self-Service > Service Catalog**, submit the record producer, end impersonation. In the flow select **Test**, pick that record, **Run Test**, open the execution details. Open the waiting approval from the record's *Approvers* related list (add the list through *Configure > Related lists* if absent), approve, refresh, and check the next branch ran.
10. **Submit** from the application home when ready ([[AEMC Pipelines and Deployments]]).

## Example

- Application **Example Trip Request**; roles admin (all rights) and user (create, read).
- Table **Trip request**, extends Task, numbers prefixed `TRP`. New fields: *Departure Date* (Date), *Return Date* (Date), *Estimated Fare* (Decimal), *Reason* (String), *From* and *To* (Reference to a **Station** table imported from a spreadsheet, display column *Name*).
- Record producer **Raise a trip request** in the Service Catalog: a dropdown *Reason* with three fixed choices, two date questions, two record-reference questions on Station, a single-line *Estimated fare* validated as number; all mandatory.
- Decision table **Regional approver**: input Trip request; condition on Opened by > Country code; three rows of countries; result a user per region (for example **Test User** for one region).
- Flow **Approvals workflow**: manager approval > regional approver from the decision table > on approval set Approval = Approved, Assignment group = **Example Group**, State = Closed complete; on either rejection email the requester "Trip request rejected" and end.

## Related

- [[App Engine Studio Building Reference]] · [[App Engine Studio Overview, Setup and Roles]] · [[Build a Flow in Workflow Studio]] · [[Create a Decision Table in Workflow Studio]] · [[Build a Request App in Creator Studio]]
