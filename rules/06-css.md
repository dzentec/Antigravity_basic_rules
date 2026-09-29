---
trigger: glob
globs: "*.css"
description: "CSS3 & styling standards: design tokens in :root, selector nesting limits, utility classes, and @layer cascading"
---

# 🎨 CSS3 & Styling Standards

---

## 1. Design Tokens & Variables

- **Centralized in `:root`:** Palette colors, spacing scales, border radii, typography tokens, and shadows must be defined exclusively via CSS custom properties:
  ```css
  :root {
    --color-bg-primary: #0d1117;
    --color-text-main: #f0f6fc;
    --color-accent: #2f81f7;
    --space-xs: 0.25rem;
    --space-md: 1rem;
    --radius-sm: 4px;
    --radius-md: 8px;
    --shadow-subtle: 0 1px 3px rgba(0, 0, 0, 0.12);
  }
  ```
- **No Raw Magic Values:** Direct use of arbitrary HEX/RGB codes and unscaled dimensions in rule bodies is forbidden.

---

## 2. Measurement Units

- **Typography & Spacing:** Use `rem` for responsive and scalable UI elements.
- **Borders & Thin Lines:** Use `px` for `border: 1px solid ...` and hairline dividers.
- **The `em` Unit:** Avoid `em` except for context-scaling icons relative to parent text sizes.

---

## 3. Selectors & Specificity

- **Nesting Limit:** Maximum 3 levels of nesting (e.g., `.card .header .title`). Long chains like `.a .b .c .d .e` are forbidden.
- **No `!important`:** `!important` is forbidden (allowed only to override unmodifiable third-party CSS libraries, with an explanatory comment).
- **Naming Conventions:** Use flat BEM-like classes (`.btn`, `.btn--primary`, `.card__header`) or reusable utility classes.

---

## 4. Reusability & Component Patterns

- **Base Classes + Modifiers:** Establish common base styles (`.card`, `.btn`, `.panel`, `.badge`). Never duplicate `background + border + border-radius + padding` across disconnected selectors.
- **Visual Utilities:** Extract shared effects (glows, glassmorphism, scrollbars) into utility classes (`.glow-accent`, `.custom-scrollbar`, `.glass-panel`).
- **Scrollbars:** Define custom scrollbar styling once globally or via a utility class.

---

## 5. Organization & Modularity

- **Media Queries:** Group responsive rules at the end of the file or extract to `responsive.css`. Do not scatter isolated `@media` blocks arbitrarily.
- **File Decomposition (> 1000 lines):** Split large stylesheets into focused modules:
  - `tokens.css` (variables and theme tokens)
  - `layout.css` (grid, flex containers, header, footer)
  - `components.css` (buttons, forms, cards, modals)
- **Cascade Layers (`@layer`):** When supported, use `@layer base, layout, components, utilities;` for predictable specificity.
- **Section Dividers:**
  ```css
  /* ==========================================================================
     CARD COMPONENT
     ========================================================================== */
  ```
