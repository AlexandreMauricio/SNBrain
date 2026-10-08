---
type: concept
tags: [concept, platform, automation, roles, domain-separation, data-integrity, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Testing and debugging applications (read 2026-10-08 through the docs site): Testing and debugging applications, Automated Test Framework (ATF), Exploring Automated Test Framework, Getting started with the Automated Test Framework, Build and run your first automated test, Next steps with the Automated Test Framework, Domain separation and Automated Test Framework. https://www.servicenow.com/docs/r/application-development/automated-test-framework-atf/atf-landing-page.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Automated Test Framework Overview

**In one line:** the Automated Test Framework (ATF) runs recorded sequences of steps (open a form, set values, submit, check a record, call a REST endpoint) against an instance and rolls its data changes back afterwards, to prove the instance still works after an upgrade, a deployment or development.

From the Brazil docs. Building and running: [[ATF Building and Running Tests]]. Suites, schedules and administration: [[ATF Test Suites, Schedules and Administration]]. Step catalogue: [[ATF Test Step Categories Reference]]. Records, properties and scripted steps: [[ATF Records, Properties and Custom Step Configurations]].

## Facts

- Plugin `com.glide.automated_testing_framework`, active by default. Menu: **All > Automated Test Framework**.
- **Running tests is switched off by default** so that nobody runs them on production by accident. Run only on sub-production instances: tests create, change and delete data.
- Everything a test creates or changes is tracked and **rolled back** when the test ends.
- Next Experience pages built with UI Builder, including their lists and forms, and landing pages are **not supported** by the standard steps (a Configurable Workspace category exists for forms and some components). Core UI forms and lists are fully supported.
- Custom step configurations can only run on the **server**.
- AI assistance: the *Test generation* skill, the Store application *ATF Test Generator and Cloud Runner*, and Test Agent ([[Autonomous Engineer and Test Agent]]).
- Other testing and debugging tools named beside ATF: Script Debugger (role `script_debugger`), session log, Script Tracer, Test Management 2.0, impersonation ([[Impersonation]]).

## Records

| Thing | Table | What it is |
|---|---|---|
| Test | `sys_atf_test` | a named group of steps that checks one feature |
| Test step | `sys_atf_step` | a step configuration plus the data for this test and an execution order |
| Step configuration | `sys_atf_step_config` | a kind of action ATF can perform (*Impersonate*, *Open a New Form*), with its input and output variables |
| Step variable | | an input or output value of a step; outputs can feed later steps |
| Test suite | | tests (and child suites) run in order; can be scheduled |
| Test result | `sys_atf_test_result` | status, duration, screenshots, logs of one run. Deleted after 30 days unless kept |
| Step result | `sys_atf_test_result_step` | status, summary and output of one step |
| Assert type | (a field on some steps) | the condition that makes the step pass, including "expected to fail" (for example *Record was not inserted*) |
| Client test runner | | a browser tab that executes the user-interface steps |
| Quick start test | | a ready-made test or suite shipped with an application's demo data, to copy and adapt |

## Roles

| Role | Can |
|---|---|
| `atf_test_admin` | everything: tests, steps, suites, runs, results, step configurations, **and edit ATF properties** (so only this role or admin can enable test execution) |
| `atf_test_designer` | the same except properties (read-only) and step configurations (read-only) |
| `atf_ws_designer` | view or set the basic authentication profiles used by REST steps |

## Step categories

| Category | Tests |
|---|---|
| Form | open a new or existing record, set and validate field values and states, UI action visibility, click a UI action or modal button, submit |
| Forms in Service Portal | the same on portal forms |
| List and Related List | list contents and list UI actions |
| Service Catalog; Service Catalog in Service Portal | open and search items, set and validate variables, price, quantity, cart, order, record producers, order guides |
| Application Navigator | menu and module visibility, navigate to a module |
| Custom UI | set, click and validate arbitrary page components; assert text on a page |
| Configurable Workspace | workspace forms and components |
| REST | send an inbound REST request to this instance and assert status, headers, time, payload |
| Server | impersonate, insert / query / update / delete / validate records, run server-side script (including Jasmine unit tests), log, create user |
| Email | generate inbound email, validate outbound email |
| Reusable Tests | call another test |

## A first test

Tests > **New** (name, description) > **Add Test Step** three times: *Open a New Form* on User (`sys_user`); *Set Field Values* (for example **First name** = Test, **Last name** = User); *Submit a Form*. **Run Test** > choose or start a client test runner > watch the progress dialog > **Go to Results**. The user record is rolled back at the end.

## Domain separation

Support level Standard. A test that depends on a domain must set it first: make the **first impersonation step** a user of that domain.

## Related

- [[ATF Building and Running Tests]] · [[ATF Test Suites, Schedules and Administration]] · [[ATF Test Step Categories Reference]] · [[ATF Records, Properties and Custom Step Configurations]] · [[ATF Headless Browser (Legacy Docker Runner)]] · [[Application Development Good Practices - Plan, Build, Validate, Deploy]]
