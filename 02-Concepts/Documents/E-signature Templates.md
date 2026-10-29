---
type: concept
tags: [concept, knowledge, forms-lists, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage people and work capabilities > E-signature (landing, Activating e-signature, Using e-signature, Create or modify an e-signature template, Using e-signature template for non-HR tasks, Components installed with e-signature), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/e-signature/e-signature.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# E-signature Templates

**In one line:** the scoped application **E-signature** (`com.snc.esign`, scope `sn_esign`) lets a task ask its assignee to sign a **managed document**, a **knowledge article** or an **HR document template** by typed or drawn signature, by credentials, or by acknowledgment.

From the Brazil docs; not tested. Different from the older *Approval with E-Signature* (re-enter credentials on approve) described in [[Managed Documents]] and [[Classic Approvals]].

Activation (admin) also turns on Document Viewer `com.snc.documentviewer` ([[Document Viewer, PDF Generation and Document Conversion]]), Managed Documents `com.snc.document_management`, and Signature pad `com.snc.signaturepad`. Demo data available.

## Template

**E-signature > E-signature template** (`sn_esign_configuration`; `sn_esign.admin` or `sn_esign.config_manager`):

| Field | Meaning |
|---|---|
| Name | |
| Task table | table the template is for (HR document templates need HR Task `sn_hr_core_task`) |
| Document type | *HR document template* (the document is picked on the HR case), *Knowledge article* (field Knowledge article), *Managed document* (field Managed document) |
| Signature type | *Acknowledgment* (accepting and completing the task; not for HR templates), *Credential* (user name and password), *Signature* (typed or drawn) |
| Acknowledgment text | check box text the signer must tick, any type, max 1,000 characters |

## Use on a non-HR task (e.g. incident)

1. Template on `incident`, Document type *Managed document*, Signature type *Signature*.
2. Add the **E-Signature Template** field to the form and the **E-signature history** related list.
3. On the record pick the template, assign group and user.
4. When the assignee moves the task to **Work in Progress**, **Sign document** appears.
5. Signatures: **System Logs > Signature Images** (`signature_image`) and the history related list. Acknowledgments: `sn_esign_acknowledgement`.

## Roles

| Role | Can |
|---|---|
| `sn_esign.admin` | manage the module (contains `sn_esign.config_manager`) |
| `sn_esign.config_manager` | manage templates |

## Example

Template *Example NDA Signature*: Task table `incident`, Managed document *Example NDA*, Signature type *Signature*, acknowledgment text "I have read the Example NDA". *Test User* signs after setting the incident to Work in Progress.

## Related

- [[Document Management]]
