---
type: concept
tags: [concept, notifications, integrations, roles, schema]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Notify (landing; Exploring Notify: Twilio Direct driver, Zoom connector, voice and SMS capabilities, How Notify processes incoming calls, Cisco Webex Connector; Configuring Notify: Activate Notify, Differences between Notify and Legacy Notify, Migrating from Legacy Notify, Configure Notify with Twilio, callback testing, advanced SMS and voice, disconnect, Amazon Polly, Configure a provider, SMS opt-out preferences; Using Notify with SMS, SMS statuses, Outbound communication requirements; Reference: Differences between Notify-Twilio and Notify-Twilio Direct, Migrate to Twilio Direct, Public URLs, Components installed with Twilio Direct driver, Numbers and number groups, Components installed with Notify), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/notify/notify-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Notify Overview, Twilio and Providers

**In one line:** **Notify** (`com.snc.notify`) gives the platform **SMS and voice** (through a telephony driver, normally **Twilio Direct**) and **conference meetings** (Twilio conferences, or Zoom and Cisco Webex connectors), with APIs, workflow activities and flow actions that other applications use: Major Incident Management, [[Incident Communications Management]], [[On-Call Scheduling]], CTI Softphone, [[Password Reset Application Overview]], SMS [[Multi-Factor Authentication]].

From the Brazil docs; not tested. Using it from tasks, conferences, ICM and on-call: [[Notify Conference Calls and Use from Tasks, Incident Communications and On-Call]]. Workflow activities and flow actions: [[Notify Workflow Activities and Flow Actions]]. Set-up steps: [[Set Up Notify with Twilio, Zoom or Webex]].

## Plugins and generations

| Plugin | Status |
|---|---|
| Legacy Notify / NotifyNow `com.snc.notifynow` | deprecated; telephony only, one Twilio number per instance, hard-coded prompts; role `notifynow_admin` |
| **Notify** `com.snc.notify` | current; activates **E164 Compliant Phone Number** `com.glide.phone_number` and **SMS Preferences** `com.snc.sms_pref`; several numbers per account, workflow-driven voice and SMS, conferencing providers, Notify on Task |
| Notify-Twilio driver `com.snc.notify.twilio` | deprecated; Java SDK based; stays active after upgrades |
| **Notify-Twilio Direct** `com.snc.notify.twilio_direct` (scope `sn_twilio_direct`) | current; JavaScript driver over outbound REST; adds Co-pilot messaging, Twilio Notify bulk SMS, speaker display, beep control, answering machine detection; the only driver for new customers |
| Notify Zoom Connector `sn_notify_zoom` | needs Zoom spoke 1.0.2 (`sn_zoom_spoke` / `com.sn.zoom.spoke`) and an Integration Hub licence; New York and later |
| Notify Cisco Webex Connector `sn_notify_webex` | needs `com.glide.hub.integrations` and the Cisco Webex Teams spoke |
| Notify connector for Microsoft Teams `com.sn.ms_teams` | listed on the landing page; its pages were not in the fetched chapter (see [[ITSM Mobile Agent]] for a use) |

Activating Notify on an instance that had Legacy Notify removes the old menu, adds *Legacy Notify* and *Legacy Notify Admin* separators with new modules (customisations of the old modules are lost), and moves old activities to a *Legacy Notify* group. With domain separation and delegated admin, activate from the global domain.

## Twilio Direct

- One Twilio **account or sub-account per instance**, used only by that instance (sharing one across instances overwrites the configuration). A separate Twilio contract is needed.
- **Notify > Administration > Twilio Direct Configuration**: Account SID and Auth Token (`<TWILIO_AUTH_TOKEN>`), **Connect**. Notify creates a **TwiML application** in Twilio pointing back to the instance and imports the account's E.164 and short-code numbers (`notify_number`) with their capabilities, country and number group. Re-open the page after buying or releasing numbers; released numbers stay as inactive records.
- Since the Brazil upgrade a reconnect also creates a credential holding a Twilio **Standard API key and secret** for outbound calls; existing connections keep SID and token until disconnected and reconnected.
- **Disconnect** clears SID and token and deactivates the numbers; an account already linked elsewhere must be disconnected there (and its TwiML apps deleted) first.
- **Test Callbacks**: **Initiate SMS** or **Initiate Test Call** to prove Twilio can reach the instance; history in `sn_twilio_direct_callback_test`.
- **Advance SMS Features**: **Intelligent SMS Handling** (Twilio Co-pilot: Messaging Service SID chooses the sender, spreads traffic, alpha sender IDs; all numbers must be in the same messaging service) and **Twilio Notify Bulk SMS** (the `sendBulkSMS` API sends to many numbers in one Twilio call; may cost extra).
- **Advance Voice Features**: **Detect answering machine** with **Machine detection timeout** (3-120 seconds).
- Text-to-speech voice: **Notify > Administration > Twilio Direct Additional Properties**, e.g. `Polly.Joanne` (Amazon Polly); not set by default since San Diego, so Twilio's own voice setting applies.
- Migration from the old driver: **Notify > Administration > Twilio Configuration (Legacy)** > **Migrate Now** copies SID and token and reconnects with Twilio Direct.
- Tables: `sn_twilio_direct_callback_processor` (scripts turning Twilio callbacks into TwiML / XML; edit with care), `sn_twilio_direct_twilio_config`, `sn_twilio_direct_basic_auth` (SID and token), `sn_twilio_direct_callback_test`. The auth token is also copied to a JWT keystore alias signing key.

