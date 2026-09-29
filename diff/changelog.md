# 📜 Changelog

All notable changes to the Universal Antigravity Rules package will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
