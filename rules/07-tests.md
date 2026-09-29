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
