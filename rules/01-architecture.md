---
trigger: always_on
description: "Core architectural standards: file and function size limits, single responsibility, clean module boundaries, and constant management"
---

# 🏗️ Architectural Standards & Decomposition

These standards apply across all projects, frameworks, and programming languages.

---

## 1. Size Thresholds & Modularity

- **File > 400 lines** — Critical threshold requiring decomposition into submodules.
- **Function > 50 lines** — Must be refactored into smaller, pure helper functions.
- **Class Method > 80 lines** — Must be decomposed; delegate domain logic to separate services.
- **Constructor (`__init__` / `constructor`) > 30 lines** — Transition to factory functions or the Builder pattern.
- **Single Responsibility Principle (SRP):** Each module handles one distinct concern. If a module's purpose cannot be stated in a single noun without the conjunction "and", it must be split.

---

## 2. Package Organization & Imports

- **Package Entry Points (`__init__.py`, `index.js`):**
  - Reserved exclusively for explicit public re-exports.
  - Business logic, heavy computations, and side effects are strictly forbidden.
  - Eager circular imports are forbidden.
- **Contract & Leaf Node Isolation:**
  - Base types, schemas, DTOs, interfaces, and utilities reside in dedicated shared layers (`contracts/`, `shared/`, `types/`, `lib/`).
  - Leaf nodes in the dependency graph must never import higher-level business services.
- **Dependency Direction:**
  - Imports must flow strictly downward across abstraction layers.
  - Upward or reverse dependencies are prohibited.
  - Circular dependencies are considered design bugs.
- **No Wildcard Imports:**
  - `from module import *` and `import * as X` are prohibited. All imports must be explicit.

---

## 3. Separation of Data and Logic

- **Data is separated from executable code:**
  - Static lookup tables, fixtures, and configs exceeding 50 lines must reside in structured data files (`JSON`, `YAML`, `TOML`, `CSV`).
  - Runtime settings and environment configurations belong in config files/env vars, never hardcoded in logic modules.

---

## 4. Public API Stability

- Signatures of public functions, methods, and endpoints must maintain backward compatibility.
- When public contracts must change:
  1. Locate all consumers via graph or search tools.
  2. Implement deprecation layers or update all callers atomically within a single change.

---

## 5. Constants Management

- All configurable parameters must be declared at the top of the module with explanatory comments.
- **No Magic Numbers:** Numeric or string literals in logic (except `0`, `1`, `-1`, `2`, `100%`, `""`) must be declared as named constants.
- **Units in Constant Names:** Time, size, and rate constants must explicitly include units in their names (`TIMEOUT_S`, `BUFFER_SIZE_KB`, `DELAY_MS`, `MAX_RETRIES_COUNT`).
