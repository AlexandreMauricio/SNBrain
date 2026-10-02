---
type: concept
tags: [concept, portal, notifications, scripting, script-include, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" (pp. 1838-1855: setting up Desktop Assistant, installers, OAuth, home page, themes, notifications API and troubleshooting, Virtual Agent, cards and sections; pp. 1904-1911: using Desktop Assistant, notifications, network test, usage metrics; pp. 2035-2046: usage metrics dashboard, installed roles and tables, notification API parameters, theme variables, screen loading issue), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DEX Desktop Assistant

**In one line:** Desktop Assistant (`sn_dex_desktop`) is a Windows and macOS tray application that gives employees a device health check, a network test, Employee Center, outages, Virtual Agent chat and push notifications from the instance.

Part of [[Digital End-User Experience Overview and Architecture]]. Roles: `sn_dex_desktop.admin` (configure), `sn_dex_desktop.user` (use), `sn_dex_desktop.notification_template_viewer` (read the notification template table).

## Install

**Desktop Assistant > Deployment > Installer and Uninstaller**. Client 2.6.0 or later; up to 75,000 devices per instance.

| Way | Notes |
|---|---|
| Single-line installer command (per OS) | run as administrator in PowerShell or Terminal; the instance URL is filled in automatically |
| Installer | Windows `Desktop_Assistant_<version>.msi` (x64); macOS `.pkg` for Intel, Apple Silicon or universal. The login page's instance URL is then empty |
| Endpoint management (Jamf, MECM, Intune: KB2324452) | deploy the installer, then set the instance URL in the configuration file on each device |

Configuration file `settings.json`: Windows `C:\Users\<user>\AppData\Roaming\desktop_assistant_app`, macOS `Users/<user>/Library/Application Support/desktop_assistant_app` (hidden folder). Keys: `instanceURL`, `loginHeader`, `loginBody`, `companyLogoSvg`. Logs are in the `logs` subfolder. Uninstall with the single-line uninstall command.

**OAuth**: **System OAuth > Application Registry > Desktop Assistant** (must be active). To skip the SSO screen: put `oauth_login.do` in **Login URL** (add the field to the form if missing) and remove the client secret.

**Login**: tray icon > **Open** > optional **Change URL** > **Sign in** (user name and password, or **Login with SSO**) > **Allow**.

## Home page

**Desktop Assistant > Configuration > Application**: **Title**, **Description**, **Employee Center URL**, **Notifications enabled** (bell icon), **Theme** (default *Employee Center (EC) Theme*), **Virtual Agent enabled** (chat icon; needs `com.glide.cs.chatbot`), **Logo** (at most about 160 × 80 px).

Themes: pick another theme, or edit the theme record's **CSS variables** (direct value, reference to another variable, or `ceil()` calculation).

| Shipped section | Shipped cards |
|---|---|
| My resources | Device health check, Network test |
| Quick links | Employee Center, Outages |

- **Hyperlink card**: **Configuration > Create Hyperlink Card**: **Name**, **Header**, **URL** (relative such as `/esc`, or a full public URL), **Description**, **Icon** (resized to 48 px).
- **Map a card to a section**: **Configuration > Home** > home page > (application scope *DEX Desktop Assistant*) > *Tab to Section Mappings* > section > *Section to Card Mappings* > **New** (card, **Order**).
- **Add a section**: *Tab to Sections Mappings* > **New** > existing section or new one (**Name**, **Show Title**).
- Delete cards or sections from the same lists.

## Employee features

- **Device health check**: see and self-resolve common device issues ([[DEX Self-Service and Device Actions]]).
- **Network test**: *Test my network* shows download and upload speed, a rating and advice; *Network Details* shows device and server names.
- **Employee Center**, **Outages** (System Status page), **Virtual Agent** chat.
- **Notifications** bell: list of notifications; also shown as system toasts. From Washington DC, notifications already issued do not appear on a newly logged-in device.

Administrators see who is logged in, connection status and client versions under DEX Administration > **Desktop Assistant > Usage metrics**.

## Notifications

Sources out of the box: **Major Incident Management** and **Proactive Engagement**. Capacity: about 400,000 per day, at most 10,000 per minute; delivery within about two minutes; each notification once per logged-in device. They inform; they are not actionable.

Major incident recipient lists (**Targeted Communications > Recipients Lists**): *All users in affected location(s)* and *Impacted application users in affected location(s)*. The second keeps only users whose application usage was above zero in an aggregation window; its script parameters are aggregation frequency (Daily 1-7 days, Weekly 1-4 weeks, Monthly 1-12 months; default Daily, 7), application type (installed or web), application sys_id, metric (for example Application Usage), metric value, location. It needs the DEX Score application and its daily aggregation job.

### Sending from a script

Script include `DesktopAppNotificationUtils` (scope `sn_dex_desktop`; **server-side only**: business rule, scheduled job, background script, flow script step; not a REST endpoint). Roles `sn_dex_desktop.admin` or admin. Property `sn_dex_desktop.enable_push_notification` must be true, otherwise the call returns 400.

```javascript
// server-side, scope sn_dex_desktop (or cross-scope call)
var utils = new sn_dex_desktop.DesktopAppNotificationUtils();
var result = utils.sendDANotification({
    notification_title: "Example title",
    notification_message: "Example message text.",
    recipient_list: "<user_sys_id_1>,<user_sys_id_2>", // sys_user sys_ids, comma-separated
    referrer_table: "incident",          // optional deep link
    referrer_id: "<record_sys_id>",
    source: "mim"                        // "mim" or "pe"
});
gs.info(JSON.stringify(result));         // responseCode 200 and metadata.notification_id on success
```

Minimum parameters: `notification_message`, `recipient_list`, `source`.

Delivery chain: the call validates and inserts a row in Desktop Assistant Notification (`sn_dex_desktop_assistant_notification`) → flow *desktop_assistant_notification_call* runs asynchronously → rows in Desktop Assistant Notification Queue (`sn_dex_desktop_notify_queue`), one per device token → event `sn_dex_desktop.triggerCheckdef` tells the ACC agent to fetch → the client shows a card (title, body, timestamp, optional deep link) and a toast.

Visibility: property `sn_dex_desktop.sn_desktop_assistant.notification_time_to_live`, 1 to 7 days (default and maximum 7).

### Troubleshooting delivery

1. Notification table: record exists, **Active** true, message, recipient list and source filled, **Expiry date** in the future. No record: check the caller's role and the enable property.
2. Queue table: status Pending (not yet fetched), Sent (fetched by the client) or Failed (agent timeout or push service error). No queue rows: the flow is not active.
3. **System Logs > Events**: event `sn_dex_desktop.trigger_checkdef`. Absent when property `sn_dex_desktop.poll_glide_for_notification` is true (polling replaces the event).
4. **Application Logs**, source containing `[DEX Notification]`: "Executing REST request", "Response body: OK", "Error during REST API call" (check network and property `sn_dex_desktop.push_notification_service_info`), "ERROR, invalid notification" (bad JSON payload).
5. Status Sent but nothing seen: is the client running and signed in, is ACC communicating (ACC logs), has the notification expired.

### Parameter rules

| Case | Result |
|---|---|
| `notification_message` empty, missing, not a string, or over 1000 characters | 400 |
| `notification_title` missing | card with an empty title, no error |
| `source` not a known source | 400 ("Source record missing ..."). A new source works only after it is added as a choice of **Notification source** on `sn_dex_desktop_assistant_notification`; matching is case-insensitive |
| enable property false | 400 at once; no record, no flow |
| only one of `referrer_table` / `referrer_id` | stored without error, but the link may not open the right record |
| time to live above 7 days, or unset | capped at / defaults to 7 days |

The card's timestamp is `sys_created_on` of the queue record; the system toast appears when the queue status is Pending as the client checks. The reference example returns the id as `metadata.notificationID`, another page writes `notification_id`: log the whole response. The property list names the switch `sn_dex_desktop.enable_notification` (default false), the notification pages `sn_dex_desktop.enable_push_notification`: check `sys_properties`.

## Usage metrics

Dashboard cards, all from Desktop Assistant Installation (`sn_dex_desktop_exp`): **Connection Status** (a user inactive for 6 hours counts as down even if logged in), **Logged in**, **Desktop Assistant Version in use**.

## Tables

| Table | Holds |
|---|---|
| Desktop Assistant (`sn_dex_desktop_app`) | the application registry: title and settings |
| Desktop Assistant Card (`sn_dex_desktop_app_card`) | base table of all cards |
| Hyperlink Card (`sn_dex_desktop_hyperlink_card`), Records View Card (`sn_dex_desktop_records_view_card`), Record Creator Card (`sn_dex_desktop_record_creator_card`) | card types: a link, a list of records, a record creator with chosen fields |
| Desktop Assistant Section (`sn_dex_desktop_app_section`), Tab (`sn_dex_desktop_app_tab`) | containers: a tab holds sections, a section holds cards |
| `sn_dex_desktop_app_to_tab_mapping`, `sn_dex_desktop_tab_to_section_mapping`, `sn_dex_desktop_section_to_card_mapping` | the mappings |
| `sn_dex_desktop_exp` | installations and usage |

`sn_dex_desktop.admin` contains `sn_dex_desktop.user`, which contains `sn_incident_read` and `sn_change_read`. The OAuth record is a standard Application Registry form (client id, redirect URL, token lifespans, default grant type).

## Theme variables

| Group | Variables (default) |
|---|---|
| Banner gradient, in this order | `brand-primary-darkest`, `brand-primary-darker`, `brand-primary`, `brand-primary-lighter` (also `brand-primary-lightest`) |
| Typography | `font-size-base` (16px), `font-family-sans-serif` and `headings-font-family` (Lato), `font-weight-base` (400), `headings-font-weight` (600), `line-height-base` (1.4); `font-size-h4`, `-h3`, `-xl`, `-xs`, `-small` are `ceil()` multiples of the base (1.125, 1.25, 1.5, 0.75, 0.875) |
| Colours | `background-primary`, `background-secondary`, `text-primary`, `text-secondary`, `text-tertiary`, `text-color` and `text-muted` (set only when the primary / tertiary one is not), `color-grey`, `link-color`, `btn-default-color`, `btn-primary-color`, `btn-primary-bg`, `brand-warning-darker`, `brand-success-darker`, `brand-danger-darker`, `alert-warning-bg`, `badge-color` |
| Borders | `border-primary`, `border-secondary`, `border-tertiary`, `border-width-xs` (1px), `border-style-solid`, `border-radius-base` (4px), `input-border` |
| Spacing | `sp-space--xxs` 2px, `--xs` 4px, `--sm` 8px, `--md` 12px, `--lg` 16px, `--xl` 24px, `--xxl` 32px; `panel-heading-padding` |
| Effects | `font-weight-lg` (600), `sp-panel-box-shadow`, `sp-box-shadow--md` |

## Empty or endlessly loading screen

Cause: the user lacks `sn_dex_desktop.user`, or `settings.json` is corrupt. Refresh; quit and relaunch; delete `settings.json` (paths above); confirm the role; confirm Desktop Assistant is installed on the instance being connected to.

## Related

- [[Digital End-User Experience Overview and Architecture]] · [[DEX Self-Service and Device Actions]] · [[Proactive Engagement]] · [[Major Incident Management]] · [[DEX Reference]]
