
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION request_reset_password(email text)
RETURNS "user" AS $$
DECLARE
	out record;
BEGIN
	UPDATE "user"
	SET reset_password_token = gen_random_uuid(),
	    reset_password_sent_at = now()
	WHERE id = (
		SELECT user_id
		FROM account
		WHERE uid = $1
	)
	RETURNING * INTO STRICT out;
	RETURN out;
EXCEPTION
	WHEN no_data_found THEN
		RAISE EXCEPTION 'Email % not found', email;
	WHEN too_many_rows THEN
		RAISE EXCEPTION 'Email % not unique', email;
END;
$$ LANGUAGE plpgsql VOLATILE;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS request_reset_password;
