# Rules Bundle

## .agents/rules/00-research-protocol.md
````markdown
---
trigger: always_on
description: "Codebase research protocol before changes: dependency graph, blast radius estimation, grep fallback, and verification"
---

# 🔍 Codebase Research Protocol

Before making ANY code changes, the agent MUST map dependencies and assess the blast radius.

---

## 1. Research Priority

When locating and analyzing dependencies, follow this strict priority order:
1. **MCP Knowledge Graph** (if available in the environment, e.g., `codebase-memory-mcp` or equivalent) — primary and preferred tool for structural discovery and relationship mapping.
2. **Grep / Ripgrep** — degraded mode, used when knowledge graph tools are unavailable in the current environment, or for discovering unstructured data (string literals, configs, environment variables).
3. **Direct File Inspection** — targeted reading, after localizing the target via graph or grep.

---

## 2. Working via Knowledge Graph (When MCP Tools are Present)

### 2.1. Graph Tool Availability Check
Before initiating research, check for graph tool responsiveness:
- If graph tools are active (e.g., `search_graph`, `trace_path`, `query_graph`) — proceed in standard graph mode.
- If graph tools are unregistered or return connection errors — record **degraded mode** and fall back seamlessly to grep/ripgrep.

### 2.2. Symbol & Module Investigation Flow
1. **Localization:** Find the definition by name or pattern (e.g., `search_graph(name_pattern="<SymbolName>")`).
2. **Inbound Callers (who depends on this):** Trace incoming consumers (e.g., `trace_path(..., direction="inbound", depth=3)`).
3. **Outbound Dependencies (what this depends on):** Trace outgoing calls (e.g., `trace_path(..., direction="outbound", depth=3)`).
4. **Source Implementation:** Read targeted code slices (e.g., `get_code_snippet(...)`).

### 2.3. Blast Radius Assessment
- **Inbound > 10:** Critical node / public contract. Any signature modification is a breaking change requiring explicit planning and atomic updates across all consumers.
- **Outbound > 5:** Hub node. Refactoring or decomposing requires a structured step-by-step plan.
- **Circular Dependencies:** Record immediately if detected. Do NOT attempt to fix circular dependencies casually as part of an unrelated task.

---

## 3. Degraded Mode (Fallback to Grep)

Used when graph tools are unavailable or when inspecting non-code assets:
- Craft narrow, highly specific search queries (filtering by file extensions).
- For files exceeding 400 lines, use line-range queries or chunked reading.
- Record `Research Mode: degraded mode (grep)` in the change report.

---

## 4. Post-Change Verification

After making changes to source code:
1. Re-verify inbound callers (via graph or symbol references) for all modified functions and classes.
2. Ensure signatures, return types, and schemas remain consistent across all consumers.
3. Run relevant test suites covering all affected modules.

---

## 5. Post-Change Report Format

Every code modification must conclude with a structured report:

```markdown
### Changes Made
- File, line range, target symbol/module

### Research Mode
- Graph Available: yes / no (degraded mode)

### Dependency Analysis
- Inbound: <list of callers / count>
- Outbound: <list of dependencies>
- Circular Dependencies: none / detected (<details>)

### Blast Radius
- Affected Modules Count: <number>
- Breaking Change: no / yes (<rationale>)

### Constants & Security
- Constants defined at module top / config: yes
- Secrets / hardcoded credentials: none
- Magic values: none

### Tests
- Command: `<test command>`, Status: pass / fail

### Quality Control (No-Crutches)
- Rule violations / temporary workarounds: none
```
````

## .agents/rules/01-architecture.md
````markdown
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
````

## .agents/rules/02-no-crutches.md
````markdown
---
trigger: always_on
description: "Prohibited anti-patterns and security invariants: strict code hygiene, schema validation, and vulnerability prevention"
---

# 🚫 Prohibitions & Security Invariants (No Crutches)

Encountering or attempting to introduce any of the patterns listed below is grounds for **immediate generation stoppage** and escalation to the user.

---

## 1. Architectural Prohibitions

1. **Global Variables in JS:**
   - ❌ `window.X = ...`, `global.X = ...`
   - ✅ Standard ES Modules (`export` / `import`).
2. **Silent Exception Swallowing:**
   - ❌ `try: ... except Exception: pass`, `catch (e) {}`
   - ✅ Catch specific exception types, log context, and handle cleanly.
3. **Hardcoded Data Blobs:**
   - ❌ Embedding static dictionaries/arrays > 20 lines in source files.
   - ✅ External configuration files (`JSON`, `YAML`, `TOML`).
