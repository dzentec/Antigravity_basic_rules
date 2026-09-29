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
