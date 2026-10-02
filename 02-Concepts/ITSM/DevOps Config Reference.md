---
type: reference
tags: [reference, change, roles, api, domain-separation, security]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Config" > "DevOps Config reference" (pp. 1725-1775: deployable associations, supported config data types, CDM data model, contextual variables, APIs, roles, encrypted data, domain separation, default policies, default exporters) and p. 1776 (last exporter), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Config Reference

**What it is:** roles, APIs, contextual variables, domain separation and the catalogue of shipped policies and exporters of DevOps Config / Configuration Data Management (CDM).

Concepts: [[DevOps Config Data Model and Changesets]], [[DevOps Config Snapshots, Policies and Exporters]].

## Roles

DevOps Config:

| Role | Can | Contains |
|---|---|---|
| `sn_devops.app_admin` | create, read, update, delete DevOps Config applications | |
| `sn_devops_config.viewer` | read only | `sn_cdm.cdm_viewer` |
| `sn_devops_config.editor` | manage config data, changesets, publish snapshots | viewer, `sn_cdm.cdm_editor` |
| `sn_devops_config.secrets` | manage encrypted data | `sn_cdm.cdm_secrets` |
| `sn_devops_config.admin` | editor plus policies, exporters, applications | `sn_devops.app_admin`, editor, `sn_cdm.cdm_admin` |

CDM:

| Role | Can | Contains |
|---|---|---|
| `sn_cdm.cdm_viewer` | read config data, libraries, changesets, snapshots and results, exporters, policies; export snapshots; see the change's Investigate page | `sn_pace.policy_reader`, itil, `canvas_user` |
| `sn_cdm.cdm_editor` | edit config data, commit, validate, publish; manage component libraries and shared components. Not: applications, deployables, the enforce validation setting | `cdm_viewer` |
| `sn_cdm.cdm_exporter_editor` | exporters | `cdm_viewer` |
| `sn_cdm.cdm_policy_editor` | policies and mappings | `cdm_viewer`, `sn_pace.admin` |
| `sn_cdm.cdm_secrets` | with viewer: read and export encrypted data; with editor: edit, encrypt, decrypt. No effect alone | |
| `sn_cdm.app_service_admin` | lets the CDM admin create an application service | |
| `sn_cdm.cdm_admin` | applications, deployables, config data, enforce validation | editor, exporter editor, policy editor, `app_service_admin`, `model_manager`, itil |
| `sn_cdm.cdm_all_app_access` | with one of the above: access regardless of **Maintained by** / **Authoring groups** membership | |
| `evt_mgmt_user` | sees snapshots, nodes and changesets for alert investigation regardless of group | itil |

Without `cdm_secrets`: encrypted values always show as asterisks; such users can request validation and delete encrypted CDIs, but cannot view, create or update them, nor export a snapshot containing them.

## APIs

| API | For |
|---|---|
| DevOps Config API | application lifecycle (delete, get, patch, post) |
| `CdmApplicationsApi` | upload to component, collection, deployable and variable folders; export; shared components |
| `CdmChangesetsApi` | create, commit, list, delete changesets; node changes; impacted applications and deployables |
| `CdmEditorApi` | create, update, include, delete and retrieve nodes |
| `CdmPoliciesApi` | policy mappings of deployables |
| `CdmSharedLibraryApi` | shared libraries and components |
| `CdmSnapshotApi` | publish, unpublish, revalidate snapshots |
| `CdmVersionApi` | publish, unpublish, export versions of shared components |

Name path formats accepted by the REST API: slash-separated (`testApp/deployables/Development1/cdi1`; not usable when a node name contains `/`), the backend path with replacement characters, or an array (`['testApp','deployables','Development1','cdi1']`).

## Contextual variables

Used in a CDI value so it takes its value from where the node ends up, for example a collection variable that resolves to the name of whichever deployable includes it: `NAME`, `APPLICATION.NAME`, `DEPLOYABLE.NAME`, `DEPLOYABLE.ENVIRONMENT_TYPE`, `COLLECTION.NAME`, `FULL_PATH`, `RELATIVE_PATH`, `RELATIVE_PARENT_PATH`. The exact delimiters around the name are garbled in the PDF text: check an instance before using.

## What config data it holds

Application and service settings, middleware (databases, queues, load balancers), Kubernetes and service mesh, cloud resources, traditional infrastructure: API keys, passwords, feature toggles, connection strings, heap sizes, scaling rules, host names, certificates, versions. Source formats: JSON, YAML, properties, INI, XML, CSV.