4. **Manual Type Checking:**
   - ❌ Cascades of `if not isinstance(...)` or `typeof x === ...`.
   - ✅ Declarative schema validation (Pydantic in Python, Zod / Yup in JS/TS).
5. **Code Duplication:**
   - ❌ Duplicating logic blocks > 5 lines across multiple files.
   - ✅ Extracting to shared helper utilities in `shared/` or `lib/`.
6. **Circular & Package Root Imports:**
   - ❌ Importing from own `__init__.py` or `index.js` within the same package.
   - ✅ Direct imports from explicit child modules.
7. **Unjustified Type Ignore Directives:**
   - ❌ Unexplained `# type: ignore`, `@ts-ignore`, `eslint-disable`.
   - ✅ Proper type definitions or explicit comments documenting why the ignore is needed.
8. **Anonymous / Undated TODOs:**
   - ❌ Comments like `// TODO: fix this`, `# TODO: refactor`.
   - ✅ Actionable TODOs with author, date, and task reference (`TODO(username, 2026-10-01): task-id`).
9. **Magic Literals in Expressions:**
   - ❌ Raw numbers and strings in conditional branches.
   - ✅ Extracted module constants.
10. **Undocumented Constants:**
    - ❌ Ambiguous constant values without docstrings or comments.
    - ✅ JSDoc / docstrings explaining meaning and units.
11. **Dead / Commented-Out Code:**
    - ❌ Leaving commented-out legacy code blocks.
    - ✅ Complete deletion — Git tracks history.

---

## 2. Security Invariants

12. **Secrets and Credentials in Code:**
    - ❌ Hardcoded API keys, tokens, passwords (`API_KEY = "sk-..."`, `SECRET = "..."`).
    - ✅ Read strictly from environment variables (`os.environ`, `process.env`), `.env` files (in `.gitignore`), or Secret Vaults.
13. **Query & Command Injections (SQL / Command Injection):**
    - ❌ Raw string formatting for queries or shell commands (`f"SELECT * FROM users WHERE id = '{user_id}'"`).
    - ✅ Parameterized queries (prepared statements) or ORM query builders.
14. **Dynamic Code Execution (Code Injection):**
    - ❌ `eval()`, `exec()` in Python, `eval()`, `new Function(...)` in JS.
    - ✅ Safe deserializers (`json.loads`, `ast.literal_eval`, `JSON.parse`).
15. **Unsafe HTML Rendering (XSS):**
    - ❌ Raw user input in `dangerouslySetInnerHTML` or `innerHTML = untrusted_str`.
    - ✅ Safe DOM methods (`textContent`), template sanitization, or DOMPurify.
16. **Unsafe Process Spawning:**
    - ❌ `subprocess.run(f"cmd {user_input}", shell=True)` or `child_process.exec(...)`.
    - ✅ Arguments passed strictly as a list with shell disabled: `subprocess.run(["cmd", arg1, arg2], shell=False)`, `child_process.execFile(...)`.
17. **Unsafe Deserialization (RCE):**
    - ❌ `pickle.loads()` / `pickle.load()`, `_pickle`, `shelve` on untrusted user or network input.
    - ❌ `yaml.load()` without safe loader (`yaml.load(data, Loader=yaml.Loader)`).
    - ✅ `json.loads()` for JSON.
    - ✅ `yaml.safe_load()` for YAML.
    - ✅ `pydantic` / `msgspec` for validated structured schemas.
18. **Directory Escape (Path Traversal):**
    - ❌ `os.path.join(base_dir, user_filename)` or `Path(base_dir) / user_input` without containment validation.
    - ✅ `Path.resolve()` with mandatory containment checks:
      ```python
      target = (base_dir / user_input).resolve()
      if not target.is_relative_to(base_dir.resolve()):
          raise PermissionError("Path traversal detected")
      ```
    - ✅ `Path(user_input).name` to safely extract only the filename.

---

## 3. Escalation Protocol

If a task cannot be achieved without violating an architectural rule or security invariant, the agent **MUST halt generation** and notify the user:

> ⚠️ **Architectural Control Alert:**
> "Resolving this task cleanly requires structural changes in module `<module_name>`. Applying a quick workaround would violate rule `<rule_number>`. Recommend performing refactoring `<refactoring_details>` before implementing this feature."
````

