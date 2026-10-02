---
type: concept
tags: [concept, reporting, incident, request, knowledge, ai]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ITSM Success Dashboard indicators" (pp. 2728-2763), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM Success Dashboard

**In one line:** a leadership dashboard (application `sn_sd_itsm`, ITSM Pro) of ServiceNow-prescribed KPIs that show how much the implementation deflects and automates: self-solve, call deflection, structured tickets, productivity, service quality, and an estimated cost saving.

Menu **Success Dashboard > Success Dashboard** (and **> Getting Started**, the admin console, which also fronts *Operational Success* and [[Benchmarks]]). Needs Performance Analytics, Performance Analytics Premium and Self-Service Analytics. An HR equivalent exists.

## Roles

| Role | Can |
|---|---|
| `sn_sd.success_dashboard_admin` | configure, manage KPIs, share |
| `sn_sd.success_dashboard_read` | view KPIs and high-level breakdowns, share |
| `sn_sd.success_dashboard_details_read` | also record-level breakdowns |

## KPIs and formulas

**Performance overview**

| KPI | Formula / rule |
|---|---|
| Self-solved % | [Self-solved (VA, KB, QnA, Proactive Engagement) + Automated resolutions] / [Total ticket resolutions + Self-solved (VA, KB, QnA, Proactive Engagement) + self-service through Password Reset apps] × 100 |
| Self-solved using Virtual Agent | conversations that solved the problem: the user finished a conversation and did not engage a human agent within 24 hours (NLU and LLM assistants) |
| Self-solved using Knowledge | user read articles and neither created a ticket nor contacted an agent within 24 hours |
| Self-solved using QnA | user got a summarised AI Search answer (portal or Virtual Agent) and did nothing further within 24 hours |
| Self-solved using Proactive Engagement for DEX | issues DEX detected and the user fixed through the proactive prompt |
| Automated resolutions | *Incident Auto Resolution* (deflection node in the Issue Auto Resolution topic) + *Request Fulfilled Automatically* (requested items of catalog items whose **Fulfillment automation level** is *Fully automated*) + accounts unlocked and passwords updated through Password Reset apps |
| Total ticket resolutions | incidents resolved + requested items closed + agent interactions closed without a ticket |
| Call deflection % | [Catalog ticket submissions + VA ticket submissions + Self-solved (VA) + Self-solved (KB)] / [Total tickets submitted + Self-solved (VA) + Self-solved (KB)] × 100 |
| Catalog ticket submissions | incidents and requested items submitted through the catalog in the portal or mobile app |
| VA ticket submissions | counted by the *Triage & Created* deflection pattern in the topic (instrument every custom topic that creates tickets) |
| Total tickets submitted | incidents created + requested items created |
| Structured tickets | requested items completed in the period |
| Productivity moments per user | search (NLU understood the intent), routing (Predictive Intelligence prediction equals the value at closure), fulfilment (incident, interaction and change summaries, resolution notes, change risk explanations generated), knowledge articles created with generative AI |

**Service quality**: customer satisfaction score, mean time to resolve, % breached SLAs, % first assignment resolution, % reopened tickets. The Insights side panel shows the two least efficient process-mining findings (incident table only) with **View in Analyst Workbench**.

**Operational Success**: tabs per process (incident, major incident, change, request, service catalog, interaction, problem, on-call), each a Platform Analytics dashboard: see [[ITSM Platform Analytics Dashboards and KPIs]]. Add a tab: a record in `sn_sd_kpi_category` (name, dashboard type, order) and one in `sn_sd_tab_m2m_dashboard` (tab → dashboard).

**Cost savings**: per contributing indicator, time saved per **persona group** × the group's hourly salary; currency from property `sn_sd.success_dashboard_currency`.

Scorecards aggregate daily values monthly, quarterly or yearly (counts are summed, percentages averaged) with a comparison to the previous period; **View details** drills primary → contributing → record level. Targets can be set per KPI (value, start date, review date); **Share dashboard** emails it or copies the link. With Benchmarks enabled the global score is shown next to yours.

## Setup checklist

1. Install `sn_sd_itsm`.
2. Knowledge bases counted for self-solve: **Self-Service Analytics > Activity Context > ITSM KB deflection** > activity type *Viewed a knowledge article* > narrow the filter to the IT knowledge bases. The deflection **Window** (refresh interval) is on the pattern in **Getting Started > Configure Knowledge deflection > Settings**.
3. Virtual Agent topics: add a **Deflection** utility node (configuration *ITSM VA Default*; pattern *ITSM VA-Self-Resolving* or *ITSM VA-Triage & Created*; activity table and ids), and append `&referrer=va` to catalog links in *Link Output* so submissions count as Virtual Agent. Or use the zero-effort self-service analytics method (**Virtual Agent deflection > Review and Configure**: refresh window, incident fields, topics considered). See [[ITSM Virtual Agent Topics and Setup]].
4. What counts as "talked to a live agent": override `checkInteraction(openedFor, windowStart, windowEnd)` in script include `SSADeflectionHelper` (extends `SSADeflectionHelperSNC`; server-side; it queries `interaction` for non-virtual-agent interactions of the user in the window).
5. Set **Fulfillment automation level** on catalog items (Unspecified, Manual, Semi-automated, Fully automated). It is a label for reporting only; it does not change how the item is fulfilled.
6. Run scheduled job *UpdateFormulasSD* (daily; run by hand if the numbers look stale).
7. Activate PA jobs: *[SD ITSM] Daily Data Collection*, *[PA SLA]*, *[PA Requested Item]*, *[PA Incident]*, *[PA ITSM Dashboard] Daily Data Collection*; run the matching *Historic Data Collection* jobs once for the past 60 days.

## Changing what feeds a KPI

- **Primary indicators** (`sn_sd_primary_indicator_registry`, PA links in `sn_sd_primary_indicator`) are prescribed: do not modify them. *Manual* ones are formulas over other primaries; *automatic* ones are the sum of their registered contributing indicators.
- **Contributing indicators** (`sn_sd_contributing_indicator_registry`): create a daily-count PA indicator with its collection job, then register it (**Name**, **Contributing Indicator**, **Primary KPI**, **Service group** ITSM or HR); the primary's formula updates itself. Add *Persona Group Time Savings* for the cost view.
- Help cards: `sn_sd_indicator_context_information` (icon, tagline, heading, HTML content, footer) linked through `sn_sd_m2m_indicator_context_information` with an order.

## Related

- [[Benchmarks]] · [[Otto for ITSM Skills and Agentic Workflows]] · [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]]
