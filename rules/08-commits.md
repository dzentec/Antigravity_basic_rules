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
