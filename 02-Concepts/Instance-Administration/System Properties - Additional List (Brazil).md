---
type: reference
tags: [reference, instance-admin, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform Administration > Get started > Available system properties, read 2026-10-30. Only properties whose name appeared nowhere else in the vault at that date. Meanings cut to a few words; open the page for detail. https://www.servicenow.com/docs/r/platform-administration/r_AvailableSystemProperties.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# System Properties - Additional List (Brazil)

**In one line:** a lookup of 235 system properties from the Brazil list that no other vault note mentions.

From the Brazil docs; not tested. Start with [[System Properties Reference]]; this list only adds to it. Many must be added to System Property (`sys_properties`) before they take effect, and some belong to products that may not be on your instance. Text ending in `...` was cut short. Security-related ones are in the Hardening notes, such as [[Hardening Settings - Access Control]].

| Property | Meaning | Type | Default |
|---|---|---|---|
| `cdu.record.watcher.timeout` | Maximum waiting period for the Cloud Discovery schedule configuration wizard to stop watching ... | integer | 120,000 milliseconds |
| `com.glide.cs.collab.event_queue.enabled` | Switch to enable the event queue for badge count calculation and publish |  |  |
| `com.glide.cs.collab.event_queue.threshold` | Calculates the unread count for each member of a chat |  |  |
| `com.glide.cs.collab.notify_all_members` | If Sidebar is unable to deliver messages to a Microsoft Teams user, this property determines ... | true / false | true |
| `com.glide.cs.collab.teams_outage_timer` | Length of time the "message not sent" notification (see ... | integer | 5 |
| `com.glide.cs.conversation_history_cross_channel.enabled` | Enables (true) or disables (false) the display of cross-channel conversation history in the ... | true / false | false |
| `com.glide.cs.field.boolean.show.choice_picker` | Enables (false) or disables (true) a Boolean option to requesters whenever a dynamic choice ... | true / false | false |
| `com.glide.cs.gen_ai.enable_mid_topic_ai_search` | Enables or disables AI Search result in Mid Topic Discovery using this flag | true / false | true |
| `com.glide.cs.instance_uri_override` | Enables Virtual Agent to use this URL value to override the instance URL for link generation | string | none |
| `com.glide.cs.notification.create_llm_actions_after_topic_migration` | Enables (true) or disables (false) whether actions for Virtual Agent notifications and ... | true / false |  |
| `com.glide.cs.proactive_trigger.create_llm_actions_after_topic_migration` | Enables (true) or disables (false) whether actions for Proactive Triggers are created after ... | true / false |  |
| `com.glide.event_handler.CollabNotificationEventHandler` | Specifies the event handler for the sidebar_notification queue |  |  |
| `com.glide.event_manager.sidebar_notification.claim_limit` | Specifies the number of sidebar_notification events the job on each node polls each time |  |  |
| `com.glide.interaction.autocreate_relationships` | Specifies whether auto-logging of records in the interaction_related_record table is turned on ... | true / false | true |
| `com.glide.script.fencing.secure_child_tables` | Controls whether to apply cross-scope access rules when querying application-administered ... | true / false | false |
| `com.glide.script.scoped_evaluator.allow_dynamic_cross_scope_eval_scoped_administration` | Controls whether to allow scripts in applications with Scoped Administration enabled to be ... | true / false | false |
| `com.glide.scripting.module.use_module_sandbox` | Separates the JavaScript module runtime environment from scripts​. Setting this property to ... | true / false | false |
| `com.glide.soap.include_non_db_fields` | Controls whether non-database fields, such as the sys_tags field, are included in WSDLs and ... | true / false | false |
| `com.glide.ui.virtual_host` | Specifies Guided Tour Designer callout icons | String |  |
| `com.glideapp.canvas` | Enables (true) or disables (false) responsive canvas for dashboards | true / false | true |
| `com.snc.apps.publish.include_inactive_choices` | Specifies whether choice table selections marked as inactive (sys_choice inactive attribute = ... | true / false | true |
| `com.snc.apps.publish.maxrows` | Defines the maximum number of data records to include when publishing an application | integer | 1,000 |
| `com.snc.iam.log_level` | Logging level for the business rule MapUpstreamImpactedCI. Debug is the most detailed option ... | string | info |
| `com.snc.pa.dc.batch_score_insert` | When true, Performance Analytics | Boolean true / f | true |
| `com.snc.pa.dc.flush_snapshot_count` | Maximum number of Performance Analytics | integer | 1000 |
| `com.snc.pa.dc.nested_collection` | Activates a hierarchical approach to score collection, where Indicator > level 1 breakdown > ... | Boolean true / f | true |
| `com.snc.pa.dc.script.use.sandbox` | Controls whether Performance Analytics data collection scripts use the sandbox | Boolean true / f | true |
| `com.snc.pa.dc.use_hashcode_for_distinct` | Sets whether Count Distinct aggregations are stored as separate values in memory or as a ... | Boolean true / f | true |
| `com.snc.pa.formula_indicator_valid_breakdown` | Controls whether users can apply a breakdown to a formula indicator when not all contributing ... | Boolean true / f | true |
| `com.snc.pdf.whitelisted_urls` | Stores a list of URLs allowed to be rendered in a PDF generated by the PDFGenerationAPI - ... | string |  |
| `com.snc.project.default_schedule` | Stores the sys_id of the default schedule attached to projects | string |  |
| `com.snc.project.loglevel` | Automatically resubmits timed-out Ajax requests | choice list | 0 (debugging disabled) |
| `com.snc.project.wbs_gantt` | Automatically resubmits timed-out Ajax requests | true / false | false |
| `css.tablet.gradient.end` | End color of the gradient for the tablet UI header | color | #111 |
| `css.tablet.gradient.start` | Start color of the gradient for the tablet UI header | color | #666 |
| `css.tablet.headerfooter.text.color` | Color of the text and icons in the tablet UI header and footer | color | #ffffff |
| `glide.activity.last_viewed_timestamp.local_storage_limit` | Specify the maximum number of last viewed timestamps to be stored in local storage | integer | 1000 |
| `glide.activity.last_viewed_timestamp.local_storage_retention_days` | Specify the number of days for which the last viewed timestamps data should be retained in ... | integer | 30 |
| `glide.amb.session.logout.overlay.style` | Specifies a cascading style sheet (css) that defines an overlay | string Example:  | empty (no overlay) |
| `glide.analytics.cache.expiration.age.in.seconds` | Value in seconds of the expiration_time field in analytics cache records | integer | 86400 (24 hours) |
| `glide.attachments.allow_html_in_ics` | It governs the handling of .ics files with embedded HTML content | text/html | null |
| `glide.authenticate.sso.saml2.require_signed_authnrequest` | Enables the Identity Provider Single sign-on service to receive a signed AuthnRequest | true / false | false |
| `glide.banner.image.url_target` | Target frame used when clicking the banner image | string | gsft_main |
| `glide.bsm.color.affect_neighbors` | Color of an affected neighbor node | color | Beige |
| `glide.bsm.map.style.font_family` | Font family name used in the map text | font name | Arial |
| `glide.bsm.map.style.font_size` | Font size of the text that appears with a CI node | integer | 14 |
| `glide.bsm.map.style.selection_background_color` | Background color of a selected CI node | color | RoyalBlue |
| `glide.bsm.map.style.selection_text_color` | Color of the text that appears under a selected CI node | color | White |
| `glide.bsm.map.style.text_color` | Color of the text that appears under an unselected CI node | color | Black |
| `glide.bsm.new_node_color` | Color for nodes that became viewable from the last expand operation | color | PaleGreen |
| `glide.bsm.refresh_interval` | Seconds between each automatic reloading of troubles and tasks | integer | 30 |
| `glide.bsm.task_threshold` | Change the CI glyph color from orange to red when the number of tasks reaches this threshold | integer | 3 |
| `glide.canvas.grid.widget_render_concurrent_max` | Defines the maximum number of widgets that can render simultaneously on a dashboard | integer | none |
| `glide.chart.decimal.precision` | Controls the rounding precision of non-currency numeric values displayed on reports | integer | 2 |
| `glide.chat.invite_fields` | (Chat plugin) Comma-separated list of fields (glide_list or references to sys_user or ... | string | none |
| `glide.chat.show_emoticons` | (Chat plugin) Enables (true) or disables (false) rendering text emoticons as images | true / false | true |
| `glide.chat_room.create_roles` | (Chat plugin) Comma-separated list of roles that are allowed to create chat rooms | string | none |
| `glide.cost_mgmt.calc_actual_cost` | (Cost Management plugin) When an expense line is created for any task with a Type of Planned ... | true / false | true |
| `glide.cost_mgmt.debug` | (Cost Management plugin) Enables debugging of cost management processing | true / false | false |
| `glide.cost_mgmt.process_task_cis` | (Cost Management plugin) Creates expense lines | true / false | false |
| `glide.cost_mgmt.service_allocation.method` | (Cost Management plugin) Defines whether business service to cost center allocation costs ... | choice list | all_units |
| `glide.db.table.update_inactive_choices_enabled` | Specifies whether choice table selections marked as inactive (sys_choice inactive attribute = ... | true / false | true |
| `glide.discovery.application_mapping` | Enables or disables the Application Dependency Mapping (ADM) feature | true / false | true |
| `glide.discovery.log_debug_info` | An optional property to populate debug information in Discovery log | true / false |  |
| `glide.discovery.log_message_chars` | When a log message is longer than this value, ServiceNow creates a preview of the message with ... | integer | 200 (characters) |
| `glide.discovery.multi_page_serial_mode` | This property controls the processing of multi-page pattern input records | true / false | false |
| `glide.discovery.sam_batch_update_size` | Enables batching the updates to table cmdb_sam_sw_install when only the field last_scanned in ... | integer | 100 |
| `glide.discovery.use_cmdb_identifiers` | Controls whether Discovery uses the CMDB Identification and Reconciliation Framework ... | true / false | true |
| `glide.domain.notify_change` | Displays a notification message telling the user that the domain picker automatically changed | true / false | true |
| `glide.domain.notify_record_change` | Displays a notification message telling the user that the domain picker automatically changed ... | true / false | false |
| `glide.eccprobe.longrunner.class` | Identifies the name of a script include that manages long running commands | string | LongRunner |
| `glide.eccprobe.longrunner.debug` | Allows LongRunner logs status on successful polls in addition to the usual messages on ... | true / false | false |
| `glide.eccprobe.longrunner.interval.backoff_percent` | Percentage that polling period grows per poll | integer | 15 |
| `glide.eccprobe.longrunner.interval.initial_seconds` | Initial polling period for long running commands in seconds | integer | 20 |
| `glide.eccprobe.longrunner.interval.max_seconds` | Maximum polling period | integer | 300 |
| `glide.eccprobe.longrunner.max_poll_count` | Maximum number of polls that is executed per 5- second polling period | integer | unlimited |
| `glide.eccprobe.longrunner.retry_minutes` | Allows bursts of polling errors up to specified minutes in duration | integer | 10 |
| `glide.ecmdb.all_relationship_role` | An example value is: itil,asset,configuration | string | none |
| `glide.element.reference.use_actual_display_value` | It controls the display value of GlideElementGlideObject fields like glide_date_time on Forms ... | true/false | false |
| `glide.element.use_object_display_value` | It ensures that the display value for GlideElementGlideObject fields like glide_date_time is ... | true/false | true |
| `glide.email_address_filter.max_exceptions` | Sets the maximum number of exceptions that can be associated with a single email | integer | 1000 |
| `glide.excel.boolean.display_value` | If true, translates columns of type boolean to the user's language when exporting records in ... | true / false | false |
| `glide.export.excel.general_formatting` | When true, values in cells in exported Excel files have the general format | true / false | false |
| `glide.export.excel.wrap_cells` | When true, values in cells in exported Excel files are wrapped automatically | true / false | true |
| `glide.glidesoap.proxy_host` | Specifies the proxy server hostname or IP address for SOAP clients | string | value of glide.http.proxy_host |
| `glide.glidesoap.proxy_port` | Specifies the port number for the proxy server for SOAP clients | string | value of glide.http.proxy_port |
| `glide.hd.payload_multi_page.device_history.mutex_expires` | Total time the thread waits to update the Discovery history before giving up | integer | 1 minutes |
| `glide.hd.payload_multi_page.device_history.mutex_max_spins` | The number of times the Discovery history is checked before giving up | integer | 600 |
| `glide.hd.payload_multi_page.device_history.mutex_spin_wait` | The time between when we check if the Discovery history database is free | integer | 100 ms |
| `glide.hd.payload_multi_page.discolog.mutex_expires` | Total time the thread waits to update the Discovery log before giving up | integer | 1 minutes |
| `glide.hd.payload_multi_page.discolog.mutex_max_spins` | The number of times the Discovery log is checked before giving up | integer | 600 |
| `glide.hd.payload_multi_page.discolog.mutex_spin_wait` | The time between when we check if the Discovery log database is free | integer | 100 ms |
| `glide.help.default.page` | Sets the overall help URL for the system if you are using context-sensitive help | string | http://wiki.servicenow.com/ |
| `glide.home.page` | Specifies which page to load when a user selects a homepage from the banner | string | home_splash.do?sysparm_direct= |
| `glide.home.refresh_disabled` | Enables (true) or disables (false) homepage refresh | true / false | false |
| `glide.home.refresh_intervals` | Comma-separated list of refresh intervals available on homepages | string | 300,900,1800,3600 |
| `glide.http.proxy_ntdomain` | Specifies the domain used to authenticate the proxy server with NTLM authentication | string | none |
| `glide.http.proxy_nthost` | Specifies the hostname used to authenticate the proxy server with NTLM authentication | string | none |
| `glide.http.proxy_ntpassword` | Specifies the password used to authenticate the proxy server with NTLM authentication | string | none |
| `glide.imap.secure` | Enables (true) or disables (false) SSL encryption for connections to the IMAP server | true / false | false |
| `glide.imap.secure_port` | Specifies the communications port for IMAP secure connections | string | 995 |
| `glide.imap.tls` | Enables (true) or disables (false) starting the IMAP server in Transport Layer Security (TLS) ... | true / false | false |
| `glide.integration.update_last_login_time.window.seconds` | Controls the frequency of updates to integration user records | integer | 60 |
| `glide.ir.query_method` | Sets the query method for global text search | choice list | simple |
| `glide.knowman.search_character_limit` | Minimum number of characters required for knowledge search | integer | 3 |
| `glide.knowman.show_language_option` | (Knowledge Management Internationalization Plugin v2) Specifies whether the Language box ... | true / false | false |
| `glide.knowman.show_language_option.roles` | (Knowledge Management Internationalization Plugin v2) Comma-separated list of roles that can ... | string | none |
| `glide.knowman.show_links` | Specifies whether the Link line appears (true) or is hidden (false) in a knowledge article | true / false | true |
| `glide.ldap.allow_empty_group` | Specifies whether all members can be removed from an Active Directory security group (true) or ... | true / false | true |
| `glide.ldap.paging` | Enables (true) or disables (false) LDAP paging query support | true / false | true |
| `glide.live_feed.company_feed_exclude_groups` | Controls whether messages posted to a public group appear (true) or are omitted (false) on the ... | true / false | true |
| `glide.live_services` | (Chat plugin) Enables (true) or disables (false) Live Services, such as chat support | true / false | false |
| `glide.messaging.reassign.enabled` | Sets property that automatically reassigns messaging if the current agent is unavailable | true / false | false |
| `glide.notification.recipient.exclude_logging.device_inactive` | Logs recipients who are excluded because their chosen notification device record is marked as ... | true / false | true |
| `glide.notification.recipient.exclude_logging.device_schedule` | Logs recipients who are excluded because the chosen notification device record’s schedule ... | true / false | true The glide.notification.re |
| `glide.notification.recipient.exclude_logging.event_creator` | Logs recipients who are excluded because they initiated the notification event, such as ... | true / false | true |
| `glide.notification.recipient.exclude_logging.invalid_email` | Logs recipients who are excluded because the email address for that user is invalid, for ... | true / false | true |
| `glide.notification.recipient.exclude_logging.user_calendar_integration_disabled` | Logs recipients of calendar invitations who are excluded because the Calendar Integration ... | true / false | true |
| `glide.notification.recipient.exclude_logging.user_inactive` | Logs recipients who are excluded because the Active check box is cleared on the user record | true / false | true |
| `glide.notification.recipient.exclude_logging.user_notification_disabled` | Logs recipients who are excluded because the Notification field is set to Disabled on the user ... | true / false | true |
| `glide.notification.recipient.include_logging.delegate` | Logs recipients who are included because they are delegates of another user | true / false | true |
| `glide.notification.recipient.include_logging.event_parm` | Logs recipients who are included because they are in the parm1 or parm2 fields of the event ... | true / false | true |
| `glide.notification.recipient.include_logging.recipient_fields` | Logs recipients who are included via a notification target record, such as an incident record, ... | true / false | true |
| `glide.notification.recipient.include_logging.recipient_groups.group_email` | Logs recipients who are included in a group email for any group provided in the notification ... | true / false | true |
| `glide.notification.recipient.include_logging.recipient_groups.manager` | Logs recipients who are included because they manage any group provided in the notification ... | true / false | true |
| `glide.notification.recipient.include_logging.recipient_groups.membership` | Logs recipients who are included via membership in any group provided in the notification ... | true / false | true |
| `glide.notification.recipient.include_logging.recipient_users` | Logs recipients who are included via notification record’s Users field (recipient_users).To ... | true / false | true |
| `glide.notification.recipient.include_logging.subscription` | Logs recipients because they are subscribed via User Notification Preferences.To modify this ... | true / false | true |
| `glide.par.export.ppt.max_visualizations_allowed` | For the ServiceNow Otto Data and Analytics skill "dashboard and visualization export," this ... | integer | 150 |
| `glide.pdf.font.size` | Sets the font size for exported PDF files | integer | 8 |
| `glide.pdf.url.whitelisting.enabled` | Enables or disables whether external URLs provided should be rendered in the PDF output ... | true / false | false |
| `glide.pdf_export_from_form_list.show_report_attrs` | Enables or disables displaying the PDF page header for all PDFs generated from a list | true / false | true |
| `glide.pg.any_rejection_rejects` | Controls the default process guide rejection handling | true / false | true |
| `glide.phone_number_e164.allow_national_entry` | When true, users can enter phone numbers in the local format listed in the territory selector | true / false | true |
| `glide.phone_number_e164.display_national` | When set to true or form, a Phone Number (E164) field displays phone numbers in a local format ... | string | false |
| `glide.phone_number_e164.display_territory_selector` | Specifies whether to display (true) or hide (false) the territory selector | true / false | true |
| `glide.phone_number_e164.display_territory_text` | When set to all, a Phone Number (E164) always displays the territory label | string | read-only |
| `glide.phone_number_e164.display_users_idd` | Specifies whether to display the international direct dialing prefix between the territory ... | true / false | false |
| `glide.phone_number_e164.strict` | Specifies whether all phone number fields must match the display format of the field's select ... | true / false | true |
| `glide.pop3.ignore_senders` | Specifies the comma-separated list of senders that cause the instance to ignore an email ... | string | mailer-daemon, postmaster |
| `glide.pop3.reply_separators` | Comma-separated list of separators that cause the instance to disregard everything below the ... | string | \n\n-----Original Message----- |
| `glide.product.help_show` | Controls whether the help icon, help.gifx, appears in (true) or is omitted from (false) the ... | true / false | true |
| `glide.product.help_url` | Global setting for the URL that the help icon goes to |  |  |
| `glide.product.image.light` | The Banner image displayed for Core UI Interface | uploaded image | none |
| `glide.product.name.style` | Specifies the CSS properties used to display the glide.product.name text in the banner to the ... | string | padding-bottom: 0px; padding-t |
| `glide.report.calendar.max_more_events_per_day` | Specifies the maximum number of calendar events that can appear in the + <number> pop-up for: | integer | 30 |
| `glide.report.new_calendar` | Enables (true) or disables (false) new calendar reports | true / false | true |
| `glide.report_home.group_report.show_usr_grp` | Enables (true) or disables (false) the Reporting preferences link in the user profile | true / false | false |
| `glide.rest.replace_request_host_with_property` | Ensures that generated links in an API payload, such as links to more pages and reference ... | true / false | true |
| `glide.rest.serialize.disable_response_stream_buffering` | Enables streaming multipart responses immediately rather than buffering responses until ... | true / false | true |
| `glide.rss.max_rows` | Controls the maximum number of records returned by the RSS Feed Generator | integer | 1000 |
| `glide.script.dot_walk.log_stack_trace_when_blocked` | When conditions prevent access to a protected table, a brief info message is displayed in the ... | boolean | true |
| `glide.security.checkacl.before.setvalue` | Controls how the high security setting glide.security.strict.updates processes ACLs | true / false | true |
| `glide.security.mime_type.aliasset` | Creates customized mime type alias sets | string |  |
| `glide.short_poll_delay` | (Chat plugin) Sets the short polling delay, in milliseconds, for XMPP requests | integer | 1000 (1 second) |
| `glide.soap.allow_null_numeric_output` | When true, SOAP XML responses return an empty element for numeric fields with no value | true / false | true |
| `glide.soap.default_security_policy` | Specifies the name of SOAP security policy the instance uses when enforcing Web Services ... | string | default security policy |
| `glide.spell.dictionary.en` | Sets the spell checker dictionary used in the system for English users | choice list | en.dic (English US) |
| `glide.spell.dictionary.max_matches` | Specifies the maximum number of spelling errors that the spell-check should detect | integer | 10 |
| `glide.split_journal_audit_records` | When set to true, ensures one-to-one mapping between [sys_journal_field] table and [sys_audit] ... | true / false | false |
| `glide.sys.activity_using_audit_direct` | [Not Supported] Controls whether the record's history is generated using the Audit table ... | true / false | false |
| `glide.sys.domain.use_record_domain_for_client_scripts` | Domain legacy | true / false | false |
| `glide.ts.reindex.sys_metadata.after.upgrade` | If true, the system automatically reindexes the sys_metadata table after an upgrade, without ... | true / false | true |
| `glide.ui.activity.displayname` | Specifies whether the activity formatter shows name values (true) or user_name values (false) | true / false | false |
| `glide.ui.activity.style.comments` | Changes the background color of the activity stream comments in UI15 | string | background-color: background-c |
| `glide.ui.activity.style.work_notes` | Changes the background color of the activity stream work notes in UI15 | string | background-color: LightGoldenR |
| `glide.ui.activity_stream.form_button` | Removes the activity stream button from forms | true / false | true |
| `glide.ui.activity_stream.list_button` | Removes the activity stream button from lists | true / false | true |
| `glide.ui.activity_stream.page_size` | Size of pages for Core UI form activity stream | integer | 0 |
| `glide.ui.activity_stream.scale_animated_gifs` | Creates a thumbnail of animated .gif files | true / false | false |
| `glide.ui.allow_deep_html_validation` | Allows administrators to prevent users from saving invalid HTML in a journal field | true / false | false |
| `glide.ui.auto.recovery` | Allows users to recover unsaved changes while working in the Studio | true / false | true |
| `glide.ui.auto.recovery.exclude.field.types` | Comma-separated list of field types to exclude from automatic recovery | string | none |
| `glide.ui.auto.recovery.unsupported.field.types` | Comma-separated list of field types no supported for automatic recovery | string | password,password2,glide_encry |
| `glide.ui.auto.recovery.unsupported.tables` | Comma-separated list of tables to exclude from automatic recovery | string | v_ws_editor |
| `glide.ui.buttons_bottom` | Controls whether UI actions appear at both the bottom and top of the form (true) or only at ... | true / false | false |
| `glide.ui.cert_task_activity.fields` | Defines which journal field is the task activity field | string | work_notes |
| `glide.ui.chart.height` | Specifies the height of a chart in pixels | integer | 300 |
| `glide.ui.clickthrough.popup` | For reference fields, enables (true) or disables (false) display of the pop-up diamond icon ... | true / false | false |
| `glide.ui.clickthrough.replace` | Enables (true) or disables (false) both the pop-up and click-through icons for reference fields | true / false | false |
| `glide.ui.default.applications` | Comma-separated list of application names that open by default in the navigation pane when ... | string | first authorized application f |
| `glide.ui.email.composer.enabled_plugins` | These plugin options are for Seismic Email Client | string |  |
| `glide.ui.email.composer.toolbar` | These toolbar options are for Seismic Email Client | string |  |
| `glide.ui.escape_form_message` | Specifies whether strings in GlideForm functions are sanitized to remove unwanted code (true) ... | true / false | false |
| `glide.ui.escape_gwindow_message` | Specifies whether strings in GlideWindow functions are sanitized to remove unwanted code ... | true / false | false |
| `glide.ui.gauge.view` | Defines which view you want to be the default for homepage gauges | string | portal |
| `glide.ui.homepage.parallel` | Enables (true) or disables (false) use of parallel rendering | true / false | true |
| `glide.ui.homepage.parallelism` | Sets the maximum number of threads that should cooperate on rendering any given homepage | integer | 2 |
| `glide.ui.homepage.preview` | Enables (true) or disables (false) displaying the preview icon for lists on the homepage | true / false | true |
| `glide.ui.html.editor.default_target_link` | Enables you to set a default target value for links in the TinyMCE | string | '' |
| `glide.ui.html.editor.remove_trailing_brs` | Specifies whether an empty line containing a <br> tag is converted to a <div>&nbsp;</div> tag ... | true / false | true |
| `glide.ui.html.editor.toolbar.line2` | Configures the editing toolbar (second line) for HTML fields when TinyMCE is enabled | string |  |
| `glide.ui.html.editor.v4.paste.html_import` | Controls how content being pasted from sources other than Microsoft Word is filtered | choice list | clean |
| `glide.ui.incident_alert_activity.fields` | Incident communication plan activity formatter fields — the list of fields tracked from the ... | string | opened_by, work_notes, comment |
| `glide.ui.label.enable` | Enables (true) or disables (false) using labels, such as Most Active, Most Recent, or ... | true / false | true |
| `glide.ui.m.clear_pasteboard_when_backgrounded` | Clears the copy/paste clipboard when the application enters the background | true / false | false |
| `glide.ui.m_agents` | Comma-separated list of browser agents considered as mobile browsers for the Smartphone ... | string | iphone,android_phone,IEMobile, |
| `glide.ui.max_calendar_duration` | Maximum number of days that a single calendar report entry can display | integer | 90 |
| `glide.ui.max_calendar_records` | Maximum number of records saved in a calendar report | integer |  |
| `glide.ui.mentions.default_limit` | Number of users with same name displayed in Activity Stream Compose editor | integer | 5 |
| `glide.ui.mobile_agents` | Comma-separated list of browser agents considered as mobile browsers for the Legacy Smartphone ... | string | iPod,Windows CE,BlackBerry,And |
| `glide.ui.nav.stripe.select.maxchars` | Numerical character limit for list menu choices within the nav stripe | integer | none |
| `glide.ui.polaris.global_search` | Toggles the Next Experience search function | true / false | true when glide.ui.polaris.exp |
| `glide.ui.polaris.history.url.param_blocklist` | URL parameters that are excluded when the system identifies and clears duplicate URLs from the ... | string | ["tinyId"] |
| `glide.ui.polaris.list_style.enable_highlighted_value_style` | Enables highlighted value style on list cells | true / false | true when glide.ui.polaris.exp |
| `glide.ui.polaris.login.show_illustrations` | Enables display of illustrative graphics on the stylized login page | string | true when glide.ui.polaris.exp |
| `glide.ui.polaris.menus` | Toggles the Unified Navigation menus in the header | true / false | true when glide.ui.polaris.exp |
| `glide.ui.report.extend_calendar_choices` | Controls which field styles are applied during calendar highlighting | true / false | true |
| `glide.ui.report.old_report_builder` | Enables (true) or disables (false) use of the old report builder UI | true / false | false |
| `glide.ui.section508` | Enables (true) or disables (false) rendering of alternate text in place of images | true / false | false |
| `glide.ui.stream_icon` | Toggles the displaying of the activity stream button on the specified table | true / false | false |
| `glide.ui.tablet.title` | Displays the specified text as a brief page title for tablet UI | string | ServiceNow |
| `glide.ui.tablet.title.ios_webapp` | Displays the specified text as the default home screen icon label used in iOS version 6 and ... | string | ServiceNow |
| `glide.ui.tablet_agents` | Uses the tablet UI if one of the specified strings (comma-separated) appears in the browser ... | string | ipad,android_tablet |
| `glide.ui.tablet_enabled` | Enables (true) or disables (false) the tablet UI | true / false | true |
| `glide.ui.welcome.profile_link` | Enables (true) or disables (false) allowing users to click their name in the welcome message ... | true / false | In new instances true. In exis |
| `glide.ui11.show_switch_link` | This property only affects a deprecated version of the UI. It is no longer supported | true / false | true |
| `glide.userauthgate.extauth.check` | Enables (true) or disables (false) the UserAuthenticationGate checks for both external and ... | true / false | false |
| `glide.ws.use_row_lock` | If true, avoid using the current web service lock that applies before running the transform | true / false | false |
| `glide.wsdl.maximum_hierarchy` | Maximum number of hierarchical levels returned in a WSDL when hierarchical SOAP web service is ... | integer | 3 |
| `glide.wsdl.show_nillable` | Enables (true) or disables (false) allowing a WSDL element to be valid if it has no element ... | true / false | false |
| `glide.xmlprocessor.use_unload_format` | Enables (true) or disables (false) unloading the XML using the display_value format | true / false | false |
| `google.maps.auto_close` | If true, automatically closes the current info window before opening a new one | true / false | true |
| `google.maps.client` | Client ID for Google Maps API for Business | string | gme-servicenow |
| `google.maps.latitude` | Starting latitude of the map | string | 36.008522 |
| `google.maps.longitude` | Starting longitude of the map | string | -95.221764 |
| `google.maps.zoom` | Starting zoom level of the map (1 is the lowest) | integer | 4 |
| `help.base.default` | (Context-Sensitive Help plugin) Sets the base URL for help contexts in which ServiceNow wiki ... | string | http://servicenow.com/docs/?co |
| `help.base.servicenow` | (Context-Sensitive Help plugin) Sets the base URL for help contexts in which ServiceNow wiki ... | string | http://servicenow.com/docs/?co |
| `mid.server.rba_debug_powershell` | Enables probe-level debugging for PowerShell probes | true / false | false |
| `promin.show_records.limit` | Specifies the maximum number of records that can be returned for an arc or node for the Show ... | integer | 30 (days)Note: Maximum value 3 |
| `security.list.internal.domains` | Other domains (excluding the ones in the comma-separated list in this property) are classified ... | Boolean | false |
| `subscription.custom_table.enforce_entitlement` | You can enable guardrails around custom tables when using certain applications, such as Mobile ... | true/false (Bool | true |
| `tablet.footer.text` | Text that appears on the footer of the tablet UI | string | Copyright ServiceNow 2012 |
| `tablet.header.text` | Text that appears on the right-hand side of the tablet UI header | string | ServiceNow |

## Example

To change how long `example.property` waits, check here for its type and default, add it to `sys_properties` on *Example Test Instance*, then test it with *Test User*.

## Related

- [[System Properties]] · [[System Properties Reference]]
