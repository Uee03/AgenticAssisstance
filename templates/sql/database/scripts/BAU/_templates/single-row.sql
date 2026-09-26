-- BAU template — SINGLE ROW via IF EXISTS guard. Never executed from here; copy into
-- BAU/Pending as  yyyyMMdd-<ticket>-<what-it-is-for>.sql
--   (e.g. 20260923-1-update-user-favorite-count.sql)
-- Fail loudly on a wrong key; forward-only once journaled.

\set ON_ERROR_STOP on
BEGIN;
DO $$
DECLARE v_rowcount integer;
BEGIN
    -- 1) THE WORK: single-row change; fail loudly if the key is wrong.
    IF NOT EXISTS (SELECT 1 FROM app.users WHERE email = 'user@example.com') THEN
        RAISE EXCEPTION 'BAU aborted: target row not found (email=%).', 'user@example.com';
    END IF;

    UPDATE app.users
       SET favorite_count = favorite_count + 1
     WHERE email = 'user@example.com';

    -- 2) GUARD: never commit a no-op.
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    IF v_rowcount = 0 THEN
        RAISE EXCEPTION 'BAU aborted: 0 rows affected.';
    END IF;
    RAISE NOTICE 'BAU ok: % row(s) affected.', v_rowcount;

-- 3) CATCH: report + re-raise so everything rolls back.
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'BAU failed (%): %', SQLSTATE, SQLERRM;
    RAISE;
END $$;
COMMIT;
