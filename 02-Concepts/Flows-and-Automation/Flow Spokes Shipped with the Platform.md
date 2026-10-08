---
type: reference
tags: [reference, flows, automation, integrations, incident, change]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Reference > Workflow Studio flow integrations (read 2026-10-08 through the docs site): Workflow Studio flow integrations, Spokes, Benchmarks Spoke, Connect spoke, Customer Service Spoke, External Related Files spoke, Field Service Spoke, ITSM spoke, Machine Learning solutions for Flow Designer, Robotic Process Automation (RPA) Spoke, Security Operations spoke, Visual Task Board (VTB) Spoke. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/spokes.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flow Spokes Shipped with the Platform

**What it is:** a *spoke* is a scoped application holding flow content (actions, subflows, triggers) for one product or record type. These spokes come with platform applications and need no Integration Hub subscription; they activate with their parent application. Third-party spokes (Jira, Teams ...) need Integration Hub. Core spoke: [[Flow Core Actions Reference]].

Other products that add flow content: App Engine Studio (flows from templates), Integration Hub (integration steps and spokes), Process Automation Designer (calls flows and actions), RPA Hub.

| Spoke | Plugin | Comes with |
|---|---|---|
| ITSM | `com.snc.itsm.spoke` | Incident, Problem, Change |
| Connect | `com.glide.connect_v3plus.core.ah` | platform |
| Visual Task Board | `com.glide.ui.vtb.ah` | platform |
| External Related Files | `com.sn.external.files` | platform |
| Customer Service | `com.snc.customer_service.spoke` | Customer Service Management |
| Field Service | `com.snc.field_service.spoke` | Field Service Management |
| Machine Learning solutions for Flow Designer | `com.snc.ml_flowdesigner` | Predictive Intelligence |
| RPA | `com.sn_rpa_foundation` | RPA Hub |
| Security Operations | `com.snc.secops.spoke` | Security Operations |
| Benchmarks | `com.sn_bm_client.spoke` | Benchmarks (read-only actions for its own flow) |

## ITSM spoke actions

| Area | Actions |
|---|---|
| Journal | Add Comment, Add Worknote |
| Assignment | Update Assignee, Update Assignment Group, Assign Incident to CI Support Group |
| Incident | Create Incident, Create Incident Task on Incident, Create Problem from Incident |
| Change from incident | Create Emergency Request from Incident, Create Normal Change Request from Incident, Create Standard Change Request from Incident |
| Change | Create Emergency Change Request, Create Standard Change Request, Create Change Task on Change Request, **Apply Change Approval Policy** (creates user and group approvals from a change approval policy; usable several times in a flow), Check Change for User Approval, Disregard Change Approvals (pending approvals become no longer required), Cancel Change Tasks from Flow |
| Request | Create Request, Create Catalog Task on Request, Create Catalog Task on Request Item |
| Generic | Create Task (a child task for any task record) |
| Outage | Create Outage (the **Task** field is filled only when the source is a task), Create Task Outage Relationship |

The actions can be opened (admin, `flow_designer`, `action_designer`): their Create Record step shows which common Task fields are copied, for example short description, configuration item, priority, company and description when making a change from an incident.

## Other spokes

| Spoke | Actions |
|---|---|
| Connect | Add Group Users to Task Conversation, Add User to Task Conversation, Send Message to Task Conversation (Connect API v3 and later) |
| Customer Service | Get Case, Create Case, Create Quick Case, Create Task on Case, Update Case, Assign Case (by matching rules), Escalate Case, Escalate Account (both only *request* escalation), Add Work Note to Task, Add Comment to Task |
| Field Service | Get / Create / Update Work Order, Get / Create / Update Work Order Task, Add Work Note to Task |
| External Related Files | Create / Update / Delete External File Record. Tables External Provider (`sn_ext_files_spoke_provider`) and External Related Files (`sn_external_related_files`, extensible). Roles `sn_ext_files_spoke.doc_reader`, `.file_admin`, `.provider_admin` |
| Machine Learning | Classification Prediction, Classification Batch Prediction, Similarity Prediction, PI Confidence Check, Regression Prediction and Regression Batch Prediction (regression is **deprecated in Australia**: existing solutions run, new ones cannot be created). Needs a trained solution; role `ml_admin` |
| Visual Task Board | boards: Create Freeform / Flexible / Guided VTB, Add / Remove VTB Member; lanes (freeform and flexible only): Add, Rename, Reorder, Delete VTB Lane; cards: Create VTB Card (freeform), Assign VTB Card, Move VTB Card, Remove Assignee from VTB Card. Moving a card on a guided board changes the task field behind the lanes; on a flexible board update the task with Update Record instead |
| RPA | work queue: Add WorkItem to Queue, Update WorkItem, Fetch Work Item Status (request and response content up to 8000 characters; encrypted when the queue is marked sensitive); people: Assign / Unassign User to Attended Automation Process, Assign / Unassign User to Attended Robot; bot processes: Start Process, Stop Process (optional graceful stop), Change Life Cycle Stage Status of a Bot Process (Build > Published; Published <> In Maintenance), Update Process Parameter, Fetch Created Jobs, Fetch Execution Status, Verify HashCode of a Package Version; subflows Start Process, Stop Process, Import Package Version Attachment |
| Security Operations | flow templates for Security Incident Response, each started when a security incident's **Category** is set or changed: Confidential Data Exposure, Denial of Service, Lost Equipment, Malicious Software, Phishing, Policy Violation, Reconnaissance, Rogue Server or Service, Spam, Unauthorized Access, Web/BBS Defacement |

## Related

- [[Flow Core Actions Reference]] · [[Flows, Subflows and Actions Overview and Architecture]] · [[Workflow Studio Overview]]
