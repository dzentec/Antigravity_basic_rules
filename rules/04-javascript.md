---
trigger: glob
globs: "*.js, *.mjs"
description: "Modern JavaScript (ES6+) standards: ES modules, immutability, async/await, DOM safety, and constant freezing"
---

# 🟨 JavaScript Standards (ES6+)

---

## 1. Module System & Scope

- **Strictly ES Modules:** Use standard `import` and `export` statements.
- **No Global Scope Pollution:** Never attach properties to `window.*` or `globalThis.*`.
- **Variables:**
  - `const` — Default for all variable declarations.
  - `let` — Only when the value is explicitly reassigned.
  - `var` — Strictly forbidden.

---

## 2. Comparisons & Type Safety

- **Strict Equality:** Always use `===` and `!==`.
- **No Loose Comparisons:** `==` and `!=` are forbidden to prevent unexpected type coercion.
- **Optional Chaining & Nullish Coalescing:** Utilize `obj?.prop` and `val ?? defaultValue`.

---

## 3. Asynchrony & Error Handling

- **Async / Await:** Prefer `async/await` syntax over complex `.then()` chains.
- **Unhandled Promises:** Floating promises must be handled with `.catch(err => logger.error(err))`.
- **DOM Event Isolation:** Asynchronous event callbacks should be wrapped in `try / catch` blocks.

---

## 4. Function Complexity & Handler Limits

- **Function > 40 lines** — Signal for decomposition.
- **Event Handlers (`handle*`) > 80 lines** — Forbidden. Handlers should only extract parameters and delegate execution to domain services.

---

## 5. DOM Manipulation & Templating

- **Safe HTML Practices:**
  - Setting raw HTML blobs via `innerHTML = '<div>...</div>'` is forbidden.
  - Use HTML `<template>` elements or `document.createElement()`.
  - Simple scalar values in `innerHTML` must be properly sanitized.
- **DOM Query Caching:**
  - Repeated calls to `document.getElementById` or `document.querySelector` inside loops or `requestAnimationFrame` callbacks are prohibited.
  - Cache DOM references during module/component initialization.

---

## 6. Constants & Configurations

- **Naming:** `SCREAMING_SNAKE_CASE` for module-level constants.
- **Mutation Protection:** Use `Object.freeze()` for configuration dictionaries and enum objects.
- **JSDoc:** Annotate public functions with parameter types and descriptions:
  ```javascript
  /**
   * Computes the target buffer size.
   * @param {number} baseSizeMb - Base buffer size in MB.
   * @param {number} multiplier - Scaling multiplier.
   * @returns {number} Buffer size in bytes.
   */
  ```
