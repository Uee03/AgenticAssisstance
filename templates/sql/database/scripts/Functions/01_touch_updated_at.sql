-- Functions/01_touch_updated_at.sql  (idempotent — CREATE OR REPLACE is a no-op re-run)
--
-- Keeps updated_at current on every UPDATE. The trigger is created via a guarded DO block
-- so re-running the script does not error on an existing trigger.

CREATE OR REPLACE FUNCTION app.touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_users_touch_updated_at') THEN
        CREATE TRIGGER trg_users_touch_updated_at
            BEFORE UPDATE ON app.users
            FOR EACH ROW EXECUTE FUNCTION app.touch_updated_at();
    END IF;
END $$;
