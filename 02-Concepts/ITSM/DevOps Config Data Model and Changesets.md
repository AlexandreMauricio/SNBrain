---
type: concept
tags: [concept, change, cmdb, integrations, data-integrity, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Config" (pp. 1553-1602 and 1643-1668: overview, CDM and PaCE, terms, setup sequence, applications and deployables, uploading config data, XML and CSV parsing, CDM system properties, config data tab, components, collections, variables, file nodes, Config Data Analyzer, changesets and conflicts), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Config Data Model and Changesets

**In one line:** DevOps Config keeps an application's configuration data (connection strings, memory sizes, feature toggles) in ServiceNow as key-value items arranged in components, collections and deployables, edited through changesets that produce read-only snapshots per environment.

**Status:** being prepared for deprecation since Washington DC: hidden and not activated on new instances, still supported. Entry point: [[DevOps Change Velocity and DevOps Config]]. Validation and export: [[DevOps Config Snapshots, Policies and Exporters]]. Pipelines: [[DevOps Config Pipeline Integration]].

## What it is made of

| Part | Role |
|---|---|
| Configuration Data Management (CDM, scope `sn_cdm`) | tables, logic and workspace pages for the data model |
| Policy as Code Engine (PaCE) | JavaScript policies run against a snapshot; versioned, with a test playground |
| DevOps Config application | the workspace (**DevOps Config > DevOps Config Workspace**), policies, application health, Insights widgets |
| Optional content packs | *DevOps Config Policy content pack* and *DevOps Config Exporter content pack* (installing either pulls in DevOps Config) |
| Dependencies | CMDB CI Class Models, Performance Analytics Premium (more than 180 days of Insights data), Expanded Model and Asset Classes |

Two uses: **manage** config data as the single source of truth (security can only be enforced if the data is stored here, not just validated), and **validate** it before deployment, as an automated gate in the pipeline.

With DevOps Change Velocity the two are linked through the application: one application model ↔ one SDLC component (CMDB) ↔ one DevOps Config application ↔ one DevOps Change Velocity application. Creating, updating or deleting the application in one product does the same in the other. An SDLC component cannot be deleted while an application is attached. Config snapshots appear in the **Config data** related list of the DevOps change.

## Terms

| Term | Meaning |
|---|---|
| Application | all config data for one application service, application model or dynamic CI group (infrastructure) |
| Component | smallest aggregation unit, for example one microservice, a server, a Docker template |
| Collection | a set of components making up a release composition (for example *release-1.0*) |
| Deployable | the config data used to deploy to one target environment (Development, Test, Production); always connected to a service in the CMDB |
| CDI (configuration data item) | one key-value pair |
| Vars | variables that roll up values used in several places |
| Snapshot | the complete data of a deployable at the moment a change is committed; read-only |
| Changeset | a draft copy of the application in which all edits are made |

Inheritance of values: a variable in a collection overrides the component's; a deployable's overrides both. A CDI in an including node is an **override** when the name already exists below, an **overlay** when it does not.

## Setup sequence (DevOps engineer)

1. Install DevOps Config (admin; **System Applications > All Available Applications**), optionally the content packs and the pipeline plugins.
2. Create an application.
3. Create deployables.
4. Upload the config data.
5. Define policies.
6. Map policies to deployables.
7. Define exporters.
8. Configure the pipeline.
9. Run validation.

## Applications and deployables

- Roles: `sn_devops_config.admin` creates, edits and deletes applications; CDM roles `cdm_admin`, `cdm_editor`, `cdm_viewer`, `cdm_policy_editor`, `cdm_exporter_editor`, `cdm_secrets` (see encrypted values), `cdm_all_app_access` (see applications regardless of group).
- **New application** creates the application and a new application model; **Application based on existing services** attaches to an existing CMDB item. Fields: **Application name**, **Application model name**, **Maintained by** (groups; only members see the data, and removing your own group locks you out), **Application description**, **Application model owner**, **Manufacturer**.
- Deleting an application sets it Inactive in DevOps Config.
- **Create deployables**: **Environment** (Development, Test, Production), **Connection preference** (auto-connect to services, or choose manually; auto only for a new application), **Quantity** (up to 100). Names are generated as `AppName_EnvironmentType_number`. Per deployable: **Deployable name**, **Deployable description**, **Identifier** (tells apart deployables sharing a name, for example by region), **Connected to** (a CI, existing or new). Every deployable must be connected to a service. If more deployables than existing services are requested, blank services are created.
- A single deployable can also be added from **Settings > Deployables > New**, with **Restrict export** (only snapshots that pass validation can be exported).
- Deleting a deployable deletes its config data and all its snapshots.

Limits: 100,000 CDIs per application, 10,000 per deployable (properties below). Uploaded items are sorted alphabetically inside folders.

## Uploading existing config data

1. Create the application and open a changeset (**Edit config data**).
2. **Model the data**: add component, collection and deployable nodes, include components in collections and collections in deployables. Node names may use any UTF-8 character including `/` from CDM 4.2.
3. Leave the changeset open and upload through the REST APIs (`CdmApplicationsApi`, `CdmChangesetsApi`, `CdmSnapshotApi`) or the editor: application name, target path, data format. Each POST also returns an **upload script** in a chosen language for reuse in the pipeline.
4. Review, set variables and overrides so a few components and collections serve every environment.
5. Commit: conflicts are checked, data is persisted, one snapshot per affected deployable is generated.

### XML

Attributes become keys prefixed with `@`; the text of an element that also has attributes becomes key `#text`. Keep the same convention to get the original XML back on export. The upload parameter `ignoreAttributes` = false retains attributes.

### CSV (RFC 4180)

Records become indexed nodes under `data`; the format attributes are stored under `metadata`. Query parameter `dataFormatAttributes`:

| Attribute | Meaning | Default |
|---|---|---|
| `delimiter` | field separator | `,` |
| `containsHeader` | first row is the header | true |
| `headers` | header names when there is no header row | `[]` |
| `securedHeaders` | columns whose values are stored encrypted (shown as asterisks) | `[]` |

Keep both `data` and `metadata` nodes for a faithful CSV export.

## Editing (Config data tab)

Application tabs: **Overview**, **Snapshots**, **Config data**, **Settings** (deployables, mapped policies), **Activity** (changesets and the list of changed nodes with old and new name, value, type, state).

- Tree on the left, **Editor** panel (only what is directly in the selected node; included collections are listed by name) and **Preview** panel (persisted, structured state). Script view or List view.
- Preview options in the more actions menu: **Apply variables** (resolved values), **View encrypted data** (role `sn_cdm.cdm_secrets`; otherwise `********`), **View excluded data**.
- Buttons: **Save** (persists the changeset, not the application), **Delete Changeset**, **Commit**.
- Node actions: **Create component / collection / CDI**, **Include in collections**, **Include in deployables**, **Inherit from collection** (child follows the parent; no circular chains; at most 5 collections in a chain, property `sn_cdm.max_inheritance_chain_length`), **Exclude from inheritance** / **Include in inheritance**, **Add file**, **Rename**, **Delete**, **Details**, **View relationships**. Inclusion takes precedence over inheritance.

### CDI values and variables

| Form | Meaning |
|---|---|
| `"key": "value"` | plain value |
| `@@variableName@@` | reference to a variable (regex in `sn_cdm.variable_regex`) |
| `"variableName": "value"` in a `vars` folder | sets the variable |
| contextual variables | shipped variables taking their value from the node's context |
| recursive variables | a variable whose name is built from another variable's value |

Every component, collection and deployable gets an empty `vars` folder, which may hold only variables and folders. **Encrypted** (role `sn_cdm.cdm_secrets`) hides a value everywhere. Good practice from the guide: put defaults in components or collections and let each deployable override what its environment needs.

### File nodes

**Add file** on a node under a component, collection or deployable (not on the top folders), or under a shared component in a component library: up to 5 MB. Actions: rename, **Extract variables** (moves `@@...@@` variables in the file to a path so they can be resolved), delete, download, **Replace file** (on an included node this is an override). A file deleted in the changeset that created it is removed with its attachment; deleted later, the attachment stays. Preview only for text types (property `sn_cdm.attachment.display_mime_types`). Exports carry URLs to the attachments.

## Commit and its options

Commit lists the affected deployables and offers: *No additional actions*, **Validate snapshots**, **Validate and publish snapshots** (only snapshots that pass are published; only published snapshots can be exported). A committed changeset cannot be changed. States: Open, Blocked, Commit in progress, Committed, Commit failed.

### Conflicts

Two people working on the same application in two changesets can collide; the later commit is **Blocked**. Either resolve or discard and redo in a new changeset (copy larger edits to a text editor first). Keep changesets short-lived and coordinate.

| Conflict | Cause |
|---|---|
| Stale data | the item's value changed, or it is no longer included, in another committed changeset (also data corruption from direct table edits) |
| Changed parent | the parent was deleted or renamed |
| Changed parent/child relationship | items were added under the parent you changed |
| Changed references | the item was included elsewhere, so it cannot be deleted |
| Duplicate | an item with that name already exists |
| Invalid includes | the included component or collection was deleted or renamed, or a descendant is already included |

## Config Data Analyzer

**Compare config data** on an application: the current application is the *target*, another application (or changeset) the *reference*. Options: folder path, **Apply variables**, **View encrypted data**. Results: a navigation tree marking nodes Different, Reference or Target; tabs **Data model** (folder-level changes, source level Direct or Included), **CDIs and variables** (name, reference value, target value, source level Direct / Include / Override) and **File information**. Difference types: values different, encryption settings different, source levels different, source levels and values different, target only, reference only. **Diff only** hides equal data.

## CDM system properties

| Property | Meaning | Default |
|---|---|---|
| `sn_cdm.variable_regex` | variable syntax | `@@([^@].*?)@@` |
| `sn_cdm.cdm_queue_request_expiry_time_ms` | queue expiry | 900000 |
| `sn_cdm.cdm_validation_timeout_ms` | validation time limit | ? |
| `sn_cdm.default_node_identifier_keys` | keys identifying objects inside array nodes | none |
| `sn_cdm.execute_exporter_async_for_standard_request` | false = export synchronously (can hurt performance) | true |
| `sn_cdm.exception_enabled` | policy exceptions allowed | true |
| `sn_cdm.node_name_allowed_character_regex`, `sn_cdm.app_name_...`, `sn_cdm.snapshot_name_...`, `sn_cdm.exporter_name_...`, `sn_cdm.exporter_argument_name_...` | allowed characters in names | word characters plus a few symbols |
| `sn_cdm.cdm_max_allowed_open_changesets` | open changesets | 10 |
| `sn_cdm.preventative_duplicate_node_name_check` | check duplicate names across all open changesets | false |
| `sn_cdm.max_allowed_upload_file_size` | REST upload size | 5 MB |
| `sn_cdm.max_allowed_cdi_per_application` | | 100000 |
| `sn_cdm.max_allowed_cdi_per_deployable`, `..._per_shared_component`, `..._per_library` | | 10000 |
| `sn_cdm.max_nodes_in_memory` | nodes for `CdmQuery.queryTree` | 10000 |
| `sn_cdm.reserved_node_names` | | vars, collections, deployables, components |
| `sn_cdm.attachment.display_mime_types` | previewable file types | text and JSON / XML types |

After changing a CDI limit, recalculate usage (server-side, Scripts - Background): `new sn_cdm.CdmApplicationManager().updateCdiCountOfApplications();`. Raising the limits can degrade performance and the UI.

## Related

- [[DevOps Change Velocity and DevOps Config]] · [[DevOps Config Snapshots, Policies and Exporters]] · [[DevOps Config Pipeline Integration]]
