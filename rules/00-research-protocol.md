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
