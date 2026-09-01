---
description: '.NET/C# coding conventions enforced on all C# files.'
applyTo: '**/*.cs'
---

# C# Coding Conventions

- **Explicit types over `var`:** write `List<Customer> customers = ...`, not `var customers`.
- **Braces on all control blocks**, even single-line `if`/`for`/`while`.
- **`async`/`await` all the way down** for IO; suffix async methods with `Async`.
- **Case-insensitive string comparison by default:** `string.Equals(a, b, StringComparison.OrdinalIgnoreCase)`
  and `StringComparison.OrdinalIgnoreCase` in `Contains`/`StartsWith`/dictionary keys. Never `==` when
  case should be ignored.
- **One public type per file;** file name matches the type name.
- Use `readonly` fields and immutable models (`record`) only where value/immutable semantics genuinely
  help; **classes by default**. Avoid `struct`/`record struct` without a demonstrated need.
- Prefer `IReadOnlyList<T>` / `IReadOnlyDictionary<T>` on public APIs over mutable collections.
- **Prefer composition over inheritance.** No empty marker base classes; use small interfaces where
  they add value.
- **Prefer explicit/manual mapping** (extension methods or constructors) over AutoMapper/Mapster.
- **Constructor injection only** — no service locator, no `new`-ing injectable dependencies.
- LINQ only where it improves clarity; prefer explicit `foreach` for hot paths / simple loops.
- No `Console.WriteLine` for diagnostics in library code — use `Microsoft.Extensions.Logging`.
- Never hardcode secrets; never string-concatenate untrusted input into SQL (always parameterize).
