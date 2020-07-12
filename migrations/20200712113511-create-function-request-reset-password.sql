
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION request_reset_password(email text)
RETURNS "user" AS $$
	UPDATE "user"
	SET reset_password_token = gen_random_uuid(),
	    reset_password_sent_at = now()
	WHERE id = (
		SELECT user_id
		FROM account
		WHERE uid = $1
	)
	RETURNING *;
$$ LANGUAGE SQL VOLATILE;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS request_reset_password;
