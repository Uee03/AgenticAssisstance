-- Tables/01_users.sql  (idempotent — safe to re-run every deploy)
--
-- Pattern: base object with CREATE TABLE IF NOT EXISTS, then append later changes as
-- guarded, additive ALTERs below (never destructive). Data tables carry is_active for
-- soft-delete; reads filter WHERE is_active.

CREATE SCHEMA IF NOT EXISTS app;

CREATE TABLE IF NOT EXISTS app.users (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email          text        NOT NULL,
    display_name   text        NOT NULL DEFAULT '',
    favorite_count integer     NOT NULL DEFAULT 0,
    is_active      boolean     NOT NULL DEFAULT true,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now()
);

-- Natural key (case-insensitive email).
CREATE UNIQUE INDEX IF NOT EXISTS uq_users_email ON app.users (lower(email));

-- ---------------------------------------------------------------------------
-- Later changes: append additive, guarded ALTERs below. Example:
-- ALTER TABLE app.users ADD COLUMN IF NOT EXISTS last_login_at timestamptz;
