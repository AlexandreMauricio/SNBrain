---
type: concept
tags: [concept, integrations, api, flows, ai, roles]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Building spokes using Spoke Generator (read 2026-10-08 through the docs site; whole chapter): Building spokes using Spoke Generator, Create spoke and build actions by importing an OpenAPI Specification, by importing a Postman collection, Use ServiceNow Otto to create spokes and build actions (install, turn on the skill, configure a third-party LLM provider, create with the spoke generation skill), Create spoke and build actions manually, Add more actions to the custom spoke. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/spoke-builder.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Spoke Generator

**In one line:** a wizard in Workflow Studio (**New > Spoke**) that creates a scoped application for one external system and generates its flow actions from an OpenAPI specification, a Postman collection, a pasted piece of API documentation (AI), or by hand.

What a spoke is and the ones shipped: [[Flow Spokes Shipped with the Platform]]. The actions it generates are ordinary custom actions ([[Custom Actions, Dynamic Inputs and Error Evaluation]]).

## Requirements

| Need | Detail |
|---|---|
| App | *Spoke Generator* (`sn_spoke_builder`) from the Store; v5.0.0 in the Australia docs |
| Plugin | *IntegrationHub Starter Pack Installer* (`com.glide.hub.integrations.starter`) |
| Licence | Integration Hub; the *Professional Pack* (`com.glide.hub.integrations.professional`), in production and sub-production, for the OpenAPI, Postman and AI methods |
| AI method | *ServiceNow Otto for Creator* (`sn_now_creator`, separate subscription), skill **Spoke Generation** turned on under **AI Admin Hub > AI Skills > Creator**; Zurich or later, Spoke Generator 4.1.0+, Workflow Studio 28.0+ |

## Roles

| Role | Can |
|---|---|
| admin | create spokes, import specifications, create connection aliases, publish or draft actions, see the spoke activity log |
| `action_designer` | see the Spokes tab and a spoke's actions; add actions (manual method, and to an existing spoke with delegated access to its application) |
| `fd_read_actions` | see only |
| `flow_designer`, `flow_operator` | see flows and subflows |

## Wizard, common part

1. **Workflow Studio > New > Spoke**.
2. **Spoke Info**: a new scope (**Spoke name**, **Description**, **System**, **Connector type** = Spoke, a logo) or an existing application. The new scope is named `x_<company-code>_<spoke-name>_<spoke>`; the company code comes from property `glide.appcreator.company.code` (default `snc`).
3. If the Store already has a matching spoke it is shown: install that instead, or choose to build your own.
4. **Build Info**: choose the method.

## Methods

| Method | Steps | Result |
|---|---|---|
| **OpenAPI Specification** | **Import new** (from a URL, or pasted JSON / YAML) > create the **Connection and credential alias** (the authentication template and base URL are proposed from the specification; credentials can be filled later with *Do it later*) > **Generate operations** > tick the operations wanted > **Publish** or **Save actions as Draft** | one action per operation, each built on the OpenAPI step with inputs and outputs mapped |
| **Postman collection** | the same, importing the collection by URL or pasted JSON | the same |
| **With AI** | create the action categories first (`sys_hub_category`); paste the documentation of **one** API operation into **AI Context** > **Generate preview** (properties, inputs, outputs, steps) > adjust the text and **Regenerate preview** if needed > alias > category > **Publish** | one action per pass. Missing fields block publishing: save as draft |
| **Manually** | the spoke opens empty; **New action** > *From OpenAPI spec* or *Manually* (opens the action designer) | |

Credentials are entered in the connection and credential alias record, never in an action: use placeholders such as `<CLIENT_ID>` in notes and test data.

**Add more actions later**: **Workflow Studio > Spokes** > the spoke tile > **New action**.

## Spoke details page

Actions (**Published**, **Draft**), flows, subflows, and the **Spoke activity log**: one entry per generation or publish operation with status `new`, `processing`, `success` or `error`.

## OpenAPI limits

| Limit | Default | Property |
|---|---|---|
| Specification size | 10 MB (up to 100 MB) | `glide.rest.openapi.max_request_size` |
| Operations | 500 (1 to 1000) | `glide.rest.openapi.max_operation_limit` |

- Request bodies: JSON media types only.
- A schema with `additionalProperties`, or with no properties, yields a plain string output.
- Not supported from OpenAPI 3.0: `oneOf`, `anyOf`, discriminator, example, link, callback, security scheme and security requirement objects, tag, external documentation, server objects, specification extensions, recursive references, and the info fields termsOfService, contact, license.

## AI method notes

- The model provider for the skill can be changed: **AI Admin Hub > Settings > Manage AI models > Manage model providers > Edit model provider > Customize > Edit provider for skill** > *Spoke Generation OOB*; or in AI Skill Kit (`sn_skill_builder`) on the skill's deployment settings. Supported: Now LLM Service, Azure OpenAI, Google Gemini, Anthropic Claude on AWS.
- Output must be reviewed and tested; availability is restricted in regulated and some regional data centres; the text pasted is processed outside the instance.

## Related

- [[Flow Spokes Shipped with the Platform]] · [[Flow Action Steps Reference]] · [[Integration Options and Interfaces Overview]] · [[Saved Triggers and External Event Sources]]
