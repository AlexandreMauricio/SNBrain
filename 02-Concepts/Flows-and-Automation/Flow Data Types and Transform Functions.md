---
type: reference
tags: [reference, flows, automation, service-catalog, fields, security]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Reference (read 2026-10-08 through the docs site): Workflow Studio input and output data variables and each data type page (Approval rules, Array.Boolean, Array.Choice, Array.Datetime, Array.Integer, Array.Object, Array.String, Choice, Conditions, Datetime, File attachment, Integer, JSON, List.[Table], Object, Password (2 Way Encrypted) design considerations, Records.[Table], Reference.[Table], String, Table name, True/false, Variables.[Table]), User preferences for flows, User roles for conversational subflows and actions, Supported input data types for conversational subflows and actions, Supported Service Catalog variable types, Transform functions (Date and time, String, Utilities, Simple math, Sanitize shell arguments, Sanitize SQL, Complex data), Types of flows and when to use them. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/action-inputs-outputs.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flow Data Types and Transform Functions

**What it is:** the variable types used for inputs and outputs of actions and subflows, how catalog variables map onto them, the no-code transform functions applied to pills, and a few per-user preferences.

Where data shows: action inputs and outputs, subflow inputs and outputs and the trigger appear as pills in the Data panel; the *inputs* of a step or action are not listed there, only what each one outputs.

## Variable options

Every variable: **Label** (free text), **Name** (letters, digits, underscore; derived from the label; used in scripts), **Type**, **Mandatory**. Advanced: **Hint**, **Default value**. Type-specific extras:

| Type | Stores | Extras and notes |
|---|---|---|
| String | text | **Max length** limits what can be typed in the designer, not what can be stored |
| Integer | whole numbers | |
| True/False | boolean | |
| Date/Time | date-time | |
| Choice | one value of a choice list | **Choices** (name, value, order), dropdown with or without *None* (with None needs a default), **Max length** |
| Reference.[Table] | one sys_id | **Reference qualifier conditions** |
| Records.[Table] | several sys_ids (a glide list) | output of Look Up Records; in script a GlideRecord |
| List.[Table] | list of sys_ids | default records (**Add [record]**), reference qualifier. Usable in For Each, which skips entries that are not sys_ids. Avoid default records in actions meant for the Store |
| Table Name | a dictionary table name | |
| Conditions | an encoded condition set for a chosen table | lets callers pass conditions into Look Up or Wait steps |
| Approval Rules | rules for Ask for Approval | give it a default rule |
| JSON | JSON text | from integration steps or scripts |
| Object | one structured object | **Structure**: create manually (then **Save as Template**) or start from a template |
| Array.String / Integer / Boolean / Datetime / Choice / Object | sequences | **Max rows** limits what the designer displays, not what is stored |
| File Attachment | one file stored with the record itself | one input per file; such files cannot be handled by the attachment actions |
| Variables.[Table] | a set of glide variables, for example decision inputs | **Data Definition** (the table holding the variables), **Depends-On Another Input** |
| Password (2 Way Encrypted) | an encrypted secret | see below |

Complex objects in practice: [[Custom Actions, Dynamic Inputs and Error Evaluation]].

### Password (2 Way Encrypted) pills

- A value can only come from another password2 pill; it cannot be typed.
- May be dropped only into: email body, HTML fields, password2 fields, PowerShell input variables, REST fields (variables, payload body, query parameters, headers, multipart and form-encoded values) and SOAP fields (headers, envelope). Never in conditions.
- Saving, publishing or testing validates this and blocks the run.
- Reading the clear value needs access to the encryption module (Key Management Framework; no vault note yet).

## Service Catalog variable types

| Catalog variable | Single-row set | Multi-row set |
|---|---|---|
| Check box, Yes/No | True/false | True/false |
| Date | Date | Date/time |
| Date and time | Date/time | Date/time |
| Duration, Email, IP Address, URL, Masked, Multi-line text, Reference | the same type (reference = Reference) | String |
| Single-line text, Wide single-line text | String | String |
| Select box, Multiple choice | Choice | Choice |
| Lookup select box, Lookup multiple choice | Choice | String |
| Numeric scale | Integer | Integer |
| List collector | List | not supported |
| HTML | HTML | not supported |
| Label, Macro, Macro with label | String | not supported |

Used by *Get Catalog Variables* and *Create Catalog Task* ([[Flow Core Actions Reference]]).

## Conversational skills: roles and inputs

| Role | Gives |
|---|---|
| `virtual_agent_admin` | all Virtual Agent tables and Now Assist admin; contains `action_designer`, `flow_designer` |
| `sn_conv_fa.conv_fa_admin` | read flows, subflows, actions; edit conversational settings (contains `sn_conv_fa.conv_fa_designer`, `fd_read_actions`, `fd_read_flows`) |
| `sn_conv_fa.conv_fa_designer` | edit conversational settings; contained in `action_designer` and `flow_designer` |
| `sn_conv_fa.csa_email_write` | lets conversational subflows and actions write to `sys_email` |

