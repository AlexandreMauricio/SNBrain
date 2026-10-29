---
type: concept
tags: [concept, notifications, incident, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Notify > Using Notify (Using Notify for making conference calls: start, add participants, mute or unmute all, mute or remove, send a message, viewing, list of Notify calls; Using Notify with tasks: start, manage, send SMS; Using Notify with Incident Communications Management: initiate, join and end, send updates; Using Notify with On-Call Scheduling: set up, communication channel, Assign by Acknowledgement workflow, WebRTC, differences with NotifyNow; Using the Notify Cisco Webex Connector with a major incident; Send an SMS with Zoom meeting invite), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/notify/using-notify.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Notify Conference Calls and Use from Tasks, Incident Communications and On-Call

**In one line:** once Notify is connected ([[Notify Overview, Twilio and Providers]]), agents start **conference calls** and send **SMS** from any task, from incident communication plans and from the Major Incident workbench, and On-Call Scheduling escalates by SMS and voice.

From the Brazil docs; not tested.

## Conference calls

- Records: **Notify > Conference Calls** (`notify_conference_call`), participants `notify_participant`; created automatically, durations set by business rules. A participant with an invalid number is still listed, marked *Invalid*. A call starts when at least two participants join and closes when the last one leaves.
- Workflows used by *Conference Call Group* and *Notify On Task Group*: *Notify: (Re)join Conference Call*, *Notify: Join Conference Call Via SMS*, *Notify: (Re)join Conference Call with muting* (demo data only).
- Who can manage: `notify_view`, `notify_admin`, `major_incident_manager`, `communication_manager` (spelled `communications_manager` on one page). Any participant flagged **host** can mute or kick.
- Actions: **Add Participant** (user, group or phone number, with an optional message), **Mute All / Unmute All** (Major Incident workbench, Conferences tab), **Mute** / **Kick** in the participants related list (kicked people can call back in), a brief message sent as SMS or voice when starting from the workbench (stored as the call description; sent by the shipped workflow).
- Calls go to the user's **Mobile phone**; it must be E.164 (a local number is converted using the user's location when possible); blank = cannot be reached. VoIP phones without touch tones may not register key presses.
- **Notify > Calls** (`notify_call`): one record per inbound or outbound call, not creatable by hand (deleting may cascade); Source column holds the task. Statuses: initiated, ringing, in_progress, no_answer, completed, busy, failed, invalid.

## From any task (Notify on Task)

Enable with `glide.enable.notify_on_task` (or by filling `glide.notify.task.phone_number`); one number (E.164 or short code) for all tasks, in a group with call and SMS workflows. Roles `notify_view` or `itil`.

- **Start conference call** related link: pick recipients, **Start**; calls appear in the **Conference calls** related list (add it to the form).
- **Manage Conference Calls** (appears while a call is active; roles also `itil_admin`, `notify_setup_admin`): **Join Conference Call**, **Add Participants**, **End Conference Call**. Hidden on `incident_alert` and `comm_task`, which have their own Join / End actions.
- **Send SMS**: choose the **From** number, recipients, message; messages in the **SMS Messages** related list.

## Incident Communications Management

Needs Notify and ICM active, and `com.snc.iam.notify_number` set to a number with outgoing voice and SMS in a group with conference workflows (the *Conference Call Group* has them). See [[Incident Communications Management]].

- **Incident Communications Management > Open** > plan > **Initiate Conference Call**: choose the **Conference Bridge** (from the provider selector), participants (user contacts recommended, plus primary and secondary on-call people when the group has a shift), **Start**. Or **Incident Communications Management > All** > **Conference** tab > **Start Conference** on a communication task.
- **Join** / **End** (roles `notify_view`, `ia_admin`, `notify_setup_admin`); ending writes duration and participants to work notes.
- **Start Updates** on a communication task with channel SMS or email: choose the **From** number and send.
- Calls appear as activities on the plan and in its **Conference Calls** related list.

## Major Incident workbench with Webex

**Incident > Major Incidents > Open** > **View Workbench** > **Collaborate** tab > communication task with channel **Conference**, frequency, due in, recipients. **Initiate**: Conference Bridge (Webex when it is the default provider selector), users, groups or emails, title (number plus short description), opening message, **Start**, **Open Link**. **(+) Participants** and **Join Call** while active. Zoom works the same way from any task; the workflow *Notify Zoom: Send SMS on Conference Change* (Zoom demo data) texts the meeting details to participants when the host starts or adds people (needs Twilio or Nexmo).

## On-Call Scheduling

See [[On-Call Scheduling]]. Put at least one number in the **On-Call Group** (workflows *On-Call: Check Assignment Response* for SMS replies and *On-Call: Assign by Acknowledgement Voice*). Copy *On-Call: Assign by Acknowledgement* (never edit the default), set the **To (script)** of its Send SMS activity so `getRecipientsAndNumberToSendFrom()` uses your number's sys_id, and select the workflow in each assignment **Trigger Rule** (Trigger action *Workflow*).

- The workflow walks the escalation chain (overlapping shifts, custom escalations), skips people on time-off, contacts by SMS, email or voice; replies are tracked in the `message_number` column of the Notify messages table (instead of the Notify Question tables used with NotifyNow).
- **Force communication channel** on a roster escalation uses only the preferred device; no fallback to email, and the failure is logged.
- **WebRTC**: with `com.snc.on_call_rotation.notify_webrtc_number`, click a name in **On Call Schedules > On Call calendars** > **Call** to phone from the browser.

## Example

On *INC-EXAMPLE* an agent with `itil` clicks **Start conference call**, adds *Example Network Team* and *Test User*, then **Send SMS** from the *Example Task Number* with "Bridge open, join now".

## Related

- [[Notify Workflow Activities and Flow Actions]] · [[Set Up Notify with Twilio, Zoom or Webex]]
