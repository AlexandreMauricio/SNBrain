---
type: reference
tags: [reference, roles, access-control, security, users, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Granular admin roles (2 topics, 1,293 cleaned lines, read in full 2026-10-08 through the docs site) - Granular admin roles, Platform security granular admin roles. The all-products table at the end of this note was extracted from the page by script (product and role names only, 361 role entries under 184 product headings; the per-role descriptions were read but are not reproduced); the platform security table and the notes above it were written by hand. https://www.servicenow.com/docs/r/platform-security/granular-admin-roles.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Granular Admin Roles

**In one line:** granular admin roles are narrow administrative roles, one or a few per product or feature, that let someone administer just that area without holding the all-powerful `admin` role.

From the Brazil docs. Role basics: [[Role Management]], [[Base System Roles]], [[Explicit Roles and Elevated Privilege Roles]]. ITSM's own set in detail: [[ITSM Granular Roles]].

## How they behave

- **Separate from `admin`**: they must be assigned independently.
- Users who already had `admin` were given the granular roles of the products or modules they had access to.
- Each product documents its own roles; the tables here are the cross-product list.
- For some tables the old `admin` ACLs were **removed and replaced** by the granular role (stated for `syslog` with `syslog_admin`, and `syslog_transaction_part_metrics` with `txn_part_metrics_admin`), so there, by my reading, even an admin needs the granular role ([[System Logs, Log Files and Protected Tables]]).
- **Instance operator** (`instance_operator`): for day-to-day operations without configuration rights: check logs and diagnose, routine maintenance, keep workflows running. Contains `identity_access_audit_viewer` and `user_role_history_viewer`.

## Platform security roles

| Area | Role | Allows |
|---|---|---|
| Access Analyzer | `access_analyzer_admin` | use Access Analyzer: compare users, simulate access, insights ([[Access Analyzer, Access Findings and Access Observer]]) |
| Adaptive authentication | `adaptive_auth_admin` (printed as `adpative_auth_admin` in the main table) | all adaptive authentication configuration and MFA settings ([[Adaptive Authentication]]) |
| | `adaptive_auth_policy_admin` | create policies and filters and change one's own; others' and defaults read only |
| API access policies, auth scopes, processor policies | `api_service_admin` with `adaptive_auth_policy_admin` | REST and SOAP policies, inbound authentication profiles, token authentication, processors (not OAuth) |
| Authentication factors | `auth_factors_admin` | caller identification and authentication for voice agents |
| Custom URL | `custom_url_admin` | create, change and delete custom instance URLs |
| Login configuration | `user_authn_admin` | everything about user login: SSO, account recovery, adaptive authentication, MFA, password policy |
| SSO | `sso_config_admin` | SAML, OIDC, digest and certificate-based login configuration. Setting up SSO also needs `business_rule_admin` and `script_include_admin`; e-signature with SSO needs `script_include_admin` and `ui_page_admin` |
| OAuth | `oauth_admin` | all OAuth configuration; `admin` still needed for non-base properties and `script_include_admin` to change scripts |
| Password policy | `password_policy_admin` | create, manage, enable and disable password policies |
| Self-registration | `external_user_self_registration_admin` | onboarding external users in volume |
| Encryption | `security_admin`; `sn_kmf.admin`; `sn_kmf.cryptographic_manager`; `sn_kmf.cryptographic_auditor` | security operations; assign KMF roles and key operations; key operations; read only ([[Key Management Framework (KMF)]]) |
| Federated ID | `iamsync_admin` | [[Federated ID and Global Identity]] |
| AI identities | `ai_user_admin` | create, edit and delete AI users and their roles |
| | `agent_role_config_admin`, `agent_role_config_viewer` | manage / view role masking configurations ([[Role Masking for AI Agents]]; that chapter names `sn_aia.admin` for the same task) |
| Identity and access audit | `identity_access_audit_viewer` (contains `role_viewer`, `group_viewer`) | view the trails and audit results; configuration stays with `security_admin` ([[Identity and Access Audit]]) |
| Identity Center | `user_login_history_viewer`, `privileged_role_config_admin`, `role_viewer` | [[Identity Center]] |
| Machine Identity Console | `mi_admin` | high privilege: contains other admin roles ([[Machine Identity Console]]) |
| Roles | `user_role_history_admin` (contains `user_role_history_viewer`, `role_viewer`) | role history operations |
| Role delegation | `role_delegator_admin` | administer role delegation |
| Time-limited roles | `user_admin` | assign a role to a user temporarily |
| Impersonation | `user_impersonation_history_viewer` | see the impersonation history ([[Impersonation]]) |
| SCIM | `scim_admin`, `scim_config_admin`, `scim_client_config_admin` | provider, custom schema and properties, client ([[SCIM Provider - Provisioning Users and Groups into the Instance]]) |
| Security Center | `sn_vsc.security_center_admin` | consoles, tools, security tasks ([[Security Center]]) |
| ServiceNow Vault | `sn_vault_console.vault_console_admin`, `sn_vault_console.vault_console_auditor` | bundles of the data classification, privacy, discovery and continuous-authentication admin or auditor roles ([[ServiceNow Vault and Otto for Vault]]) |
| Auditing | `audit_admin` | write and delete on `sys_audit` ([[Auditing and Record History]]) |

## Platform roles worth knowing

| Role | Allows |
|---|---|
| `update_set_admin` | create, delete and manage update sets |
| `source_control_admin` | all source control functions |
| `script_include_admin`, `background_script_admin` | script includes; background scripts |
| `flow_admin` | all Flow Designer tables |
| `events_admin`, `system_scheduler_admin`, `business_calendar_admin` | event processing; scheduler and the scheduled jobs dashboard; business calendars |
| `web_service_admin`, `web_service_configuration_admin` | create scripted REST and GraphQL operations; web service behaviour and security settings |
| `connection_admin`, `credential_admin` | connections and credentials tables ([[Connections, Credentials and Aliases]]) |
| `notification_admin`, `email_admin`, `email_bounce_admin`, `push_admin` | configure notifications; resend and reprocess email; bounces; push |
| `catalog_admin`, `knowledge_admin` (printed `knowledge_Admin`), `sla_admin`, `ui_builder_admin`, `mobile_admin`, `localization_admin` | the named product, without admin scripting rights |
| `sn_incident_admin`, `sn_mim_admin`, `sn_change_admin`, `sn_on_call_admin`, `sn_sow_admin.sn_sow_admin` | ITSM areas ([[ITSM Granular Roles]]) |
| `sn_cmdb_admin` | highest CMDB access: CI Class Manager policies, identifiers, full access to `cmdb_ci` |
| `response_header_admin` | records in `sys_response_header` |

## All products (names as printed)

Extracted by script; oddities are the source's (for example `adpative_auth_admin`, `sn__itom_ccg.admin`, `sn_Ig_hold.legal_hold_admin`, a role literally named `admin` for Service Graph Connectors, and Security Posture Control listing a group, *SPC Admin Group*, instead of a role).

| Product or area (as printed) | Granular admin roles |
|---|---|
| Access Analyzer | `access_analyzer_admin` |
| AE - StreamConnect | `message_replication_admin`, `stream_connect_admin` |
| Agent Chat | `awa_admin`, `interaction_admin` |
| AI Agents | `sn_aia.admin` |
| AI Search | `ais_admin` |
| AI Virtual Agent | `sn_nowassist_admin.nsa_admin` |
| App Governance | `sn_aemc.aemc_admin`, `sn_app_summary.app_summary_admin`, `sn_deploy_pipeline.deployment_pipeline_admin`, `sn_pipeline.pipeline_admin` |
| Application Vulnerability Response | `sn_vul.app_sec_manager` |
| Alumni Center | `sn_asc.admin` |
| Audit, History and Journal | `audit_admin` |
| Authentication | `adaptive_auth_policy_admin`, `adpative_auth_admin`, `custom_url_admin`, `password_policy_admin`, `sso_config_admin`, `user_authn_admin` |
| Authentication Factors | `auth_factors_admin` |
| Career Conversations | `sn_egd_act.admin` |
| CMDB Admin | `sn_cmdb_admin` |
| Code Assist Experience | `background_script_admin`, `now_assist_code_admin`, `now_assist_code_rag_admin` |
| Collaborative Work Management | `sn_cwm.cwm_admin` |
| Configuration Compliance | `sn_vulc.admin` |
| Container Vulnerability Response | `sn_vul_container.vulnerability_admin` |
| Contract Management Pro | `sn_cm_core.contract_admin` |
| Contract Management Pro - Contract Workspace | `sn_cm_workspace.admin` |
| Contract Management Pro - Contracts Dashboard | `sn_cm_pa.pa_admin` |
| Contract Management Pro - Now Assist in Contract Management | `sn_cm_gen_ai.ai_contract_admin` |
| Cloud Accelerate-Cloud Workspace | `sn_itom_cam.cw_admin` |
| Cloud Accelerate-CSC | `sn_cmp.cloud_service_user.root_admin` |
| Cloud Accelerate - CSC | `sn_cmp.cloud_admin` |
| Cloud Accelerate - CPG | `sn_cmp.cmp_root_admin` |
| Creator Studio | `sn_creatorstudio.configuration_admin`, `sn_creatorstudio.task_admin` |
| CSM - CRM Foundation | `entitlement_admin`, `sales_agreement_admin`, `service_contract_admin`, `sn_crm_customer_access_management_admin`, `sn_crm_escalation_admin`, `sn_crm_foundation_admin`, `sn_cs_queryrules.admin`, `sn_install_base.install_base_admin`, `sn_l2c_core.admin`, `sn_prm.enterprise_partner_admin`, `sn_crm_sequence.admin`, `sn_tmt_core.admin` |
| CSM - Case Management | `sn_csm_case_type.config_admin`, `sn_customerservice.case_admin`, `sn_case_line.admin`, `sn_csm_case_digest.admin`, `sn_task_plan.admin`, `sn_complaint.admin`, `sn_onboarding.admin`, `sn_csm_ppm.admin`, `sn_action_status.admin`, `sn_uib_dyn_rel_rec.admin`, `sn_cs_sm.admin` |
| CSM - Omni | `sn_openframe.admin` |
| CSM - Self Service | `actsub_admin`, `sn_communities.admin`, `sn_csm_ec.ec_admin`, `sn_csm_walkup.walkup_admin`, `sn_embeddable_core.emb_admin`, `sn_ext_usr_reg_admin`, `sn_gamification.admin`, `sn_otp_support_util_admin` |
| CSM - Base Entities | `csm_admin`, `sn_res_shaper.admin` |
| CSM - Customer Central | `sn_customer_central_admin` |
| Customer Success Management | `sn_acct_lc.customer_success_application_admin` |
| Data Streaming | `hermes_admin`, `idr_admin`, `data_mgmt_tools_admin` |
| Digital End-User Experience | `sn_dex.admin` |
| Document Intelligence | `platform_ml_di.admin`, `sn_docintel.admin` |
| Document Management | `document_admin`, `platform_document_management_admin` |
| Employee Center Outlook Add-in | `sn_outlook_addin.outlook_addin_setup` |
| Employee Center Pro | `sn_hr_sp.esc_admin` |
| Employee Profile | `sn_employee.admin` |
| Encryption | `security_admin`, `sn_kmf.admin` |
| Enterprise Architecture | `sn_apm.apm_admin` |
| Event Management | `evt_mgmt_admin` |
| External Content Connectors | `sn_ext_conn.xcc_admin` |
| Flow Designer UI | `flow_admin` |
| Flow Engines | `flow_admin` |
| FSC-Accounts Payable Invoice Processing | `sn_ap_apm.admin`, `sn_ap_apm.invoice_tolerance_admin`, `sn_ap_cm.admin` |
| FSC - Finance Case Management | `sn_fin_ops.admin` |
| FSC - Integrations | `sn_fcms_intg.admin` |
| FSC - Purchase Order Management | `sn_poem_core.admin` |
| FSC - SLO | `sn_slm.admin`, `sn_kpi.admin` |
| FSC - SPO | `sn_fin.finance_admin`, `sn_shop.procurement_administrator`, `sn_shop.shopping_hub_admin`, `sn_spend_psd.psd_admin`, `sn_spend_sdc.admin` |
| FSM - Plan Schedule | `dynamic_scheduling_admin`, `sn_task_recommend.task_rec_admin`, `timecard_admin`, `sn_task_grouping.admin`, `wm_admin` |
| Gen AI Controller | `global_genai_admin` |
| Grants Management | `sn_gsm_grnt_mgmt.grant_admin` |
| GRC | `sn_rec_pg_vertical.admin` |
| GRC - AI Risk and Compliance Management | `sn_ai_case_mgmt.ai_case_admin`, `sn_grc_ai_gov.ai_risk_and_compliance_admin`, `sn_privacy.admin` |
| GRC - Corp Compliance | `sn_audit.admin`, `sn_compliance.admin`, `sn_grc.admin`, `sn_grc_advanced.evidence_admin`, `sn_grc_reg_change.it_admin`, `sn_grc_taxonomy.taxonomy_admin` |
| GRC - Formula builder | `sn_fb_connected.admin` |
| GRC - Operational resilience | `sn_oper_res.admin`, `sn_oper_res.irm_opres_admin` |
| HRSD - Case and Knowledge Management | `sn_hr_core.admin`, `sn_hr_er.admin`, `sn_em.admin`, `sn_interview_temp.admin`, `sn_hr_ef.admin`, `sn_sp_admin_ws.admin`, `sn_hr_ra.admin` |
| HRSD - Employee Journey Management | `sn_ja.admin`, `sn_hr_le.admin`, `sn_hr_le_pa.admin`, `sn_jny.admin` |
| HRSD - Hiring Experiences | `sn_ta_hiring_core.admin`, `sn_ta_tp.talent_profile_admin` |
| HRSD - Talent Experience | `sn_egd_core.admin`, `sn_egd_shared_lib.admin`, `sn_hr_lm.admin`, `sn_td_na.admin` |
| Health and Safety | `sn_ohs_im.admin` |
| Identity | `agent_role_config_admin`, `mi_admin`, `privileged_role_config_admin`, `role_delegator_admin`, `scim_client_config_admin`, `scim_config_admin` |
| IH Core | `connection_admin`, `credential_admin`, `ih_process_sync_admin` |
| Industrial Connected Workforce | `sn_icw.application_admin` |
| Inbound web services | `web_service_admin`, `web_service_configuration_admin` |
| Industry Banking | `sn_appss.admin`, `sn_bom.admin`, `sn_bom.service_definition_admin`, `sn_bom_clo_b2b.admin`, `sn_bom_clo_b2c.admin`, `sn_bom_compl.admin`, `sn_bom_credit_asmt.admin`, `sn_bom_credit_card.admin`, `sn_bom_deposit_b2b.admin`, `sn_bom_deposit_b2c.admin`, `sn_bom_fraud.admin`, `sn_bom_kyc.admin`, `sn_bom_loan.b2c_admin`, `sn_bom_loan_b2b.admin`, `sn_bom_pa.admin`, `sn_bom_payment.admin`, `sn_bom_po.admin`, `sn_bom_remote.admin`, `sn_bom_treasury.admin`, `sn_data_sec.admin`, `sn_doc_processor.admin`, `sn_evnt_inq.admin`, `sn_fso_intg_friss.admin`, `sn_fso_intg_jha.admin`, `sn_ins_claim.admin`, `sn_ins_claim_cml.admin`, `sn_ins_claim_indl.admin`, `sn_ins_claim_pers.admin`, `sn_ins_gen_claim.admin`, `sn_ins_group_life.admin`, `sn_ins_group_uw.admin`, `sn_ins_indiv_life.admin`, `sn_ins_indiv_uw.admin`, `sn_ins_policy_b2b.admin`, `sn_ins_policy_b2c.admin`, `sn_ins_siu.admin`, `sn_ins_underwrite.admin`, `sn_ins_uw_b2b.admin`, `sn_jha_spoke.admin`, `sn_payment_card.admin`, `sn_req_criteria.admin` |
| Information Request Playbook | `sn_gsm_info_req.admin` |
| IntegrationHub - Finance and Operations Spoke | `sn_ms_fin_ops_spk.admin`, `sn_onedrive_spoke.Microsoft_OneDrive_Admin`, `sn_uipath_spoke.uipath_admin` |
| ITAM | `asset_licensing_admin`, `asset_recommendation_admin`, `asset_system_admin`, `asset_task_admin`, `contract_system_admin`, `procurement_system_admin` |
| ITAM - CCM | `sn_cld_intg_core.cloud_integrations_admin`, `sn_cld_intg_core.read`, `sn_cld_spend_core.spend_admin`, `sn_clin_core.insights_admin` |
| ITAM - EAM | `sn_eam.enterprise_admin`, `asset_aia_admin`, `asset_integration_admin` |
| ITAM - HAM | `asset_aia_admin`, `asset_integration_admin`, `sn_hamp.ham_system_admin` |
| ITAM - SAM | `sam_admin`, `sam_integrator` |
| ITOM - Agent Framework | `agent_client_collector_admin` |
| ITOM - CA | `sn__itom_ccg.admin` |
| ITOM - Cloud Configuration Governance | `sn_cmp.cloud_root_admin`, `sn_itom_cam.cw_admin` |
| ITOM - Certificate Inventory and Management | `sn_disco_certmgmt.pki_admin`, `sn_disco_firewall.firewall_admin`, `sn_itom_licensing.admin` |
| ITOM - Tag Governance | `sn_itom_tag.tag_governance_admin` |
| ITOM - Discovery | `discovery_admin` |
| ITOM - Leap | `sn_itom_leap.leap_admin` |
| ITSM - FE | `sn_sow_admin.sn_sow_admin` |
| ITSM - Incident Management | `sn_incident_admin` |
| ITSM - Major Incident Management | `sn_mim_admin` |
| ITSM - Incident Communications Management | `sn_iam_admin` |
| ITSM - Contact Management | `sn_contact_admin` |
| ITSM - Task Communications Management | `sn_tcm_admin` |
| ITSM - Task Outage | `sn_task_outage_admin` |
| ITSM - Change Management | `sn_change_admin` |
| Journey Accelerator | `sn_ja.admin` |
| Journey Designer | `sn_jny.admin` |
| Key Management Framework | `sn_kmf.admin` |
| Knowledge management | `knowledge_Admin` |
| Lifecycle Events | `sn_hr_le.admin` |
| Localization Framework | `localization_admin` |
| LSD - Legal Request Management | `sn_lg_ops.legal_admin`, `sn_lg_ops.request_admin`, `sn_lg_ops.legal_assignment_rules_admin`, `sn_lg_ops.legal_catalog_admin`, `sn_lg_ops.legal_notification_admin` |
| LSD - Legal Matter Management | `sn_lg_matter.matter_admin` |
| LSD - Legal Content Review | `sn_lg_cont_review.admin` |
| LSD - Legal Digital Forensics | `sn_lg_forensics.forensics_admin` |
| LSD - Legal Investigations | `sn_lg_investigate.admin` |
| LSD - Legal Simple Privacy | `sn_lg_simple_priva.privacy_admin` |
| LSD - Gifts and Entertainment Compliance | `sn_lg_gifts.gifts_admin` |
| LSD - Legal Conflict of Interest | `sn_lg_coi.coi_admin` |
| LSD - Legal Hold Notification | `sn_Ig_hold.legal_hold_admin` |
| LSD - Now Assist for Legal Service Delivery | `sn_lg_gen_ai.admin` |
| LSD - Contract Management Pro for Legal Service Delivery | `sn_lg_cnt.contract_admin` |
| LSD - Advanced Work Assignment for Legal Service Delivery | `sn_lg_awa.admin` |
| LSD - Legal Counsel Center | `sn_lg_cf_workspace.admin` |
| LSD - External Legal Service Center | `sn_lg_ext_portal.ext_admin` |
| LSD - Legal and Contracts Common Utilities | `sn_lco_cmn.admin` |
| Mobile | `mobile_admin` |
| Notification | `email_admin`, `email_bounce_admin`, `email_digest_admin`, `notification_admin`, `notification_category_admin`, `notification_classification_admin`, `portal_notification_pref_admin`, `push_admin`, `smime_certificate_admin` |
| Notify | `notify_setup_admin` |
| Now Assist - CSM | `sn_customerservice_agent`, `sn_customerservice.consumer_agent` |
| Now Assist for HR Service Delivery | `sn_hr_gen_ai.admin`, `sn_hr_ai_agents.admin`, `sn_hr_aia_voice.admin` |
| Now Assist - TMT | `sn_tmt_agentic_ai.app_admin` |
| Now Assist for Vulnerability Response | `aia-admin` |
| On-Call Scheduling | `sn_on_call_admin` |
| Operational Technology - CMDB | `cmdb_ot_admin` |
| Operational Technology - ISA | `cmdb_ot_isa_admin` |
| Operational Technology - Industrial Process Health | `ot_health_admin` |
| Operational Technology - Subnet Mapping | `sn_ot_amazing_admin` |
| Operational Technology - Change Management | `sn_ot_change_admin` |
| Operational Technology - Incident Management | `sn_ot_incident_admin` |
| Operational Technology - Vulnerability Integration | `sn_otvr.integration_admin` |
| Operational Technology - Risk Score Calculator application | `sn_risk_score_calc.admin` |
| Outlook Actionable Messages integration | `oam_admin` |
| Password policy | `password_policy_admin` |
| Password Reset | `password_reset_admin` |
| Platform | `source_control_admin`, `update_set_admin`, `cds_client_admin`, `cluster_node_admin`, `nds_admin`, `normalizer` |
| Platform Server - Side Scripting | `script_include_admin`, `sys_es_latest_script_admin`, `sysevent_script_action_admin` |
| Platform Data Fabric | `df_connection_admin` |
| Platform Deployment Analyzer | `deployment_analyzer_admin` |
| Platform Dev Sandbox | `sandbox_manager` |
| Platform Event Processing | `events_admin` |
| Platform ISM | `response_header_admin` |
| Platform Scheduler | `app_resource_quota_admin`, `business_calendar_admin`, `system_scheduler_admin` |
| Plato Predictive Intelligence | `ml_admin` |
| Playbook | `playbook.admin` |
| Proactive Prompts | `sn_pp.admin` |
| Process Mining | `sn_process_mining_admin` |
| Public Sector Digital Services | `sn_gsm.admin` |
| Role delegation | `role_delegator_admin` |
| Roles | `user_role_history_admin` |
| Retail | `sn_retail.ro_admin` |
| SBOM | `sn_sbom_core.admin` |
| Search | `ais_admin`, `ts_admin` |
| Search UX | `ais_admin` |
| Security Center | `sn_vsc.security_center_admin` |
| Security Operations - Data Loss Prevention | `sn_dlir.admin` |
| Security Operations - Security Incident Response integrations | `sn_si.ingestion_profile_admin` |
| Security Operations - Security Incident Response | `sn_si.admin` |
| Security Operations - Now Assist for Security Incident Response | `sn_si.admin` |
| Security Operations - Threat Intelligence Security Center | `sn_sec_tisc.admin` |
| Service Applicant Information | `sn_svc_appl_info.admin` |
| Service Applicant Program Management | `sn_svc_appl_pgm_mg.admin` |
| Service Catalog | `catalog_admin` |
| Service Graph Connectors | `admin`, `sn_cmdb_int_util.sgc_admin`, `cmdb_inst_admin` |
| Service Level Management | `sla_admin` |
| ServiceNow Studio | `sn_udc.admin`, `sn_prfrd_tables.admin` |
| ServiceNow Vault | `sn_vault_console.vault_console_admin`, `sn_vault_console.vault_console_auditor` |
| ServiceNow for Teams – Core | `sn_now_teams.admin` |
| Skills Foundation | `sn_skills_int.admin`, `sn_skills_int.job_arch_admin` |
| Smart Operations | `sn_smartops.admin` |
| Social Benefits Playbook | `sn_gsm_soc_bnfts.admin` |
| System Engineering Core | `openstack_admin`, `vcenter_admin` |
| System Logs (Log Entry) | `syslog_admin` |
| Talent Feedback | `sn_tf.admin` |
| Task Mining | `sn_tm_core.admin` |
| Third-party risk management | `sn_vdr_risk_asmt.vendor_risk_admin` |
| Transaction Part Metrics Logs | `txn_part_metrics_admin` |
| TSOM Visibility | `tsom_visibility_admin` |
| TSOM Assurance | `tsom_assurance_admin` |
| UI Builder | `ui_builder_admin` |
| Usage Analytics | `usage_admin` |
| Universal Request | `sn_uni_req.ur_admin` |
| Universal Task | `sn_uni_task.admin`, `sn_uni_task.emp_form_admin` |
| Usage Insights | `analytics_admin` |
| User Experience-Scope | `sn_cda.analytics_admin` |
| Vulnerability Response | `sn_vul.vulnerability_admin` |

## Related

- [[Role Management]] · [[Base System Roles]] · [[ITSM Granular Roles]] · [[Explicit Roles and Elevated Privilege Roles]] · [[Users, Groups and Roles Overview]]
