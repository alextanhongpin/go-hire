
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION request_confirmation(email text)
RETURNS "user" AS $$
DECLARE
	out record;
BEGIN
	UPDATE "user"
	SET confirmation_token = gen_random_uuid(),
		confirmation_sent_at = now(),
		confirmed_at = null,
		unconfirmed_email = $1
	WHERE id = (
		SELECT user_id
		FROM account
		WHERE uid = request_confirmation.email
	)
	RETURNING * INTO STRICT out;

	RETURN out;
EXCEPTION
	WHEN no_data_found THEN
		RAISE EXCEPTION 'Email % not found', email;
	WHEN too_many_rows THEN
		RAISE EXCEPTION 'Email % not unique', email;
END;
$$ LANGUAGE PLPGSQL VOLATILE;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS request_confirmation;
