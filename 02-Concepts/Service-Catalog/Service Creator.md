---
type: concept
tags: [concept, service-catalog, roles, notifications, release-specific]
status: documented
source: ServiceNow docs, Australia, Build workflows > Service Creator (read 2026-10-08 through the docs site; whole chapter): Service Creator, Service creator process, Activate Service Creator, Installed with Service Creator, Components created with new service categories, Service Creator roles, Manage a service, Designing services, Add a template notification, Notification configurations, Create the category and table, Delete a template notification, Designate an editor, Designate a service fulfiller, Fulfill a service request, Publish a service. https://www.servicenow.com/docs/r/australia/build-workflows/service-creator/c_ServiceCreator.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Service Creator

**In one line:** a legacy application that lets a department (HR, Facilities ...) publish its own simple services in the service catalog: each *service* is a record producer, and each *service category* gets its own task table, application menu and role.

**Status:** since Zurich it is being prepared for deprecation: hidden and not activated on new instances, still supported where present. ServiceNow points to Creator Studio for new work.

## Process

| Step | Who | Where |
|---|---|---|
| Request a service category | department manager | **Self-Service > Service Catalog >** *Departmental Services* **>** *Service Category Request*: **Department** (defaults to the user's; drives the next two), **Category name**, **Category manager** (the department's manager), **Needed by**, **Comments** |
| Approve | catalog administrator | **Service Creator > Category Requests** > record in state Requested > check the proposed **Table name** > **Create Category and Table** (or **Reject**) |
| Name editors and fulfillers | category manager | **Service Creator > My Service Categories** > published category > **Editors** field; **Service Fulfillers** related list. Only users of the department can be chosen |
| Design services | manager, editors | the service design interface; **Create New Service** |
| Publish a service | manager | on the category, right-click the service in **Draft Services** > **Publish** (it moves to **Services**) |
| Request | any user | orders the catalog item |
| Fulfil | service fulfiller | *the category's application* **> Assigned to me** > work the task > **State** = Closed Complete. The questions and answers show in the Variables section |

New tasks go to the service's **Fulfillment Group** or **Fulfillment User**; when neither is set, to the category manager.

## What approving a category creates

| Component | Detail |
|---|---|
| Table *&lt;Department&gt; Tasks* | extends Task (`task`); name from the category's **Table name**; own number record; own application menu and modules |
| Role `<table name>_user` | given to the manager, editors and fulfillers; required to be assigned the tasks; ACLs on the new table |
| Notifications | copies of the *template notifications*: task opened / commented / closed for the requester; assigned, commented, work-noted, closed for assignee and for group |
| Form *&lt;Department&gt; Task* | with a formatter showing the service's questions and the answers given |
| Catalog category | the default category for the services of this service category |

The category's **State** becomes *Published to Catalog*.

## Tables, roles, properties

| Table | Holds |
|---|---|
| Service Category (`catalog_category_request`) | service categories |
| Service Category Request User (`catalog_category_request_user`) | fulfillers per category |
| Service (`sc_cat_item_producer_service`) | services (record producers) |
| Service Category App Menu (`service_category_app_menu`) | the menus created |
| Service Category User Role (`service_category_user_role`) | users who hold a role as editors |

| Role | Does | Granted |
|---|---|---|
| `catalog_admin` | approves category requests; creates, edits, publishes categories and services; manages (template) notifications | by an administrator |
| `catalog_manager` | creates, edits, publishes services; names editors and fulfillers | automatically to a category's manager |
| `catalog_editor` | creates and edits services | automatically to editors |
| `<table name>_user` | works the category's tasks | automatically |

Fulfillers see their category's application, not the Service Creator application.

| Property | Default | Effect |
|---|---|---|
| `glide.citizen_developer.category.auto_publish` | true | new service categories appear in the catalog as subcategories of *Departmental Services* |
| `glide.citizen_developer.set_category_roles` | admin, catalog_admin | roles that may set the category of a new service |
| `glide.service_creator.auto_add_to_category` | true | new services are also added to *Departmental Services* |

The *Departmental Services* category is demo data; without it a catalog administrator must put the *Service Category Request* item in another category.

## Notifications

- **Service Creator > Template Notifications**: the set copied into every category created afterwards. To add one: **New**, **Send when** = *Event is fired*, **Event name** = `ccrTemplate`. Deleting a template does not touch categories that already exist.
- **Service Creator > Notifications**: the application's own (category request inserted / opened, published, rejected, created, publication requested).

## Behind the scenes

Plugin installed from **System Applications > All Available Applications**. It ships before-query business rules that limit non-`catalog_admin` users to the categories, services and drafts they manage or edit (*Category Request query*, *Service Query*, *Draft Item Query*), rules that grant and remove the roles above as managers, editors and fulfillers change, *Catalog Category Request Approved* (creates the components), *Default Fulfillment User*, and client scripts that propose and validate the table name and warn about duplicate category names.

## Related

- [[Request Management Data Model and Process]] · [[Business Rules]] · [[Email Notifications]]
