---
type: concept
tags: [concept, security, data-management, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Privacy (chapter read in full 2026-10-08) - Tokenization, Create a tokenization policy, Review de-tokenization job summaries. https://www.servicenow.com/docs/r/platform-security/data-privacy-classic/reversible-tokenization-overview.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Tokenization of Sensitive Data

**In one line:** tokenization replaces a sensitive value with a same-shaped token and keeps the mapping on the instance, so most users see the token while users holding an authorised role can get the original back; unlike anonymization it is reversible.

From the Brazil docs. Part of [[Data Privacy Overview]]. Irreversible alternative: [[Data Anonymization - Techniques, Policies and Jobs]].

## How it behaves

- **Deterministic:** the same value always gives the same token.
- **Format preserving:** a nine-digit number stays nine digits, so reports and integrations keep working (some types limit token length or characters).
- The mapping is protected by a cryptographic key; plan key rotation so tokens stay readable. Where the key lives is not stated in these pages (?).
- **Detokenization** is only for the roles named in the policy, is requested through the ServiceNow Otto panel, and is logged.
- Applies only to **real-time entries by users**; the pages contradict themselves on existing data (one summary line says existing data must be tokenized through policies, the limitations say only real-time entries are covered).
- Once a form holds tokenized data the field cannot be edited by anyone; a user with the authorised role must first choose **Show sensitive data** to edit or save.
- Child tables have their own tokenization context: the same value can get a different token in a parent and a child table, and you choose to tokenize parent, child or both.
- Costs processing time on busy tables; searches, reports and exports see tokens.

## Policy

**System Security > Data Privacy > Tokenization > Create tokenization policy** (roles `data_privacy_admin` and `admin`):

1. Name; the tables and columns in scope.
2. The roles allowed to see original values.
3. **Select child tables**: tokenize them independently, with the same policy, or not at all.
4. **Data patterns**: which patterns inside those fields are tokenized (built-in or custom, see [[Data Discovery - Patterns, Policies, Jobs and Findings]]).
5. **Save** (Draft), then **Publish** to activate.

## Monitoring

Same page, **De-tokenization jobs**: per job a summary, description, created by, start and end time, preview expiry; exportable for compliance. Review these regularly and keep the authorised roles to the minimum.

## Related

- [[Data Privacy Overview]] · [[Real Time Protection - Alerts, Blocking and Attachment Quarantine]] · [[Data Privacy Channel Policies - AI Prompts, Inbound Email and Virtual Agent]]
