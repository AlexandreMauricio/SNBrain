---
type: concept
tags: [concept, api, integrations, scripting, schema]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Web services > Additional integration resources > Query record data using the GraphQL API framework (overview), GraphQL system properties, read 2026-10-30. Create schema steps, GraphQL Explorer and component query pages listed, not read in detail. https://www.servicenow.com/docs/r/api-reference/web-services/scripted-graph-ql.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# GraphQL API Framework

**In one line:** define a custom GraphQL API over record data, for Next Experience components or third parties, instead of many REST endpoints.

From the Brazil docs; not tested. Scripts are server side, in the schema's scope.

| Part | Where |
|---|---|
| **Schema (SDL)** | **Schema** on GraphQL Scripted Schemas (`sys_graphql_schema`); Query and Mutation only |
| **Resolvers** | GraphQL Scripted Resolvers related list; data per field |
| **Typeresolvers** | for interfaces and unions |
| **Resolver mappings** | link resolvers to fields |

**Not supported:** subscriptions, custom scalars. Introspection is off by default.

Queries need both namespaces: `query { x_example_app { example_schema { findAll { name } } } }`.

`env.getArguments()`, `env.getSource()` in resolvers; `getObject()`, `getTypeName()` in typeresolvers. Directives: `@source`; `@defer` for slow fields (client must accept `multipart/mixed`; test performance). Demo plugin `com.glide.graphql.framework.demo`.

Properties (**System Web Services > GraphQL > Properties**): `glide.graphql.introspection_enabled` (needs `graphql_schema_admin`), `glide.graphql.glide_record_schema.introspection_enabled`, `glide.graphql.debug`, all false.

## Example

Application namespace `x_example_app`, schema namespace `example_schema`, type `ExampleCase`, resolver with `GlideRecordSecure` by id, tested in GraphQL Explorer.

## Related

- [[REST API Fundamentals]] · [[Scripted REST APIs]]
