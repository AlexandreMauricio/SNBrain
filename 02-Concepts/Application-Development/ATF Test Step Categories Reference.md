---
type: reference
tags: [reference, platform, automation, service-catalog, forms-lists, api, email, scripting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Testing and debugging applications > Automated Test Framework (ATF) > Test step categories (processed 2026-10-08 through the docs site; 4,330 cleaned lines): Reusable Tests, Service Catalog in Service Portal, Application Navigator, Configurable Workspace, Custom UI, Form, Service Catalog, Forms in Service Portal, List and Related List, REST, Email, Server, UI. The Form and Server categories were read line by line; the others were read with the fields repeated on every step (Execution order, Active, Application, Test, Step config, Description, Notes) filtered out by script. The Service Catalog and Forms in Service Portal categories mirror their Service Portal and Form counterparts and were only skimmed. https://www.servicenow.com/docs/r/application-development/automated-test-framework-atf/test-step-categories.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ATF Test Step Categories Reference

**What it is:** every ATF step by category, with the inputs that matter, the assert types, the outputs later steps can use, and the stated limits.

From the Brazil docs. How steps are added and chained: [[ATF Building and Running Tests]]. Every step also has **Execution order**, **Active**, **Application**, **Notes** and a generated **Description**; many have a **Timeout** (the check is retried until it passes or the time is up).

## Form (client test runner)

**Form UI** selects Standard UI or a workspace; tab navigation inside a workspace is not supported (reopen the form instead). Agent Workspace tests no longer work.

| Step | Inputs | Notes |
|---|---|---|
| **Open a New Form** | **Table**, **View** | invalid view = default view |
| **Open an Existing Record** | **Table**, **Record**, **View** | relying on existing records makes tests fragile |
| **Set Field Values** | **Table**, **Set field value** | **does not apply reference qualifiers**, at design or run time |
| **Field Values Validation** | **Conditions** (condition builder, case-sensitive, fields visible on the form) | only real fields of the record: not Additional comments, Work notes, Approval history (use *Record Validation* on the server). One step per value to test values independently |
| **Field State Validation** | lists **Visible**, **Not visible**, **Read only**, **Not read only**, **Mandatory**, **Not mandatory** | |
| **UI Action Visibility**; **Declarative Action Visibility** | **Visible**, **Not visible** | depends on the impersonated user |
| **Click a UI Action**; **Click a Declarative Action** | the action; **Assert type**: *Form submitted to server* or *Form submission canceled in browser* | outputs `table`, `record`. Form context menu actions supported in Brazil |
| **Click Modal Button** | Standard UI: **UI page**, **Button** (element id such as `OK_button`). Workspace: **Modal action** (confirm or cancel), **Modal values**. **Assert type**: modal closed and page reloaded, closed and not reloaded, not closed | workspace modals only when opened with `g_modal` `alert`, `confirm`, `confirmDestroy`, `showFields` |
| **Add Attachments to Form** | **Upload Attachments** | not for workspace UIs |
| **Submit a Form** | **Assert type**: submitted to server, canceled in browser, *None* | outputs `table`, `record` |

After *Submit a Form* or *Click a UI Action* the browser returns to wherever the navigation stack leads: **never assume which page is shown**; open the form again explicitly before more form steps.

## Forms in Service Portal

Same idea on portal forms: **Open a Form (SP)**, **Set Field Values (SP)**, **Field Values Validation (SP)**, **Field State Validation (SP)**, **Add Attachments to Form (SP)**, **UI Action Visibility Validation (SP)**, **Click UI Action (SP)**, **Submit a Form (SP)**.

## List and Related List

Each step has **List type** (List or Related list), **Table** (for a related list: the parent form's table) and **Related list**. A related list is addressed as `<child_table>.<field>` (for example `task.parent`) or `REL:<sys_id>` for a custom relationship (`sys_relationship`).

| Step | Inputs / asserts | Output |
|---|---|---|
| **Validate Related List Visibility** | **Visible**, **Not visible** lists | |
| **Apply Filter to List** | **List filter**; assert at least one, exactly one, or no matching record | `first_record` |
| **Validate Record Present in List** | **Record**; present or not present | |
| **Open a Record in List** | **Record** | |
| **Validate List UI Action Visibility** | **Visible**, **Not visible** | |
| **Click a List UI Action** | **List action**, **Action type**, **Apply to** (with **Record** for a single record); assert *None* or *Page reloaded or redirected* | |

Docs' advice: test only related lists with custom logic (client scripts, UI policies, custom relationships); the platform's default lists need no tests.

## Service Catalog and Service Catalog in Service Portal

Portal steps need plugin `com.glide.automated_testing_impl.service_catalog_portal` (active on new instances). Both families support parameterised tests. Custom variables are not supported by the variable steps. A variable inside a variable set is labelled `set name » variable name`.

| Step (platform / portal) | Notes |
|---|---|
| **Open a Catalog Item**, **Open a Record Producer**, **Open an Order Guide (SP)** | portal: **Query Parameters** |
| **Set Variable Values**, **Validate Variable Values** (catalog conditions), **Variable State Validation** (visible, read only, mandatory and their opposites) | between opening and ordering or submitting |
| **Add row to multi-row variable set (SP)**, **Save current row of multi-row variable set (SP)** | assert saved or cannot save |
| **Set Catalog Item Quantity**, **Validate Price and Recurring Price** (price, recurring price, frequency) | not for record producers |
| **Add Item to Shopping Cart**, **Add Order Guide to Shopping Cart (SP)** | assert added or cannot add; output `cart_item_id` |
| **Order Catalog Item**, **Submit an Order Guide (SP)** | assert ordered or cannot order; outputs `table`, `record_id`. With two-step checkout on, ordering goes to the cart preview instead of creating the request. One record producer at most in an order guide |
| **Submit Record Producer** | assert submitted or cannot submit; output `table` (and the record) |
| Order guide (SP): **Navigate within Order Guide** (Describe Needs, Choose Options, Summary), **Validate Order Guide Items**, **Review Item in Order Guide** (**Included**), **Review Order Guide Summary** | |

Server-side companions: *Search for a Catalog Item*, *Checkout Shopping Cart*, *Replay Request Item* (below).

## Application Navigator

**Navigator**: Core UI or Next Experience (the default follows what the instance uses).

| Step | Inputs |
|---|---|
| **Application Menu Visibility** | **Visible application menus** with assert *At least these* or *Only these* are visible; the same pair for **Not visible** |
| **Module Visibility** | the same for modules |
| **Navigate to Module** | **Module** (must be visible to the current user). Not testable: separators, modules that run client JavaScript (Studio, Script Debugger), external links, modules that reload or redirect the whole page |

Menus and modules themselves: [[Application Menus and Modules]].

## Custom UI, Configurable Workspace, UI

| Step | Notes |
|---|---|
| **Open Service Portal Page** | open a portal page (with URL parameters) before testing its components |
| **Set Component Values**, **Component Value Validation** | the value defaults to the last retrieved one |
| **Click Component**, **Component State Validation** (Enabled, Disabled) | |
| **Assert Text on Page** | case-sensitive; also works in workspaces for tests created since Rome |
| **Open Workspace Page** | **Workspace URL** (stored without the domain so it works on other instances) |
| **Test Page** | interact with a workspace component through the authoring inspector |
| **Run UI Test Script** | a client-side test script run entirely in the client test runner (what Test Agent generates: [[Autonomous Engineer and Test Agent]]) |

## REST (server; this instance only)

| Step | Inputs |
|---|---|
| **Send REST Request - Inbound - REST API Explorer** | build and send in the REST API Explorer, then **Create Automated Test Step**; afterwards editable only as the next step type |
| **Send REST Request - Inbound** | **Authentication Type** (None for public APIs; basic or mutual need role `atf_ws_designer`), **Basic authentication** profile, **Mutual authentication** certificate, **Method** (GET, POST, PUT, DELETE, PATCH), **Path** (the part after the instance name only), **Query Parameters**, **Headers** (not encoded), **Body** |
| **Assert Status Code** | is, is not, less than, greater than, less than or is, greater than or is |
| **Assert Status Code Name** | contains, does not contain, is, is not |
| **Assert Response Time** | less than or greater than a value in ms |
| **Assert Response Header** | header; contains, does not contain, is, is not, is not empty |
| **Assert Response JSON Payload is Valid**; **Assert Response XML Payload is Well-Formed** | |
| **Assert JSON Response Payload Element**; **Assert XML Payload Element** | **Element path** such as `/result/short_description`; same operators |
| **Assert Response Payload** | compare the whole body; give the fragment exactly as it appears, without braces: `"short_description":"Example"` |

The send step itself validates nothing: it fails only if the request is invalid, cannot be sent, or the response is too large. Asserts must follow it directly.

## Email (server)

| Step | Inputs | Output |
|---|---|---|
| **Validate Outbound Email** | **Conditions** on Email (`sys_email`), for example Recipients is `user@example.com` | times out after two minutes by default |
| **Validate Outbound Email Generated by Flow** | **Source Flow** (only mail from the flow's *Send Email* action) | |
| **Validate Outbound Email Generated by Notification** | **Source Notification** (`sysevent_email_action`), also when the notification was fired from a flow | |
| **Generate Inbound Email** | **From**, **To**, **Subject**, **Body** | `output_email_record` (receive type New) |
| **Generate Inbound Reply email** | **Target Table**, **Target Record** (adds the watermark), from, to, subject, body | `output_reply_email_record` (receive type Reply) |
| **Generate Random String** | **Length** (10 by default, up to 10,000) | `random_string` |

## Server

| Step | Inputs / asserts | Output |
|---|---|---|
| **Create a User** | **First name**, **Last name**, **Roles**, **Groups**, **Impersonate this user** | `user`. Rolled back at the end. The recommended way to get a test user |
| **Impersonate** | **User** | `user`. Lasts until the next Impersonate or the end. Do not impersonate someone holding the test author's role; sys_ids of users differ per instance and update sets do not fix the reference; `snc_external` users can be impersonated |
| **Record Query** | **Table**, **Conditions**, **Enforce security**; assert at least one record or none | `table`, `first_record` |
| **Record Insert** | **Table**, field values, **Enforce security**; assert inserted or *was not inserted* | `table`, `record_id` |
| **Record Update** | **Table**, **Record**, **Field values**; assert updated or not | **passes even when an ACL blocked one field**: follow with *Record Validation* |
| **Record Delete** | **Table**, **Record**; assert deleted or not | |
| **Record Validation** | **Table**, **Record**, **Field values**; assert validated or *Record not found* | |
| **Run Server Side Script** | **Jasmine version** (3.1 for new scripts, 1.3 legacy), **Test script** | `record_id`, `table`. Not usable in parameterised tests (the page also says it "now supports parameters as step inputs": contradictory (?)) |
| **Log** | **Log** message, may include earlier outputs | |
| **Add Attachments to Existing Record** | **Table**, **Record**, **Upload Attachments** | |
| **Search for a Catalog Item** | **Search term**, **Catalog**, **Category**, **Search in Portal only**, **Assert item** present or not | `catalog_item_id` |
| **Checkout Shopping Cart** | **Requested For**, **Delivery Address**, **Special Instructions**; assert checked out or *Empty cart* | `request_id` |
| **Replay Request Item** | **Original Request Item**: re-orders it for the same requester | `table`, `request` |
| **Custom Scripted StepConfig** | a sample custom step (checks that a user name starts with A) to copy from | `value` |

**Enforce security** off = the server step ignores ACLs (it runs like a system script); on = ACLs and read-only roles apply to the impersonated user.

*Run Server Side Script* (server side, in the step's application scope; data it creates is rolled back):

```js
(function (outputs, steps, params, stepResult, assertEqual) {
  var task = new GlideRecord('sc_task');
  task.setValue('short_description', 'Example task created by a test');
  var id = task.insert();
  outputs.table = 'sc_task';
  outputs.record_id = id;                 // usable by later steps
  // steps('<sys_id of an earlier step>').record_id reads an earlier step's output
  assertEqual({ name: 'task was inserted', shouldbe: true, value: !!id });
  stepResult.setOutputMessage('Inserted ' + id);   // one message; a second call overwrites it
  return true;                             // false fails the step
})(outputs, steps, params, stepResult, assertEqual);
```

Jasmine `describe` / `it` blocks are supported in global scope only (uncomment `jasmine.getEnv().execute();`). The docs' own sample mixes the variable names `now_GR` and `gr`: it would not run as printed.

## Reusable Tests

Lists the reusable tests of the instance as steps (or under another category if the reusable test names one).

## Related

- [[ATF Building and Running Tests]] · [[Automated Test Framework Overview]] · [[ATF Records, Properties and Custom Step Configurations]] · [[Application Menus and Modules]]
