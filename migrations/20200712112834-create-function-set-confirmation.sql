
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION set_confirmation(token text, confirm_within_hours int default 24)
RETURNS "user" AS $$
DECLARE
	local_user_id uuid;
	local_sent_at timestamptz;
	out record;
BEGIN
	SELECT id, confirmation_sent_at
	INTO STRICT local_user_id, local_sent_at
	FROM "user"
	WHERE confirmation_token = token;

	-- The sent_at + hours_before_expires gives the date when the token will expire.
	-- If the current date is greater than that date, it means the token expired.
	IF local_sent_at + interval '1 hour' * confirm_within_hours < now() THEN
		RAISE EXCEPTION 'Confirmation token expired'
		USING hint = 'Check your confirm within hours';
	END IF;

	UPDATE "user"
	SET email = unconfirmed_email,
		email_verified = true,
		confirmation_token = null,
		confirmation_sent_at = null,
		confirmed_at = now(),
		unconfirmed_email = ''
	WHERE id = local_user_id
	RETURNING * INTO out;

	RETURN out;
EXCEPTION
    WHEN no_data_found THEN
        RAISE EXCEPTION 'Confirmation token % not found', token;
    WHEN too_many_rows THEN
        RAISE EXCEPTION 'Confirmation token % not unique', token;
END;
$$ LANGUAGE plpgsql;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS set_confirmation;
