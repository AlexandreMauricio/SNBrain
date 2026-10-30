---
type: concept
tags: [concept, flows, integrations, import-sets]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Integration Hub > Data Stream actions and pagination (overview, design considerations, MID Server support, create, generate the Parsing phase, test, use in a flow), first paragraphs read 2026-10-30; field tables and pagination script detail not read. https://www.servicenow.com/docs/r/integrate-applications/create-integrations-applications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Data Stream Actions

**In one line:** an action that sends REST, SOAP or JDBC requests to an API returning more than 10 MB or paged results, and parses the response into a stream of complex objects for a flow to process one at a time.

From the Brazil docs; not tested. Needs Integration Hub: plugin `com.glide.hub.action_type.datastream`. See [[Integration Hub Overview and Subscription]].

## Parts

- **Request:** a REST, SOAP or JDBC step. It sends several requests by itself when the API paginates.
- **Pagination:** written to fit the third party; the docs warn it may need a script.
- **Parsing:** a splitter step and a parser step.
- **Outputs:** a complex object for each item.

On a REST-based action, **Test REST Step** calls the endpoint, analyses the response and generates the Parsing section and Outputs (`action_designer` or `admin`).

## Using it

- In a flow it appears as a **For each** block; each item can create a record.
- Testing returns the first **20** items by default.
- It can also be the data source of [[Integration Hub Overview and Subscription|Integration Hub - Import]] and [[Import Sets - Data Sources, Staging Tables and Cleanup|import sets]].
- [[Workflow Studio Overview]] records a limit on where data stream actions can be used.

## MID Server

When selected, the MID Server fetches the data and sends each page to the instance as an attachment. **The actions inside the For Each block always run on the instance.**

## Example

Action *Example Employee Stream* calls a paged HR API with a REST step. Flow *Example Employee Import* uses it as a For each block and creates one *Example Employee* record per item.

## Related

- [[Flow Action Steps Reference]] · [[Custom Actions, Dynamic Inputs and Error Evaluation]] · [[Flows, Subflows and Actions Overview and Architecture]]