## Domain separation

- DevOps Config: **no support** (data segregation only).
- CDM: **Basic**. Works when everything for an application (create, upload, commit, validate, map, export) is done by users of the application's domain; use one user per domain; policies and exporters must be in the application's domain or global. Tables with a domain column: `sn_cdm_application`, `sn_cdm_changeset`, `sn_cdm_deployable`, `sn_cdm_exporter`, `sn_cdm_exporter_execution`, `sn_cdm_exporter_execution_log`, `sn_cdm_exporter_version`, `sn_cdm_exporter_version_argument`, `sn_cdm_node`, `sn_cdm_node_main`, `sn_cdm_pace_policy_mapping`, `sn_cdm_restricted_groups`, `sn_cdm_snapshot`.

## Shipped policies: generic

Most accept `exceptionList` (keys to ignore) and `caseSensitive`.

| Policy (name) | Non-compliant when | Main inputs |
|---|---|---|
| All Key-Value Comparator (`allKeysValuesComparator`) | keys or values differ between the main and additional deployables (drift between staging and production) | `additionalDeployablesInput`, `includeNodes` |
| Key Existence Comparator (`keyExistenceComparator`) | a key of the main deployable is missing in the others | `additionalDeployablesInput` |
| Same Values Comparator (`sameValuesComparator`) | listed keys differ across deployables | `keysList`, `stopAtFirstFound` |
| Unique Values Across Deployables (`checkUniqueKeyValue_crossDeployables`) | a key has the same value in several deployables | `keyName` |
| Authorized Email Domains (`authorizedEmailDomains`) | an email domain is not in the list | `authorizedDomains` |
| Authorized Hosts in URLs (`authorisedHostsInURLS`), Correct Host Regex (`correctHostRegex`) | a URL host does not match | `authorizedHostsRegex` / `authorizedHostRegex` |
| Authorized Key-Value Combinations (`authorisedKVCombinations`) | a key has a value outside its allowed list | `authorisedList` (JSON) |
| Forbidden Key-Value Combinations (`forbiddenKVcombinations`), No Forbidden Values (`noForbiddenValues`) | a forbidden value is present | `forbiddenKV` / `forbiddenValues` (default `root`) |
| Authorized Ports Range (`authorisedPortsRange`) | a value is outside its range (any numeric range, not only ports) | `keysRegexWithRange` (JSON of regex → `min-max`) |
| Memory Limit Validator (`memoryLimitValidator`) | a memory value is outside min and max (KB, MB, GB, KiB, MiB, GiB) | `pathAndLimitsArray` |
| Certificate Validator (`certificateValidator`) | a certificate has expired or expires within the period | `certificatesNode`, `expirationDays` |
| Consistent Nodes Comparator (`consistentNodesComparator`) | first-level nodes differ (a group of identical machines) | |
| Node Keys Comparator (`nodeKeysComparator`), Nodes Value Comparator (`nodesValueComparator`) | two nodes differ in keys / in the listed values | `fromNode`, `toNode`, `sameValueKeys`, `diffValueKeys`, `allowMissingKeys` |
| Different Key Names Same Values (`differentKeyNamesSameValues`) | paired keys do not share a value | `keyPairs` (`["key1=key3"]`) |
| Different Values Nodes Comparator (`differentValuesNodesComparator`), Unique Key Value (`uniqueKeyValue`) | a key has the same value in several components / in several occurrences | `keynameList` / `keyList` |
| Same Key Value (`sameKeyValue`) | a key differs between components | `keyList` |
| Duplicate Values (`duplicateValues`), No Duplicate Keys (`noDuplicateKeys`) | duplicate values / key names | `exceptionList`, `keyNames` |
| List Comparator (`listComparator`) | two keys hold the same list of values | `list1Node`, `list2Node` |
| Generic Validator (`genericValidator`) | a key fails its comparison: `=`, `<`, `>`, `<=`, `>=`, `!=`, `RANGE`, `IN`, `NOT IN`, `CONTAINS`, `NOT CONTAINS`, `REGEX` | `keysToValidate` [{`key`, `operator`, `refValue`}] |
| Generic List Validator (`genericListValidator`) | a list value fails `IN`, `EQUALS`, `CONTAINS`, `NOT CONTAINS` | `keysToValidateObject` [{`keyPath`, `operator`, `referenceList`}] |
| Key Path Validator (`keyPathValidator`) | the key at a path has a wrong value (or is absent, if `ignoreIfNotFound` is false) | `pathAndDesiredValues`, `pathSeparator` |
| Key Value Substring Check (`keyValueSubstringCheck`) | a value lacks the required substring | `keyNameWithKeyValues` |
| Key Naming Convention (`keyNamingConvention`) | key names break length, prefix or suffix rules | `maxLength`, `approvedPrefixArray`, `approvedSuffixArray` |
| Mandatory Keys (`mandatoryKeys`), Mandatory Value (`mandatoryValue`), Mandatory Value By Type (`mandatoryValueByType`), No Empty Values (`noEmptyValues`) | a required key is missing, empty or of the wrong type | `mandatoryKeys`, `keysList`, `keyNamesString` / `Integer` / `Boolean` |
| Mandatory Tags List (`mandatoryTagsList`) | a tag value is not authorised | `tagsNodeName`, `tagsList` |
| No Clear Sensitive Data (`noClearSensitiveData`) | a key whose name contains a keyword is not encrypted | `keyWords` (default `pass,pwd,secret`) |
| No HTTP / No FTP / No LDAP (`noHTTP`, `noFTP`, `noLDAP`) | a URL uses the insecure protocol | `searchValue` |
| No White-Space Characters Allowed (`noWhiteSpaceAllowed`) | a value contains white space | `excludedKeyNames` |
| Unresolved Variables (`unresolvedVariables`) | a variable cannot be resolved | |
| Detect Unused Variables (`detectUnusedVariables`) | warning: a declared variable is not used | |
| Docker Image Format / Registry / Network Validator (`dockerImageFormatValidator`, `dockerImageRegistryValidator`, `dockerNetworkValidator`) | image tag does not match the regex; registry not authorised; service network not defined | `imageExpectedRegex`, `authorizedRegistryList` |