Input types a conversational subflow or action accepts: array of strings, true/false, choice, the date and time types (date, time, date/time, calendar, due date, schedule date/time), document ID, email, sys_id (GUID), HTML, integer, long, reference, string, table name. Settings: [[Subflows in Workflow Studio]].

## Transform functions

Hover a pill > **f(x)** > pick from *Available Transforms* > parameters > **Apply**. Several can be stacked; they run top to bottom.

- A function applied to the wrong pill type does nothing: the input comes back unchanged. A date conversion that yields no valid date **cancels the flow**.
- The transform belongs to that one input; the pill itself is unchanged, so repeat it wherever the pill is used.
- Execution details show only the final value. Outputs are stored values, not display values; dates are UTC.
- Custom transform functions do not exist: use an inline script.

| Category | Functions |
|---|---|
| Date and time | **Add Time**, **Subtract Time** (a duration; a Date input gets time 00:00:00), **String to Date**, **Date to String** (preset or custom format), **Day**, **Hour**, **Minute**, **Second**, **Month**, **Week**, **Year** (integers), **Date Difference** (a duration, expressed as an offset from 1970-01-01 00:00:00), **End of Month** (after adding N months) |
| String | Convert String to Number, Contains, Does not Contain, Starts With, Ends With, First Character, Last Character, **Replace String** (JavaScript regex + replacement), Size, **Split** (to Array.String; empty separator = no change), **Substring** (start and end index from 0, end included; a start beyond the length returns the whole string, unlike JavaScript), To Lower Case, To Upper Case, To Proper Case (words split on space, hyphen, slash, backslash), Trim |
| Utilities | Get First / Last Item from Array, Get Item from Array (index from 0), **Get Item from Name/Values** (key, default), **Key Value Map** (map a value to another, with default: for example priority number to a text), Is Blank / Is Not Blank (not for references), Is Null, Is True, Is False (empty string, 0 and false count as blank / false), **Sort** (case-sensitive for strings), **Unique**, **Join** (delimiter) |
| Simple math | Add, Subtract, Multiply, Divide, Power, Absolute Value, Square Root, **Round** (to N significant digits from the left: 194 with 2 gives 190), **To Fixed** (truncate decimals); on arrays: Sum, Average, Median, Min, Max, Count |
| Sanitize shell arguments | **Sanitize Bash shell arguments** (wraps in single quotes, escapes inner ones); offered automatically on the SSH step's Command |
| Sanitize SQL | **Sanitize SQL Identifier** and **Sanitize SQL Value**, per database (MySQL, Oracle, PostgreSQL, Microsoft SQL Server); offered automatically on the JDBC step's SQL Statement. Do not add quotes yourself. An identifier containing a period errors: sanitise the two parts as separate pills |
| Complex data | **To XML** (complex object to an XML string) |

Custom date format letters follow the Java pattern: `yyyy` year, `MM` / `MMM` month, `dd` day, `HH` hour 0-23, `hh` hour 1-12, `mm` minute, `ss` second, `SSS` millisecond, `a` am/pm, `E` weekday name, `z` / `Z` / `X` time zone; text in single quotes is copied as is (`'On' MMM dd, yyyy 'at' hh:mm a`). An incomplete format fills in current year and month, day 1, time 00:00:00.

## User preferences for flows

| Preference | Default | Effect |
|---|---|---|
| Show triggered flows | off | flows with a trigger appear in the subflow picker |
| Show store spokes | on | content of installed Store spokes in the action picker |
| Show inline script toggle | on | |
| Show advanced connection options | off | for actions using aliases or inline connections |
| Show flows as diagrams | off | open flows in diagram view |
| Auto Refresh Tests | off | test execution details refresh by themselves |
| Show recommendations | on | AI next-step suggestions |

## Flow or subflow

| Need | Build |
|---|---|
| a fixed start event and data | flow |
| variable input, a call from a flow or script, reuse, declared inputs and outputs | subflow |
| a flow of 25 or more actions | split into subflows |
| outputs that depend on each other, or something to do when all are done | parallel subflows |
| independent work on one event | several flows on the same trigger event |
| automatic correction of record errors, or more than 10 error-handler items | subflow |

*Dynamic Flow* is flow logic, not a kind of flow ([[Flow Logic Reference]]).

## Related

- [[Flow Action Steps Reference]] · [[Flow Core Actions Reference]] · [[Flow Authoring Aids - History, Variables, Inline Scripts and AI]]
