---
type: reference
tags: [reference, platform, automation, instance-admin, data-management, update-sets, api, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Testing and debugging applications > Automated Test Framework (ATF) (read 2026-10-08 through the docs site): Building and running automated test suites (create, copy, filter, add test, add child suite, run, schedule, run a scheduled suite using a script, re-run failed tests), Parallel testing, Accelerate ATF tests failure resolution, Metadata exception list, Performance profiling, Administering the Automated Test Framework, Creating custom test step configurations (and categories), Working with test step templates, Testing Configurable Workspace components, Enable or disable executing tests, Modify data retention policy, Manage test client runner policies, Moving automated tests between instances, Compare results and execution times, Administering REST test step configurations (auth profile, header filter, REST properties), Optimizing automatic test performance (screenshots, transaction data), Working with scheduled test suites, ATF Code Coverage. https://www.servicenow.com/docs/r/application-development/automated-test-framework-atf/atf-suites-overview.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ATF Test Suites, Schedules and Administration

**What it is:** grouping ATF tests into suites, scheduling them, running in parallel, analysing failures and performance, code coverage, and the administration settings (enabling execution, retention, screenshots, REST profiles, templates).

From the Brazil docs. Building single tests: [[ATF Building and Running Tests]]. Scripted step configurations, record fields and the full property list: [[ATF Records, Properties and Custom Step Configurations]].

## Suites

A suite holds tests and child suites; a test holds only steps.

| Task | How |
|---|---|
| Create | **Suites > New**: **Name**, **Description**, then either a **Filter** (condition on tests: the suite is dynamic, new matching tests join by themselves) or rows in *Test Suite Tests* |
| Per test in the suite | **Execution order**; **Abort on Failure** (default false: the suite goes on after a failure) |
| Nest | on the child suite set **Parent suite** |
| Copy | **Copy Test Suite** copies nested tests and child suites; only from the suite's own scope; failures are skipped with a warning |
| Run | **Run Test Suite** (browser dialog if any UI step) |
| Re-run | **Re-run failed tests** on the suite result or progress viewer: everything not passed (failure, error, skipped, canceled; not *Success with warnings*). A new result hierarchy is created; tests added or deactivated since are not run; **Previous suite result** links back |
| Compare | suite > *Test Suite Results* > select rows > **Compare test results** (execution times); **Display aging report** (passed versus failed across runs). For one test: *Test Results* > **Compare test step results** |

## Schedules

Three records: the suite, a **suite schedule** (when), and a **scheduled suite run** joining the two (a schedule can run many suites and the reverse). Only suites can be scheduled.

1. **Schedules > New**: name, **Run** (frequency, or *On Demand*), time, time zone, optional **Conditional** script.
2. *Scheduled Suites* related list > **New**: the suite, client constraints for UI steps (browser, OS), and a **watch list** of people to email when it ends.
3. For UI steps a **Scheduled Client Test Runner** tab matching the constraints must already be open on an unlocked, powered machine (or use the headless or cloud runner: [[ATF Headless Browser (Legacy Docker Runner)]]). The system cannot open one itself.

Start a scheduled suite immediately from a server-side script (Scripts - Background or a CI job, global scope; it starts real test runs):

```js
// returns the sys_id of the progress worker (sys_progress_worker)
new sn_atf.ScheduledRunsExecutor().setScheduleSysId('<sys_id of the suite schedule>').start();
```

The completion email shows counts of suites and tests by status (F failed, E error, S skipped, C canceled, P passed) and a per-test history with links; by default only suites with failures (an email property changes this). Email sending must be on.

## Parallel runs

- Limit: `max(1, worker threads - 2)` tests at once; beyond that, tests wait in `sys_trigger` until a worker frees up. Two or fewer worker threads: have the instance reviewed.
- Design tests to create their own data; mark tests that share a resource as mutually exclusive.
- After design, the docs recommend one hierarchical base suite rather than many loose parallel runs.

## Failure analysis

On a **failed** test result: **Find changes since last successful run** fills a *What changed* list with metadata records modified between the last pass and this failure; **Comparison** shows the two versions; **Create a task** opens one task for the selected records (an incident by default; `sn_atf.test.triage.task.type`). Not covered: declarative action tables, Service Portal structure tables (`sp_page`, `sp_portal`, `sp_css` ...), several `sys_ui_*` help and homepage tables, `sc_catalog`, `sc_cat_item`, `catalog_script_client`.

## Performance profiling

**Run Performance Test** (or **Run Performance Suite**): one warm-up run (not counted) then 10 sequential runs; the system first waits for running jobs to finish; one test at a time. Results: *Performance Test Results* list, **Performance Profiling > Performance Runs**, and **Performance Comparisons** between two runs (means and delta). Use it before and after an upgrade.

## Code coverage (since Australia)

Records which lines of custom scripts ran during ATF runs: server-side (business rules, script includes, workflow scripts), client-side (client scripts, UI policies), global or per scope; aggregated per test, suite, script and deployment.

- **ReleaseOps uses it**: by default a deployment request whose custom code has under **70%** coverage moves to *Reconciling* and a test failure task is created; the threshold is set in the assessment playbook.
- It slows tests; can be disabled globally or per script; stored payloads are truncated at 4,000 characters (`was_truncated`; `glide.db.truncate_utf8`); when tracing is cut short the result is flagged incomplete.
- REST: `POST /api/now/atf/code_coverage/all`, `/by_script_id`, `/by_line_number`.

## Administration

| Setting | Where | Notes |
|---|---|---|
| Enable running tests | **Administration > Properties** > **Enable test/test suite execution** (role `atf_test_admin`); separately **Enable scheduled test suite execution** | off by default; keep off on production |
| Result retention | **Administration > Table Cleanup**: one auto-flush policy each for `sys_atf_test_result` and `sys_atf_test_suite_result`: **Matchfield** (`sys_created_on`), **Age in seconds** (30 days by default), **Cascade delete** (also `sys_atf_test_result_item`, `sys_atf_test_result_step` and attachments), **Conditions** (*Retain indefinitely* is false) | do not change **Tablename** on these records. A result with **Retain indefinitely** ticked is kept |
| Runner housekeeping | Properties > *Test Runner Properties*: **Test runner heartbeat interval**, **Test runner timeout** (seconds) | |
| Screenshots | Properties > **Enable or disable screenshot capture**: all steps (default), failed steps only, or none; **Screenshot timeout**. Per runner: the runner's preferences icon > **Screenshot mode** (until that tab closes) | fewer screenshots = faster tests |
| Slow steps | *Step transactions* on a step result and *Test Transactions* on a test result (from `syslog_transaction`) | very short transactions may not be logged |
| REST steps | **Basic authentication** profile on a *Send REST Request - Inbound* step (role `web_service_admin`; credentials must be valid on the instance where the test runs: use a dedicated test account). `glide.atf.rest.log.header_blacklist` = headers stored as "Header redacted for security". `glide.atf.rest.request_payload_max_size` (100 Kb, max 1024) and `glide.atf.rest.response_payload_max_size` (100 Kb, max 5120) | |
| Step templates | **Administration > Test Templates > New**: **Name**, **Test Template** (unlock, add step types in order), **Description** | steps can be removed anywhere but added only at the end; supports tables, catalog items and record producers |
| Step categories | **Administration > Step Configuration Categories**: **Name**, **Step Environment** (Server - Independent, UI, Server - REST), **Display name** | |
| Moving tests | tests, suites and related records travel in **update sets** | retrieved Custom UI component lists do not: retrieve again. A clone over the instance wipes tests that exist only there |

### Configurable Workspace steps

Category *Configurable Workspace*: **Open Workspace Page** (a workspace URL), then **Test Page** steps authored in a page inspector that opens the workspace in a new tab: **Refresh component list**, drag the inspector onto a component, choose one of the actions the component understands, give inputs and optionally an expected return value. **Edit page interaction** on a step reloads the page and replays the earlier Test Page steps of the batch.

## Related

- [[Automated Test Framework Overview]] · [[ATF Building and Running Tests]] · [[ATF Records, Properties and Custom Step Configurations]] · [[ATF Test Step Categories Reference]] · [[Scheduled Jobs]]