## Shipped policies: Kubernetes

Admission plugin AlwaysPullImages enabled; basic auth file not set; token auth file not set; insecure bind address not set; bind address of scheduler and controller manager; secure port not 0; kubelet HTTPS true; service account private key file specified; containers: minimum UID (`min_uid`, default 10000), drop capabilities required, run as non-root, not privileged, no SYS_ADMIN, privilege escalation not allowed, read-only root file system, seccomp profile (Localhost or RuntimeDefault), image pull policy Always, CPU and memory requests within limits; Docker daemon socket not exposed; no wildcard in RBAC rules.

## Shipped policies: Red Hat OpenShift

Audit log max backup and max size set (`lowerLimit`, `upperLimit`); audit log path set; basic auth file and token auth file not set; containers not privileged; host PID namespace disabled in at least one SCC (warning); NamespaceLifecycle plugin enabled; kubelet read-only port disabled; request timeout set; streaming connection idle timeout not 0.

## Shipped exporters

| Exporter | Returns | Arguments |
|---|---|---|
| `returnAllData-now` | the whole snapshot including vars | application, deployable, format (json, yaml, xml, ini, raw) |
| `returnAllData_noVars-now` | everything except the vars folders and the deployable name at the root | |
| `returnDataforNodeName-now` | the subtree of one node; errors if the name is not unique or not found | `nodeName`, `includeNodeInOutput` |
| `returnDataForNodeNames-now` | nested data for several nodes, with a per-node error entry | `nodeNames` |
| `returnDataForPath-now` | data at a node path | `nodePath` |
| `returnNodeListForLevel-now` | names of nodes at a depth (0 = the deployable root) | `nodeLevel`, `ExcludeVarsNode` |
| `returnNodeListForPath-now` | child node names at a path | `nodePath`, `pathSeparator` |
| `returnValueForKeyAtNodeName-now` | value of a key somewhere under a node (must be unique there) | `keyName`, node name |
| `returnValueForKeyPath-now` | value at a key path; errors if the path is a node | `keyPath`, `pathSeparator` |
| `returnValueForUniqueKeyName-now` | value of one or more keys expected to be unique in the whole snapshot (first value found if not); formats json, yaml, raw only (no xml, ini); errors when the key is missing or not found | `keyName` |

Exporters fail for deleted applications or deployables.

## Related

- [[DevOps Config Data Model and Changesets]] · [[DevOps Config Snapshots, Policies and Exporters]] · [[DevOps Config Pipeline Integration]]
