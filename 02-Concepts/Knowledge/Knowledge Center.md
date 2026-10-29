---
type: concept
tags: [concept, knowledge, workspace, ai]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage content capabilities > Knowledge Center (landing, Exploring Knowledge Center, Knowledge Center home page, Knowledge Center article editor, Potential knowledge gaps, Knowledge blocks in Knowledge Center; Configuring Knowledge Center, Enable system properties for Knowledge Center, Enable knowledge blocks in the Knowledge Center, Integrate Box in Knowledge Center; Using Knowledge Center, Search knowledge article, Check Knowledge Center insights, Manage potential knowledge gaps, Identify and resolve duplicate articles, Address items that requires attention, Generate and edit articles with the article editor, Create knowledge articles using AI and Box, Create knowledge articles using AI and Microsoft SharePoint, Using knowledge blocks in the Knowledge Center: edit, add, create), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-center.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Center

**In one line:** a workspace-style home for knowledge authors and managers (plugin scope `sn_km_center`), with search, **Insights** (gaps, duplicates, article optimization, health score), a **Requires Attention** queue, and a new block-based **article editor**; most insights need Otto (generative AI) skills.

From the Brazil docs; not tested. Available from Yokohama Patch 11 and Zurich Patch 4 (as the page states). Open from **Knowledge > Knowledge Center** or **Workspaces > Knowledge Center**. Quality scans and scores: [[Knowledge Center Article Optimization and Health Score]]. AI skills: [[Otto in Knowledge Management]].

## Turning it on

Properties (**System Properties**; new customers: all true; existing customers: all false, so current processes are not disturbed):

| Property | Meaning |
|---|---|
| `sn_km_center.glide.knowman.enable` | access to Knowledge Center at all |
| `sn_km_center.glide.knowman.ece.enable` | use the Knowledge Center **article editor** (false = classic TinyMCE editor; choose by training and workflow needs). The property name is listed on the configuration page; the table on the properties page shows the description without the name, so the pairing is inferred |
| `sn_km_center.glide.knowman.redirect.enable` | knowledge links open in the new interface |

Other `sn_km_center` / `sn_km_gen_ai` properties (auto-fix, auto-merge, health score, reading ease, stale and expiring thresholds, Box) are listed in [[Knowledge Center Article Optimization and Health Score]].

## Home page

| Section | What it does | Condition |
|---|---|---|
| Search | by title or body; AI Search when Otto for AI Search is active, otherwise contextual search; **View all Knowledge** (cards) or **Go to list view** | |
| Insights | top knowledge actions, knowledge base health score, potential duplicates, potential gaps, article optimization | AI skills enabled for the user's role |
| Requires Attention | My Approvals, My Pending Group Requests, My Feedback Tasks, My Article Checklist (user is reviewer), My Flagged, Articles expiring in 90 days (assigned to the user), My Translation Requests; also reachable from **Knowledge > Requires Attention** | by role |
| Quick View | jump to bases; most viewed, most useful, featured | |
| Knowledge Features | guide to KM workflows | |
| Actions | create article, create block, manage (ownership) groups | Otto for AI-assisted create / update |
| Configurations | links to settings (health score configuration, properties, etc.) | |
| Knowledge Resources | learning and community links | |

**Top knowledge actions** shows six items split across the categories the user can access (Duplicates, Gaps, Article Optimization): two from each of three, three from each of two, or six from one.

## Article editor

- Metadata pane (short description, base, Valid to), device previews (desktop, tablet, mobile), outlines, undo / redo, clear.
- Drag **components** (columns, text, image, table, video); block **Settings** for margins and alignment; floating inline toolbar; image resize / rotate / flip.
- Insert **knowledge blocks** (search, advanced search; create blocks from the editor).
- Otto open prompts (summarise, expand, format; generate a whole article from a prompt); article templates for layout and form templates for default content.
- Word count next to the size controls (feeds the article length scan).
- Side panel: **Article Overview** (duplicate content, article health score, usage insights such as AI content references, views and attaches to cases / incidents), **Article Optimization** (findings, stale or expiring card), **Health Score**, **Attachments** (up to 1024 MB as stated), **Templates** (save new article templates).
- Create: **Knowledge > Knowledge Center > Lists** > pick list (Unpublished, Published, Retired ...) > **New** > base and template > preview > Next > write > **Save**. Role on the page: `agent`.

