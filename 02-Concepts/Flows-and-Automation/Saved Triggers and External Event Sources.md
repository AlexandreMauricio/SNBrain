---
type: concept
tags: [concept, flows, automation, integrations, roles]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Build triggers (read 2026-10-08 through the docs site): Building triggers, Create a saved record-based trigger, Create a saved scheduled trigger, Create a scheduled trigger using business calendar, Create a saved external trigger, Managing external event sources, Use a saved trigger, Edit a saved trigger, Detach a saved trigger from a flow, Delete a saved trigger; plus the Triggers and Wait conditions parts of General guidelines for Workflow Studio flows, subflows, and actions. Section start https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/building-triggers.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Saved Triggers and External Event Sources

**In one line:** a saved trigger is a start condition defined once (**New > Trigger** in Workflow Studio) and reused by many flows; changing it changes every flow that still uses it.

Per-flow triggers and the trigger list: [[Building Flows - Properties, Triggers, Stages and Error Handling]]. Every trigger type and its options: [[Flow Trigger Types Reference]].

## Roles

| Role | Can |
|---|---|
| `trigger_designer` | create, edit, delete saved triggers and external event sources |
| `trigger_designer_read` | read external event sources |
| `flow_designer`, admin | all of the above (flow_designer contains trigger_designer), and use a saved trigger in a flow |

## Trigger properties (all three kinds)

**Trigger name**, **Trigger type**, **Description**, **Application** (scope; default Global), **Domain**; under *Show additional properties*: **Accessible from** (this scope or all scopes), **Protection** (read-only), **Category**, **Trigger annotation** (text an author sees before choosing it). Then **Build trigger**, fill the definition, **Publish**. Changes save automatically.

## Record-based

Type **Record > Created / Updated / Created or updated**. Definition: **Table**, **Conditions**, **Advanced options** (where and when to run).

For the conditions and for the advanced options you decide whether flow authors may *view* them and whether they may *add conditions / modify options*. Once an author modifies the advanced options in their flow, later changes you make to those options in the saved trigger no longer reach that flow.

## Scheduled

Type **Scheduled > Recurrence**. **Time zone**, **Start date and time**, then **Repeat**:

| Repeat | Detail |
|---|---|
| Daily | every N days |
| Weekly | every N weeks, on chosen weekdays |
| Monthly | every N months, on a fixed day or a relative weekday (first Monday) |
| Yearly | chosen month, fixed day or relative weekday |
| Time interval | `hh:mm:ss`, for example 47:30:00 |
| Does not repeat | once |

**End**: never, or *On this day* with a date and time.

### On a business calendar

A calendar-date schedule ignores weekends and holidays. Instead point the trigger at an existing business calendar (the trigger does not create one):

| Field | Meaning |
|---|---|
| **Business calendar** | which calendar |
| **Business calendar type** | fire at the *start* or the *end* of each calendar entry (start of week, end of shift) |
| **Offset option** | No offset, after, before; then **Offset number** (for example 60 minutes before the shift starts) |
| **Business calendar condition** | exclude some calendar entries |

## External (webhook)

Type **External > Event (Webhook)**. Needs an Integration Hub subscription and plugins *ServiceNow Integration Hub External Trigger* (`com.glide.ih.external_trigger`, for shipped external triggers) and *External Trigger Builder* (`sn_ext_trg_bldr`, to save your own).

1. Have an **event source** (below), or use one shipped with the Jira, GitHub, Docusign eSignature or Microsoft Azure DevOps Boards spokes. Choose the spoke's scope as **Application** and the **Event source**.
2. **Parser**: **Trigger output name**, optional **Request headers** and **Query parameters**.
3. **Body**: paste a sample event payload (JSON) from the other product's webhook documentation > **Visualize objects**: each property becomes a pill; reorder or remove them.
4. **Condition editor**: drag pills into condition sets (and / or, **+ New condition set**).
5. **Publish**. After publishing only the output **Label** fields can be edited.

### External event sources

An event source is the endpoint on the instance that the other system posts to; trigger definitions listen to it. **Workflow Studio > Integrations >** the spoke **> Event sources > Create event source** (name, description; created as draft), choose **Authentication**, **Publish**.

| Authentication | Extra fields |
|---|---|
| Basic | none: the sender's user name and password are checked |
| OAuth | none |
| Hash | **Authentication Location** (query parameters or header), **Parameter Name**, **Hash algorithm** (HmacSHA256, HmacSHA384, HmacSHA512), **Prefix**, **HMAC Util Script** |
| Token | **Authentication Location**, **Parameter Name**, **Prefix** |

A draft can be changed completely; a published one only in name and description (ellipsis > **Properties**). It cannot be deleted while a trigger uses it.

## Using, editing, detaching, deleting

- **Use**: in the flow, **Add a trigger** > under *Installed applications* pick the scope > the trigger (info icon shows details). If allowed, add conditions: they affect only this flow.
- **Edit**: **Triggers** list > trigger > **Edit trigger** > change conditions or options > **Publish**; review the list of flows using it first. Type and table cannot be changed. Properties: More Actions > **Properties**.
- **Detach**: trigger > More Actions > **Associated objects** > flow > **Detach saved trigger**. The conditions are copied into the flow as its own trigger. Do this for flows the new definition would not suit.
- **Delete**: only when no flow uses it (detach first).

## Trigger design guidelines

- Put the condition in the trigger, not in a *Wait For Condition* as the first step: a waiting flow costs more than a flow that never started.
- Flows on the same table need distinct conditions: with identical filters the run order is unknowable and they can overwrite each other.
- Record triggers do **not** fire for records created or changed by committing an update set or importing XML.
- Service Catalog tables are not offered for record triggers: use the Service Catalog trigger.
- No existing trigger fits? Start a **subflow** from a script rather than giving a flow a dummy trigger ([[Flow Administration, Execution Details and Access]]).

## Related

- [[Flow Trigger Types Reference]] · [[Building Flows - Properties, Triggers, Stages and Error Handling]] · [[Flows, Subflows and Actions Overview and Architecture]]
