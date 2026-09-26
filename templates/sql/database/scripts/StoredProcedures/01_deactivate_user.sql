-- StoredProcedures/01_deactivate_user.sql  (idempotent — CREATE OR REPLACE)
--
-- Soft-delete over DELETE: "removing" a user flips is_active to false.

CREATE OR REPLACE PROCEDURE app.deactivate_user(p_email text)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE app.users
       SET is_active = false
     WHERE lower(email) = lower(p_email)
       AND is_active;
END;
$$;
