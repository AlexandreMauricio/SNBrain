---
type: reference
tags: [reference, platform, automation, client-script, javascript, data-integrity, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Testing and debugging applications > Automated Test Framework (ATF) > Test building and execution, and Test types and techniques (read 2026-10-08 through the docs site): Building and running automated tests, Create a new automated test, Add a template, Add steps, Change a step, Edit step order, Copy automated test, Run an automated test, Implementing breakpoints, Debug using breakpoints, View test results, Identify and resolve client errors, UI test steps, Custom UI test steps, Page Inspector, Inspect different page types, Enable and use the page inspector, Create a custom UI test, Override component test actions, Override component data type, Select2 functionalities, Browser recommendations, Working with client test runners, Pick a browser, Cloud Runner browser, Server test steps, REST test steps, Attachment test steps, List UI actions test steps, Parameterized tests (create, add a parameter, add data sets), Allowed client errors (four ways), View the progress, Passing data between steps, Auto-generate ATF tests, Cancelling tests, Reusable tests, Mutually exclusive tests, Quick start tests. https://www.servicenow.com/docs/r/application-development/automated-test-framework-atf/atf-build-overview.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ATF Building and Running Tests

**What it is:** how an ATF test is built, run, debugged and read; how user-interface steps use client test runners; testing custom pages; parameterised, reusable and mutually exclusive tests; and tolerating known browser errors.

From the Brazil docs. Concepts and roles: [[Automated Test Framework Overview]]. Steps by category: [[ATF Test Step Categories Reference]]. Suites and scheduling: [[ATF Test Suites, Schedules and Administration]].

## Build

| Task | How |
|---|---|
| New test | **Automated Test Framework > Tests > New**: **Name**, **Description**, optionally **Enable parameterized testing** |
| Add a step | *Test Steps* related list > **Add Test Step** > category (or All Steps) > step type > **Insert after** > **Next** > fill its fields > **Submit**. Form sequences start with *Open a New Form* or *Open an Existing Record* and end with *Submit a Form* |
| Add several steps | **Add Test Template** > **Table**, **Template**: inserts a predefined sequence and writes instructions into the test description |
| Order | **Execution order** on each step (next free integer by default); editable in the related list |
| Use an earlier result | the mapping icon beside an input field lists the output variables of previous steps; a record output opens a tree to dot-walk its fields. For example *Record Insert* outputs **Record** (the sys_id) |
| Copy | **Copy Test** (only from the test's own scope) |
| Generate | **Auto-generate Tests** needs the Store application *ATF Test Generator and Cloud Runner* |

## Run

- **Run Test** shows only when test execution is enabled. A test with any user-interface step first asks for a browser (**Pick a Browser**): an active client test runner, **Start a new test runner**, or the *Cloud Runner* (needs the Store application and a configured user). Server-only tests start immediately.
- Progress dialog: **Go to Result**, **Cancel Pending Steps** (rolls back). Reopen it with **Show Progress** on the result. Queued runs are cancelled by deleting them under **Run > Waiting/Running Test Runs**.
- **Debug Test** honours breakpoints (right-click a step > **Add/Remove Breakpoint**; one per step; visible only to their creator; ignored by Run Test). At a breakpoint the test pauses for up to 10 minutes: **Continue** or **Step over**. **Pause before rollback** stops just before the data is rolled back, so the created records can be inspected.

### Client test runners

A browser tab that executes UI steps as the signed-in user (until an Impersonate step). Two kinds: *Client Test Runner* for manual runs, *Scheduled Client Test Runner* for scheduled suites. An idle runner polls every five seconds.

- `window.confirm` is answered true, `window.prompt` returns the string `test value`, `alert` is ignored.
- UI steps wait by themselves for the page to settle; no wait steps are needed.
- **Everything done in the runner's browser session is recorded for rollback.** Do not work in the same session while a test runs; for parallel runs open each runner in a private window, and close runners when finished.
- Keep the runner in its own window, at least partly visible, screen unlocked (browsers throttle hidden tabs; on macOS a locked screen makes tests time out), zoom 100% for screenshots. Restart older browsers periodically.
- Runners register in the Active Test Runners table (modules *Active Manual Test Runners* and *Active Scheduled Test Runners*); a runner that stops reporting is marked inactive, then deleted.

## Results

**Test Results** > a result: *Step Results* (status, summary, output), *Test Log*, screenshots as attachments named `screenshot` plus a UTC timestamp. Suites: **Suite Results**.

### Client errors

A JavaScript error in the browser fails the step that was running ("This step failed because the client error ... was detected"). Find it in the runner's browser console; the cause is usually a client script, UI action, UI macro, UI page, UI policy or UI script, possibly one skipped during an upgrade; also check ACLs, application access and domain.

**Allowed client errors** (`sys_atf_whitelist`) let runs continue past known errors:

| Report level | Step status | Log |
|---|---|---|
| Warning | Success with warning(s) | Warning |
| Ignored | Success | Ignored |

- Matching is a **contains** search on the error message.
- Add from a test result, step result or log line (*Add all client errors to warning list / ignored list*), or by hand under **Run > Allowed Client Errors** (**Report level**, **Active**, **Error message**, **Description**).
- Meant for temporary tolerance (old library, pending fix, suspected platform bug), not as a way to make tests pass.

## Step kinds

| Kind | Runs | Notes |
|---|---|---|
| UI steps | in a client test runner | forms, catalog, navigator, custom UI |
| Server steps | on the server, no runner | impersonate, record operations, scripts |
| REST steps | server | only against **this** instance; XML and JSON only. Assert steps must directly follow *Send REST Request - Inbound*. The request runs as whoever runs the test: use a basic authentication profile to make it deterministic |
| Attachment steps | from a form (UI) or through the server API | attachments added by the step are rolled back; pre-existing ones are not, so avoid records that already have attachments |
| List UI action | UI | navigate to the list or the form with the related list first; action types: banner button, bottom button, context menu, list choice, list link; **Timeout** appears with the assert *Page reloaded or redirected* |

## Custom UI steps

For UI pages, UI macros, portal pages and other custom HTML. Not for Next Experience pages.

- Testable components are ordinary HTML elements a user can set or click, reachable in the DOM (not the shadow DOM), handled in the same tab, and not already covered by another category.
- Not testable this way: forms (use Form steps; UI formatters inside forms are testable), lists, catalog items, workspaces, dashboards, reports, images, hidden controls, file fields, Excel or PDF content, platform tools (Flow Designer, Studio), embedded external sites.
- **Page Inspector** shows what ATF sees: System Settings > Developer > **Automated Test Framework Page Inspector**, or **Manual Page Inspector** (page type UI Pages, Standard UI, Service Portal, Custom; give a relative URL such as `/home.do`). Drag the inspect icon onto an element; try the actions (*Click On Component*, *Set Component Value*, *Get Component Value*, *Is Component Disabled*).
- In a test: navigate with ordinary steps (*Navigate to Module*, *Open an Existing Record* then *Click a UI Action*, *Open Service Portal Page*), then add Custom UI steps and **Retrieve Components** (runs the test up to that step in a foreground runner). The retrieved list is data: it is **not** in update sets and must be retrieved again on another instance. `sn_atf.page_data_capture.enabled` = true refreshes it on every run (useful while designing, slower afterwards).
- Steps: *Set Component Values*, *Click Component*, *Component Value Validation*, *Component State Validation*, *Assert Text on Page*.

Making your own markup testable (page source; client side):

| Attribute | Effect |
|---|---|
| `sn-atf-id="stable_value"` | identify a component whose `id` or `name` changes between runs |
| `sn-atf-area` | name shown in the *Page area* column (otherwise the label path; `sn_atf.element.use_label_path`, true since Rome) |
| `sn-atf-clickable="true"` | treat the element and its children as one clickable component; ATF sends it an `sn-atf-click` event |
| `sn-atf-settable="true"` | the same for a settable component; ATF sends `sn-atf-setvalue` with the new value in `event.detail` |
| `sn-atf-disabled`, `sn-atf-component-value` | report disabled state and current value |
| `sn-atf-data-type` (`glide_date`, `glide_date_time`, `reference`), `sn-atf-data-type-params` (`{"reference":"incident","reference_qual":"active=true"}`) | the field type offered when building the step |
| `sn-atf-class="MyObject"` | a JavaScript object on the page implementing `initialize`, `click` or `setValue` (with `isSettable: true`), `getValue`, `isDisabled`; in Jelly wrap it in `<g2:atf_only>` so it loads only during tests |

```html
<!-- UI page markup: client side -->
<div sn-atf-settable="true" id="exampleSettable" sn-atf-component-value="initial">
  <input id="exampleInput" value="initial">
</div>
<script>
  document.getElementById('exampleSettable').addEventListener('sn-atf-setvalue', function (event) {
    document.getElementById('exampleInput').value = event.detail.newValue;
  });
</script>
```

The docs write the property both as `event.detail.newvalue` and `event.detail.newValue`; the sample code uses `newValue`. Select2 dropdowns (library 3.5.1 to 3.5.4 and 4.0.0 to 4.0.13, with a search box) are set by typing the text and taking the first match.

## Parameterised tests

One test, several **data sets**: it runs once per data set and gives one result each.

| Part | Detail |
|---|---|
| Parameter | a typed variable. *Shared* (usable by any parameterised test; a column of `sys_atf_parameter_set`) or *exclusive* (this test only; a row of `sys_atf_parameter_variable`). The type must match the field it will fill |
| Data set | one row of values (`sys_atf_parameter_set`) with an **Order**; add by hand or **Import** from an Excel template (*Add* or *Replace*) |

Limits: fails if there is no data set; *Run Server Side Script* is not supported; Custom UI steps retrieve components with the first data set only. Copying copies parameters and data sets.

## Reusable and mutually exclusive tests

- **Reusable test** (**Reusable Tests > New**: **Name**, **Category**, **Description**): callable only from another test, through the Reusable Tests step category; never run alone nor added to a suite directly. *Reusable Input Variables* come from the caller; *Reusable Output Variables* go back to it.
- **Mutually exclusive tests** never run in parallel with each other. The system marks them when they modify the same record (and a test never runs in parallel with itself); add your own from the test's *Mutually Exclusive Tests* list, the Tests list action, or a result's *Parallel Test Runs* list. Typical manual case: one test changes a system property another test relies on.

## Quick start tests

Shipped with applications; they pass only against the application's **demo data**. Copy a test or a whole suite and adapt it (each step has **Notes**). **Copied from** links the copy; when an upgrade changes the original a message appears and **Revert Copy to Base System** adopts the new version; the *Copies to Review* module lists affected copies. The catalogue: [[ATF Quick Start Tests by Application]].

## Related

- [[Automated Test Framework Overview]] · [[ATF Test Step Categories Reference]] · [[ATF Test Suites, Schedules and Administration]] · [[ATF Records, Properties and Custom Step Configurations]] · [[UI Policies]] · [[UI Actions]]
