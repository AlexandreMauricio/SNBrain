---
type: concept
tags: [concept, automation, notifications, scripting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Notify > How Notify processes incoming calls, Notify flows, Create a custom Notify subflow, Notify workflow activities (Join conference call, Call, Send SMS, Forward call, Input, Hangup, Play, Record, Reject, Say, Forward to notify client, Queue), Notify activity event handlers, Creating Notify activities, Notify languages, Available Notify activity event handlers, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/notify/c_NotifyActivities.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Notify Workflow Activities and Flow Actions

**In one line:** what happens on a Notify call or SMS is decided by the **workflows (or subflows) attached to the number group** of the Notify number; Notify supplies call and SMS **activities** for legacy Workflow and, from Zurich, the same as **flow actions** in Workflow Studio.

From the Brazil docs; not tested. Numbers and groups: [[Notify Overview, Twilio and Providers]]. Legacy Workflow: [[Classic Workflow Overview]], [[Classic Workflow Activities Reference]].

## How an incoming call runs

A call to a Notify number starts the group's incoming call workflow. Each Notify activity's `onExecute()` writes a `notify_wf_activity` record (State *execute*) with JSON actions; Notify sends them to the provider (State *processed*); the provider's answer (digits, recording info) lands in `response_args` (State *complete*) and is copied to **Last action** on the `notify_call` record; the workflow calls `onUpdate()` on running activities, which finish and transition.

Rules: call workflows run on **Notify Call** (`notify_call`); set the workflow's **If condition matches** to *-- None --* (number groups decide what runs); no **Timer** between Notify activities on a live call; `current.is_human` tells whether an outbound call was answered by a person (always true inbound).

## Activities (and flow actions since Zurich)

| Activity / action | Does | Inputs and notes |
|---|---|---|
| Join Conference Call | puts the call in a conference | `workflow.scratchpad.conference_call` must hold the conference GlideRecord (set automatically by `Notify.call(notifyNumber, toNumber, conferenceCall)`; set it yourself otherwise); Record; Advanced script `config` attributes `hangupOnStar`, `muted`, `beepOnEnter`, `beepOnExit`, `enableImmediateInput` (digit after leaving goes to `workflow.scratchpad.confDigits`; needs hangupOnStar). Flow action inputs: Notify Call, Notify Conference Call, Record, Muted, Start on enter, End on exit, Hangup on Star, Beep on enter, Beep on exit, Enable immediate input, Additional config |
| Call | outbound call, any table | Notify Number (its group's outgoing call workflow runs), Phone number to call (E.164); Advanced script returns `{notify_number: '<sys_id>', phone_number: '+...'}` |
| Send SMS | text message, any table | From, To (users), To (groups), Message (field and scratchpad variables; too long = truncated with a warning); Advanced **To (script)** returns `{notify_number, users: [], groups: [], numbers: []}`; needs a provider configured |
| Forward Call | forward to an E.164 number | number, Timeout, Record; when the callee hangs up, later activities run for the caller only |
| Input | phone menu (IVR) | Number of digits, Finish key, Timeout; one condition per option, its Name read aloud (max 100 characters, prefix `fr-CA:` etc. for language), Condition `parseInt(workflow.scratchpad.digits) == 3`; Advanced script builds `answer = {"1": {play: '<url>'}, "3": {speak: '...', language: 'en-US'}}` (old `say` still accepted), stored in `workflow.scratchpad.menu[<activity name>]` |
| Hangup | end an answered call | use Reject for unanswered |
| Play | play an audio URL | Loop; skipped if unreachable or MIME type not in `notify_mime_type` |
| Record | record the caller | Max duration, silence timeout, Finish key; writes `workflow.scratchpad.recording` (recordingDuration, from_number, notify_number, recordingID, recordingURL); conferences are recorded through Join Conference Call instead |
| Reject | refuse an unanswered call | reason, e.g. busy |
| Say | text to speech | Text, Language (`notify_language`); Advanced returns `{language: 'en-US', text: '...'}` |
| Forward to Notify Client | to a user's WebRTC browser client | User or script returning a `sys_user` GlideRecord, Timeout, Record |
| Queue | put the call on hold in a queue with a random ID | on `notify_call` |

Custom subflow: **Process Automation > Flow Designer** (Workflow Studio) > **New > Subflow** > Action > *Global* > a Notify action (e.g. *Say*: text, language, Notify call) > **Publish**; then map it in **Notify > Number Groups**. The shipped conference workflows (*(Re)join Conference Call*, *Join Conference Call with muting*, *Join Conference Call with SMS*) have subflow equivalents for new instances.

## Custom activities and event handlers

Handlers run on all executing Notify activities when the provider reports an event: `onExecute` (start), `onUpdate` (call record updated), `onCompleted` (call ended), `onFailed` (error) for all call activities; `onRinging`, `onInProgress`, `onNoAnswer`, `onBusy` for Forward Call, Call, Join Conference Call and Forward to Notify Client (provider must support the event). Pattern for a custom activity: in `onExecute` build a `NotifyAction` object and serialise it to `notify_wf_activity`; in `onUpdate` deserialise it and continue; e.g. `onCompleted: function() { activity.result = 'call_ended'; }`. Server-side, global scope (workflow activity definitions).

To change an attribute on the shipped join activity: **Workflow > Administration > Workflow Versions** > *Notify: (Re)join Conference Call* > **Show Workflow** > **Checkout** > activity > **Advanced** > set e.g. `hangupOnStar` true in `config` > **Update** > **Publish**.

## Related

- [[Flows, Subflows and Actions Overview and Architecture]] · [[Notify Conference Calls and Use from Tasks, Incident Communications and On-Call]]
