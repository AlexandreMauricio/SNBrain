---
type: concept
tags: [concept, knowledge, ai, reporting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Exploring > Machine learning solutions for Knowledge Management, Predictive Intelligence for Knowledge Management, Knowledge demand insights; Configuring > Train the similarity solution for Knowledge Management, Configuration tasks for knowledge demand insights (Configure Knowledge Demand Insights, solution definitions, mapping with task tables, frequency, assignment, analyze from a dashboard), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/knowledge-demand-insights.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Demand Insights and Predictive Intelligence

**In one line:** plugin **Predictive Intelligence for Knowledge Management** (`com.snc.knowledge_ml`, scope *Knowledge Management - Machine Learning*) trains similarity and clustering models that (1) suggest **similar / related articles** and (2) find **knowledge gaps**: groups of resolved incidents or cases that no article covers, shown on **Demand Insights** dashboards where a curator turns them into feedback tasks.

From the Brazil docs; not tested. General Predictive Intelligence: [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]].

## Solution definitions

| Definition | Type | Use |
|---|---|---|
| Knowledge Similar Articles (`ml_sn_global_knowledge_similar_articles`; template when `com.snc.contextual_search_ml` is also active) | Similarity | related articles on the Knowledge form (**Knowledge results**, needs the **Contextual Search Results** field on the form), **Related Articles** on the portal article page and Now Mobile, Agent Assist with **Similar Articles (ML)** |
| Demand Insights: Similar Incidents and Knowledge (`ml_sn_global_similar_incidents_and_kbs`) / Similar Cases and Knowledge (`ml_sn_global_similar_cases_and_kbs`) / Similar HR Cases and Knowledge (`ml_x_sn_hr_core_global_demand_insights_similar_hr_cases_and_knowledge`) | Similarity | compare resolved tasks with articles |
| Demand Insights: Incident Clusters Need Knowledge (`ml_sn_global_incidents_need_knowledge_cluster`) / Case Clusters Need Knowledge (`ml_sn_global_cases_need_knowledge_cluster`) / HR case clusters need knowledge (`ml_x_sn_hr_core_global_demand_insights_hr_case_clusters_need_knowledge`) | Clustering | group uncovered tasks into topics |

Similarity form: word corpus, table `kb_knowledge` with fields and filter, **Test Table** and test fields (the tasks), processing language (English always included) and stopwords, training and update frequency; **Submit & Train** / **Update & Retrain**, then review similarity examples and set the **Similarity Score Threshold** on the ML solution. Clustering form: table **Task knowledge coverage** (`kb_task_knowledge_coverage`), fields, filter, frequencies. Edit only in the scope Knowledge Management - Machine Learning.

## Setting up demand insights

Easiest through **Knowledge > Administration > Guided Setup > Knowledge Demand Insights**. By hand:

1. **Knowledge Demand Insights > Solution Definitions**: one similarity and one clustering definition per task type (defaults for incident, CSM case, HR case; New for others).
2. **Demand Insights Configuration** (`admin`): KB curation configuration per **Curation table** (`incident`, `sn_customerservice_case`, `sn_hr_core_case`): fields holding article IDs (e.g. resolution notes), query condition, the two definitions. Other task types also need users with `sn_km_ml.knowledge_curation_user` and their own dashboard.
3. **Scheduled Jobs**: *[Knowledge Curation]: Generate Incident Clusters* / *Case Clusters* / *HR Case Clusters*; default every 90 days, advice no more than monthly; **Execute Now** to run.
4. **Knowledge Gap Assignment** (`admin` or `assignment_rule_admin`): assignment rules on **Knowledge Feedback Task** (`kb_feedback_task`) with condition Feedback Task Type is *Knowledge gap*, assign to a user or ownership group (or script). Without rules, assign by hand in Feedback Management.

## Using the dashboard

Needs read access to the tasks and `sn_km_ml.knowledge_curation_user`. **Knowledge Demand Insights** or **Self-Service > Dashboards**: *Demand Insights for Incidents*, *for Cases*, *for HR cases*. A **Pareto chart** shows collections of similar uncovered tasks, largest first, with a line marking how many collections cover 80% of them. In **Knowledge Curation Tasks**: **Generate Representative Sample**, select tasks, **Report Knowledge Gap** (description prefilled with frequent words) → one feedback task for all of them (*Is knowledge gap created* = true), or **Ignore Collection** (cannot be reported later).

## Related

- [[Knowledge Management Dashboards]] (dashboard roles and data) · Knowledge Center gap skills: [[Knowledge Center]], [[Otto in Knowledge Management]]
- [[Knowledge Feedback, Ownership Groups and Article Quality]] · [[Self-Service Analytics and Case Deflection]] · [[Contextual Search]]
