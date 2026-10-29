---
type: table
tags: [table, schema, knowledge]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Create a knowledge base, Components installed with Knowledge Management Core, read 2026-10-29. Column names marked ? are not stated on those pages. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/create-a-knowledgebase.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# kb_knowledge_base

**Label:** Knowledge Base
**What it stores:** knowledge bases: owner, managers, publish and retire processes, feature switches and access lists.
**Extends:** none stated
**Extended by:** none stated
**Scope:** global (scoped bases record their application in **Application**)

## Key columns

| Label | Name | Type | Meaning | Confidence |
|---|---|---|---|---|
| Title | `title`? | string | | ? |
| Owner, Managers | `owner`?, `kb_managers`? | reference / list | get `knowledge_manager` automatically | label documented |
| Publish flow / Retire flow (and Publish workflow / Retire workflow) | ? | reference | process per base | label documented |
| Article Validity | ? | integer (days) | default Valid to | label documented |
| Disable commenting / suggesting / category editing / rating / mark as helpful, Enable blocks, Checklist, Active, Languages, Auto-create translation tasks, Set default knowledge field values, Related products, Application, Icon | ? | | | label documented |

## Relations

- Articles: [[kb_knowledge]].`kb_knowledge_base`
- Access lists: `kb_uc_can_read_mtom`, `kb_uc_cannot_read_mtom`, `kb_uc_can_contribute_mtom`, `kb_uc_cannot_contribute_mtom` → [[user_criteria]]
- Categories `kb_category`, featured keywords `kb_knowledge_keyword`, templates (Article Templates related list), portals (Service Portal **Knowledge Bases** related list)

See [[Knowledge Bases and Categories]].