## .agents/rules/03-python.md
````markdown
---
trigger: glob
globs: "*.py, *.pyi"
description: "Python 3.11+ development standards: strict type annotations, Pydantic, structured logging, safe exceptions, and constant immutability"
---

# 🐍 Python Standards (3.11+)

---

## 1. Typing & Signatures

- **Mandatory Typing:** All function/method arguments and return values must be explicitly type-annotated.
- **Postponed Evaluation:** Always place at the very top of each file:
  ```python
  from __future__ import annotations
  ```
- **Modern Syntax:** Use built-in generics (`list[str]`, `dict[str, int]`, `tuple[int, ...]`) and union operators `X | Y` instead of `Optional[X]` and `Union[X, Y]`.
- **Protocols & Interfaces:** For structural subtyping (duck-typing), use `typing.Protocol` instead of inheritance from heavy abstract base classes.

---

## 2. Data Validation & System Boundaries

- **Declarative Schemas:** At I/O boundaries (APIs, CLI arguments, config parsing, file reading), validate payloads using Pydantic models (`BaseModel`, `Field`) or `msgspec`.
- **No Manual Type Checks:** Avoid cascading `if not isinstance(val, int): raise ValueError()`. Parsing and conversion should be handled declaratively.
- **Safe Deserialization:** Use `yaml.safe_load()` or `json.loads()`. Never use `pickle` on untrusted input.

---

## 3. Logging & Diagnostics

- **Module-Level Loggers:**
  ```python
  import logging
  logger = logging.getLogger(__name__)
  ```
- **No `print()` Calls:** `print()` is forbidden in production code (allowed only in transient scratch scripts and CLI output formatters).
- **Structured Context:** Pass structured parameters via `extra` or logging formatters:
  ```python
  logger.info("Processing request started", extra={"request_id": req_id})
  ```

---

## 4. Exception Handling

- **Specific Exceptions:** Catch only expected exception types (`KeyError`, `ValueError`, `FileNotFoundError`).
- **No Swallowing:** `except Exception: pass` is strictly prohibited.
- **Exception Chaining:** When re-raising or wrapping, preserve causality: `raise CustomDomainError("details") from err`.
- **Traceback Logging:** For unexpected errors, always use `logger.exception("Unexpected error occurred: %s", err)`.

---

## 5. Default Arguments & Mutability

- **No Mutable Defaults:** `def process(items: list = [])` is strictly forbidden.
- **Idiomatic `None` Initialization:**
  ```python
  def process(items: list[str] | None = None) -> None:
      target_items = items if items is not None else []
  ```

---

## 6. Constants & Formatting

- **Immutable Constants:**
  ```python
  from typing import Final

  DEFAULT_TIMEOUT_S: Final[float] = 30.0
  MAX_RETRY_ATTEMPTS: Final[int] = 3
  ```
- **F-Strings:** Use f-strings (`f"Result: {value}"`). `%` and `.format()` formatting are forbidden.
- **Absolute Imports:** Use absolute package imports (`from app.services import core`) rather than deep relative imports (`from ...services import core`).
- **Code Style:** Comply with `ruff` / `black` / `isort` configurations.
````

## .agents/rules/04-javascript.md
````markdown
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
````

## .agents/rules/05-html.md
````markdown
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
````

## .agents/rules/06-css.md
````markdown
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
````

## .agents/rules/07-tests.md
````markdown
---
trigger: glob
globs: "test_*.py, *_test.py, conftest.py, *.test.js, *.spec.js"
description: "Unit and integration testing standards: AAA structure, hermetic isolation, parameterization, and 5-point boundary coverage"
---

# 🧪 Testing & Quality Assurance Standards

---

## 1. Structure & Naming Conventions

- **Single Assertion Focus:** Each test case verifies exactly one distinct behavior or expectation.
- **Naming Pattern:** Clearly state what is being tested: `test_<target>_<condition>_<expected_result>` (e.g., `test_parse_config_when_file_missing_raises_not_found`).
- **AAA Pattern (Arrange-Act-Assert):**
  - Explicitly partition tests into three sections: setup (Arrange), execution (Act), verification (Assert).
  - Separate blocks with single blank lines.

---

## 2. Test Hermeticity & Isolation

- **Hermetic Tests:** Unit tests must not depend on network calls, global system state, or external disk paths (use `tmp_path` fixtures).
- **Mocks on Boundaries Only:** Mock only external I/O boundaries (HTTP, DB connections, system clocks, random generators). Never mock internal private methods.
- **No Sleep Calls:** `time.sleep()` and `setTimeout` are forbidden in tests. Use `freezegun` / `freeze_time` or mock clock timers.
- **Execution Independence:** Tests must be idempotent and pass in any execution order.

