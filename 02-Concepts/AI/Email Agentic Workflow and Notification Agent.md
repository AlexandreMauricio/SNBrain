---
type: concept
tags: [concept, ai, email, notifications]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Notification agent and agentic workflows in Notifications" (pp. 2707-2723), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Email agentic workflow and Notification agent

**In one line:** two Now Assist features around email: an agentic workflow that reads inbound email, works out the **intent**, runs a subflow or drafts a reply; and a chat agent that builds notification records from a prompt. Both need a separate Now Assist subscription.

## Intent to action (inbound email)

Plugin Notifications Email Agents (`sn_notif_agents`). Three AI agents in sequence:

| Agent | Job |
|---|---|
| Intent Identification | finds one or more intents in the email and maps them to configured intents |
| Intent Executor | extracts the inputs and runs each intent's actions; runs the **default** action when nothing matches |
| Email Generator | writes the reply, as a **draft** for a human or sent automatically |

- **Intent** (**System Notification > Email > Email Intents**): name, description, conditions. **Intent actions**: *Subflow Invocation* or *Reply Email* (content guidelines, delivery mode Auto or Draft, an AI Search profile to answer questions, an email template containing the token `${INTENT_NOTIF_EMAIL_RESPONSE}`), with Order, Stop processing, Default, and execution criteria.
- Turn it on in **one** place only: the inbound action **Trigger Intent to Action** (order 999 by default, so it runs last), **or** the Workflow Studio flow of the same name.
- Missing inputs: property `sn_notif_agents.missing_inputs_execution_mode` = `request_missing_inputs` (default: stop and ask the sender), `skip_intents_with_missing_inputs`, or `execute_all_intents`.
- Runs with the **sender's** permissions, masked to roles shared with `sn_notif_agents.intent_executor`; guests use `guest_email_agent`. Extra access goes in as child roles of the executor role.
- Reply Email needs a **target record** on the email; drafts need **Assigned to** on that record.
- Roles: `sn_notif_agents.notification_ai_admin`, `.notification_ai_reader`, `.intent_executor`.

### Writing intents

Describe the user's full request, not a topic: "User requesting to cancel music subscription", not "cancel subscription". Include the detail that separates similar requests, separate action requests from information questions, and avoid intents that fire on a mere mention. The guide recommends that workflows produce drafts for human review instead of final results.

## Notification agent

From **Admin > Admin Home** > product overview > **Configure** > Notifications > **Configure with Now Assist**. Two intents: create or edit a notification. It checks for duplicates, fills name, table, trigger, template and recipients, shows them for review, then creates on confirm. Requires the Implementation Agent orchestration framework; role admin.

## Related

- [[Inbound Email Actions]] · [[Email Notifications]]
