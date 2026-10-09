---
type: concept
tags: [concept, ai, security, access-control, roles, domain-separation, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Agentic AI security and governance (7 topics, 260 cleaned lines, read in full 2026-10-08 through the docs site) - Agentic AI security and governance, Permissions-based access control, Data protection, Agent traceability and monitoring, Governance and admin safeguards, AI threat protection, External AI agent security. These pages are overviews that point to topics in the AI documentation (AI Admin Hub, AI Agent Studio, AI Guardian, AI Control Tower); those linked topics were not read. https://www.servicenow.com/docs/r/platform-security/now-assist-security.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Agentic AI Security and Governance

**In one line:** a map of the controls around AI agents and generative AI skills on the platform, in six areas: what an agent may access, how data is protected on the way to a model, how agent activity is traced, how readiness and domain separation are governed, how harmful content and prompt injection are caught, and how agents from other vendors are let in.

From the Brazil docs; an overview chapter, so most rows point elsewhere. The agents themselves: [[Otto for ITSM Skills and Agentic Workflows]], [[Otto for ITSM Agentic Workflows and AI Agents Reference]].

## The six areas

| Area | Controls named | In this vault |
|---|---|---|
| **Permissions** | ACLs decide **who can invoke** an agent; the user identity it runs under decides **what data it reaches**; role masking narrows inherited roles during tool execution. Agents are subject to the same ACLs as users. Guided setup defines user access and data access for an agent, an agentic workflow or a custom skill, and a manual access test checks who can discover and invoke it | [[Role Masking for AI Agents]], [[Access Control Lists (ACLs)]] |
| **Data protection** | usage policy for user data; masking of personal data before it reaches the model; privacy policies; a *data steward* role that decides on data sharing; opting out of sharing data with ServiceNow for model improvement (admin console **Settings**); keys, field encryption and classification; Otto for Vault skills (schedule a discovery job, check role access to an encrypted column, generate a data pattern); AI Data Kit to scan and cleanse datasets before evaluations | [[Data Privacy Channel Policies - AI Prompts, Inbound Email and Virtual Agent]], [[Data Discovery - Patterns, Policies, Jobs and Findings]], [[Data Classification]], [[Field Encryption - Modules, Encrypted Fields and Access]], [[Key Management Framework (KMF)]], [[ServiceNow Vault and Otto for Vault]] |
| **Traceability** | AI Guardian logs and analytics (exportable); AI analytics for skill usage, adoption and performance; the AI Agent Analytics dashboard (use, time to resolution, tasks closed); AI Control Tower for tracking AI assets | no note yet |
| **Governance** | the *Now Assist Readiness Evaluation* application: scheduled jobs and guided setup, then assessment tabs with actionable items and direct links, for generative AI products and for agentic AI in ITSM and CSM. Domain separation is stated as supported for the AI Admin Hub console, AI Agent Studio, AI Admin Center and Now Assist in Virtual Agent | [[Domain Separation Overview]] |
| **Threat protection** | **AI Guardian** inspects requests to models and their responses at run time for offensive content, prompt injection and sensitive topics, and logs or blocks according to configuration. Settings: guardrail service provider, offensiveness protection, prompt injection protection, sensitive topic filters (redirect a Virtual Agent conversation), enabling it for AI agents | no note yet |
| **External agents** | third-party agents join through the Agent2Agent (A2A) protocol or manual integration in AI Agent Studio; securing them means scoped credentials, controlled discoverability and instance-level data access settings | [[Connections, Credentials and Aliases]] |

## Roles named

| Role | Allows |
|---|---|
| `sn_nowassist_admin.nsa_admin` (Now Assist Admin) | create, edit and configure skills and settings |
| `sn_nowassist_admin.user` (AI Admin Hub console user) | read-only access to the AI Admin Hub console |
| `sn_aia.admin` | AI agent tables, role masking |

More in [[Granular Admin Roles]].

## Compliance framing

The chapter presents these controls as the means to meet requirements such as HIPAA, GDPR and NIST; it lists no control-by-control mapping.

## Related

- [[Role Masking for AI Agents]] · [[Data Privacy Overview]] · [[Otto for ITSM Skills and Agentic Workflows]] · [[Agentic Development Overview, Tool Comparison and Governance]] · [[Security Center]] · [[Granular Admin Roles]]
