---
type: concept
tags: [concept, security, ai, email, data-management, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy (chapter read in full 2026-10-08). This note draws on - Data Privacy for ServiceNow Otto (landing, Exploring, Configuring), Data privacy for inbound emails, Create an inbound email channel policy, Data Privacy for Virtual Agent, Real time anonymization, Real time anonymization failures, Bring Your Own PII Detection Service, Create an external PII detection service configuration, and the Now Assist remarks on Configure Data Discovery patterns. https://www.servicenow.com/docs/r/platform-security/data-privacy-classic/real-time-anonymization.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Data Privacy Channel Policies - AI Prompts, Inbound Email and Virtual Agent

**In one line:** besides rewriting stored data, Data Privacy masks sensitive data **in transit** on a *data channel*: prompts sent to a large language model, inbound email, chat conversations, and entries into chosen columns; each channel has a policy listing the data patterns to mask.

From the Brazil docs. The Brazil pages call the generative AI product *ServiceNow Otto*; older text and menu names still say *Now Assist*. Overview: [[Data Privacy Overview]]. The patterns themselves: [[Data Discovery - Patterns, Policies, Jobs and Findings]].

## Real time anonymization (RTA)

- A policy of type **Real time data** (**System Security > Data Privacy > Anonymization > Create new policy**) with a data channel, or with target columns.
- For columns: every entry is checked against the **active data patterns**; a match is rewritten with the technique set on that pattern.
- Failures: **System Security > Data Privacy (Classic)**, the real time anonymization failures table (role `admin`): table, column, record, privacy configuration, failure reason and details, timestamp.

## Generative AI prompts

- **Two-way masking:** matches are replaced by placeholders or anonymized values in the prompt, and the originals are put back in the response. The user therefore sees unmasked data; the point is that the model never receives it.
- Role `now_assist_data_privacy_admin`; no full licence is needed to configure it. Available from Yokohama (Xanadu used the Sensitive Data Handler, whose regular expressions are migrated).
- **All > Data Privacy (Classic) > Privacy Policy Advanced Configuration** > **New**: name, **Data Channel**, **Active**; reopen the record > **Select Data Patterns**.

| Data channel | Sanitizes |
|---|---|
| **Now Assist** | data before it goes to the Generative AI Controller |
| **Data Kit** | data used to evaluate AI models |
| **Data Extraction** | data before it is sent for model training |

- Only **one active configuration per data channel**.
- A pattern applies to prompts when it is associated with the Generative AI data channel; it then applies to skills, Virtual Agent, AI agents and custom skills alike. The pattern's technique decides the mask: synthetic replacement (a plausible fake), static replacement, selective replacement with x, or remove.
- Named entity recognition (NER, *Model* type) patterns need a Vault licence, an extra zero-cost SKU and the latest Generative AI Controller, and are rate limited; beyond the limit only the regex patterns apply. Discrepancy: the *Exploring* page states that only regex patterns are supported and contextual (model) patterns are not, while the landing page and the NER page describe NER masking for prompts.
- Availability of AI features varies for in-country, FedRAMP and other restricted, self-hosted and regulated-market customers.

### Bring your own PII detection service

- Routes the inline guardrail for prompts to **your own** detection service instead of the built-in patterns. It does not touch data stored on the platform. Needs a Data Privacy or Vault licence.
- **System Security > Data Privacy > Anonymization > External Anonymization Services > Create new service** (roles `data_privacy_processor` and `admin`): **Service label**, a script that shapes the request and maps the response back, the authentication details, **Active**, **Default** (one default only), **Test Connection** with sample text, then **Publish**.
- Services can be deactivated without deleting them. Advice from the docs: test in non-production, watch response times, plan a fallback service.

## Inbound email

- Detects and redacts sensitive data in inbound emails and the inbound actions they trigger ([[Inbound Email Actions]]). Requires the *Sensitive Data Redaction for inbound emails* plugin.
- **Anonymization > Create new policy > Real time data**, name, **Data to process** = *Inbound email*, **Select data patterns**, **Save** (draft) or **Publish** (active). Roles `data_privacy_admin` and `admin`.
- On upgrade to Brazil, existing redaction settings and their active patterns become an email channel policy; with no patterns, an empty default policy is created.
- Attachments may not be covered.

## Virtual Agent and Agent Chat

- Role `virtual_agent_data_privacy_admin`. Replaces the deprecated Sensitive Data Handler (KB0867184); its settings are migrated as a policy.
- **All > Conversational Interfaces > Settings > Sensitive data detection > View all** (the button reads *Get data privacy* if the application is missing): set **Active**, pick at least one flow, then **Manage in Data Privacy** to create the policy.

| Flow | Masks what |
|---|---|
| Requester to agent | the requester types in Agent Chat |
| Agent to requester | the agent types in Agent Chat |
| Requester to Virtual Agent | the requester types to the bot |

Virtual Agent setup: [[ITSM Virtual Agent Topics and Setup]].

## Related

- [[Data Privacy Overview]] · [[Real Time Protection - Alerts, Blocking and Attachment Quarantine]] · [[Tokenization of Sensitive Data]] · [[ServiceNow Vault and Otto for Vault]]
