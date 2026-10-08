---
type: concept
tags: [concept, security, ai, data-management, admin, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > ServiceNow Vault (whole chapter, 27 topics, 1,099 cleaned lines) and ServiceNow Otto for Vault landing page (67 lines), both read in full 2026-10-08 through the docs site; plus the guide landing pages Secure your instance and Platform Security (83 lines). Covers Exploring ServiceNow Vault, Vault Suite, AI in Vault, installation (Vault, Vault Suite, plugins, Otto for Vault), roles, guided setup, agentic workflows, generative AI skills, console dashboard, Insights, tools and metrics, default policies and configurations. https://www.servicenow.com/docs/r/platform-security/servicenow-vault-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ServiceNow Vault and Otto for Vault

**In one line:** Vault is a paid bundle of the platform's data-protection tools (discover and classify sensitive data, anonymize it, encrypt it, demand re-authentication to reach it, export logs, sign code) behind one console, with an AI companion (Otto for Vault) that performs the common set-up tasks by conversation.

From the Brazil docs. The pieces it bundles that are already in the vault: [[Zero Trust Access - Session Access and Continuous Authentication]], [[Access Analyzer, Access Findings and Access Observer]]. Other chapters of the same guide: [[Data Privacy Overview]], [[Log Export Service (LES)]], [[Code Signing and the Circle of Trust]]; Encryption is not yet in the vault at the time of writing.

- Console: **All > Vault > Vault Console** (read-only until you elevate to the console admin role; preview-only until the console application is installed).
- Subscription product; some plugins are activated with the purchase, others from the application list.

## What it bundles (Vault Suite)

One Store installation (**Application Manager > Vault Suite > Install**, or the *ServiceNow Vault* tile on Admin Home > **Start new setup**, shown only with an entitlement). Without an entitlement the plugins install inactive and the console cards stay disabled. Installing over an existing Vault keeps its configuration.

| Capability | Id | Purpose |
|---|---|---|
| Vault Console | Store app, scope `sn_vault_console` | the dashboard |
| Data Privacy | Store app, scope `sn_dp_store_app` | discover, classify and anonymize sensitive data (clones, right-to-be-forgotten requests, masking in channels) |
| Code Signing | `com.glide.code_signing_enterprise` | integrity of code artefacts |
| Field Encryption | `com.glide.field.encryption.enterprise` | unlimited field and attachment encryption, customer-managed keys |
| Zero Trust Access - Continuous Authentication | `com.snc.zero_trust_continuous_authentication` | re-authentication when touching sensitive data |
| Zero Trust Access - Location | `com.snc.zero_trust_location_access` | access to classified data by location |
| Zero Trust Access - Session Access | `com.snc.zero_trust_session_access` | reduced privileges per session |
| Log Export Service | `com.sn_logstoanalytics` | instance logs to external analytics |
| Cloud Encryption | `com.glide.platform.cloud_encryption` | encryption at rest; **not** installed by the suite (comes with new instances; older ones request it, KB1117369) |

Data Discovery works as soon as the console is installed; Data Classification is part of the platform. Console tool cards show whether each tool is included, fully licensed, limited, or unlicensed.

## Roles

| Role | Gives |
|---|---|
| `sn_vault_console.vault_console_admin` | the console and guided setup; combines the data classification, data privacy and continuous authentication admin roles; read-only on the tool charts and protection configurations; includes `access_analyzer_ai_user` |
| `sn_vault_console.vault_console_auditor` | read-only console |
| `ca_policy_admin` / `ca_admin` | continuous authentication policies / plus properties, dashboards, metrics |
| `data_privacy_admin` | anonymization techniques and policies (no jobs) |
| `data_privacy_processor` / `data_privacy_clone_processor` | user-based / data-class-based anonymization jobs |
| `security_admin` | field encryption configurations in guided setup, ACLs, high security settings. **No longer part of the console admin role and not in the Elevate list for it: an admin must grant it** ([[Explicit Roles and Elevated Privilege Roles]]) |
| `sn_kmf.admin`, `sn_kmf.cryptographic_manager` | key management: needed for encryption work and to see key metrics |

## Guided setup: secure one application

**Vault Console > Guided vault**: *ServiceNow apps* tab > **Get started** on an application; or *Custom apps* tab > **+ Add custom app** (needs Otto for Vault), or ask the assistant "Find and secure my custom apps".

1. **Select app data**: table, column, existing class, proposed class and the reason (proposals come from column names and application context).
2. **Preview data classification** > tick **Agree** > **Classify data**; then the summary (failures are handled in Data Classification).
3. **Protect existing data**: per column, whether anonymization, field encryption and zero trust access are *Available* or already applied; **Available** starts that tool's configuration.
4. **Protect real-time data**: real-time anonymization per channel or column (instance-wide, not per application).

## Console dashboard

| Section | Content |
|---|---|
| **Insights** | AI summary: one insight and one next step each for data discovery, classification, and data protection (anonymization, field encryption and zero trust together). Same data as the charts. Needs Otto for Vault; visible to the console admin role only (hidden for auditors); an area is silently left out if its product is missing, returns nothing, or has no next step. Marked "Generated by AI. Check for accuracy" |
| Overview, resources, assistant | video, FAQs, the conversational panel |
| **Guided vault** | the application cards above |
| **Tools and metrics** | below |

| Tool | Metrics shown |
|---|---|
| Data Discovery | occurrences by pattern; status of findings (new, classified, ignored); findings in attachments |
| Data Classification | classifiable tables and columns; classified dictionary entries |
| Anonymization | classified data anonymized or not, per workflow; successful real-time calls per channel; job run times |
| Cloud Encryption with Key Management | rotations of the active key; time between rotations (KMF roles needed) |
| Field Encryption | classification status of encrypted fields; share of classified data encrypted; active keys, ideally one per classification (KMF roles and `security_admin`) |
| Log Export Service | MB exported per month over six months; top topics; this month by topic |
| Zero Trust Access | classifications and classes covered by continuous authentication policies |
| Code Signing | operations on signed records in the past week, and by table |
| **AI Insights** (monitoring) | users who entered sensitive data in assistant channels or in tables with real-time discovery; occurrences per channel and per table by pattern |

## Default policies and configurations

Only with a Vault subscription (Vault Console 2.1 or later):

| Tool | Default | How applied |
|---|---|---|
| Anonymization | real-time protection policies | **Activate** on the tool card; added to existing policies |
| Log Export Service (3.5.0 or later) | configurations | **Activate**, only if none exist |
| Zero Trust Access | step-up authentication when opening Cryptographic Module (`sys_kmf_crypto_module`), Encrypted Field Configuration (`sys_platform_encryption_configuration`) or Module Access Policy (`sys_kmf_crypto_caller_policy`): MFA for local logins, back to the IdP for SSO; `maint` exempt | created automatically when the subscription, the console and the continuous authentication plugin are present **and no policy exists yet**; `ca_admin` can deactivate them under **Continuous Authentication > Policies** |

## Otto for Vault

Store application `sn_vault_gen_ai`. After installing, check **Admin > AI Admin Hub > AI Skills**, workflow *Vault*, that the skills are active. Skills appear in the assistant panel of the console (the pages still call it both *ServiceNow Otto* and *Now Assist*).

Generative skills:

| Skill | Does | Role |
|---|---|---|
| Generate custom data pattern | writes a regular expression from a description and adds it as an active data pattern | console admin |
| Check role access for encrypted column | lists roles holding access to the encryption and decryption keys | console admin + `security_admin` |
| Schedule data discovery job | creates a one-time or recurring Data Discovery job from a description (tables, columns, patterns, window) | console admin |

Agentic workflows (on by default; managed in **AI Agent Studio > Create and manage**; duplicate to change; turn off there or by an AI Control Tower policy, not from the skill list):

| Workflow | Agents | Does | Roles |
|---|---|---|---|
| Securing custom apps with Vault agents | Custom app recommendations | reads a custom application's schema; proposes classifications and available protections | console admin |
| Access Observer configuration | Access observer configuration manager | view, create, deactivate, delete Access Observer settings for a field | + `security_admin` |
| Summarize Access Observer logs | Access observer log analyzer | who reached a field, with which roles, through what | + `security_admin` |
| Field encryption with Vault module | Vault crypto module manager | encrypts fields and grants access to chosen roles | + `security_admin`, `sn_kmf.admin`, `sn_kmf.cryptographic_manager` |
| Field Encryption and Auto Generate Access Policies | Field access auditor, Vault crypto module manager | finds the roles that can read a field today, lets you edit the list, then creates a module access policy per role and encrypts the field with module `vault_encryption_module`. Asks before each action. **Elevated roles are not evaluated: grant them separately** | the same four |
| Classifying ServiceNow assets with Vault agents | Classify assets with ServiceNow Vault | recommends a data class, with a reason, for each ServiceNow column in the Data Catalog (Workflow Data Fabric), from the classes defined on the instance; applies what you confirm | `dcg_data_privacy_admin`; needs Data Catalog Governance (`sn_dcg_app`) and Otto for Vault 3.1 or later |

Classifying assets, in practice: start it from the assistant ("Classify my ServiceNow assets") or pick it in the Workflow Data Fabric panel; choose unclassified, classified (adds, never replaces) or all assets; open the *Data sensitivity classification* link and **Refresh** until *Complete* (or *Complete with some columns skipped* after model errors); filter and review; confirm only when generation has finished. Results show on the data assets after the next metadata collector run. "No assets found" usually means the collector has not run.

Notes on the AI part: agents use the instance's configured model (Now LLM Service, Azure OpenAI, Google Gemini or Anthropic Claude on AWS, set in AI Control Tower and AI Admin Hub); skills live in the global domain and respect the user's domain; data leaves the instance for processing; availability is restricted in in-country, FedRAMP, IL5, IRAP and regulated-market environments (KB1584492, KB0743854, KB2593939).

## Related

- [[Zero Trust Access - Session Access and Continuous Authentication]] · [[Access Analyzer, Access Findings and Access Observer]] · [[Explicit Roles and Elevated Privilege Roles]] · [[Multi-Factor Authentication]] · [[Agentic Development Overview, Tool Comparison and Governance]]
