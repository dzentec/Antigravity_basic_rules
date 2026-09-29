# 📦 Universal Antigravity Rules Package (v1.1.0)

A portable, domain-agnostic, and token-efficient set of development rules for the **Antigravity AI Agent** in **Python**, **JavaScript**, **HTML5**, and **CSS3** projects.

---

## 📁 Package Contents

- **`rules/`** — 10 modular rule files with YAML frontmatter triggers (`always_on`, `glob`, `model_decision`).
- **`hooks/`** — `graph-router.sh` hook script for routing search requests to MCP knowledge graphs.
- **`diff/`** — Unified diff patches (`install.patch`, `uninstall.patch`, modular sub-patches) for Git-based deployment.
- **`pack/`** — `rules-bundle.md`: A single flat Markdown file containing all rules and hooks.
- **`install.sh` / `install.ps1`** — Cross-platform installation and rollback scripts.
- **`pack.sh` / `pack.ps1`** — Cross-platform bundler and extractor scripts.

---

## 🚀 Installation Methods

### Method 1: Via Markdown Bundle (Simplest)
Copy `pack/rules-bundle.md` to your target project and run:

```bash
./pack.sh unpack /path/to/project
```
*(or in PowerShell: `.\pack.ps1 unpack "D:\Projects\TargetProject"`)*

Or place `rules-bundle.md` into the project root and instruct Antigravity:
> *"Unpack rules-bundle.md to the filepaths specified in the headers."*

---

### Method 2: Via Git Patch (Recommended for Git Repositories)
Applies changes cleanly and preserves history without overwriting existing files on conflict:

```bash
# Preview changes and dry run
./install.sh /path/to/project --dry

# Apply patch
./install.sh /path/to/project

# Clean rollback
./install.sh /path/to/project --revert
```

In PowerShell (Windows):
```powershell
.\install.ps1 -Target "D:\Projects\MyProject"
```

---

### Method 3: Direct File Copy
For projects not initialized with Git:

```bash
./install.sh /path/to/project --copy
```

---

## 📂 Target Project Directory Structure

After installation or unpacking, the following structure is placed in the target project:

```text
<target_project>/
├── .agents/
│   ├── rules/
│   │   ├── 00-research-protocol.md    # [always_on] MCP knowledge graph research & blast radius
│   │   ├── 01-architecture.md         # [always_on] Modularity, size limits, SRP, clean imports
│   │   ├── 02-no-crutches.md          # [always_on] 18 prohibitions & security invariants
│   │   ├── 03-python.md               # [glob *.py] Python 3.11+ strict typing & Pydantic
│   │   ├── 04-javascript.md           # [glob *.js] ES6+ modules, async/await, DOM safety
│   │   ├── 05-html.md                 # [glob *.html] HTML5 semantics, a11y, id vs class
│   │   ├── 06-css.md                  # [glob *.css] Design tokens in :root, selector limits
│   │   ├── 07-tests.md                # [glob test_*] AAA pattern, 5-point boundary coverage
│   │   ├── 08-commits.md              # [model_decision] Conventional Commits & hygiene
│   │   └── 09-api.md                  # [glob *api*..*schema*] REST & HTTP API architecture standards
│   └── hooks.json                     # PreToolUse router hook
└── scripts/
    └── graph-router.sh                # Executable MCP graph routing script
```

---

## 🔍 Verification After Installation

1. In the Antigravity chat, execute:
   ```text
   /memory show
   ```
2. Verify that the rules are loaded into the active agent context.
3. Confirm that all 10 `.md` files exist under `.agents/rules/` and `hooks.json` is located under `.agents/`.
