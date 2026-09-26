-- BAU template — MANY ROWS via MERGE. Never executed from here; copy into BAU/Pending as
--   yyyyMMdd-<ticket>-<what-it-is-for>.sql   (e.g. 20260923-1-deactivate-legacy-users.sql)
-- Forward-only: once journaled, do not edit — write a new corrective script instead.

\set ON_ERROR_STOP on
BEGIN;
DO $$
DECLARE v_rowcount integer;
BEGIN
    -- 1) THE WORK: insert / update / deactivate keyed off a source set.
    MERGE INTO app.some_table AS t
    USING (VALUES ('key-a'), ('key-b')) AS s(key)
        ON t.key = s.key
    WHEN MATCHED AND t.is_active THEN
        UPDATE SET is_active = false;

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
