---
type: concept
tags: [concept, service-catalog, update-sets]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Catalog Builder, topics "Catalog Builder", "Catalog Builder overview", "Setting up the Catalog Builder", "Creating or editing catalog item template", "Create a catalog item using a template", "Create a question for a catalog item in Catalog Builder", "Configure an auto-populate value for a question", "Edit a question in Catalog Builder", "Edit a catalog item in Catalog Builder", "Add advanced capabilities to a catalog item", "Create UI policies in Catalog Builder", "UI policy form in Catalog Builder", "Create client script in Catalog Builder", "Catalog client script form", "Discard a catalog item", "Transfer catalog items using update sets", "Localization Framework integration with Catalog Builder", "Add step, section, or question to catalog item wizard", "Catalog Wizard form", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/catalog-builder.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Catalog Builder

**In one line:** a guided, step-by-step editor (**All > Service Catalog > Catalog Builder**) that lets business owners build and maintain catalog items and record producers from templates that catalog admins prepare, while advanced settings stay in the classic forms.

## Who does what

- `catalog_admin`: makes **templates** (what is preset, what may be edited, which choices are allowed), sees and edits all items.
- `catalog_builder_editor`: builds items from templates assigned to them.
- `catalog_builder_developer`: also client scripts, attributes, advanced reference qualifiers, scripted defaults, availability; can build without a template.

## Item states

| State | Meaning |
|---|---|
| **Draft** | new item, or a copy of a published item checked out for editing (with copies of its variables, UI policies, client scripts). Always inactive, not searchable; **Active** cannot be changed |
| **In review** / **Reviewed** | only with a pre-publish review subflow |
| **Publishing** | short transition after submit; cannot be checked out |
| **Published** | the live item. While checked out its **Checked out** field is true and it cannot be edited in the classic form unless the checkout is cancelled (which discards the draft changes) |

On submit the draft's changes are merged into the published item and the draft deleted. A never-published draft can be deleted (**Discard draft**); a published item cannot, only made inactive.

## Templates

**Dashboard > Create a catalog item template**, type *Standard* or *Record Producer*. Steps: **Template Details** (name, **Use template scope for creating records**, **Template Available for** = user criteria, max 50), **Details** (suggested name and descriptions), **Destination** (producers), **Location** (catalogs, categories, Employee Center topics, max 50), **Questions** (required question sets and allowed question types), **Settings** (portal options), **Access**, **Fulfilment** (flow or workflow), **Overrides** (**Can Edit**, **Must specify**, **Restricted selections**), **Review and submit**. Template changes do not alter existing items, though new restrictions apply when they are next edited. Templates are deleted only from the classic UI (items then lose the restrictions).

## Building an item

Steps follow the template: **Details**, **Destination**, **Location**, **Questions**, **UI Policy**, **Client Script**, **Settings**, **Access**, **Fulfilment** (with service fulfillment steps for a registered flow: see [[Catalog Fulfilment - Flows, Workflows and Execution Plans]]), **Review and submit**. Changes save when moving between steps. **Preview** shows the item in a portal (`glide.sc.builder.preview_portal_id`, default `swp`), Now Mobile or a Virtual Agent conversation (needs the topic blocks plugin; topic from `glide.sc.builder.va_preview_topic_id`). The default build path is **Build with ServiceNow Otto** (see [[AI Authoring for Catalog Builder]]); **Build on your own** for manual work.

### Question types available

Text (Single-line, Multi-line, Rich text = HTML), Option (Check box, Yes/No), Choice (Dropdown fixed = Select Box, Dropdown from table = Lookup Select Box, Record reference = Reference, Radio = Multiple Choice, Multi-select = List Collector), Date/Time (Date, Date & Time, Duration), Display label (Plain = Label, Rich = Rich Text Label). Other types are shown read-only. Two consecutive check boxes form a virtual group container. **Auto-populate** tab: fill a question from a field (dot-walk allowed) of the record chosen in another Reference or Requested For question, e.g. the requester's manager.

### Not editable in Catalog Builder

Meta tags, execution plans (an item with one cannot change its process engine here), price settings, variable attributes, tooltips, advanced or dynamic reference qualifiers, permissions, availability, lookup label and price fields, unique values, help text and always-expanded help, data lookup rules, questions inside variable sets, items with more than two container levels or two-column containers inside containers. Add these with **Edit in advanced view** (catalog_admin) or the related link **Edit checked out item in advanced view** on the classic form.

### UI policies and client scripts in the builder

UI policies with conditions, several actions and scripts (**UI Type** Desktop / Mobile-Service Portal / All) and the three "applies" options (when requested, on catalog tasks, on the RITM). Client scripts (onLoad, onChange on a question, onSubmit) need `catalog_builder_developer`. Note: the docs' UI policy form lists Visible choices as Leave alone / Set value / Clear value, which looks like a copy error.

## Settings (properties)

| Property | Effect |
|---|---|
| `glide.sc.builder.content_url` | link on the builder home to your own "how we build catalog items" page |
| `glide.sc.builder.preview_portal_id` | portal used for preview (default `swp`) |
| `glide.sc.builder.template_access` | true: anyone who can use a template may edit all items made from it (default false) |
| `glide.sc.builder.item_review_flow` | sys_id of a pre-publish subflow (copy **Template: Catalog Builder - Item review**; input `catalog_item` = draft sys_id; output `state` = `completed` or `failed`, case sensitive) |
| `glide.sc.builder.item_filter_mode` | which items a user sees and edits: `default` (read access, edit with write access), `catalog_editor` (where editor or manager), `owner_only` |
| `glide.sc.builder.allow_create_from_scratch` | developers may skip templates (default true) |
| `glide.sc.cb.item.update_set_prefix` | name format of per-item update sets, default `CB_${template_name}_${item_name}_${timestamp}` |
| `glide.sc.catalog_builder.localization.enable_request_translation_mode` | true: request translations through Localization Framework tasks; false (default): edit translations side by side |

Feedback panel texts are records in `sc_wizard_feedback`. The builder is itself a catalog wizard: **Service Catalog Wizards > Maintain Wizards** > *Create catalog item* or *Create record producer* to add steps, sections and questions.

## Moving items between instances

Each item created or edited in the builder gets its own local update set named as above; related records in other scopes go into child update sets (batching). Transfer them like any update set. See [[Update Sets]].

## Translation

**Translation Status** tab on an item, with the Localization Framework installer for Service Catalog and Dynamic Translation plugins. States: Not available, Not translated, Translations requested (request mode), Partially translated, Translated. Items are created only in the primary language; editing in another language in the builder does not translate. See [[Localization Framework, Workspace and Dynamic Translation]].

## Domain separation

An item can only be edited in the domain it was created in; UI policies and actions added in the builder go to the item's domain.

## Related

- [[Create a Catalog Item in Catalog Builder]] · [[Service Catalog Wizards]] · [[Creator Studio Overview, Setup and Roles]] (uses catalog templates and variable sets as "question sets") · [[App Engine Studio Overview, Setup and Roles]]
