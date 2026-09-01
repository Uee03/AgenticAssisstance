---
description: 'Python coding conventions enforced on all Python files.'
applyTo: '**/*.py'
---

# Python Coding Conventions

- **Type hints everywhere** (public functions, methods, attributes). Prefer precise types over `Any`;
  use `list[str]`, `dict[str, int]`, `X | None`. Code must pass mypy.
- **Case-insensitive string comparison:** `a.casefold() == b.casefold()` — never compare mixed-case
  strings directly when case should be ignored.
- **f-strings** for formatting; never `%`/`.format()` in new code.
- **`pathlib.Path`** for filesystem paths, not string concatenation.
- Prefer **`@dataclass`** (or Pydantic) for data holders; `frozen=True` for value objects.
- One public class/concern per module; modules `snake_case`, classes `PascalCase`.
- **Constructor injection:** pass collaborators via `__init__`; don't construct dependencies or reach
  for globals/singletons inside classes. Depend on `Protocol`/`ABC` across boundaries.
- **Prefer explicit/manual mapping** (a `to_response()` method or small function) over reflection-based mappers.
- Comprehensions/generators only where they improve clarity; prefer explicit `for` loops for complex
  or side-effecting logic.
- Outbound HTTP via **`httpx`** (explicit timeouts, reused client) behind an adapter — not bare `requests`.
- No `print()` for diagnostics in library code — use the `logging` module. Never log secrets/PII.
- Never hardcode secrets; never f-string untrusted input into SQL (always parameterize).
- Follow PEP 8 (enforced by Ruff); public APIs get docstrings.
