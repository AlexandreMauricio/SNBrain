---
type: concept
tags: [concept, integrations, workspace, ai, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage people and work capabilities > ServiceNow Voice (41 topics: exploring; setting up: install applications, domain separation, phone PIN, E.164 format, CTI component logging, real time transcription for CSM and ITSM, scripting for operation handlers, provider configuration, extension points; using: inbound and outbound calls, transfers; integrating with Amazon Connect incl. SSO, contact flows, VDI; with ITSM, CSM, Virtual Agent, AWA voice routing, HR; reference: components for Core, Amazon Connect, ITSM, CSM, HR), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/cloud-call-center-overview.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# ServiceNow Voice with Amazon Connect

**In one line:** **ServiceNow Voice** (`sn_cti_core`, formerly Cloud Call Center) connects a cloud phone system, by default **Amazon Connect**, to the instance: calls become **interactions**, agents answer and dial from a softphone inside the workspace (OpenFrame), callers can self-serve through bots that call **operation handlers** on the instance, and recordings, transcripts and sentiment land on the interaction.

From the Brazil docs; not tested. Needs a licence that includes the Voice SKU (e.g. ITSM Pro or CSM), an AWS account, and Amazon Connect (not AWS GovCloud). Different from [[Notify Overview, Twilio and Providers]] (Twilio telephony for notifications and conferences).

## Applications

| Application | Scope | Purpose |
|---|---|---|
| ServiceNow Voice (Core) | `sn_cti_core` | framework; brings Interaction Management `com.glide.interaction` ([[Interaction Management]]) and OpenFrame `com.sn_openframe` |
| ServiceNow Voice with Amazon Connect | `sn_cti_amzn_cct` | the Amazon Connect adapter, guided setup |
| ServiceNow Voice UI Components | `sn_cti_ux` | recording, transcription, sentiment in workspaces |
| Voice for ITSM | `sn_cti_itsm_cnt` | ITSM contact flows and handlers (ITSM Pro) |
| Voice for CSM | `sn_cti_csm_cnt` | CSM flows, handlers, PIN record producer (needs `com.sn_customerservice`) |
| Voice for HR Agent Workspace | `sn_cti_hr_cnt` | HR flows and handlers (needs `sn_hr_agent_ws`) |
| Real Time Transcription | listed with ID `sn_cti_amzn_cct` (same as the adapter) | live transcript for agents |

Install the core three, then at least one content pack.

## How a call flows

Caller dials > Amazon Connect **contact flow** (voice or DTMF) > a node calls the instance's **CTI API** operation endpoint > the **provider configuration** picks the **provider component** and its **message transformer** (input script shapes the request, output script shapes the response) > an **operation handler** runs > answer back to the caller. If a bot cannot resolve it, the call is queued to an agent, who gets an interaction.

| Connect node | Provider component | Transformer |
|---|---|---|
| Get Customer Input (Lex bot) | `sn_aws_connect_lex_intent_processor_component` | *AWS - Lex - Intent - Message Transformer (SN Proxy)*; the Lex **intent name** must match an operation handler name (or name plus a suffix) |
| Invoke AWS Lambda Function | `sn_aws_connect_lambda_proxy_component` | *AWS - Connect - Lambda - Message Transformer*; parameters `sn_component`, `sn_operation` (handler name, e.g. `interactionEvent`), optional `queueName`, `queueId`, `authToken`, `interactionId` |

**Operation handlers** (**ServiceNow Voice - Core > Operation Handlers**, `sn_cti_operation_handler`; `sn_cti_core.admin`): Operation Name, **Type** (*Script*, *Forward to Handler* by sys_id, *Forward to Operation* by name, *Integration Hub - Action*, *Integration Hub - Subflow*), Application, Domain, Active, **Require Authentication** (only after a valid PIN), Description, Script / Forward To / action / flow. Server-side, scoped (`sn_cti_core`); APIs `CTIOperationRequest`, `CTIOperationResponse`, logger `ctx.getLogger()`.

Shipped handlers: Core `$transcript`, `$query2ssml` (secure query returned as SSML), `workItemEvent` (creates the AWA work item before queueing), `interactionEvent`, `authenticate` (PIN), `fetchVoiceInteraction`; Connect `$connect.kinesis.event` (contact trace records), `$connect.s3.event` (recordings, transcripts, analysis), `createPhoneLog` (per transfer); ITSM `sn_FallbackIntent`, `manageIncident`, `manageIncident.DialogCodeHook`, `unlockAccount`, `announcements`, `createIncident`, `createITSMInteraction`, `fetchITSMInteraction`; CSM `speakToCSMAgent`, `createCSMCase`, `manageCSMCase`, `csmAnnouncements`, `create/update/fetchCSMInteraction`, `$csm.connect.s3.event`, `$csm.connect.kinesis.event`; HR `createHRInteraction`, `fetchHRInteraction`. Demo contact flows: *ServiceNow ITSM / CSM / HR Inbound Demo Flow* and *Outbound Demo Flow* (whisper message), *CSM Transfer to Agent Flow*, *Transfer to Queue Flow*.

Extension points: `sn_cti_core.clickToCallContextMap` (copy fields to the interaction on outbound calls), `sn_cti_core.CTICallAnalysisExtractor` (how recordings and transcripts are fetched), `sn_cti_core.SoftPhoneEventSink` (map softphone events).

## Set up Amazon Connect

`sn_cti_amzn_cct.admin`: **Amazon Connect Integration > Setup Instance**: Name, **AWS ARN**, Active, **Override Params** (for the newer `*.my.connect.aws` domain instead of `*.awsapps.com`), Instance Params (generated JSON with ccpHost, ccpUrl, recording URL prefix), **SSO Login URL**. Then **View Instances** > **Setup Guide** in order: Select Application (optionally **Enable AI Voice Agents** with Call Context API URL and Voice Service ID from Assistant Designer), Setup S3 Bucket, Deploy Stack (CloudFormation; on upgrade move Lambda to a supported runtime), Deploy Lex Bot, Connect Setup, Import Contact Flows (optionally **AWA Voice Routing**: Lambda and OAuth credential, hold music under 5 seconds, AWA queue), Real Time Transcription, Call Recording Events, **Setup Authentication** (a service account, *Web service access only*, with `sn_cti_core.service`; for transcription add `interaction_integration_user`), Additional Configuration (OpenFrame softphone, ICC voice controls). Associate the phone number with the contact flow in Connect.

- **SSO** (KB3025173): Connect provisioned with SAML 2.0; Multi-Provider SSO installer `com.snc.integration.sso.multi.installer`; same user identity in ServiceNow, IdP and Connect; put the IdP-initiated SAML URL (e.g. `https://<idp-domain>/app/<app>/<id>/sso/saml?RelayState=<aws-federation-url>`) into **SSO Login URL**; empty = normal Connect login. See [[Multi-Provider SSO - SAML and OIDC]].
- **Real time transcription**: Contact Lens on in Connect (recording and analytics block, real-time and post-call analytics); property `sn_cti_csm_cnt.enable_ims_update` or `sn_cti_itsm_cnt.enable_ims_update` = true (also makes outbound calls create a conversation record; `createConversation` flag for Core); redo the setup guide (Lambda template and contact flows changed).
- **VDI**: OpenFrame Configuration VDI type `CITRIX`, `AWS_WORKSPACE` or `OMNISSA`, agents grouped by environment.
- **Native voice control in Service Operations Workspace**: plugin Interaction Controls Component `com.app_interaction_control`; **OpenFrame > Configurations** > e.g. *CTI* > **Enable interaction controls**, User Group, third-party URL. Phone interactions then open the SOW voice page with interaction controls and Customer History ([[Service Operations Workspace Configuration and Customization Reference]]).
- **Logging**: **ServiceNow Voice Core > Log Configuration** (`sn_cti_log_cfg`) per component (operation handler, provider component, configuration, transformer), level Off to Debug; not left on in production; lines in the system log prefixed `cti_core::` with P, C, T, O ids.

## Agents and callers

- Inbound: roles `sn_openframe.user` and `interaction_agent` (with AWA also `awa_agent` and `awa_integration_user`). Interaction states: New (in the IVR or not yet routed), Closed Complete (deflected by the bot or hung up before queueing), Work in Progress (assigned), Closed Abandoned (hung up while queued).
- Outbound: **click-to-call** on any E.164 phone number shown (user mobile or business phone; add **Caller** to the incident form if missing); creates a Phone interaction in Work in Progress. Presence states in the inbox (synced with AWA): CallingCustomer, Busy, AfterCallWork (after **End call**), Available (after **Clear contact**), FailedConnectAgent.
- Transfer (CSM): **Quick connects** to an agent or queue; the second agent **Join**s, and the interaction is reassigned when the first leaves.
- The interaction activity stream gets the recording URL, contact trace record and transcript; `sn_cti_core.user_manager` can analyse them (Call Analysis tab).
- **Phone PIN**: callers set it at **ServiceNow Voice - Core > My Phone PIN**; `sn_cti_core.user_manager` resets locked ones at **User Pin Reset** (new PIN, clear **Disabled**). CSM consumers use the *Setup PIN* record producer.
- E.164 for consumer phone fields: dictionary type **Phone Number (E164)** (territory list plus number).

## Roles

| Role | Can |
|---|---|
| `sn_cti_core.admin` | build the integration framework, operation handlers |
| `sn_cti_core.service` | service account for the phone system (contains `sn_openframe_api_user`) |
| `sn_cti_core.user_manager` | call analysis, reset PINs |
| `sn_cti_amzn_cct.admin` | Amazon Connect integration (contains `sn_cti_core.admin`) |

CSM: `agent_workspace_user`, `sn_customerservice_manager`, `sn_customerservice.consumer` / `.customer`.

## Other integrations

- **ITSM**: demo flows deflect or route by caller context; PIN-authenticated callers can check and update incidents; Workforce Optimization for ITSM shows Connect phone metrics through AWA ([[Workforce Optimization for ITSM]]).
- **Virtual Agent as IVR** (needs Virtual Agent API `sn_va_as_service`): VA topics answer calls, escalate through AWA, callbacks, sentiment, transcription.
- **HR**: interactions with the IMS prefix; add *Interaction Related Record -> Interaction* to the HR Workspace view.

## Domain separation (Basic)

Separated tables: `sn_cti_instance`, `sn_cti_log_cfg`, `sn_cti_operation_handler`, `sn_cti_provider_component`, `sn_cti_provider_config`, `sn_cti_provider_msg_transformer`, `sn_cti_user`, `sn_cti_aws_resource`, `sn_cti_connect_instance`.

## Unconfirmed variants

- Real Time Transcription is listed with the same ID as the Connect adapter (`sn_cti_amzn_cct`) and with the property `sn_cti_csm_cnt.enable_ims_update` in the component column.
- The Real Time Transcription page says "CSM only"; a separate page covers ITSM with its own property.
- Adapter named *ServiceNow Voice with Amazon Connect* and *Amazon Connect Integration with ServiceNow Voice*.

## Example

Operation handler *exampleCheckTicket* (Type Script, Require Authentication) is called from an *Invoke AWS Lambda Function* node with `sn_component` = `sn_aws_connect_lambda_proxy_component` and `sn_operation` = `exampleCheckTicket` after the `authenticate` handler returns an `authToken`.

## Related

- [[Working Records in Service Operations Workspace]] · [[Authentication Factors for AI Voice Agents and Human-Assisted SMS OTP]]
