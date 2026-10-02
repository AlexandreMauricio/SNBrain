---
type: reference
tags: [reference, instance-admin, platform, glossary]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Available system properties" (pp. 21-132), read 2026-10-01. The guide lists about 630 properties; this note keeps the ones an administrator is likely to meet and names the families left out
sn-release: Australia
verified:
updated: 2026-10-01
---

# System properties reference

Defaults are the guide's. A property marked (add) usually has to be created in `sys_properties` first: [[Add a System Property]]. Background: [[System Properties]]. Email properties are in [[Email Properties Reference]]; export limits in [[Export Limits and Properties]].

## Sessions and login

| Property | Default | Effect |
|---|---|---|
| `glide.ui.session_timeout` | 30 | inactive session timeout, minutes |
| `glide.ui.session_timeleft` | 2 | minutes of warning to extend before timeout |
| `glide.ui.active.session.life_span` | 0 | maximum session length regardless of activity, minutes (0 = none) |
| `glide.guest.session_timeout` | 30 | guest (not logged in) session timeout |
| `glide.integration.session_timeout` | 1 | inactive timeout of integration (API) sessions, minutes |
| `glide.integrations.active.session.life_span` | 0 | maximum integration session length |
| `glide.ui.auto_req.extend.session` | true | homepage auto-refresh keeps the session alive |
| `remember_me_cookie.duration_in_days` / `remember_me.max_duration_in_days` | 15 / 30 | "remember me" cookie life and cap |
| `glide.ui.remember.me.default` | true | "Remember me" pre-ticked |
| `glide.login.home` | `home.do` | page after login; blank = last page visited |
| `glide.entry.loggedin.page_ess` | none | page for users without roles |
| `glide.login.no_blank_password` | true | blocks logins with blank passwords |
| `glide.basicauth.update_last_login_time`, `glide.oauth.update_last_login_time` | true | integration calls update the user's **Last login** fields |
| `glide.user.default_password` | (set) | password for users auto-created from email; must be reset at first login |

## Dates, time and locale

| Property | Default | Effect |
|---|---|---|
| `glide.sys.date_format` | `yyyy-MM-dd` | system date format unless the user overrides |
| `glide.sys.time_format` | `HH:mm:ss` | system time format |
| `glide.sys.default.tz` | none | system time zone |
| `glide.ui.date_format.first_day_of_week` | 1 | week start for calendar reports (1 = Sunday) |
| `glide.ui.date_picker.first_day_of_week` | 1 | week start in date pickers |
| `glide.ui.filter.first_day_of_week` | 2 | week start for "this week" style filters (2 = Monday) |
| `glide.db.aggregates.trend.use_iso_week` | none | weekly trends by ISO week |
| `glide.schedules.repeat_nth`, `glide.schedules.fifth` | day, last | how monthly "nth weekday" schedule entries behave |

## Forms, lists and UI

| Property | Default | Effect |
|---|---|---|
| `glide.ui.dirty_form_support` | true | warn about unsaved changes when leaving a form |
| `glide.ui.task.insert` | false | allow **Insert** / **Insert and Stay** on task tables |
| `glide.ui.update_on_iterate` | false | save when using the form's next/previous arrows |
| `glide.ui.glide_list.start.locked` | true | watch-list style fields start locked |
| `glide.ui.max_ref_dropdown` | 25 | max records for a reference shown as a dropdown |
| `glide.ui.first.field.reference` | false | first list column always opens the record |
| `glide.ui.reference.readonly.clickthrough` | false | reference preview on read-only reference fields |
| `glide.ui.personalize_form`, `glide.ui.personalize_form_role` | true, none | Personalize Form menu and who gets it |
| `glide.ui.remember_view` | true | remember the last view per user |
| `glide.ui.table.labels` | true | show table labels instead of names |
| `glide.ui.goto_use_contains` | false | list **Go to** uses contains instead of greater-than |
| `glide.ui.textarea.character_counter` | false | character counter on journal and multi-line fields |
| `glide.ui.textarea_initial_rows` | 0 | initial rows of multi-line fields |
| `glide.template.max_context` | 15 | templates listed in the form context menu |
| `glide.ui.show_template_bar` | true | template bar; per table with `.<table>` suffix |
| `glide.ui.allow.field.dependency.for.templates` | true | templates respect dependent choice fields |
| `glide.itil.assign.number.on.insert` | false | assign the task number at submit instead of at form load (avoids gaps) |
| `glide.lists.live_list_enabled` | false | list refresh prompt |
| `glide.list.filter_max_length` | 0 | max length of a condition builder query |
| `glide.secondary.query.sysid` | false | add sys_id as secondary sort for stable paging |
| `glide.xmlhttp.excessive` | 100 | items shown in the Available side of a slushbucket |
| `glide.ui.polaris.experience` | true on new instances | Next Experience UI |
| `glide.product.name`, `glide.product.description`, `glide.product.icon`, `glide.banner.image.url` | | browser title, banner text, favicon, banner link |

