---
type: concept
tags: [concept, change, ai]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Analyze change request risk and impact" and subtopics, "Success Probability definitions", "Calculated Risk Score", "Change success score", "Predictive Intelligence for Change Management" (pp. 639-646, 742-754), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Change risk calculation and assessment

**In one line:** the **Risk** of a change comes from up to four engines (risk conditions, a questionnaire, success-probability lookups, machine learning); when several run, the **highest** risk wins.

## 1. Risk conditions (Risk Calculator, active by default)

**Change > Administration > Risk Conditions** (`risk_conditions`). Each rule: **Order**, **Active**, a condition (builder, or **Use advanced condition** script setting `answer`), and the **Risk** and/or **Impact** to set (or **Use script values**). Evaluated lowest order first; the **first match wins** and the rest are ignored. Do not use Keywords in the condition.

When they run (`glide.ui.risk_calculate_rule`, **Change > Administration > Risk Properties**):

| Value | Behaviour |
|---|---|
| UI Action (default) | related link **Calculate Risk** on demand |
| Business Rule | on insert/update (*Run Risk Calculation*); suppressed while a risk assessment is attached |
| None | disabled |

## 2. Risk assessment questionnaire (plugin `com.snc.change_management.risk_assessment`)

**Change > Administration > Risk Assessments** (`change_risk_asmt`, role `itil_admin`), built on Assessments: **Condition** (which changes it applies to; keep them mutually exclusive), one **Assessment Category** with weighted **Assessment Metrics** (questions), and **Assessment Thresholds** (**Score greater than** → **Risk**). Score = sum of answer value × weight.

Users select the related link **Risk Assessment** (Normal or Emergency, state New/Assess/Authorize), answer, then **Calculate Risk**. The form header then shows the assessed risk, the condition-based risk and the final value.

Legacy assessments (`com.snc.change.risk_assessment`) are migrated with **Migrate to Risk Assessment**; negative-score choices are not migrated.

## 3. Success probability and calculated risk score

- **Change success score** (ITSM Professional): daily PA job scores each assignment group from its history. Multipliers: successful +3, successful with issues −2, unsuccessful −5, P1 incident caused −10, P2 −5, P3 −2. Ratings Low/Medium/High/Excellent in **Change > Administration > Change Success Score Ratings**; card next to **Assignment group**.
- **Success Probability definitions** combine Change Success Score and Change Model Success into a band (tables `sn_chg_probability_success`, `sn_chg_probability_model_success`, `sn_chg_probability_calculated_lookup`).
- **Calculated Risk Score** (**Change > Administration > Calculated Risk Score**, `sn_chg_probability_risk_lookup`): nine rows mapping Impact × success probability → Risk. Details in `sn_chg_probability_details`.

## 4. Risk Intelligence (plugin `com.snc.change_management.ml.risk`)

**Change > Intelligent Solution Configuration > Risk Intelligence**: solution type *Similarity* or *Classification*; **Predicted value usage** *View risk value* or *Set risk value*; confidence threshold.

## Troubleshooting a risk that does not change

Rule inactive; a lower-order rule matched first; **Use script values** script does not set both values; an attached risk assessment suppresses the business rule; a higher risk from another engine wins.

## Related

- [[Change Management Overview and Lifecycle]] · [[Change Approval Policies]] (route approvals by Risk)
