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
