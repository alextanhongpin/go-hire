
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION authenticate(email text, plaintext_password text)
RETURNS "user" AS $$
DECLARE
	out record;
BEGIN
	SELECT *
	INTO STRICT out
	FROM "user"
	WHERE id = (
		SELECT user_id
		FROM account
		WHERE uid = authenticate.email
		AND compare_password(plaintext_password, token)
	);

	RETURN out;
EXCEPTION
	WHEN no_data_found THEN
		RAISE EXCEPTION 'Email (%) or password is invalid', email;
	WHEN too_many_rows THEN
		RAISE EXCEPTION 'Email % not unique', email;
END;
$$ LANGUAGE PLPGSQL STABLE;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS authenticate;
