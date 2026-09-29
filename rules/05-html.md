---
trigger: glob
globs: "*.html"
description: "HTML5 standards: semantic markup, accessibility (a11y), clean separation of concerns, and template reuse"
---

# 🌐 HTML5 & Markup Standards

---

## 1. Structural Semantics

- **Semantic Tags:** Use `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>`.
- **Restricted `<div>` and `<span>`:** Use only as CSS layout wrappers (flex/grid containers) when no semantic element applies.
- **Heading Hierarchy:** Exactly one `<h1>` per page. Sub-headings `<h2>` through `<h6>` must follow a strict non-skipping hierarchy.

---

## 2. Separation of Concerns: `id`, `class`, `data-*`

- **The `id` Attribute:** Reserved exclusively for JavaScript hooks, form label bindings (`for="input-id"`), and anchor targets. Never use `id` for CSS styling.
- **The `class` Attribute:** Used exclusively for CSS styling and visual state modifiers.
- **The `data-*` Attributes:** For passing state and parameters to JavaScript (`data-state="active"`, `data-user-id="123"`). Do not encode state in class names.

---

## 3. No Inline Code

- **No Inline Styles:** The `style="..."` attribute is forbidden (except for dynamic runtime transforms computed in JS, e.g., `element.style.transform = ...`).
- **No Inline Scripts:** `<script>` tags without `src` and inline event handlers (`onclick="..."`) are forbidden. Use `<script type="module" src="...">`.

---

## 4. Templating & Component Reusability

- **The `<template>` Element:** Reusable dynamic HTML snippets (modals, catalog cards, table rows) must be defined once inside `<template id="...">` and cloned via JS.

---

## 5. Accessibility (a11y)

- **Icon-Only Buttons:** Buttons containing only icons must have an explicit `aria-label="Description of action"`.
- **Images:** Mandatory `alt` attribute (empty `alt=""` only for purely decorative graphics).
- **Forms:** Every form input must have an associated `<label>` or `aria-labelledby`.
- **Custom Interactive Widgets:** Custom components must define appropriate `role` and state attributes (`aria-expanded`, `aria-hidden`, `aria-selected`).

---

## 6. Formatting & Cleanliness

- **Attribute Order:** Standard order: `id` → `class` → `data-*` → `type` / `name` / `value` → `aria-*` / `role`.
- **Quotes:** Double quotes for all attribute values.
- **Spacing:** `<br>` tags are forbidden for vertical spacing. Use CSS margins/padding/gap.
- **Large Sections:** Divide sections > 100 lines with structured comments:
  ```html
  <!-- ==================== SECTION: METRICS PANEL ==================== -->
  ```
