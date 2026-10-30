---
type: concept
tags: [concept, ai, roles, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, Conversational Interfaces > Virtual Agent (236 topics; Explore, chat experiences, LLM topic discovery, Configure, Create assistants and Build conversations overviews, roles and tables start), (Legacy) Virtual Agent for NLU landing, read at overview depth 2026-10-30. Topic control property sheets, messaging integrations (164 topics), Bot Interconnect and most of Legacy NLU (250 topics) not read. https://www.servicenow.com/docs/r/conversational-interfaces/virtual-agent/chat-experiences.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Virtual Agent Overview and Assistant Designer

**In one line:** the platform's chatbot: conversations are built as **topics**, and an LLM or an older NLU model decides which topic answers the user.

From the Brazil docs; not tested. Two names to keep apart: **Virtual Agent** is plugin `com.glide.cs.chatbot`; **ServiceNow Otto for Virtual Agent** is `sn_nowassist_va`. ITSM content is in [[ITSM Virtual Agent Topics and Setup]].

**Direction:** from Brazil, Virtual Agent for NLU and Virtual Agent Lite are being prepared for future deprecation, and the docs now label NLU as Legacy. For new work, use LLM topics.

## LLM and NLU

| | LLM topics | NLU topics |
|---|---|---|
| Discovery | plain-language **description** on the Properties tab | intents, backup keywords |
| Entities | extracted by the LLM | mapped by the author |
| Topic switching | in natural language | harder |
| Effort | no model training | models to train and maintain |

The topic description is therefore the key field. If several topics match, the user chooses.

## Assistant Designer

The central place to create, test and analyse chat and voice assistants.

- An **LLM topic must belong to an assistant**, or it cannot be discovered or tested. The default is the *ServiceNow Otto for Virtual Agent* assistant.
- **Asset library:** a diagram tool for topics, topic blocks and other assets.
- **Promote or demote** assets to reorder them.
- **Test assistant** on the home page appears only when an assistant is selected.
- **Analytics** tab: performance of assistants.

## Chat experiences

| Feature | Standard | Enhanced | Premium |
|---|---|---|---|
| Topic flows, post-chat survey | yes | yes | yes |
| Generative AI responses | no | yes | yes |
| Knowledge search | basic | AI | AI |
| Dynamic search window, chat history | no | yes | yes |
| Third-party messaging | no | no | yes |

Each tier depends on licensing. Premium appears across the platform and adapts to where the user is.

## Building a topic

Controls cover user input, bot responses and utilities such as **Decision** branching. Topics can use script variables, topic blocks and custom controls. **Setup topics** apply to all conversations (for example greetings); **small talk topics** handle casual talk. A topic must be **published** to reach users. Configuration needs `virtual_agent_admin` or `admin`.

Custom controls can hold secure `password2` inputs, passed to a Workflow Studio action, but only following its scoped application requirements. **Run as**: *User who initiates session* or *System User*.

## Delivery

- **Portable chat widget:** on third-party pages, Service Portal or UI Builder portals.
- **Custom chat integrations:** Custom Chat Configuration Integration Framework (CCCIF) for third-party clients.
- **Messaging apps:** Slack, Teams and others, through integration apps.
- **Virtual Agent notifications:** sent to users through the chatbot on supported channels.
- **Agentic conversations:** Virtual Agent can plan across AI agents, topics, and conversational actions and subflows.
- **Domain separation:** supported, but Service Portal is not, so create portal versions restricted to a domain for chat.

## Roles and tables

`virtual_agent_admin` is the parent role and contains the sub-roles, such as `va_branding`, `action_designer`, `flow_designer`, `image_admin`, `external_app_install_admin`, `search_application_admin`, `evam_admin`, `localization_requestor`, `sn_ace.ace_user`.

`com.glide.cs` installs user `virtual.agent`, which ongoing conversations are assigned to.

| Table | Holds |
|---|---|
| `sys_cs_topic` | topics |
| `sys_cs_conversation` | conversations |
| `sys_cs_message` | messages |
| `sys_cs_deflection_log` | deflection records |
| `sys_cs_channel`, `sys_cs_provider`, `sys_cs_provider_application` | channels and providers |
| `sys_cs_custom_control`, `sys_cs_custom_control_definition` | custom controls |
| `sys_cs_branding_setup` | web client branding |
| `sys_cs_adapter_card` | adapter cards |

Meanings beyond the page text are inferred from the names.

## Example

LLM topic *Example View My Tickets* has the description "Shows the user their open incidents", belongs to assistant *Example Help Assistant*, and is published. *Test User* asks "what tickets do I have open?" in Test assistant.

## Related

- [[ITSM Virtual Agent Topics and Setup]] · [[Conversational Catalog Requests and Virtual Agent]] · [[Advanced Work Assignment and Live Agent Tools]] · [[Authentication Factors for AI Voice Agents and Human-Assisted SMS OTP]] · [[AI Search Indexing, Relevancy and Result Differences]]
