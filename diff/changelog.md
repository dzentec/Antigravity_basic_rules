# 📜 Changelog

All notable changes to the Universal Antigravity Rules package will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - 2026-09-30

### Added
- **`09-api.md`:** Comprehensive REST and HTTP API design standards covering:
  - Resource URI naming conventions (kebab-case, nouns, max 3 nesting levels).
  - HTTP method & idempotency matrix (including merge-patch vs JSON patch handling).
  - HTTP status codes (2xx, 4xx, 5xx) with explicit `Location` and `Retry-After` headers.
  - Strict Request & Response DTO separation without server-generated field leakage.
  - Standardized error response envelope (`code`, `message`, `request_id`, `details`).
  - Pagination (Offset & Cursor) with server-enforced hard caps.
  - URL path versioning and RFC deprecation headers.
  - Async route handler safety, dependency injection, and worker offloading.
  - Authentication / Authorization boundary enforcement (401 vs 403, Bearer over HTTPS).
  - `Idempotency-Key` header handling and 409 conflict semantics for mutations.
  - Caching & conditional requests (`ETag`, `If-None-Match`, `Cache-Control`).
  - Rate limiting standard headers and 429 throttling mechanics.
  - Strict CORS policy (no wildcard + credentials, explicit origin allowlist).
  - Request tracing & observability (`X-Request-ID`, structured logging, latency budgets).
  - OpenAPI 3.x schema-first generation from runtime DTO models.
  - Data access patterns & N+1 query prevention.
- **Smart PreToolUse Router (`graph-router.sh` & `hooks.json`):**
  - Fail-open safety trap with guaranteed `decision: allow` on script errors.
  - Automatic session marker tracking (`/tmp/antigravity_graph_<conversationId>.marker`).
  - Gated symbol-level lookups (`^[A-Za-z_][A-Za-z0-9_.]*$`) with explicit redirection to graph tools.
  - Automatic unblocking of `grep_search` for text, logs, regexes, and post-graph secondary searches.

---

## [1.0.2] - 2026-09-29

### Added
- **`02-no-crutches.md`:**
  - **Rule 17 (Unsafe Deserialization):** Ban `pickle.load()` on untrusted input, enforce `yaml.safe_load()`, `json.loads()`, and Pydantic schemas.
  - **Rule 18 (Path Traversal):** Ban unsanitized `os.path.join()`, enforce `Path.resolve().is_relative_to(base_dir)` and `Path.name`.
- **`03-python.md`:** Synchronized safe deserialization requirements and mandatory `logger.exception()` for unexpected exceptions.
- **`pack.sh` & `pack.ps1`:** Added standalone Markdown bundling (`pack/rules-bundle.md`) and idempotent extraction.
- **Translation:** Full English translation across all rules, scripts, and documentation for maximum LLM comprehension.

---

## [1.0.1] - 2026-09-29

### Changed
- **`00-research-protocol.md`:** Generalized MCP knowledge graph integration (removed hardcoded vendor lock-in, added seamless fallback to grep).
- **`02-no-crutches.md`:** Added **Security Invariants** section (secrets in code, SQL/command injection, dynamic code evaluation, XSS, shell=True).

---

## [1.0.0] - 2026-09-29

### Added
- Initial release of 9 modular rules (Python, JS, HTML, CSS, Testing, Architecture, Commits, Research, Prohibitions).
- Knowledge graph router hook (`hooks.json`, `graph-router.sh`).
- Unified diff distribution (`install.patch`, `uninstall.patch`, modular sub-patches).
- Cross-platform installers (`install.sh`, `install.ps1`).
- Automated validation suite (size checks, frontmatter verification, diff test).
