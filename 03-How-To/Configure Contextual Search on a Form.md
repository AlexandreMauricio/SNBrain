---
type: how-to
tags: [how-to, knowledge, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Contextual search", topics "Define a search context", "Configure table for a contextual search", "Add multiple search fields", "Configure search resource context properties" (pp. 2008-2020), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Configure contextual search on a form

**Goal:** show related knowledge (and other sources) on a task form while the agent types.
**Prerequisites:** role admin. The table is text-indexed.
**Navigation:** All > Contextual Search > Search Contexts, then Table Configuration

## Steps

1. **Search Contexts > New**: **Name**, **Searcher** (for example *Knowledge only*), **Searcher text**, tick **Search on tab** and **Active**. Save.
2. Optional: in the context's **Resource Configurations**, open *knowledge* and set **Condition** to restrict to one knowledge base. In **Additional Resource Configurations** add sources such as *Resolved Incidents*.
3. **Table Configuration > New**: **Table**, **UI type** (Platform or Workspace), **Search context**, **Title**, **Limit**, **Results per page**; tick **Enable related search box** and **Active**. Submit.
4. In the new record's **Search Fields**, keep **Short description** or add another short text field.
5. Add the **Contextual Search Results** formatter to the form layout if the form does not have it.

## Result / how to check it worked

Open a record of the table, type a few words in the search field and leave it: the **Related Search Results** panel lists matches with **Attach** / **Order** buttons.

## Example

| Record | Values |
|---|---|
| Search context | *Example problem deflection*, searcher *Knowledge only* |
| Knowledge condition | `kb_knowledge_base=<sys_id of the IT knowledge base>` |
| Table configuration | table Problem, title *Related knowledge*, limit 10 |
| Search action *Attach* | **Attach note field** = `work_notes` |

## Tables / fields involved

- `cxs_context_config`, `cxs_table_config`, `cxs_table_field_config`, `cxs_res_context_config`

## Gotchas

- A search field that is not on the form never triggers a search.
- After changing the attach-note field, the cache must be flushed for it to apply (do it outside business hours).
- The formatter step is not described in this guide's chapter; verify on the instance.
- Background: [[Contextual Search]] · [[Formatters]].
