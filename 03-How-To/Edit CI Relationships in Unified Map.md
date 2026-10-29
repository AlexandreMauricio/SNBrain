---
type: how-to
tags: [how-to, cmdb, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Unified Map > Editing a map, Add a CI to a map, Remove a CI, Update a connection, Delete a connection (read in full through the docs site API 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/unified-map/unified-map-editing-map.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Edit CI Relationships in Unified Map

**Goal:** create, change or delete CI relationships graphically with the Unified Map editor.
**Prerequisites:** role `sn_cmdb_editor` or `sn_cmdb_admin` (the *Remove a CI* page says `admin`: discrepancy in the docs).
**Navigation:** All > CMDB Workspace > Unified Map, or **Open Map** on the CI

Background: [[Unified Map]], [[CI Relationships]]. The classic alternative: [[Create or Delete a CI Relationship]].

## Steps

1. Open the map on the CI to work on. Reduce **Levels** and use filters so only the CIs you need are shown.
2. Select the **edit map** icon. A thick blue outline means the editor is on; related items and badges are hidden while editing.
3. **Add a CI** (one at a time, existing CIs only): right-click empty space > *Add CI*, or the *Add CI* icon. Pick the class, build a filter, select one CI (optionally save the filter for later).
   - If it is already connected to something on the map: **Add to map**.
   - If not: **Add to map and connect**; the *Manage connection* panel opens.
4. **Create a connection**: right-click a CI > *Connect to*, or select a CI and the *Manage connection* icon. Set **Source CI** (parent) and **Target CI** (child) (swap icon to reverse), tick **Show suggested relationships**, choose the **Relationship type** (e.g. *Contains::Contained by*), **Create connection**.
5. **Change a connection**: select the line > *Manage connection*, or the CI > *Attributes* > *Change* on a connection box; adjust, **Change**.
6. **Delete**: a single line > *Delete* (Attributes panel or right-click); selected connections of a CI from its editing panel; all of a CI's connections with **Remove CI**. A CI added in this session and not yet saved can be removed (hidden) with *Remove*.
7. **Save**. Use the reset icon to discard all unsaved changes. **Exit** to get the timeline, search and filters back.

## Result / how to check it worked

New or changed rows exist in CI Relationship (`cmdb_rel_ci`) and show as solid lines. Deleted relationships are gone; CIs whose last connection was removed disappear from the map but their CI records remain.

## Example

Home node *Example App Server*. Add the CI *example-war-01* with **Add to map and connect**, source *Example Tomcat*, target *example-war-01*, type *Contains::Contained by*, **Create connection**, **Save**. Then delete the old *Runs on::Runs* line to *example-host-old*, **Save**.

## Tables / fields involved

- CI Relationship (`cmdb_rel_ci`; the docs also write `cmdb_ci_rel` on these pages, a typo), Relationship Type (`cmdb_rel_type`)

## Gotchas

- An added CI is saved to the map only if it has a path (direct or indirect) to the home node.
- Deleting connections can leave an orphan CI: saving warns. A CI cut off from the home node, with everything downstream of it (an *island branch*), is hidden after saving, with its downstream edits saved.
- Not possible here: editing service instances, endpoint CIs, deleting reference or endpoint connections (or removing a CI that has them), changing the applicative flow relationship type, creating or deleting CI records.
- Greyed-out connections are not editable.