## Activity stream and journals

| Property | Default | Effect |
|---|---|---|
| `glide.ui.incident_activity.fields` (pattern per table) | list | fields shown in the activity formatter |
| `glide.ui.activity.email_roles` | `itil` | roles that see emails in the activity formatter |
| `glide.ui.activity_stream.style.work_notes` / `.comments` | gold / transparent | colour bar of work notes / comments |
| `glide.ui.journal.use_html` | false | rich text in journal fields |
| `glide.history.max_entries` | 250 | described in the guide as the length of the journal input preview; verify before relying on it |
| `glide.max_journal_list_size` | 10 | max size of journal input, MB |
| `glide.history_set.pull_journal_entries_from_journal_table` | true | history sets read journals from `sys_journal_field` rather than audit |

## Attachments and HTML

| Property | Default | Effect |
|---|---|---|
| `com.glide.attachment.max_size` | 1024 | max attachment size, MB |
| `glide.attachment.extensions` | none | allowed extensions (empty = any) |
| `glide.attachment.role` | public | roles allowed to attach |
| `glide.security.file.mime_type.validation` | false | check that content matches the extension |
| `glide.ui.attachment.force_download_all_mime_types` | true on new instances | attachments download instead of rendering |
| `glide.html.sanitize_all_fields` | true | sanitise HTML fields |
| `glide.html.escape_script` | true | script tags in HTML fields are escaped |
| `glide.ui.html.editor.toolbar.line1` / `.line2` | | TinyMCE toolbar buttons |
| `glide.ui.html.image.allow_url` | false | insert images by URL |
| `glide.html.enable_media_sites` | list | sites allowed for embedded media |

## Scripting and database

| Property | Default | Effect |
|---|---|---|
| `glide.db.max_view_records` | 10000 | cap on rows a scripted GlideRecord query returns (per the guide; do not raise) |
| `glide.invalid_query.returns_no_rows` | false | true: a query with an invalid field returns nothing instead of ignoring that condition |
| `glide.db.max.aggregate.size` | 20 | max groups rendered in a grouped list or report |
| `glide.db.forced.chunk.threshold` | 100,000,000 | size above which multi-row deletes/updates are chunked |
| `glide.db.audit.ignore.delete` | | tables whose deletions are not logged in `sys_audit_delete` |
| `glide.sys.audit_inserts` | false | audit inserts as well as updates |
| `glide.ui.audit_deleted_tables` | user/group/role tables | tables whose deletions appear in history |
| `glide.update.suppress_update_version` | `sys_user,sys_import_set_row` | tables without version records |
| `glide.businessrule.callstack` | false | log start and end of every business rule (debugging) |
| `glide.businessrule.async_condition_check` | false | re-check an async rule's condition when it runs |
| `glide.script.log_level` | all | behaviour of `gs.log` |
| `glide.script.use.sandbox` | true | sandbox for client-supplied scripts (filters, GlideAjax) |
| `glide.script.ccsi.ispublic` | false | client-callable script includes are private on public pages |
| `glide.script_processor.admin` | admin | role needed for Scripts - Background |
| `glide.ui.ui_policy_debug`, `glide.ui.js_error_notify` | false, true | UI policy logging; show client script errors |
| `glide.sys_reference_row_check` | false | apply ACL script conditions to reference field lookups |
| `glide.rollback.version` | true | rollback contexts enabled |

