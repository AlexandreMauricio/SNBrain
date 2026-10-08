---
type: concept
tags: [concept, platform, workspace, portal, javascript, ai, glossary, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Builder library (read 2026-10-08 through the docs site): Builder library, Create custom components using ServiceNow CLI, Develop a component for Virtual Agent, Add properties to communicate with Virtual Agent, Test a component for Virtual Agent, Add a component to Agent Workspace. The slider sample code is not reproduced. https://www.servicenow.com/docs/r/application-development/builder-library-table.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Builder Tools Overview and Custom UI Components

**In one line:** which builder makes what on the platform, and how a custom Next Experience component is written with the `ui-component` extension of the ServiceNow CLI, including the extra properties a Virtual Agent component needs.

From the Brazil docs.

## Which builder for what

| Builder | Makes | Vault note |
|---|---|---|
| Decision tables (Decision Builder) | decision logic kept out of code | [[Decision Tables]] |
| Flow Template Builder | templates guiding flow authors | |
| Process Optimization with Performance Analytics | process analysis on indicators | |
| Mobile App Builder | screens and navigation of mobile apps | |
| Mobile Card Builder | card templates for mobile lists, forms, maps, search | |
| NLU Workbench | language-understanding models for Virtual Agent | |
| Platform Analytics for workspaces | dashboards and visualisations inside workspaces | |
| Reports | reports on table data | |
| Service Portal Designer | portal pages from containers, rows and widgets | |
| Table Builder | tables, forms, UI policies, record flows | [[Table Builder]] |
| Theme Builder | colours and branding of Next Experience | |
| UI Builder | pages for workspaces and custom experiences | [[UI Builder Overview and Concepts]] |
| Virtual Agent Designer | conversation topics | |
| Workspace Builder | a workspace without code | [[Workspace Builder]] |

Where each file type is stored: [[Metadata File Types and Primary Tables]].

## Custom components (Next Experience UI Framework)

Write one only when the component library lacks what is needed. Prerequisites: web component and JavaScript knowledge, npm, a current Node.js, and the ServiceNow CLI with its `ui-component` extension ([[ServiceNow CLI]]: `snc ui-component project`, `develop`, `deploy`).

- A component is reusable, has its own encapsulated scope, and exposes **properties**, **slots** and **actions**.
- Data: the Http Effect API, or GraphQL through a scripted GraphQL schema.
- It deploys into a **scoped application**: scope up to 18 characters, snake case, `x_<company code>_<component name>` (company code from `glide.appcreator.company.code`); generated if not given, or set as `scopeName` in `now-ui.json`.
- Using it afterwards: in a workspace modal opened by a UI action; on a landing page through UI Builder (properties declared in `now-ui.json`); in the component area of a workspace record view.

### Virtual Agent components

Role to add them: `virtual_agent_admin` or admin. After deploying, register the component in Virtual Agent Designer as a custom control with a definition.

| Kind | Property / action | Purpose |
|---|---|---|
| Response (shows information only) | `controlData` (JSON object) | initial data sent by the Virtual Agent server while the topic runs |
| Input (collects an answer) | `controlData` | the same |
| | `responseValue` (JSON object) | the user's answer, from the client or from the server after a refresh |
| | `forceCloseControl` (Boolean) | true = the control is closed and takes no more input |
| | action `VA_CONTROL#VALUE_SENT` (JSON object) | dispatched by the component to send the answer to the server |

States of an input component: *waiting for input* (data set, not closed) > the user acts and the component dispatches the action and closes > *closed* (answered, or the chat ended) > rendered again on the user's side showing `responseValue`.

**Testing locally** (workstation; nothing is changed on the instance):

1. In the component's `package.json` add `@servicenow/sdk-ci` and `@servicenow/library-translate`.
2. Create `example/sampleProps.json` with the initial property values.
3. In the example entry file import the component, `@servicenow/sdk-ci` and the sample properties, create a `tool-ci-custom-control-tester` element, set its `componentTagName` and `initialExampleData`, and append it to the page.
4. Run the development server; the tester shows the input JSON and what the component returns.

```bash
snc ui-component develop --open --port 8081
```

## Related

- [[ServiceNow CLI]] · [[UI Builder Overview and Concepts]] · [[Workspace Builder]] · [[Table Builder]] · [[Application Development Tools and Lifecycle]]