---

## 3. 5-Point Boundary Matrix (Edge Cases)

When testing domain logic, parsers, and validators, always cover:
1. **Happy Path:** Standard valid input scenario.
2. **Minimum Boundary:** Zero, empty string `""`, empty list `[]`, lower limit.
3. **Maximum Boundary:** Upper limit, large buffer, max capacity.
4. **Invalid Types / Formats:** Malformed syntax, unexpected types.
5. **Null / None Scenarios:** Missing values (`None`, `null`, `undefined`).

---

## 4. Parameterization & Fixtures

- **Data-Driven Tests:** For testing multiple inputs/outputs against the same logic, use `@pytest.mark.parametrize` (Python) or `test.each` (JS) instead of copying test bodies.
- **Shared Fixtures:** Place reusable fixture factories in `conftest.py` or test helper modules.

---

## 5. Bugfix-First Protocol

When fixing defects:
1. Write a failing test reproducing the reported bug.
2. Apply the minimal code fix.
3. Verify that the new test passes and no regression was introduced.
````

## .agents/rules/08-commits.md
````markdown
---
trigger: model_decision
description: "Git commit standards: Conventional Commits, atomicity, focus on the rationale (WHY), and git repository hygiene"
---

# 📦 Git Commit Standards & Repository Hygiene

---

## 1. Atomicity & Frequency

- **One Commit = One Logical Change:** Never mix new feature logic with unrelated refactoring or cleanup.
- **Green Builds:** Every commit must leave the repository in a compiling, passing test state.
- **Separate Refactoring:** Structural changes and renames must be committed separately from functional feature changes.
- **Pre-Commit Review:** Always inspect staged changes via `git diff --staged` before committing.

---

## 2. Commit Message Structure

Follow the Conventional Commits specification:

```text
<type>(<scope>): <concise description in imperative mood>

<detailed explanation of WHY the change was made>

[References: Closes #123]
```

### Commit Types:
- `feat` — New feature or capability for the user
- `fix` — Bugfix in existing functionality
- `refactor` — Code restructuring with no behavior change
- `test` — Adding or updating test suites
- `perf` — Performance optimization
- `docs` — Documentation changes only
- `chore` — Dependency updates, build configs, linters

### Formatting Rules:
1. **Title Line:** Maximum 72 characters, lowercase, imperative mood ("add", not "added" or "adds"), no trailing period.
2. **Message Body:** Focus on **WHY** the change was made (the diff shows "what").
3. **Breaking Changes:** Indicated by an exclamation mark after the type (`feat(api)!: change response envelope`) and a `BREAKING CHANGE:` section in the body.
4. **No Vague Messages:** Messages like `fix`, `wip`, `minor updates`, `cleanup` are strictly forbidden.

---

## 3. Repository Hygiene: Prohibited Junk Files

Strictly forbidden from staging or committing:
- Environment variables and secrets (`.env`, `.env.local`, `*.pem`, `credentials.json`)
- Build artifacts and caches (`__pycache__/`, `.pytest_cache/`, `dist/`, `build/`, `node_modules/`, `*.pyc`)
- Transient logs and scratch directories (`scratch/`, `*.log`, `.tmp/`)
- Local IDE configurations (`.idea/`, `.vscode/settings.json`)
````

## .agents/hooks.json
````json
{
  "graph-router": {
    "PreToolUse": [
      {
        "matcher": "grep|glob",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/graph-router.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
````

## scripts/graph-router.sh
````bash
#!/usr/bin/env bash
# ==============================================================================
# graph-router.sh: Hook script for routing search requests to MCP Graph Knowledge
# Protojson format: camelCase {"decision": "allow"}
# ==============================================================================

set -euo pipefail

LOG_DIR="validation"
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR" 2>/dev/null || true
fi
LOG_FILE="$LOG_DIR/graph-router.log"

# Read input payload from stdin if available
INPUT_PAYLOAD=$(cat || echo "{}")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date)

# Log event for diagnostic tracking
echo "[$TIMESTAMP] PreToolUse triggered for grep/glob. Payload length: ${#INPUT_PAYLOAD}" >> "$LOG_FILE" 2>/dev/null || true

# Return protojson response in camelCase format required by Antigravity v2.18+
cat <<EOF
{"decision": "allow"}
EOF
````

