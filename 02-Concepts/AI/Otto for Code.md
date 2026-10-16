---
type: concept
tags: [concept, ai, scripting]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > ServiceNow Otto for Code, topics "ServiceNow Otto for Code", "Exploring", "General guidelines for code generation", "Configuring", "Install", "Configure AI model providers", "Enable or disable AI skills", "Using", "Generate code", "Generate code with autocomplete", "Add comments to code", "Explain and summarize code", "Tracking AI-generated code", "Properties", "Roles", "Keyboard shortcuts", https://www.servicenow.com/docs/r/api-reference/scripts/now-assist-code-landing.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Otto for Code

**In one line:** generative AI inside platform script editors (forms and Workflow Studio script steps): generate code from a prompt, autocomplete as you type, edit, comment, explain and summarise code.

## Setup

- Part of **Creator Pro Plus**. Install **ServiceNow Otto for Creator** (`sn_now_creator`) from the Store; it installs Otto for Code (`sn_now_assist_code`). Check the skills under **AI Admin Hub > Skills > Creator**; they are on by default and can be turned off there.
- Model providers: Now LLM Service, Azure OpenAI, Google Gemini, Anthropic Claude on AWS. AI stewards allow providers in **AI Control Tower**; admins set defaults in **AI Admin Hub > Settings > Manage AI models** (whole instance, per skill group or per skill); each user can pick another allowed provider from **Settings** in the editor.
- Roles: `now.assist.creator` to use it; `now_assist_code_admin` (elevated) to manage it.
- Not available in FedRAMP, NSC DoD IL5, Australia IRAP-Protected, self-hosted and some regions (KB0743854). Data goes to a central environment and possibly Azure; inputs, outputs and the scripts where it is called are collected unless opted out.

## Skills

| Skill | Use |
|---|---|
| **Code generation** | right-click > *Open Code with Otto* or Ctrl+Enter (Cmd+Enter); prompt under 1,000 characters; suggestion highlighted, **Accept**, **Reject** or revise; inline or floating prompt box |
| **Code autocomplete** | grey suggestion after you stop typing; Tab accepts, Esc rejects; uses retrieval-augmented generation; turn off per session in editor **Settings** |
| **Code edit** | rewrite a highlighted block in context |
| **Add comments**, **Summarize code**, **Explain code in detail** | from the Otto menu on selected code |

Prompt guidance from the docs: short, specific, name the API ("Use GlideAggregate to count P1 incidents closed between March 3 and April 13 assigned to admin" rather than "Count P1 incidents"); a hint appears at 200 characters and more than 300 is refused in one prompt box (the generation page says under 1,000: two different limits on two pages). Always review and test the code.

## Tracking AI-written lines

Accepted lines get a marker beside the line numbers until edited. Kept 6 months by default: change **Age in seconds** of the `sys_auto_flush` record for `sn_now_assist_code_ai_generated_lines`. Tracking adds records to update sets; turn it off with `sn_now_assist_code.show_ai_code_line_marker` = false.

## Properties

| Property | Default |
|---|---|
| `sn_now_assist_code.enable_code_assist` | true (code generation in editors) |
| `sn_now_assist_code.enable_promptless_experience` | false |
| `sn_now_assist_code.enable_prompt_modal` | true |
| `sn_now_assist_code.show_ai_code_line_marker` | true |
| `sn_now_assist_code.collect_schema_for_code_assist` | true (table and script schema for context; off = faster, less relevant) |
| `sn_now_assist_code.log_edited_response` | true (admin role needed to change) |
| `sn_now_assist_code.async_max_payload_size` | 7056 bytes (under the 8 KB message bus limit) |
| `sn_now_assist_code.enable_autocomplete` | true |
| `sn_now_assist_code.disable_snowsk8s_autocomplete` | false |

Names taken from the page's summary, where underscores were lost (`snnowassistcode...`); restored by analogy with the first property, so treat the exact spelling as unconfirmed.

## Related

- [[JavaScript Syntax Editor]] · [[Otto for Creator and Otto for App Engine]] · [[AI Authoring for Catalog Builder]]