## Potential knowledge gaps

Areas where incidents or cases recur with no supporting article (supported for CSM, ITSM and HR). Views: all gaps, top five gaps. Actions (`admin` per the page): **Unmark as gap**, **Mark as resolved**, **Report (knowledge) gap** (feedback task; once an article exists the gap cannot be reported again), **Create an article**. Needs the gap skills ([[Otto in Knowledge Management]]). The older ML route is [[Knowledge Demand Insights and Predictive Intelligence]].

## Duplicates

**Potential duplicates** card (trend of duplicate topics this year) > **View all**; **Unmark as Duplicate** for valid articles; merging is in [[Knowledge Center Article Optimization and Health Score]].

## Knowledge blocks in Knowledge Center

Same blocks as in [[Knowledge Article Templates and Knowledge Blocks]] (`com.snc.knowledge_blocks`; activating it also activates Knowledge Management Advanced).

- Enable per base (`knowledge_admin` or `knowledge_manager`): **Knowledge > Administration > Knowledge Bases** > base > **Enable blocks** (add the field to the form if missing). To disable later, all blocks in the base must be deleted first.
- Create (contribute access): **Lists > Knowledge Blocks > All** (check for an existing one) > **New**: Number, Knowledge base, Category, Ownership Group (when ownership groups are on), **Can Read** / **Can't Read** user criteria (combined with base criteria), Valid to (expired block content disappears from the article and from search hits), Short description, Article body, Version, Article type (HTML only), Workflow; ignore Source Task. Saved to Unpublished; **Publish** follows the base's publish flow (instant or approval).
- Insert: open the article, **Blocks** icon in the side panel > **Insert** (or search). Blocks cannot be edited inside the article; open the block record (published blocks need checkout). With versioning, publishing moves the block to the next whole number (e.g. 2.02 → 3.0).
- Unpublished blocks are not found by search.
- Docs example: one holiday article with a block per office location, each secured by user criteria.

## Articles from external sources (Box, SharePoint)

In the editor, **Source** drop-down > *Integrations* > **Box** or **SharePoint**, then a prompt (e.g. "Create an article about password reset"). Outcomes: files found (article drafted from them), none found (article from the prompt alone), user not authorised ("Unable to retrieve Box / SharePoint identity for this account": the user needs an account there). SharePoint needs the SharePoint External Connector (plugin, admin consent, credentials); roles `knowledge_admin`, `knowledge_manager` or `knowledge`.

**Box setup** (summary; admin of the Box Dev Console needed):

1. Box: **My Platform Apps > New App**, *Client Credentials Grant*; note the **Enterprise ID**; access level *App + Enterprise Access*; scopes read and write all files and folders, **Manage AI**; admin action **Manage users**; enable *as-user header* and *Generate user access tokens*; Box admin authorises the app (a service account is created); copy client ID and secret.
2. Instance: **System OAuth > Application Registry** > New > *Connect to a third party OAuth Provider*: Client ID `<CLIENT_ID>`, Client Secret `<CLIENT_SECRET>`, OAuth API Script **OAuthUtilBox**, grant **Client Credentials**, token URL `https://api.box.com/oauth2/token`, send credentials *In Request Body (Form URL-Encoded)*; default OAuth entity profile with grant Client Credentials.
3. Set `sn_km_center.box_integration_enterprise_id` to the Enterprise ID.
4. REST Message **Open Prompt - Box Integration**: attach the OAuth profile, **Get OAuth Token** to test. General outbound OAuth: [[OAuth 2.0 Outbound - The Instance as OAuth Client]].

## Related

- [[Knowledge Management Overview]] · [[Create and Edit Knowledge Articles]] · [[Knowledge Management Properties Reference]] · [[Knowledge Management Dashboards]]
