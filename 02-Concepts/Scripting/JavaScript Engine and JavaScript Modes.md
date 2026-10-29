---
type: concept
tags: [concept, scripting, javascript, release-specific]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > Write server-side scripts, topics "JavaScript engine on the platform", "JavaScript modes", "Considerations for switching JavaScript modes", "Set the JavaScript mode for an application", "Turn on ECMAScript 2021 (ES12) mode for a script", "JavaScript engine feature support", "Updates to the JavaScript engine in Brazil", "Using regular expressions in server-side scripts", and Debug scripts > "Packages Call Removal Tool", https://www.servicenow.com/docs/r/api-reference/scripts/c_JS_engine_upgrade.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# JavaScript engine and JavaScript modes

**In one line:** server scripts run on ServiceNow's fork of Mozilla Rhino, in one of three modes per application (ECMAScript 2021 (ES12), ES5 Standards, Compatibility); the mode decides which modern syntax works and how strict the engine is.

## Modes

| Mode | Default for | Supports | Notes |
|---|---|---|---|
| **ECMAScript 2021 (ES12)** | new scoped apps; **every new script** since Xanadu, whatever the app mode | a subset of ES2021 and some ES2022: `let`/`const`, arrow functions, classes, template literals, destructuring, default and rest parameters, `for...of`, Map/Set, optional chaining `?.`, nullish `??`, spread | not available app-wide for **global** apps, only per script; drops pre-Tokyo legacy behaviours |
| **ES5 Standards** | new global apps | ES5: `"use strict"`, accessors, property attributes, newer Array and Date methods, native JSON, libraries such as lodash and moment | drops pre-Helsinki legacy behaviours |
| **Compatibility** | scripts written before ES5 mode existed | legacy behaviour; `JSON.stringify`/`parse` are native, `new JSON().encode()/decode()` kept for legacy use | no third-party libraries |

- Set per application: `sys_app` record > **JavaScript Mode** (delegated developer with full access, or admin), or in ServiceNow Studio app settings.
- Per script: **Turn on ECMAScript 2021 (ES12) mode** on the script form (read-only when the app is already ES12).
- Scoped apps can run ES12 since Tokyo. No plugin or property is needed for the engine itself.

## What changes when you switch

| Behaviour | Compatibility | ES5 | ES12 |
|---|---|---|---|
| `arguments` reflects parameter changes | yes | no (strict mode) | no |
| Missing semicolons | auto-inserted, sometimes wrongly | syntax error | syntax error |
| Calling a missing function | ReferenceError | TypeError | EcmaError |
| Missing property | `undefined` | `undefined` | `undefined` |
| Reserved word as property (`obj.for`) | not allowed | allowed per the table (its summary says not) | allowed |
| `let`, `yield` as identifiers | allowed | `let` keyword, `yield` reserved in strict | both keywords |
| Numeric literals | decimal, hex | stricter | adds `0b`, `0o`, BigInt `123n` |
| Line continuations / comments | page example: all three calls run | only the first call runs | as ES5 |
| Boolean primitives | overridable | better protected | as ES5; test `x instanceof Boolean ? x.valueOf() : x` |

Test before switching an existing app: error messages and some results change.

## Feature support worth knowing (Brazil table)

Three labels: **Supported**, **Not Supported** (not validated), **Disallowed** (error, conflicts with the platform model or is a security / performance risk).

- Supported in ES12 mode, not in ES5 mode: `Promise` with `async`/`await` and `.finally`, `Promise.any` / `allSettled` / `withResolvers` / `try`, `Array.prototype.at`, `flat`/`flatMap`, `Object.hasOwn`, `Object.fromEntries`/`entries`/`values`, `padStart`/`padEnd`, `matchAll`, BigInt, `globalThis`, logical assignment `||=` `&&=` `??=`, numeric separators, regex named groups, lookbehind and `s` flag, `Error.cause`, public and static class fields, static init blocks, the new `Set` methods (`union`, `intersection`...).
- Supported in both modes: `findLast`, `toSorted` / `toReversed` / `toSpliced` / `with`, `replaceAll`, `Math.f16round`, `Error.isError`.
- Disallowed everywhere: async generators and `for await`, `SharedArrayBuffer` and `Atomics`, `WeakRef` / `FinalizationRegistry`, template literal revision, well-formed `JSON.stringify`.
- Not supported even in ES12: private instance fields and methods, regex `d` flag. Test ES2022 features thoroughly before production.
- Brazil engine update: Rhino pull requests merged for inferred function names, object spread, `__proto__` updates, ArrayBuffer transfer, ISO date millisecond rounding, argument evaluation order fixes, and more.

## Regular expressions

Server regexes use an enhanced engine; flag **`j`** (e.g. `/ex(am)ple/j` or with inline flags `/(?ims).../j`) runs the pattern with Java's engine (lookbehind and other Java-only syntax). `SNC.Regex` is not available in scoped apps: use standard JavaScript regexes.

## Packages calls

Direct Java calls such as `Packages.com.glide.monitor.AbstractBucketCollector` will be blocked in a future release. The **Packages Call Removal Tool** plugin (admin) finds them (**Find Packages Fields**, **Find Packages Calls**) and proposes replacements in **Packages Call Items** (states Proposed, Error, Rejected, Completed, Canceled). Naming rule: take the third package term (glide, snc, glideapp), capitalise it and prefix the class name: `GlideAbstractBucketCollector`, `SncBaselineCMDB`. Many of these Glide classes are undocumented and unsupported for customer use. Capture the changes in an update set.

## Related

- [[Scripting Overview - Script Types and Where They Run]] · [[Script Sandbox and Guarded Script]] · [[Application Scope and Namespace Identifiers]]
