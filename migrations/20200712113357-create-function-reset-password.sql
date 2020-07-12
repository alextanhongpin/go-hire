
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION reset_password(token text, plaintext_password text, reset_within_hours int DEFAULT 24)
RETURNS "user" AS $$
DECLARE
	local_user_id uuid;
	local_sent_at timestamptz;
	is_using_old_password boolean;
	out record;
BEGIN
	SELECT id, reset_password_sent_at
	INTO STRICT local_user_id, local_sent_at
	FROM "user"
	WHERE reset_password_token = token;

	IF local_sent_at + interval '1 hour' * reset_within_hours < now() THEN
		RAISE EXCEPTION 'Reset password token expired'
			USING hint = 'Check your reset within hours';
	END IF;

	SELECT compare_password(plaintext_password, account.token)
	INTO STRICT is_using_old_password
	FROM account
	WHERE provider = 'email'
	AND user_id = local_user_id;

	IF is_using_old_password THEN
		RAISE EXCEPTION 'Password cannot be the same'
			USING hint = 'Ensure new password is not the same as old password';
	END IF;

	UPDATE account
	SET token = encrypt_password(plaintext_password)
	WHERE provider = 'email'
	AND user_id = local_user_id;

	UPDATE "user"
	SET reset_password_sent_at = null,
		reset_password_token = null
	WHERE id = local_user_id
	RETURNING * INTO STRICT out;

	RETURN out;
EXCEPTION
	WHEN no_data_found THEN
		RAISE 'Reset password token % not found', token;
	WHEN too_many_rows THEN
		RAISE 'Reset password token % not unique', token;
END;
$$ LANGUAGE plpgsql;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS reset_password;
