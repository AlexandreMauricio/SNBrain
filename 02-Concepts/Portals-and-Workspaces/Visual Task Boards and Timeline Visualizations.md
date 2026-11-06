---
type: reference
tags: [reference, task, portal, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Personalize your experience > Visual Task Boards (55 topics; types, elements, tools, SLA indicators, accessibility, activation, creating boards, lanes, members, sharing, customizing, labels, swimlanes, query and lane pivots, lane limits, cards, checklists, reference) and Timeline Visualizations (13 topics; key terms, activation, installed components, roles, create a visualization and view, planning, use), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g, chapters feJZmI72_Gk2xiNjtJuwZg and 5rHHyqticML_x4fJ26Q5ag).
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Visual Task Boards and Timeline Visualizations

**In one line:** a **Visual Task Board** (VTB, `vtb_board`) shows task records as cards in lanes; moving a card updates the record; a **Timeline Visualization** (`roadmap_page`) shows records such as projects or changes as panels on a 2D or 3D timeline for leaders.

From the Brazil docs; not tested. Needs Core UI or Next Experience (classic pages); not for external users; ACLs decide board access and card visibility.

## Board types

| Type | Cards | Lanes |
|---|---|---|
| **Freeform** | any task records plus **personal tasks** (`vtb_task`, Private Task, extends task) | free; default To Do, Doing, Done |
| **Flexible** (data driven, Lane Field *None*) | records of one task table matching the board filter; removed automatically when they stop matching | free, like freeform |
| **Guided** (data driven, Lane Field a choice or reference) | same | one lane per choice value (all values) or per reference value **in use**; lanes cannot be removed; Add Lane only for reference-based lanes |

Create: **Self-Service > Visual Task Boards** > New (or *Create New Visual Task Board*) > Freeform or Data Driven (Task Table, Lane Field, filter, optional sort and Swimlane Field). Add records to a freeform board from a form or list (*Add to Visual Task Board*); on data-driven boards **Add Task** pre-fills fields from the filter and lane. A **lane field pivot** (Info > Vertical Lane Field) turns flexible into guided or back, keeping members and history. The docs also say a freeform board must exist before a guided one can be created (unclear; recorded as printed).

## Board features

- **Tools:** Info (owner, counts, table, Edit Filter, lane, swimlane and due date fields, URL, *Exclude Child Table Records* for choice lanes), Members (members vs assignees, Promote All), Labels, Activity, Configuration (owner only).
- **Members:** only members open a board; any member adds or removes members. Deleting a board leaves the tasks intact but cannot be undone.
- **Customize:** colour theme, quick panel (users, labels), card options (Compact Cards, Card Info, Card Attachment thumbnail, **Show SLAs** with breach alerts showing the SLA with the highest elapsed percentage), hidden lanes, sort criteria (owner), **swimlanes** (horizontal lanes, compact cards only), **lane limits** (WIP; red mark and error when exceeded).
- **Labels:** seven per board; adding and renaming needs `global_tags_creator` (the page lists `tags_admin` and `global_tags_creator`); stored in `label`, the same table as tags ([[Core UI Navigation, Settings and Common Elements]]).
- **Cards:** edit details, assign (primary assignee limited by the table's rules), attach (`vtb.board.upload_limit`, 10 MB), archive (freeform only, restorable), open the record, move between lanes or (freeform) boards. Card fields come from the table's **VTB** form view. Up to 1,000 cards per board by default (`glide.vtb.board_max`; most recently updated shown). If a move fails although the user can write the record, create `glide.vtb.enable_list_edit_acl` = false.
- **Checklists** on cards (progress bar; create a task from an item, types from `glide.ui.create_task_type_option_list`); templates in `checklist_template` ([[Core UI Lists, Forms and Related Lists]]).
- **Share:** favorite (Core UI only), list view of the cards, Connect conversation synchronised with members ([[Connect Chat and Connect Support (Core UI)]]).
- **Accessibility:** skip link *View tasks as a list*, *Open Card Details* button when accessibility is on.
- Plugin `com.glide.ui.vtb` (active on new instances). Tables `vtb_board`, `vtb_board_member`, `vtb_lane`, `vtb_card`, `vtb_card_history`, `vtb_task`. Domain separation: Basic.

## Timeline Visualizations

- Plugin `com.snc.timeline_visualization`; the **CIO Roadmap** also needs PPM (`com.snc.financial_planning_pmo`). Roles `timeline_admin` (contains `timeline_user`), `timeline_user` (also granted through `project_manager` and `project_user`).
- Terms: **lane** (3D grouping), **panel** (a record in 2D, one or more in 3D), **summary view** (pop-up on click, defined by a timeline view), **marker** (month start), **slider**. 2D groups by month and prints; 3D groups by lanes.
- **Timeline Visualization > Create New** (`roadmap_page`): Name, **Panel table**, **Relationship field** (lane titles), Show slider, **Panel name**, **Panel date** (date fields), Default (one per table, business rule *Check only one default*), Max items per lane (500 3D, 99 2D; add to form), **Lane condition** and **Panel condition** with sorting. Personalization stored in `roadmap_user_page`. Script includes `RoadmapUtil`, `Roadmap2DUtil`, `RoadmapConfig`, `RoadmapItems`, `RoadmapCommonUtil`.

## Example

Guided board *Example Network Incidents* on `incident`, filter assignment group *Example Network Group* and active, Lane Field State, Swimlane Field Assigned to, lane limit 5 on *In Progress*; timeline *Example Change Calendar* on `change_request`, relationship field Assignment group, panel date Planned start date.

## Related

- [[Adoption Services, Boards and Legacy UI Tools]] · [[Core UI Lists, Forms and Related Lists]] · [[Core UI Navigation, Settings and Common Elements]] · [[SLA Definitions and Task SLAs]]
