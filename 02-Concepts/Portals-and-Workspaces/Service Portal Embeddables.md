---
type: concept
tags: [concept, portal, javascript, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Developing custom widgets > Embeddables in Service Portal (5 topics, updated September 2026; read 2026-11-06 through the docs site API, map 7xQNQY92V5DYmBMD7wXg9g).
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Service Portal Embeddables

**In one line:** UI Builder components placed in Service Portal pages (and external sites) and driven from a widget client script through the `spEmbeddables` AngularJS service, without rebuilding them in AngularJS.

From the Brazil docs; not tested. Pages updated September 2026, so likely new or changed in Brazil (inference). Widget basics: [[Service Portal Widget Development]]. Not the same as **Web Embeddables** sessions for external sites ([[Personal OAuth Authentication and Web Embeddables Sessions]]); how the two relate is not stated.

## Enable

Role `admin`.

1. Install plugins `com.glide.ux.embeddables` and `app-embeddables-core`.
2. Service Portal > Portals > the portal > **Enable Embeddables** (missing means the first plugin is not installed).
3. Optional: in **Embeddable Macroponents**, pick components to **preload** with the page.
4. Theme: Service Portal > Themes > CSS variables > **Matching NOW experience theme** = a UI Builder theme. Without one, the default UI Builder theme applies.

Enabling loads the **Seismic** framework and the embeddable APIs on the portal.

## spEmbeddables API (widget client controller)

| Method | Does |
|---|---|
| `init()` | starts the framework with the theme; Service Portal calls it itself |
| `getEmbeddables(tagNames)` | returns component data by tag name (promise) |
| `setEvents(element, events)` | registers handlers on the component element |
| `setProperties(element, properties)` | changes properties at runtime; the component re-renders |

## Example

```html
<!-- Widget HTML template: example-record-list is the component's tag name -->
<example-record-list data-filter-config="c.filters"></example-record-list>
```

```javascript
// Widget client controller (client)
function($scope, spEmbeddables, spUtil) {
    var c = this;
    spEmbeddables.getEmbeddables(['example-record-list']).then(function(components) {
        c.recordList = components['example-record-list'];
    });
    c.bind = function() {
        var el = document.querySelector('example-record-list');
        spEmbeddables.setEvents(el, { onSelect: function(id) { spUtil.addInfoMessage('Selected ' + id); } });
        spEmbeddables.setProperties(el, { filterConfig: 'active=true' });
    };
}
```

The docs examples write the controller as `app.controller('caseListWidget', function($scope, spEmbeddables) {...})` rather than the usual widget `function()` form; which one a widget record needs is unconfirmed.

## Related

- [[Service Portal Widget Development]] · [[Service Portal Overview and Configuration]] · [[Service Portal Widgets]]
