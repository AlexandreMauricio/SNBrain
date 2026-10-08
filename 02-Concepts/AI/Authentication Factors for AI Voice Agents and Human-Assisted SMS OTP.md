---
type: concept
tags: [concept, ai, security, users, admin, scripting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Authentication factors (whole section, 22 topics, 1,189 cleaned lines, read in full 2026-10-08 through the docs site) - explore and configure authentication factors for AI voice agents, voice input, TOTP, Okta Verify push, Soft PIN, step-up authentication, SMS OTP, Email OTP, knowledge-based authentication (questions, answers, mappings, service mapping), human-assisted SMS OTP and its configuration. https://www.servicenow.com/docs/r/platform-security/authentication/authentication-factors.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Authentication Factors for AI Voice Agents and Human-Assisted SMS OTP

**In one line:** how a **caller on the phone** is identified and verified before an AI voice agent helps them (security questions, PIN, app code, push approval, texted or emailed code), plus a separate API that lets a **human agent** verify a customer by texted code during a live interaction.

From the Brazil docs. This is distinct from MFA for logging in to the instance ([[Multi-Factor Authentication]]), though it reuses the same SMS providers. Menu **Authentication Factors**; role `auth_factors_admin`. AI voice agents need *Now Assist for Platform* (`sn_genai_platform`).

## Flow for a caller

1. **Identification**: who is calling? Knowledge-based questions matched against a record (the caller's number, an employee id).
2. **Authentication**: one factor, or two in sequence. **Two are required by default**; `glide.voice.authenticate.mfa_mandatory` = false makes one enough.
3. Optional **step-up**: one more challenge when the call reaches an agent marked as sensitive.

Which factors a voice assistant uses is chosen on the *Caller verification* screen of AI Voice Assistant Designer.

| Factor | Assurance | Alone | 1st | 2nd | Step-up |
|---|---|---|---|---|---|
| Authenticator app code (TOTP) | high | yes | yes | yes | yes |
| Push approval (Okta Verify only) | high | yes | yes | yes | yes |
| Soft PIN | medium | sometimes | yes | yes | no |
| SMS code | medium | no | no | yes | yes |
| Email code | medium | no | sometimes | yes | no |
| Knowledge-based questions (KBA) | low | no | yes | no | no |

Numeric factors can be keyed in or spoken: **Authentication Factors > Services > Service Configurations** > **Authentication Factor**, optional **Service Profile**, **Input Type** *Text* (keypad) or *Voice* (format, examples and validation pattern are preset and read-only).

### The factors

- **Okta Verify push**: create an API token in the Okta admin console; on the instance open the connection and credential alias for it, add an **HTTP(s) Connection** (name, alias, connection URL) with an **API Key Credential** whose value is the token prefixed with `SSWS ` (do not paste real tokens into notes or scripts).
- **Soft PIN**: six digits the user enrols in advance (profile > **Enroll Soft PIN**, in the platform, the portal, or **Authentication Factors > Soft PIN > Enroll**). Rules: no digit more than twice in a row, no rising or falling run longer than two digits, not one of the previous five PINs. Property `glide.auth_factors.softpin.enrollment.enabled` (default true; the concept page prints it with a space, "Soft PIN").
- **Email code**: no plugin. **Email OTP Factor > Email OTP Service Configuration** tells where the address is: **Table** (default `sys_user`), **Email Column**, **User Column**; a configuration for a specific service profile overrides the instance default. Domain-separated.
- **SMS code**: the MFA SMS providers.

### Knowledge-based authentication

**Authentication Factors > Knowledge Based Factor**. Four record types:

| Record | Content |
|---|---|
| **Question** | text, **Keyword**, **Category** (*Phone Number*: partial matching and the caller's number (ANI) offered automatically, identification only; or *Others*), **Input Type** (text, or voice with format description, examples and a validation regular expression), **Type** (identification, authentication, or both) |
| **Answer** | where the right answer is: **Answer Table**, **Answer Column**, **User Column** (the reference to the user). Or a script (below) |
| **Question Answer Mapping** | links the two |
| **Question Service Mapping** | assigns a question to a voice service as identification (**Usage** *Primary* or *Fallback*) or authentication. Created automatically from the designer |

Default questions: phone number (`sys_user.mobile_phone`), employee id (`employee_number`), email, manager, zip code.

- **User Column empty = guest**: the caller can be identified and given non-sensitive, personalised information, but **cannot be authenticated**. `glide.auth_factors.kba.enable_user_column` (default true) makes the field mandatory.
- All answers of one question must be of the same kind; a scripted answer must be the question's only answer.
- **External data** (`snc_external` users only): **Script Configuration** *Identification* (input `user_input`; output `table_name` and `sys_id` of the matched record) or *Authentication* (inputs `user_id`, `user_input`, `kba_session_context` = earlier scripted questions and answers of the call; output `kb_auth_result` true or false). Time limit `glide.auth_factors.kba.script_execution_time_out` (15 seconds; 1 to 30). Nothing from the external system is stored.

### Step-up authentication

- Marked per AI agent in AI Agent Studio (*Access rules*); the factor is chosen once per voice assistant (*Caller verification* > step-up card).
- **One attempt**; failure sends the caller to the assistant's fallback. A factor already used earlier is challenged afresh (a new code).
- Lasts for the rest of the call; not carried to another assistant or to a live agent. Applies to the whole agent, not single actions.
- Property `glide.conv_ai_voice.step_up.enabled` (default true). No factor selected = callers reaching such an agent go to fallback.

## Human-assisted SMS OTP

For a person (service desk, customer service, field service) who must verify the other party before a sensitive action. **API only: there is no agent screen**; the consuming application builds it.

- Plugin `sn_auth_ha_sms_otp` (needs `com.snc.authentication.sms_mfa`). Roles `sn_auth_ha_sms_otp_admin` (configure) and `sn_auth_ha_sms_otp_caller` (call the API); the calling application scope needs explicit permission to the API.
- Two calls: `generateCode`, then `validateCode` (signatures not given in these pages (?)).

**Authentication Factors > Human-Assisted SMS OTP > Service Configurations** (one active record per domain):

| Field | Default | Meaning |
|---|---|---|
| **Delivery Mode** | OOB | *OOB*: the platform sends the text through the active MFA provider. *BYO*: the code is returned to the application, which sends it itself |
| **Phone Number Resolution** | config-table lookup | *Provided by calling application*, or *Resolved from configured table* (**Phone Table**, **Phone Column** in E.164, **User Column**). OOB only. With a custom MFA provider, that provider's own table and field win. BYO + table lookup is refused |
| **OTP Code Length** | 6 (6 to 8) | |
| **OTP Expiry (Minutes)** | 3 (1 to 10) | |
| **Retry Limit** | 3 | wrong codes per conversation |
| **Resend Cooldown (seconds)** | 60 | between new codes in a conversation; resends do not use up retries |
| **Global User Retry Limit**, retry window and lockout duration (days) | 10 | wrong codes per end user across conversations, then lockout |
| **Rate Limit Per Minute Per Agent / Per Tenant** | 10 / 100 | 0 disables |

Every call is audited (agent, end user, conversation, phone number for OOB, result, time) for 90 days. In BYO mode the platform cannot know whether the text was delivered.

## Related

- [[Multi-Factor Authentication]] · [[Adaptive Authentication]] · [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]] · [[Non-Interactive Users]]