**Public URLs** (Twilio calls them unauthenticated; on-premises instances need port forwarding or a reverse proxy, and `glide.notify.endpoint` set to the public name): Twilio Direct `/api/sn_twilio_direct/twilio_callbacks/process/twiml/{callback_name}` and `.../process/xml/{callback_name}`; old driver `/NotifyTwilioCallProcessor.do`, `...CallStatusProcessor.do`, `...SMSProcessor.do`, `...DialStatusProcessor.do`, `...EventProcessor.do`, `...DialProcessor.do`, `...RecordingProcessor.do`.

## Numbers, number groups and provider selectors

- **Notify > Numbers** (`notify_number`): Number, Phone number (E.164), **Notify group**, Number owner (provider), Short Code, Active. One group per number.
- **Notify > Number Groups** (`notify_group`): Name and four workflows (or subflows): Incoming call (must run on `notify_call`), Incoming SMS, Outgoing call, Outgoing SMS (SMS ones on `notify_message` or `global`). Never put a workflow that itself sends SMS as the Outgoing SMS workflow (e.g. *Notify: Join Conference Call Via SMS*): it loops. Short codes only in SMS groups. Shipped groups include *Conference Call Group*, *Notify On Task Group*, *On-Call Group*. Voice-only numbers cannot join groups with SMS workflows and vice versa.
- **Notify > Provider Selector** (`notify_group_selector`, choices `notify_group_selector_choice`): Name, Order (unique), Source table, Condition, Active, **Catch-all**, **Manual selection** (only when forced, e.g. by a communication plan), **Default** (one active default); choices point to a conference provider (Zoom, Webex) or a Notify group of numbers; these feed the "From" and "Conference Bridge" pickers.

## SMS behaviour

- Messages in `notify_message`. Over 160 characters (70 Unicode) are split into several SMS, each charged; some carriers do not support concatenation. Limit `glide.notify.sms.max_characters`. Templates `notify_sms_template`.
- APIs: `sendSMS` (one recipient) and `sendBulkSMS` (array of numbers in one call). Delivery status through Twilio status callbacks: queued, accepted, sending, sent, receiving, received, delivered, undelivered, failed, unknown (delivered / undelivered only if the carrier reports them).
- Recipients must be **E.164** numbers and differ from the sending number; invalid numbers stop the workflow and log an error (`glide.notify.debug` = true for detail).
- **Opt-out** (CTIA rules): **Notify > Administration > SMS Preference Configuration**: Provider, Name, Order, **Default preference** (Opt-in or Opt-out), Enable for long code, Enable for short code, opt-out keywords (STOP, STOPALL, END, CANCEL, QUIT, UNSUBSCRIBE), opt-out confirmation, opt-in keywords (START, UNSTOP, YES), opt-in confirmation. Opting out applies to the one Notify number texted, not all numbers. Off by default; do not use it for numbers in a Twilio Messaging Service (Twilio's Advanced Opt-Out already handles them). `glide.notify.sms.save_confirmation_in_db` keeps confirmations in `notify_message`.

## Roles

| Role | Can |
|---|---|
| `notify_setup_admin` | full Notify 2 administration; contains `notify_admin`, `sn_twilio_direct.admin`, `workflow_admin`, `workflow_creator`, `workflow_publisher` |
| `notify_admin` | Notify modules, Twilio configuration |
| `notify_view` | read conference calls and participants; inherited by `itil` when ICM and Notify are active |

Notify tables are protected by deny-unless ACLs for `notify_admin` and `notify_view`; add new roles to that ACL list if they need access.

## Tables

`notify_conference_call`, `notify_call`, `notify_queue`, `notify_call_status`, `notify_client_session` (WebRTC sessions), `notify_participant`, `notify_participant_session`, `notify_message`, `notify_number`, `notify_group`, `notify_language`, `notify_recording`, `notify_wf_activity`, `notify_mime_type`, `notify_action` (serialized actions waiting), `notify_sms_template`.

## Properties

| Property | Meaning |
|---|---|
| `sn_twilio_driver.max_conference_participants` | Twilio participant limit |
| `com.snc.iam.notify_number` / `com.snc.iam.enable_notify` | Notify number for ICM conferences (must be in a group with conference workflows); setting the number equals enabling |
| `glide.enable.notify_on_task` / `glide.notify.task.phone_number` | Notify on Task; setting the number equals enabling |
| `glide.notify.endpoint` | public name of the instance behind a reverse proxy |
| `glide.notify.sms.max_characters`, `glide.notify.sms.save_confirmation_in_db`, `glide.notify.debug` | SMS length, opt-in/out confirmations, debug logging |
| `com.snc.on_call_rotation.notify_webrtc_number` | voice number for browser calls from On-Call |
| `sn_major_inc_mgmt.notify_webrtc_number` | voice number for browser calls from the Major Incident workbench |

Business rules worth knowing: *No Call Workflows for Shortcodes*, *Restrict Workflows For only Voice Nums / only SMS Numbers*, *Check default notify group is unique*, *No Default selector set*, *Check active default selector is unique*, *Process SMS preferences for incoming SMS*, *Trigger conference end* (event `notify.conference.end`), participant duration and state rules, *Warn for incorrectly configured workflow*.

## Unconfirmed variants

- Zoom spoke plugin ID: `sn_zoom_spoke` vs `com.sn.zoom.spoke` (same page).
- Roles that can activate: "if you are an administrator" with role required `notify_setup_admin`.
- Notify Messages table written `notify_message` (tables list, SMS pages) and `notify_messages` (On-Call pages, column `message_number`).
- Administrator labels: `notify_setup_admin` is labelled "Notify administrator" on the roles page, the same label usually given to `notify_admin`.

## Related

- [[Notification Preferences and Channels]] (SMS as a notification device) · [[Email Notifications]]
