---
type: approach
tags: [approach, email, flows, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Inbound email", topic "Automating system responses to inbound email" (pp. 2656-2658), read 2026-10-01. The flow side is only outlined in this guide
sn-release: Australia
verified:
updated: 2026-10-01
---

# Processing inbound email: flow or inbound action

**Problem:** react automatically to an email received by the instance.

## Options

### A. Inbound email flow (Workflow Studio)
- **How:** a flow with an inbound email trigger (**Flow Designer > Inbound Email Flows**). Details to be documented from a Workflow Studio source.
- **Pros (as the guide states them):** natural-language interface; configuration and runtime information in one place; reusable actions; upgrade-safe logic instead of custom script.
- **Cons:** not described in this guide.
- **Status:** documented (overview only)
- **Best when:** new automation, especially where people who do not script maintain it.

### B. Inbound email action (script)
- **How:** see [[Create an Inbound Email Action]]
- **Pros:** full scripting access to the email and the record; the base system's incident handling is built this way.
- **Cons:** script to maintain; runs only after flows.
- **Status:** documented
- **Best when:** existing actions to extend, or logic that needs code.

## Recommendation

The guide presents flows as the preferred route for new work. Remember the precedence: **flows are evaluated first**, and a flow that stops processing prevents inbound actions from running, so mixing both on the same kind of email needs care. Sample flows mirroring the classic actions exist (*Inbound Email Flow Example: handling email replies*, *logging a problem*).
