---
type: concept
tags: [concept, security, instance-admin, admin, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Antivirus Scanning (6 topics, 224 cleaned lines) - Exploring, Configuring, Reviewing quarantined files, Review antivirus activity, dictionary attributes, read in full 2026-10-08 through the docs site. https://www.servicenow.com/docs/r/platform-security/antivirus-protection.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Antivirus Scanning

**In one line:** every attachment is virus-scanned when it is uploaded and again when it is downloaded; infected files are quarantined, shown as unavailable, and reported to the user and the antivirus administrator.

From the Brazil docs. Related hardening settings: [[Hardening Settings - Validation, Files, Logging and Other]]. Metrics: [[Security Center]].

- Plugin **Antivirus Protection** (`com.glide.snap`), active by default. Menu **Antivirus** (Configuration, Quarantine, Activity). Roles `antivirus_admin` (or `admin`).
- Scans attachments (`sys_attachment`) of every supported file type, on upload and on download. Definitions are updated daily.
- Not scanned: files over **100 MB**; edge-encrypted files; inbound email (that is the email filters' job: [[Email Filters, Address Filters and Bounce Management]]).
- Switch: `com.glide.snap.enable_scan` (commercial) or `com.glide.snap.fed_enable_scan` (government cloud). Turning it off needs support.
- **File Attachment fields** store their files against generated `ZZ_YY<table>` pseudo-tables; only those of live profiles are scanned unless listed in property `com.glide.snap.scan.zz_yytables` (for example `zz_yyincident,zz_yycase`).

What users see:

| Case | Behaviour |
|---|---|
| Upload of an infected file | quarantined; shown as *unavailable* in the attachment list; message asking to remove it; email to the user and the antivirus administrator |
| Download of an infected file | scanned at that moment, quarantined, download refused |
| Download of all attachments as ZIP | clean files are zipped; an `error.txt` names what was left out; the infected file moves to *Potential security risks* |

**Antivirus > Configuration**: *Enable Antivirus scanning*; *Allow attachments to be downloaded when Antivirus scanner is unavailable* (on = download proceeds unscanned if the scanner times out; off = blocked until it can be scanned: the hardened choice, property `com.glide.snap.infected_download_allowed` = false); *List of Tables Excluded*.

Table-level dictionary attributes (on the table's collection row):

| Attribute | Effect when true |
|---|---|
| `exclude_from_antivirus_scan` | attachments on the table are not scanned |
| `supress_antivirus_email_notification` (spelt so in the docs) | no email when an infected file is found |
| `suppress_antivirus_ui_notification` | no on-screen message |

**Antivirus > Quarantine**: per file **Delete**, **Restore** (scan it with your own product first), **Download** for analysis. **Antivirus > Activity**: log of discovery, quarantine, restore and delete events.

## Discrepancies in the docs

- The attribute names are printed with a capital first letter, and one of them with a missing letter (`Supress_...`): check the exact spelling on an instance before relying on it (?).

## Related

- [[Hardening Settings - Validation, Files, Logging and Other]] · [[Security Center]] · [[Email Filters, Address Filters and Bounce Management]] · [[Dictionary Attributes Reference]] · [[High Security Settings]] · [[HTML Sanitizer]]
