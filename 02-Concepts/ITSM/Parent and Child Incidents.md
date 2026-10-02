---
type: concept
tags: [concept, incident, task]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topics "Copy an incident or create a child incident", "Synchronizing parent and child incidents" (pp. 2476-2479), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Parent and child incidents

**In one line:** many incidents about the same issue are linked to one parent through **Parent Incident** (`parent_incident`); work happens on the parent and most state changes flow down to the children.

## Creating

- **Create Child Incident** (form context menu): copies the parent's fields and sets **Parent Incident**. Needs `com.snc.incident.create.child.enable`.
- **Copy Incident**: same copy without the link; work notes get "Created from a similar incident: INC...". Needs `com.snc.incident.copy.enable`.
- Or set **Parent Incident** by hand / with a list action.
- Add the **Parent Incident** field and the related list **Incident -> Parent Incident** to the form to see them.

Copied by default: category, subcategory, service, CI, impact, urgency, assignment group, short description, description, caused-by change, location, company, problem, change request, parent incident (inactive references are skipped), plus the related lists Affected CIs, Impacted Services, Service Offerings. Not copied: resolution fields, knowledge. Configurable in [[Incident Properties Reference]].

An itil user can copy any incident; a user without roles only their own.

## State synchronisation

| Parent becomes | Children |
|---|---|
| In Progress | In Progress |
| On Hold, reason Awaiting Change / Problem / Vendor | same state and reason |
| On Hold, reason **Awaiting Caller** | **not updated** |
| Resolved | Resolved; the parent's resolution notes are copied to the child's activity |
| Closed | **not closed**: each child is closed by its caller or by auto-close |
| Canceled | no change |

- Reopen by an itil user: parent and children go back to In Progress. Reopen by the caller (no role): only the parent.
- Proposing or accepting the parent as a **major incident** does not change the children's states ([[Major Incident Management]]).

## Example

Ten users report the same VPN outage. The first incident becomes the parent, the other nine are linked. The agent resolves the parent with notes; all nine callers get their own incident resolved with those notes, and each closes or auto-closes separately.

## Related

- [[incident]] · [[Incident Management Overview and Lifecycle]]
