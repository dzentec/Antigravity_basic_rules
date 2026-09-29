# 📊 Rules Sources & Mapping Report

This document records the lineage, origin, and design rationale for each rule in package v1.0.2.

---

## 00-research-protocol.md
- **Base:** Universal architectural standards for dependency discovery and MCP knowledge graphs.
- **Derived from `catyyy/everything-antigravity/rules/architect.md`:**
  - Generalized dependency graph traversal (`inbound`/`outbound`/`blast radius`).
  - Blast radius risk thresholds (Inbound > 10, Outbound > 5).
- **Derived from `KeithTorda/gravirules`:**
  - Degraded mode fallback to grep when MCP servers are unavailable.
- **Custom Additions:**
  - Vendor-agnostic tool signatures.
  - Standardized post-change report template with security and constant checks.

---

## 01-architecture.md
- **Base:** Core modularity and Clean Architecture principles.
- **Derived from `fjb040911/ai-rules/cli/src/inspect-logic.js`:**
  - Quantitative size limits: file ≤ 400 lines, function ≤ 50 lines, method ≤ 80 lines.
- **Derived from `modem-dev/ossrules/AGENTS.md`:**
  - Single Responsibility Principle (SRP) naming rule.
  - Leaf contract isolation in `contracts/` and `shared/`.
- **Custom Additions:**
  - Standardized constant naming with explicit units (`_MS`, `_S`, `_KB`).

---

## 02-no-crutches.md
- **Base:** Prohibitions registry and Security Invariants.
- **Derived from `lifedever/claude-rules/base/core.md`:**
  - Silent exception swallowing ban (`except Exception: pass`), `# type: ignore` justification requirement.
- **Derived from `awesome-ai-rules`:**
  - Global `window.*` mutation ban in JS, large data hardcoding ban (> 20 lines).
- **Security Invariants (v1.0.2):**
  - Secrets/credentials in source code ban (env/Vault only).
  - Raw SQL and command string interpolation ban (parameterized only).
  - Dynamic code evaluation ban (`eval()`, `exec()`, `new Function()`).
  - XSS ban (`dangerouslySetInnerHTML`, raw `innerHTML`).
  - Process spawning with `shell=True` ban.
  - Unsafe deserialization ban (`pickle.load()`, unsafe `yaml.load()`).
  - Path traversal vulnerability ban (`Path.resolve().is_relative_to()`, `Path.name`).
- **Custom Additions:**
  - Structured architectural escalation template.

---

## 03-python.md
- **Base:** Python 3.11+ Best Practices.
- **Derived from `Lay4U/awesome-ai-rules/rules/cursor/python/`:**
  - `from __future__ import annotations`, built-in generics `list[str]`, union operator `|`.
  - Boundary validation via Pydantic.
- **Derived from `lifedever/claude-rules/languages/python.md`:**
  - Structural subtyping via `typing.Protocol`.
  - Module logging via `logging.getLogger(__name__)`.
- **Custom Additions:**
  - Strict immutability with `typing.Final`.
  - Mandatory `logger.exception()` for unexpected exceptions and safe YAML parsing.

---

## 04-javascript.md
- **Base:** Modern ES6+ module standards.
- **Derived from `lifedever/claude-rules/languages/javascript.md`:**
  - Ban `var`, prefer `const`, strict equality `===`.
- **Derived from `awesome-ai-rules`:**
  - Configuration dictionary protection via `Object.freeze()`.
- **Custom Additions:**
  - Safe templating via HTML `<template>` instead of `innerHTML`.
  - Handler complexity limit (`handle*` ≤ 80 lines).

---

## 05-html.md
- **Base:** HTML5 Specification and W3C A11y.
- **Derived from `lifedever/claude-rules/languages/html.md`:**
  - Semantic container elements (`<header>`, `<main>`, `<footer>`), `aria-label` for icon buttons.
- **Custom Additions:**
  - Strict separation of `id` (JS/Hooks) vs `class` (CSS) vs `data-*` (Data state).
  - Ban `<br>` tags for spacing.

---

## 06-css.md
- **Base:** Synthesized from modern CSS3 engineering practices.
- **Core Principles:**
  - Mandatory design tokens in `:root`.
  - `rem` for spacing/typography and `px` for thin borders.
  - Max selector nesting depth ≤ 3.
  - Ban `!important` except for third-party library overrides.
  - Modularity for stylesheets > 1000 lines and `@layer` cascading.

---

## 07-tests.md
- **Base:** AAA (Arrange-Act-Assert) and TDD.
- **Derived from `sfc-gh-myoung/ai_coding_rules`:**
  - AAA test partitioning, parameterized test suites.
- **Custom Additions:**
  - 5-point boundary coverage matrix (`Happy Path`, `Min`, `Max`, `Invalid`, `Null/None`).
  - Bugfix-first protocol.

---

## 08-commits.md
- **Base:** Conventional Commits Specification v1.0.0.
- **Derived from `Lay4U/awesome-ai-rules`:**
  - Commit types (`feat`, `fix`, `refactor`, `test`, `chore`, `perf`).
- **Custom Additions:**
  - Commit body focus on "WHY" rather than "WHAT".
  - Explicit list of prohibited junk and secret files.