## Security

| Property | Default | Effect |
|---|---|---|
| `glide.security.use_csrf_token` | true | CSRF token on requests |
| `glide.security.strict_elevate_privilege` | true on new instances | admins must elevate for every elevated role |
| `glide.security.granular.create` | true | create needs write access on each field |
| `com.glide.acl_check_all_filter_on_new` | false (add) | ACL check when creating from a filtered list |
| `glide.set_x_frame_options` | true | X-Frame-Options SAMEORIGIN |
| `glide.cookies.http_only` | true | HTTP-only cookies |
| `glide.image_provider.security_enabled` | true | images need authentication |
| `glide.security.diag_txns_acl`, `glide.custom.ip.authenticate.allow` | false, none | who can open `stats.do`, `threads.do` |
| `com.snc.hr.core.impersonateCheck` | true | HR restrictions still apply while impersonating |

The guide points to *Instance Security Hardening Settings* for the security properties' recommended values.

## Integrations and web services

| Property | Default | Effect |
|---|---|---|
| `glide.http.connection_timeout` | 10000 ms | outbound HTTP connect timeout |
| `glide.http.timeout` | 175000 ms | outbound HTTP response timeout |
| `glide.http.outbound.max_timeout` | 30 s | cap for synchronous RESTMessageV2 / SOAPMessageV2 calls |
| `glide.hosts.allowlist` | empty | hosts that outbound HTTP may reach |
| `glide.rest.apis.disabled` / `glide.rest.apis.enabled` | all enabled | switch REST APIs off or on by name |
| `glide.rest.choice.allow_non_existing_value` | false | REST may set a choice value that does not exist |
| `glide.rest.debug` | false | log REST processing stages |
| `glide.processor.json.row_limit` | 250 | rows returned by the legacy JSON processor |
| `glide.remote_glide_record.max_count` | 250 | rows returned through SOAP GlideRecord |
| `glide.soap.request_processing_timeout` | 175 s | inbound SOAP processing timeout |
| `glide.http.proxy_*` | none | outbound proxy |

## Imports

| Property | Default | Effect |
|---|---|---|
| `glide.import.debug` | false | debug logging for imports |
| `com.glide.loader.verify_target_field_size` | false | grow import set columns to fit data instead of truncating |
| `glide.import_set_row.dynamically_add_fields` | false | imports may add columns to the staging table |
| `com.glide.csv.loader.ignore_non_parseable_lines`, `com.glide.csv.loader.max_errors_allowed` | false, 100 | skip bad CSV rows, up to a limit |
| `glide.import_set.preserve.leading.spaces` | false | keep leading spaces from Excel |
| `glide.import_excel.use_only_user_session_date_format` | true | Excel dates converted to the session date format |
| `glide.transform.reuse_coalesce_field_value` | true | do not re-run coalesce scripts |
| `glide.db.impex.XMLLoader.max.file.size.mb` | 100 | max XML import size |

## Task and ITSM

| Property | Default | Effect |
|---|---|---|
| `com.snc.task.associate_ci` | `incident,problem,change_request` | task types with the affected-CI list |
| `com.snc.task.refresh_impacted_services` | `incident,change_request` | task types with **Refresh Impacted Services** |
| `com.snc.time_worked.update_task_timer` | false | time worked records update the task timer |
| `sn_chg_soc.*` | 40 / 20 / 1000 | change schedule record limits |

## Families not copied here

`css.*` and `glide.bsm.*` (colours, maps), `com.snc.pa.*`, `glide.analytics.*`, `par_*` (Performance / Platform Analytics), `glide.cmdb.*`, `glide.identification_engine.*`, `glide.discovery.*`, `sn_agent.*` (CMDB and Discovery), `glide.knowman.*` (Knowledge), `glide.ldap.*`, `password_reset.*`, `google.maps.*`, `sa_analytics.*` (Event Management), `glide.cost_mgmt.*`, `glide.phone_number_e164.*` (see [[E164 Phone Number Fields]]), `glide.notification.recipient.*_logging*` (why a recipient was included or excluded: see [[Notification Email Not Sent or Not Received]]), chat, tablet and legacy UI properties. Look them up in the source when a topic needs them.
