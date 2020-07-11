
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION encrypt_password(plaintext_password text, minlength int default 6, cost int default 12)
RETURNS text AS $encrypted_password$
DECLARE
	result text;
BEGIN
	IF NULLIF(plaintext_password, '') IS NULL THEN
		RAISE EXCEPTION 'Password is required'
		USING hint = 'Please check that you pass in the password';
	END IF;

	IF LENGTH(plaintext_password) < minlength THEN
		RAISE EXCEPTION 'Password must be at least % characters', minlength
		USING hint = format('Please check that the password length is at least %s characters', minlength);
	END IF;

	SELECT crypt(plaintext_password, gen_salt('bf', cost)) INTO result;
	RETURN result;
END;
$encrypted_password$ LANGUAGE plpgsql STABLE;

-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS encrypt_password;
