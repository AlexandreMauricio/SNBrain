---
type: reference
tags: [reference, integrations, flows, ai, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Integration Hub > Build integrations > Integration Hub spokes (table of contents only, 530 topics under 207 entries; no individual spoke page read), Now Assist for Integration Hub (3 topics) read 2026-10-30. https://www.servicenow.com/docs/r/integrate-applications/create-integrations-applications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Integration Hub Spokes Catalog

**In one line:** the spokes documented in the Brazil guide, a lookup for "is there a spoke for X?". It lists names only.

From the Brazil table of contents; not tested. A listing does not mean the spoke is installed or licensed: most come from the Store and need [[Integration Hub Overview and Subscription|Integration Hub]]. Spokes that ship with platform applications are in [[Flow Spokes Shipped with the Platform]].

The contents list 207 entries and 206 distinct names; Metrikus appears twice. Some have two generations, kept as listed: Jenkins and Jenkins v2, Microsoft Active Directory and v2.

| | Spoke |
|---|---|
| A | Adobe Experience Platform, Adobe Sign, Agent Client Collector, Aha!, AI Search, Amazon Alexa, Amazon CloudWatch, Amazon Connect, Amazon DynamoDB, Amazon EBS, Amazon EC2, Amazon Elastic Container Service, Amazon RDS, Amazon Route 53, Amazon S3, Amazon SNS, Amazon SQS, Amazon VPC, Ansible, Asana, Atlassian Administration, Automation Anywhere, AWS Certificate Manager, AWS CloudFormation, AWS Elastic Beanstalk, AWS Elastic Load Balancing, AWS IAM, AWS Lambda, AWS OpsWorks, AWS Translate |
| B | BigFix Inventory, Blue Prism, BMC Remedy, Box |
| C | Calendly, Cisco Webex Meetings, Cisco Webex Teams, Confluence Cloud, Confluent Kafka REST Proxy, Continuous Integration and Continuous Delivery (CICD), Cornerstone, Coupa, Craft, Credly, CrowdStrike |
| D | Databricks, Docker, Docusign eSignature, Dropbox Business, Dun and Bradstreet DirectPlus |
| E | Equifax, Ethoca |
| F | F5 BIG-IP, First Advantage, FRISS |
| G | GitHub, GitLab, Gmail, Google Calendar, Google Chat, Google Cloud Datastore, Google Cloud DNS, Google Cloud Functions, Google Cloud Load Balancer, Google Cloud Pub Sub, Google Cloud SQL, Google Cloud Storage, Google Cloud Translator Service, Google Cloud Virtual Network, Google Cloud VPC Access, Google Compute Engine, Google Directory, Google Docs, Google Drive, Google Identity and Access, Google Meet, Google Persistent Disk, Google Sheets, Google Tasks, GoTo, GovNotify, Gremlin, Guidewire |
| H | HL7 FHIR |
| I | iManage, Infoblox |
| J | Jack Henry jXchange, Jamf, Jenkins, Jenkins v2, Jira, Jira Service Management |
| K | Kubernetes |
| L | Legal Tracker, Lenovo, Looker, Lucidchart Diagramming |
| M | Magnit, Mastercard, Metrikus, Microsoft 365 Excel, Microsoft Active Directory, Microsoft Active Directory v2, Microsoft Azure Application Insights, Microsoft Azure Artifacts, Microsoft Azure Automation, Microsoft Azure Blob Storage, Microsoft Azure Cosmos DB, Microsoft Azure DevOps Boards, Microsoft Azure DevOps Pipelines, Microsoft Azure Managed Storage, Microsoft Azure Notification Hub, Microsoft Azure RBAC, Microsoft Azure Resource Management, Microsoft Azure SQL Database, Microsoft Azure Traffic Manager, Microsoft Azure Virtual Machine, Microsoft Azure Virtual Network, Microsoft Dynamics 365, Microsoft Dynamics 365 for Finance and Operations, Microsoft Dynamics CRM, Microsoft Endpoint Configuration Manager, Microsoft Entra Entitlement Management, Microsoft Entra ID Spoke (formerly Microsoft Azure Active Directory spoke), Microsoft Exchange Online, Microsoft Exchange Server, Microsoft Intune, Microsoft OneDrive, Microsoft SCCM, Microsoft Security Response Center, Microsoft SharePoint Online, Microsoft Teams, Microsoft Teams Communications, Microsoft Teams Graph, Miro, monday.com |
| N | Navex EthicsPoint |
| O | Okta, OneLogin, Oracle Autonomous DB, Oracle Block Storage, Oracle Boot Volume, Oracle Cloud IAM, Oracle Compute Engine, Oracle EBS, Oracle Financial Cloud, Oracle HCM Cloud, Oracle NetSuite, Oracle Object Storage Management, Oracle Peoplesoft Financial, Oracle Virtual Cloud Network |
| P | PagerDuty, Plivo, Pluralsight |
| Q | Qualtrics |
| R | Rally, Redox Electronic Health Record, Roadmunk |
| S | Saba, Salesforce, Salesforce Marketing Cloud, SAP Ariba, SAP Commerce Cloud, SAP Concur, SAP ECC IDoc, SAP ECC RFC, SAP Fieldglass, SAP S4 HANA IDoc, SAP S4 HANA OData, SAP S4 HANA Public Cloud, SAP S4 HANA RFC, SCCM Usage Metering, Secureworks CTP, ServiceNow Remote Instance, ServiceNow University, Shodan, Slack, SmartRecruiters, Smartsheet, Snowflake, Socure, SuccessFactors, SuccessFactors Learning, SumTotal, SurveyMonkey |
| T | Tableau, Trello, Twilio |
| U | UCF, Udemy, UiPath, UKG, Utility Actions |
| V | Verifi, Visa, Vonage |
| W | Workday Financials, Workday HR, Workday Learning, Workfront, Workplace from Facebook, Wrike |
| X | X Spoke (formerly Twitter Spoke) |
| Y | YouTube |
| Z | Zendesk, Zoom |

Older spokes named in the plugin list but not in these contents, such as HipChat, are not included. SAP and Workday spokes overlap with [[Zero Copy Connector for ERP]]; UiPath, Blue Prism and Automation Anywhere with [[Automation Center]].

## Now Assist for Integration Hub

Store application, v2.2.0 on the page, supported from Xanadu Patch 7. Needs Now Assist for Platform (`sn_genai_platform`) and an Integration Hub subscription. It makes spoke actions conversational, and supplies AI agents callable from AI Agent Studio and Virtual Agent.

- **Meeting scheduler AI agent:** finds rooms, attendees and a free slot, then creates a calendar, Teams or Zoom event, with the logged-in user as organiser. Needs the Microsoft Exchange Online spoke with a client credential alias; Zoom links need the Zoom spoke.
- **Spokes with their own AI agents:** Box, Coupa, Docusign eSignature, F5 BIG-IP, GitHub, GitLab, Google Calendar, Google Chat, Google Cloud Storage, Google Docs, Google Drive, Google Meet, Google Tasks, GovNotify, Jenkins, Jira, Jira Service Management, Kubernetes, Microsoft Active Directory v2, Microsoft Entra ID, Microsoft Azure DevOps Boards, Microsoft Dynamics CRM, Microsoft Exchange Online, Microsoft OneDrive, Microsoft Security Response Center, Microsoft SharePoint Online, Microsoft Teams Graph, Miro, Okta, Oracle HCM Cloud, PagerDuty, SAP Ariba, SAP Concur, Slack, Smartsheet, SuccessFactors, X, Workday HR, Wrike, Zoom.
- Agents run with the user's own access: they need the roles for the tables involved. Access to agentic workflows uses role masking.

## Related spoke solutions

- **Retry Handler Framework:** retries HTTP requests on status 429 after the retry-after time; available only with the Microsoft Exchange Online spoke or the Journey Accelerator app. Compare the retry policy in [[Custom Actions, Dynamic Inputs and Error Evaluation]].
- [[Client Software Distribution 2.0]]
- **ServiceNow Kafka Consumer:** see [[Stream Connect for Apache Kafka]].

## Example

A team needs Example Tracker issues in flows. It checks this list, requests the spoke from the Store, configures the alias, then uses the spoke's actions in *Example Issue Flow*.

## Related

- [[Integration Hub Overview and Subscription]] · [[Flow Spokes Shipped with the Platform]] · [[Connections, Credentials and Aliases]]
