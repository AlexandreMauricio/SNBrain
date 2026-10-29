---
type: reference
tags: [reference, integrations, cmdb, import-sets, scripting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Integration Commons for CMDB > RTE operation types, RTE transforms template scripts (read 2026-10-29; examples summarised, not copied). https://www.servicenow.com/docs/r/servicenow-platform/cmdb-integration-commons/cmdb-rte-transforms.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# RTE Operations and Integration Commons Transforms Reference

**In one line:** the ready-made Robust Transform Engine (RTE) operations you can pick in IntegrationHub ETL or an ETL definition: generic operation types, plus the CMDB cleansing and class-derivation templates from [[Integration Commons for CMDB]].

Each operation is a record in its own table, with input field(s) `source_sys_rte_eb_field(s)` and output field(s) `target_sys_rte_eb_field(s)` on the ETL entity. Context: [[Robust Import Set Transformers and ETL Definitions]].

## Generic operation types

| Operation | Table | Does | Extra fields |
|---|---|---|---|
| Concatenation | `sys_rte_eb_concat_operation` | join inputs into one string | `joining_string` |
| Convert to Boolean | `sys_rte_eb_to_boolean_operation` | `true`/`1` (any case) → true, else false | |
| Convert to Date | `sys_rte_eb_to_date_operation` | parse with a date format to GlideDateTime; falls back to direct parsing; empty if unparsable | `date_format` |
| Convert to Numeric | `sys_rte_eb_to_numeric_operation` | number, empty if not numeric | |
| Copy | `sys_rte_eb_copy_operation` | copy one source to several targets | `overwrite_existing_value` |
| Extract First Numeric | `sys_rte_eb_extract_numeric_operation` | first number in the text (`100 mb` → 100) | `decimal_places`, `remainder_target_field` |
| Glide Lookup | `sys_rte_eb_glide_lookup_operation` | look up a table by matching columns, return target columns (e.g. location sys_id from street and state) | `target_table`, `glide_matching_fields`, `glide_target_fields` (counts must match inputs/outputs) |
| Multiple Input Script | `sys_rte_eb_multi_in_script_operation` | script over a batch, one output | `script`, `use_unique_input_sets` |
| Multiple Input/Output Script | `sys_rte_eb_multiple_input_output_script_operation` | script setting several outputs | `script` |
| Regex Replace | `sys_rte_eb_regex_replace_operation` | regex replace | `match_regex`, `replacement_regex` |
| Replace | `sys_rte_eb_replace_operation` | plain text replace | `match_string`, `replacement_string` |
| Round Numeric | `sys_rte_eb_round_numeric_operation` | round to whole number; non-numbers become empty | (docs list match/replacement strings here too, probably copied by mistake: unconfirmed) |
| Script | `sys_rte_eb_script_operation` | one input, script output; kept for backward compatibility, prefer Multiple Input Script | `script`, `use_unique_input_sets` |
| Set | `sys_rte_eb_set_operation` | constant value | `set_value`, `overwrite_existing_value` |
| Set Min/Max | `sys_rte_eb_min_max_operation` | min or max of inputs | `data_type` (STRING, NUMERIC, DATE), `min_max` |
| Split | `sys_rte_eb_split_operation` | split into targets in order (missing parts null, extra parts dropped) | `splitting_string` |
| Trim / Uppercase / Uppercase Trim | `sys_rte_eb_trim_operation`, `..._upper_case_operation`, `..._upper_case_trim_operation` | as named | |

`use_unique_input_sets` = true sends each distinct input combination to the script once (fewer IRE items); false processes every row.

### Script shape (server side, inside the RTE, scope of the ETL)

```javascript
// Multiple Input Script operation: batch = array of input rows, output = array of results
(function(batch, output) {
    for (var i = 0; i < batch.length; i++) {
        var type = gs.nil(batch[i].record_type) ? '' : batch[i].record_type;   // input field names as mapped
        var os = gs.nil(batch[i].operating_system) ? '' : batch[i].operating_system;
        output[i] = type + '_' + os;              // Multiple Input/Output: output[i].<field> = ...
    }
})(batch, output);
```

The single-input **Script** operation exposes the source value as `batch[i].input`.

## Integration Commons templates (scope `sn_cmdb_int_util`)

Multi-value outputs are joined with `|||` (e.g. `<company sys_id>|||<company name>|||<model sys_id>|||<model name>`) and usually followed by a Split.

| Template | Use | Script include function |
|---|---|---|
| CI Lookup | read a field of an existing CI by discovery source + source native key (via `sys_object_source`) | (table `sn_cmdb_int_util_ci_lookup_operation`) |
| Cleanse Company | normalise a manufacturer and create/find it in `core_company` | `CmdbIntegrationHardwareModelUtil().cleanseCompany` |
| Cleanse Hardware Model (with Model Number) | find or create company and hardware model via the `MakeAndModelJS` API; optional CI class picks the model class from **Model Category** (`cmdb_model_category`), else `cmdb_hardware_product_model` | `CmdbIntegrationHardwareModelUtil().cleanseModelAndCompany` |
| Cleanse IP Address / IP Version | fix IPv4/IPv6 formats (spaces, dashes, lists → first address) / return 4, 6 or empty | `CmdbIntegrationNetworkUtil().cleanseIpAddress`, `.deriveIpVersion` |
| Cleanse MAC Address | normalise to `aa:bb:cc:dd:ee:ff` | `CmdbIntegrationNetworkUtil().cleanseMacAddress` |
| Cleanse Operating System | shorten and normalise OS names (mostly Windows) and add to the `cmdb_ci_computer.os` choice list | `CmdbIntegrationOsUtil().cleanseAndInsertOs` |
| Cleanse Serial Number (with alternate value) | drop invalid serials; alternate value if shorter than `sn_cmdb_int_util.minimum_valid_serial_number_length` (7) | `global.SerialNumberManager().isValid` |
| Cleanse IMEI (with alternate value) | alternate value unless length = `sn_cmdb_int_util.valid_imei_number_length` (15) | none |
| Cleanse Software Model / Create Software Instance Name | normalise publisher, name, version (version removed from name) | `CmdbIntegrationSoftwareModelUtil().cleanseSoftwareModel`, `.createSoftwareInstanceName` |
| Derive CI Class from Model / Native Class Identifier / Operating System | choose a computer class when the source is ambiguous (can be chained) | `CmdbIntegrationClassUtil().deriveClassNameFromModelInput`, `...FromNativeValue`, `...FromOsName` |
| Derive Virtual From Hardware Model / Native Indicator / Serial Number | set the virtual flag | `CmdbIntegrationVirtualDetectionUtil().detectVirtualFromModelName`, `...FromNativeIdentifier`, `...FromSerialNumber` |
| Extract and Scale by Units / Scale Unit | `2048Mb` or value + units → target units (e.g. 1 GB → 1024 MB) | `CmdbIntegrationExtractScaleUnitUtil().extractAndScaleUnits`, `CmdbIntegrationScaleUnitUtil().scaleUnits` |
| First Non Null Value | rank several source fields for one target | `CmdbIntegrationFirstNonNullValueUtil().firstNonNullValue` |
| Process Name, Domain, FQDN, DNS set / Process FQDN | derive name, domain, FQDN, DNS from whichever are given | `CmdbIntegrationHardwareNameUtil().processNameDomainFqdnDnsSet` (FQDN variant function not printed) |
| Software Bundle ID Lookup | Mac bundle ID → publisher, name, seller (e.g. Jamf); unknown IDs queued for the *Lookup Mac Software Bundle IDs* data source | `CmdbIntegrationSoftwareBundleIdLookup.lookupSoftware` |
| User Lookup | `sys_user` by user name, then email | (table `sn_cmdb_int_util_user_lookup_operation`) |

Table names of the templates follow `sn_cmdb_int_util_<name>_operation`. Garbled names printed in the docs (kept as unconfirmed variants): `sn_cmdb_int_util_cle$anse_serial_number_with_alternate_value_return_if_invalid`, bundle table `sn-cmdb_int_util_bundleid_lookup` vs operation table `sn_cmdb_int_util_software_bundle_id_lookup_operation`.

## Related

- [[Integration Commons for CMDB]] · [[Robust Import Set Transformers and ETL Definitions]] · [[Models, Model Categories and the Product Catalog]]
