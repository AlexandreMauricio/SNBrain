---
type: concept
tags: [concept, ai, reporting, roles]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > ServiceNow Otto for Platform Analytics > Platform Analytics in the ServiceNow Otto panel, Dashboard Summary, read 2026-10-30. Example question lists not summarised. https://www.servicenow.com/docs/r/now-intelligence/analytics-assist-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Otto for Platform Analytics Skills

**In one line:** beyond [[AI Data Explorer]], Otto offers skills to generate visualizations and export dashboards from the Otto panel, and to summarize a dashboard. All rest on [[Query Generation and the Semantic Layer]]. The glossary calls the panel skills *Analytics Assist*.

From the Brazil docs; not tested. English only. The skills come in the Generative AI Controller, included in most Otto Store applications.

## Skills

| Skill | Roles | Default | Notes |
|---|---|---|---|
| **Data visualization generation** | `now_assist_panel_user` plus `now_assist_analytics_generation` or `now.assist.creator.analytics` (each contains `sn_query_gen.user`) | activate in AI Admin Hub (`admin`) | can add to an inline dashboard you can edit |
| **Dashboard and visualization export** | `now_assist_panel_user`; scheduling also `par_scheduler` | on, for any authenticated user | limit roles from the **AI Dashboard Insights** scope |
| **Dashboard summarization** | any authenticated user | on with the plugin (`now_assist_admin` configures) | off = dashboards show a message to contact an admin |

## Generating visualizations: limits

Types: single score, dial, gauge, bars, pie, donut, semi-donut, time series, list. Only tables in the semantic configuration. **Only the first** group by, table or condition is used; one time period per question. Not on technical dashboards. Simplify the question to work around these.

## Exporting: limits

- Saved items only, though a dashboard export includes its unsaved visualizations. No technical dashboards.
- Say whether it is a dashboard or a visualization; an open item is taken from context.
- Whole dashboard or one tab to PowerPoint; whole dashboards only to PDF.
- Download over 10 seconds arrives by email instead. Maximum 150 visualizations in one PowerPoint by default.
- Avoid phrases *Mail to me* and *Mail with subject and body as Visualization/Dashboard name*.
- Reset the conversation between requests, or options can carry over.

**Unconfirmed variant:** this page says filters apply only to PowerPoint exports; [[Platform Analytics Dashboards]] says PDF export offers **Export with applied filters** too. Formats are the same as in that note.

## Dashboard Summary

Needs a Now Assist application and Platform Analytics experience Bundle v8.4. On inline dashboards and workspaces, by default; not technical dashboards. **Generate Summary** gives a short state, what changed since the last run, and Key Highlights, adapted to the user's role, title and department and respecting active filters. Internal skills: Dashboard Facts Generator, Dashboard Highlights, Change Summary. Not covered: Process Mining map, Usage Insights funnel, iFrame. Summaries are cached 24 hours. **Refine** shortens, elaborates or changes tone.

Skill navigation appears as **AI Admin Hub** and as **ServiceNow Otto Admin > Skills**: unconfirmed variants. Otto context menu placement is in [[Platform Analytics Dashboards]].

## Example

In the panel, *Test User* asks *Show open incidents by priority as a donut*, adds it to *Example Service Desk Overview*, then asks *Export this dashboard to PowerPoint with applied filters*.

## Related

- [[Platform Analytics Data Visualizations]] · [[Platform Analytics Experience Overview]]
