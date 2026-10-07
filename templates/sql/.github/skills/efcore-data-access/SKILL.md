---
name: efcore-data-access
description: 'How to access a SQL database from .NET securely — Entity Framework Core (code-first: DbContext, entities, LINQ), EF Core raw SQL (FromSql/SqlQuery/ExecuteSql and their *Raw variants), and standard hand-written SQL via Dapper/ADO.NET. SECURITY-FIRST: every query that takes input MUST be a parameterized query. Use when writing EF Core models/queries, running raw SQL from EF, or authoring SQL data-access code in .NET.'
---

# EF Core & SQL Data Access (.NET)

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer.

> **SECURITY IS THE HIGHEST PRIORITY.** Any query that includes a value derived from input **MUST be a
> parameterized query**. Never build SQL by string concatenation or string interpolation of untrusted
> data — that is SQL injection (OWASP A03). This rule is absolute across EF Core, Dapper, and ADO.NET.

Three ways to talk to the database, in order of preference:

1. **EF Core LINQ** (code-first) — parameterizes automatically. Default for CRUD and most queries.
2. **EF Core raw SQL** — when LINQ can't express it. Use the parameter-safe APIs below.
3. **Standard SQL** via Dapper / ADO.NET — read-heavy or SQL-first work. Parameterize every value.

Access the DB behind a **repository/interface** in the Application layer (see
[database-selection](../database-selection/SKILL.md)); keep engine-specific SQL out of the domain.

## 1. Entity Framework Core (code-first)

Model entities + a `DbContext`; changes ship as EF Core migrations
(see [sql-migrations](../sql-migrations/SKILL.md)).

```csharp
public sealed class User
{
    public long Id { get; set; }
    public required string Email { get; set; }
    public int FavoriteCount { get; set; }
    public bool IsActive { get; set; } = true;   // soft-delete flag
}

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.HasDefaultSchema("app");
        b.Entity<User>(e =>
        {
            e.ToTable("users");
            e.HasKey(u => u.Id);
            e.HasIndex(u => u.Email).IsUnique();
            e.Property(u => u.Email).IsRequired();
            e.HasQueryFilter(u => u.IsActive);        // reads filter WHERE is_active by default
        });
    }
}
```

- **LINQ queries are parameterized by the provider** — variables become SQL parameters, never inlined:

  ```csharp
  // email is sent as a parameter ($1 / @__email_0) — safe by construction.
  var user = await db.Users
      .AsNoTracking()                                   // read-only: skip change tracking
      .Where(u => u.Email == email)
      .Select(u => new UserDto(u.Id, u.Email))          // project — don't return entities/over-fetch
      .FirstOrDefaultAsync(ct);
  ```

- **Project** to DTOs (`Select`) instead of returning entities; use `AsNoTracking()` for reads.
- **Page** large results (keyset/`Skip`/`Take`); never materialize unbounded sets.
- Store **enums as strings** (`.HasConversion<string>()`); expose strings at the API.
- Pass `CancellationToken` to every async call. Soft-delete = set `IsActive = false` (never hard delete).

## 2. EF Core raw SQL (when LINQ isn't enough)

EF gives **parameter-safe** APIs and matching `*Raw` variants. Prefer the safe form; only use `*Raw`
with explicit parameter objects — **never** interpolate input into a `*Raw` string.

| Purpose | Safe (auto-parameterized) | Raw (parameters required) |
|---|---|---|
| Query entities | `FromSql($"…{value}")` | `FromSqlRaw("… {0}", value)` |
| Query scalars/DTOs | `Database.SqlQuery<T>($"…{value}")` | `Database.SqlQueryRaw<T>("… {0}", value)` |
| Non-query (INSERT/UPDATE/DELETE/DDL) | `Database.ExecuteSql($"…{value}")` | `Database.ExecuteSqlRaw("… {0}", value)` |

```csharp
// SAFE: FromSql takes a FormattableString; each {interpolated} value becomes a DbParameter.
var users = await db.Users
    .FromSql($"SELECT * FROM app.users WHERE email = {email}")
    .ToListAsync(ct);

// SAFE: scalar / non-entity result.
int count = await db.Database
    .SqlQuery<int>($"SELECT count(*) AS \"Value\" FROM app.users WHERE is_active AND created_at > {since}")
    .SingleAsync(ct);

// SAFE: non-query with a named parameter object.
int affected = await db.Database.ExecuteSqlRaw(
    "UPDATE app.users SET is_active = false WHERE email = {0}", email);
```

```csharp
// ❌ NEVER — FromSqlRaw with an interpolated string inlines input = SQL injection.
db.Users.FromSqlRaw($"SELECT * FROM app.users WHERE email = '{email}'");   // DO NOT DO THIS
// ✅ Use FromSql (interpolation → parameters) OR FromSqlRaw with a real parameter (shown above).
```

- `FromSql`/`FromSqlRaw` must return **all columns** of the mapped entity; they compose with LINQ
  (`.Where(...)`, `.OrderBy(...)`, `.Include(...)` after the call).
- Parameter **placeholders differ by provider**: Npgsql accepts positional `{0}`/named; you can also
  pass `new NpgsqlParameter("email", email)`. Let EF/the provider format them — don't hand-quote.
- **Identifiers (table/column names) can't be parameters.** If a name must be dynamic, pick it from a
  **fixed allow-list** in code — never from raw input.

## 3. Standard SQL via Dapper / ADO.NET

For SQL-first / read-heavy paths. Same rule: values are **parameters**, not concatenated text.

```csharp
// Dapper — anonymous object supplies named parameters (@email); never string.Format/interpolation.
const string sql = "SELECT id, email FROM app.users WHERE email = @email AND is_active";
var user = await connection.QuerySingleOrDefaultAsync<UserDto>(sql, new { email });

// ADO.NET (Npgsql) — explicit parameter object.
await using var cmd = new NpgsqlCommand(
    "UPDATE app.users SET favorite_count = favorite_count + 1 WHERE email = @email", conn);
cmd.Parameters.AddWithValue("email", email);
await cmd.ExecuteNonQueryAsync(ct);
```

- Placeholders: `@name` (Npgsql/`Microsoft.Data.SqlClient`, Dapper) or positional `$1` (raw Npgsql).
- **`IN (...)` lists:** pass an array/`ANY(@ids)` (Npgsql) or Dapper list expansion (`WHERE id = ANY(@ids)`
  / `WHERE id IN @ids`) — never build the list by joining strings.
- **`LIKE`:** parameterize the value and escape user wildcards (`%` `_`) so input can't widen the match.
- Explicit column lists (no `SELECT *` in app queries); wrap multi-statement writes in a transaction.

## Security checklist (must pass)

- [ ] **Every input value is a bound parameter** — no `+`, `$"{...}"`, `string.Format`, or `String.Concat`
      building SQL from input, anywhere (EF `*Raw`, Dapper, ADO.NET).
- [ ] Raw SQL uses `FromSql`/`ExecuteSql`/`SqlQuery` (interpolated → parameters) or a `*Raw` overload
      **with** parameter objects.
- [ ] Dynamic **identifiers** come from a code-side allow-list, not input.
- [ ] Input validated/typed at the boundary (length, format, enum) before it reaches SQL.
- [ ] Least-privilege DB user; secrets from config/env, never in source or SQL.
- [ ] No `SELECT *` in application queries; reads project to DTOs and are paged.

See [postgres-conventions](../postgres-conventions/SKILL.md) /
[sqlserver-conventions](../sqlserver-conventions/SKILL.md) for engine syntax and
[sql-schema-design](../sql-schema-design/SKILL.md) for modeling.
