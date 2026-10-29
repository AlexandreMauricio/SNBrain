---
type: concept
tags: [concept, platform, automation, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > ATF Test Generator and Cloud Runner (14 topics: intro, exploring, configuring the cloud user, generating tests, tests for flows and flow logic, executing with Cloud Runner, parallel testing, scheduling, BOQ log entries, roles), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/atf-test-generator-and-cloud-runner/atf-tg-cr-intro.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# ATF Test Generator and Cloud Runner

**In one line:** a Store application (admin only) that **generates** ATF regression tests by analysing the instance (forms, catalog items, record producers, and the flows behind them) and **runs** ATF tests on **Cloud Runner**, a headless browser hosted by ServiceNow, including in parallel and on schedules.

From the Brazil docs; not tested. Builds on [[Automated Test Framework Overview]]; the browser choice is in [[ATF Building and Running Tests]]; it replaces the self-hosted [[ATF Headless Browser (Legacy Docker Runner)]]. Also required by Build Agent UI validation and Test Agent ([[Autonomous Engineer and Test Agent]]) and by [[ReleaseOps]]. Available (from Yokohama) in GCC, SPP EU and SP, NSC, on premises and some regulated markets.

**Prerequisite:** the instance should be behind an **ADCv2** load balancer (ADCv2 migration KB; KB1639216 otherwise). A misconfigured ADCv2 or a client script that redirects login breaks Cloud Runner.

## Set up the cloud user (once, `admin`)

**Automated Test Framework (ATF) > Administration > Select Cloud User** > choose an admin user. Use a **dedicated** admin who is not *Web service access only*, not an *Internal Integration User*, not read only, and needs no password reset; selection takes a while because it starts a cloud browser and logs in. The modules are visible only to `admin`; an ATF test admin cannot see them.

## Generate tests

**ATF > Administration > Test Generator** (one generation at a time; others queue). Without **Advanced** it covers every table; **Advanced** offers: specific tables, **Maximum Test Count**, per table, per catalog item (default 10), **Create separate update sets per scope** or one **Scope for generating tests** (default Global), **Email** for the summary, **Presets** (saved filter sets; the *None* preset cannot be deleted; example presets editable) with condition sets per tab. **Start Test Generation**, then look in **Suites > ATF Generated Suite** (only tests that passed are kept; do not run it while generation is in progress). Only basic form and server steps are generated: open the form, set every mandatory field from sample data, validate after each step, submit, check the record.

| Property | Default | Meaning |
|---|---|---|
| `sn_atf_tg.generation.create_separate_update_set` | true | false = generated records go into the user's current update set |
| `sn_atf_tg.enable_flow_generation` | true | generate steps for the flows and flow logic behind catalog items and record triggers |
| `sn_atf_tg.unsupported_flow` | | flows (sys_ids or names, comma separated) to skip |
| `sn_atf_tg.unsupported_flow_logic` | | flow logic names to skip |

Flow steps are server steps wrapped by log messages; for catalog items (one flow per item) they come after record validation; triggers *Created* (after the first validation steps), *Updated* (at the end), *Created or Updated* (middle or end); several flows may share a trigger.

## Run on Cloud Runner

**Run Test Suite** (or **Run Test**) > **Pick a Browser** > **Cloud Runner** (or *Start a new test runner*). With Cloud Runner the tests of a suite run **in parallel**, ignoring execution order and *abort on failure* (unlike ordinary parallel runs, which run several suites at once). Two concurrent cloud runners by default; five more can be bought. Runs continue after the progress window is closed. Test data passes temporarily through a browser session in a ServiceNow data centre and is removed afterwards. An admin can hide the Cloud Runner choice by setting `atf_cloud_runner.radio_visible` to false.

**Schedules** (**ATF > Schedules** > New): Name, Active, Application, run frequency and time, **Run on cloud runner** (true for new schedules, false on existing ones); child tests keep running on Cloud Runner even if another browser is named; **Execute Now**. See [[ATF Test Suites, Schedules and Administration]].

**Logs**: **ATF > Administration > Browser Orchestration Queue** (BOQ) lists each generation and run with state and log entries (success with a *See generated tests* link, cancelled by the user, login redirected, API key deleted after the request went to BOS/BOQ).

## Example

Dedicated admin *Example ATF Cloud User* selected; Advanced generation on the catalog with *Maximum test count per catalog item* 5 into scope *Example App*; schedule *Example Nightly Regression* runs *ATF Generated Suite* daily at 02:00 on Cloud Runner.

## Related

- [[ATF Records, Properties and Custom Step Configurations]] · [[Build Agent]]
