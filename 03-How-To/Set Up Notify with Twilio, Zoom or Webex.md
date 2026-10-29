---
type: how-to
tags: [how-to, notifications, integrations, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Notify > Activate Notify, Configure Notify with Twilio, Twilio-Direct callback testing, Numbers and number groups (create, associate), Configure a provider in Notify, Configure Notify Zoom connector in Notify, Set up Notify Zoom connector in Zoom, Disable Zoom meeting password, Configure Notify Cisco Webex Connector (install, Cisco app, OAuth entity, OAuth credential, connection and credential alias, default communication channel, Notify properties), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/notify/configuring-notify.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Set Up Notify with Twilio, Zoom or Webex

**Goal:** make Notify able to send SMS, place calls and open conferences. Concepts: [[Notify Overview, Twilio and Providers]]. Untested; from the Brazil docs.

## 1. Activate Notify

`notify_setup_admin` (an admin): **System Applications > All Available Applications > All**, find **Notify** (`com.snc.notify`), **Install**. E.164 phone numbers and SMS Preferences come along. With domain separation and delegated admin, do it from the global domain.

## 2. Twilio (voice and SMS)

1. A Twilio account or sub-account **reserved for this instance** (SID and auth token; separate contract).
2. `notify_admin`: **Notify > Administration > Twilio Direct Configuration** > Account SID, Auth Token `<TWILIO_AUTH_TOKEN>` > **Connect**. The numbers appear (read-only list).
3. **Test Callbacks** > **Initiate SMS** and **Initiate Test Call**. On-premises: make the callback URLs public and set `glide.notify.endpoint`.
4. Optional: **Advance SMS Features** (Intelligent SMS Handling, Twilio Notify Bulk SMS), **Advance Voice Features** (Detect answering machine, timeout 3-120 s), a Polly voice in **Twilio Direct Additional Properties**.

## 3. Number groups and numbers

1. **Notify > Number Groups** > New: Name and the four workflows (e.g. Incoming call *Notify: (Re)join Conference Call*). Never an SMS-sending workflow as Outgoing SMS workflow.
2. **Notify > Numbers** > open each number > **Notify group**. Short codes only in SMS groups.
3. For tasks: `glide.notify.task.phone_number` (enables Notify on Task). For ICM: `com.snc.iam.notify_number` (number in a conference-capable group). For On-Call: a number in *On-Call Group*. Also **Notify > Administration > Notify Properties** (Enable Notify integration for Task table and extensions; for Incident Communications Management).

## 4. Provider selector

**Notify > Provider Selector** > New: Name, Order, Source table (e.g. `incident`), Condition, Active, Catch-all or Manual selection, or **Default**. Submit, then in **Provider Selector Choices** add the conference provider or the Notify group of numbers (for SMS, the group of SMS numbers).

## 5. Zoom connector (optional)

Needs the Zoom spoke 1.0.2 with its OAuth credentials; the meeting host must have a Zoom account with the same email.

1. In the **Zoom OAuth app** used by the spoke: **Feature > Add Feature > Event Subscription**, on; URL `https://<instance>.service-now.com/api/sn_notify_zoom/notify_zoom/ZoomEvent`; **Add Events**: all *Meeting* events, and under *Recording* *All Recordings have completed* and *Recording Transcript files have completed*; **Save**; copy the **Verification Token**.
2. **Notify > Zoom > Configuration** > *Main*: **Webhook secret token** = the token `<ZOOM_TOKEN>`, **Run subflow on conference change**, **Do not set password** (meetings without passcode), **Zoom transcript handling** (do not store; store link only, the default; download as `.vtt` attachment), **Store zoom summary** (off by default). **Update**.

## 6. Cisco Webex connector (optional)

1. Install **Notify Cisco Webex Connector** (`sn_notify_webex`, admin; needs entitlements; demo data optional).
2. Cisco admin portal: **Start Building Apps > Create a New App > Create an Integration**: no mobile SDK, name, icon, description, redirect URI `https://<instance>.service-now.com/oauth_redirect.do`, scopes `meeting:admin_participants_read`, `meeting:admin_schedule_read`, `meeting:admin_schedule_write`, `spark:all`. Keep the client ID and secret.
3. **System OAuth > Application Registry** > *Cisco Webex Teams spoke*: Client ID `<CLIENT_ID>`, Client Secret `<CLIENT_SECRET>`, redirect URL as above; check the four scopes.
4. **Connections & Credentials > Credentials** > *OAuth 2.0 Credentials*: name, OAuth Entity Profile (the Webex Teams profile), Applies to, Order, Credential alias; Submit; **Get OAuth Token** signing in with a dedicated Cisco account not assigned to a person.
5. Connection and credential alias *CiscoWebexTeams* > **Connections** > New: name, the credential, Connection URL `https://webexapis.com` ([[Connections, Credentials and Aliases]]).
6. Provider selector with **Default** ticked for `incident`, choice *Webex* as conference provider; Notify properties as in step 3.

## Example

Instance *example-dev* gets its own Twilio sub-account; after **Connect**, number `+15550100` goes into new group *Example Conference Group* (incoming call *Notify: (Re)join Conference Call*), `glide.notify.task.phone_number` = that number, and provider selector *Example Incident Bridge* (Source table `incident`, Default) points to the group. Test: **Start conference call** on an incident with *Test User*.

## Related

- [[Notify Conference Calls and Use from Tasks, Incident Communications and On-Call]] · [[Notify Workflow Activities and Flow Actions]] · [[Password Reset Verifications and Enrollment]] (SMS codes through Notify)
